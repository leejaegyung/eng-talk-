import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:speaking_coach/data/providers/chatgpt/chatgpt_auth.dart';
import 'package:speaking_coach/domain/providers/provider_failure.dart';

import '../../helpers/fakes.dart';

const issuedClientId = 'oaiapp_FAKE123';

/// Unsigned JWT with the given payload (signature isn't checked: tokens come
/// straight from the token endpoint over TLS).
String jwt(Map<String, Object> payload) {
  String part(Object o) =>
      base64Url.encode(utf8.encode(jsonEncode(o))).replaceAll('=', '');
  return '${part({'alg': 'none'})}.${part(payload)}.sig';
}

/// Plays OpenAI's part: records authorize URLs and token requests, and
/// "redirects" the browser to the app's loopback callback.
class FakeOpenAi {
  final authorizeUrls = <Uri>[];
  final tokenForms = <Map<String, String>>[];
  final revocations = <Map<String, String>>[];

  /// Pages the loopback server showed the browser.
  final pages = <String>[];
  String scope =
      'openid profile email offline_access resource.invoke '
      'chatgpt.tokens.use.direct';
  String? callbackClientId = issuedClientId;
  bool tamperState = false;
  bool tamperNonce = false;
  String? refreshError;
  int access = 0;

  Future<void> openBrowser(Uri url) async {
    authorizeUrls.add(url);
    final q = url.queryParameters;
    final redirect = Uri.parse(q['redirect_uri']!).replace(
      queryParameters: {
        'code': 'auth-code',
        'scope': scope,
        'state': tamperState ? 'other' : q['state']!,
        'client_id': ?callbackClientId,
      },
    );
    // Delivered asynchronously, like a real browser.
    Future<void>(() async {
      final client = HttpClient();
      final req = await client.getUrl(redirect);
      pages.add(await (await req.close()).transform(utf8.decoder).join());
      client.close();
    }).ignore();
  }

  http.Client get client => MockClient((req) async {
    if (req.url.path.endsWith('/.well-known/openid-configuration')) {
      return http.Response(
        jsonEncode({'revocation_endpoint': 'https://auth.openai.com/revoke'}),
        200,
      );
    }
    if (req.url.path == '/revoke') {
      revocations.add(req.bodyFields);
      return http.Response('', 200);
    }
    final form = req.bodyFields;
    tokenForms.add(form);
    if (form['grant_type'] == 'refresh_token' && refreshError != null) {
      return http.Response(jsonEncode({'error': refreshError}), 400);
    }
    final nonce = authorizeUrls.isEmpty
        ? ''
        : authorizeUrls.last.queryParameters['nonce']!;
    access++;
    return http.Response(
      jsonEncode({
        'access_token': 'access-$access',
        'refresh_token': 'refresh-$access',
        'id_token': jwt({
          'iss': 'https://auth.openai.com',
          'aud': form['client_id']!,
          'nonce': tamperNonce ? 'wrong' : nonce,
        }),
        'token_type': 'Bearer',
        'expires_in': 3600,
        'scope': scope,
      }),
      200,
    );
  });
}

void main() {
  late MemoryVault vault;
  late FakeOpenAi openAi;
  late DateTime now;

  ChatGptAuth auth() => ChatGptAuth(
    vault: vault,
    openBrowser: openAi.openBrowser,
    client: openAi.client,
    now: () => now,
    preferredPort: 0,
  );

  setUp(() {
    vault = MemoryVault();
    openAi = FakeOpenAi();
    now = DateTime.utc(2026, 10, 17, 12);
  });

  group('first sign-in', () {
    test('registers dynamically with PKCE and stores tokens', () async {
      final a = auth();
      await a.signIn();

      final q = openAi.authorizeUrls.single.queryParameters;
      expect(openAi.authorizeUrls.single.host, 'auth.openai.com');
      expect(q['client_id'], 'dynamic_agent_client');
      expect(q['agent_name_hint'], ChatGptAuth.agentName);
      expect(q['response_type'], 'code');
      expect(q['code_challenge_method'], 'S256');
      expect(q['resource'], 'https://api.openai.com/v1');
      expect(q['scope']!.split(' '), contains('chatgpt.tokens.use.direct'));
      expect(
        Uri.parse(q['redirect_uri']!).replace(port: 0).toString(),
        'http://127.0.0.1:0/auth/callback',
      );
      expect(
        q['ext_agent_host_id'],
        matches(
          RegExp(
            r'^urn:uuid:[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}'
            r'-[0-9a-f]{12}$',
          ),
        ),
      );

      final form = openAi.tokenForms.single;
      expect(form['grant_type'], 'authorization_code');
      expect(form['client_id'], issuedClientId);
      expect(form['code'], 'auth-code');
      expect(form['redirect_uri'], q['redirect_uri']);
      final challenge = base64Url
          .encode(sha256.convert(ascii.encode(form['code_verifier']!)).bytes)
          .replaceAll('=', '');
      expect(q['code_challenge'], challenge);
      expect(form.containsKey('client_secret'), isFalse);

      expect(await a.isSignedIn(), isTrue);
      expect(await a.accessToken(), 'access-1');
    });

    test('returning sign-in reuses the issued client id and host id', () async {
      await auth().signIn();
      await auth().signOut();
      openAi.callbackClientId = null; // may be omitted on reauthorization
      await auth().signIn();

      final first = openAi.authorizeUrls.first.queryParameters;
      final second = openAi.authorizeUrls.last.queryParameters;
      expect(second['client_id'], issuedClientId);
      expect(second.containsKey('agent_name_hint'), isFalse);
      expect(second['ext_agent_host_id'], first['ext_agent_host_id']);
    });

    test('code exchange waits until the app is back in front', () async {
      final front = Completer<void>();
      final a = ChatGptAuth(
        vault: vault,
        openBrowser: openAi.openBrowser,
        client: openAi.client,
        now: () => now,
        preferredPort: 0,
        whenForeground: () => front.future,
      );
      final signIn = a.signIn();
      await Future<void>.delayed(const Duration(milliseconds: 100));
      expect(openAi.pages, hasLength(1), reason: 'callback was delivered');
      expect(openAi.tokenForms, isEmpty);

      front.complete();
      await signIn;
      expect(openAi.tokenForms, hasLength(1));
      expect(await a.isSignedIn(), isTrue);
    });

    test('done page links back to the app when a return link is set', () async {
      await ChatGptAuth(
        vault: vault,
        openBrowser: openAi.openBrowser,
        client: openAi.client,
        now: () => now,
        preferredPort: 0,
        returnLink: 'myapp://signed-in',
      ).signIn();
      expect(openAi.pages.single, contains('href="myapp://signed-in"'));

      await auth().signOut();
      await auth().signIn();
      expect(openAi.pages.last, isNot(contains('href=')));
    });

    test('state mismatch is rejected and nothing is stored', () async {
      openAi.tamperState = true;
      await expectLater(
        auth().signIn(),
        throwsFailure(ProviderFailure.signInRequired),
      );
      expect(vault.values, isEmpty);
      expect(openAi.tokenForms, isEmpty);
    });

    test('nonce mismatch in the ID token is rejected', () async {
      openAi.tamperNonce = true;
      await expectLater(
        auth().signIn(),
        throwsFailure(ProviderFailure.signInRequired),
      );
      expect(await auth().isSignedIn(), isFalse);
    });

    test('declined plan-usage consent is planNotEligible', () async {
      openAi.scope = 'openid profile email offline_access';
      await expectLater(
        auth().signIn(),
        throwsFailure(ProviderFailure.planNotEligible),
      );
      expect(await auth().isSignedIn(), isFalse);
    });

    test('a different client id on reauthorization is rejected', () async {
      await auth().signIn();
      await auth().signOut();
      openAi.callbackClientId = 'oaiapp_SOMEONE_ELSE';
      await expectLater(
        auth().signIn(),
        throwsFailure(ProviderFailure.signInRequired),
      );
    });
  });

  group('tokens', () {
    test('valid access token is reused without refreshing', () async {
      final a = auth();
      await a.signIn();
      now = now.add(const Duration(minutes: 30));
      expect(await a.accessToken(), 'access-1');
      expect(openAi.tokenForms, hasLength(1));
    });

    test(
      'near expiry the token is refreshed once for concurrent callers',
      () async {
        final a = auth();
        await a.signIn();
        now = now.add(const Duration(minutes: 59));

        final tokens = await Future.wait([a.accessToken(), a.accessToken()]);

        expect(tokens, ['access-2', 'access-2']);
        final refresh = openAi.tokenForms.last;
        expect(openAi.tokenForms, hasLength(2));
        expect(refresh['grant_type'], 'refresh_token');
        expect(refresh['refresh_token'], 'refresh-1');
        expect(refresh['client_id'], issuedClientId);
        expect(refresh['resource'], 'https://api.openai.com/v1');
        expect(refresh.containsKey('scope'), isFalse);
      },
    );

    test('rotated refresh token is stored', () async {
      final a = auth();
      await a.signIn();
      now = now.add(const Duration(hours: 2));
      await a.accessToken();
      now = now.add(const Duration(hours: 2));
      await a.accessToken();
      expect(openAi.tokenForms.last['refresh_token'], 'refresh-2');
    });

    test('terminal refresh error clears the session', () async {
      final a = auth();
      await a.signIn();
      openAi.refreshError = 'invalid_grant';
      now = now.add(const Duration(hours: 2));
      await expectLater(
        a.accessToken(),
        throwsFailure(ProviderFailure.signInRequired),
      );
      expect(await a.isSignedIn(), isFalse);
    });

    test('server outage during refresh keeps the session', () async {
      final a = auth();
      await a.signIn();
      openAi.refreshError = 'temporarily_unavailable';
      now = now.add(const Duration(hours: 2));
      await expectLater(
        a.accessToken(),
        throwsFailure(ProviderFailure.unknown),
      );
      expect(await a.isSignedIn(), isTrue);
    });

    test('not signed in → signInRequired', () async {
      await expectLater(
        auth().accessToken(),
        throwsFailure(ProviderFailure.signInRequired),
      );
    });
  });

  test(
    'sign-out revokes the refresh token and keeps the registration',
    () async {
      final a = auth();
      await a.signIn();
      expect(await a.signOut(), isTrue);

      final r = openAi.revocations.single;
      expect(r['token'], 'refresh-1');
      expect(r['token_type_hint'], 'refresh_token');
      expect(r['client_id'], issuedClientId);
      expect(await a.isSignedIn(), isFalse);
      expect(vault.values.keys, [ChatGptAuth.registrationRef]);
    },
  );

  test('vault never holds tokens under the registration entry', () async {
    await auth().signIn();
    final reg = vault.values[ChatGptAuth.registrationRef]!;
    expect(reg, isNot(contains('access-')));
    expect(reg, isNot(contains('refresh-')));
  });
}

Matcher throwsFailure(ProviderFailure f) =>
    throwsA(isA<ProviderException>().having((e) => e.failure, 'failure', f));
