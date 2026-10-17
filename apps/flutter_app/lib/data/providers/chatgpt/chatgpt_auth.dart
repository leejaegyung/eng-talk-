import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;

import '../../../core/logging/app_logger.dart';
import '../../../domain/credentials/credential_vault.dart';
import '../../../domain/credentials/provider_account.dart';
import '../../../domain/providers/provider_failure.dart';

/// Sign in with ChatGPT for open-source apps (ADR-011,
/// developers.openai.com/siwc/token-sharing-open-source): dynamic client
/// registration, PKCE public client, loopback redirect. Tokens live only in
/// the vault.
class ChatGptAuth implements ProviderAccount {
  ChatGptAuth({
    required this._vault,
    required this._openBrowser,
    http.Client? client,
    DateTime Function()? now,
    this._preferredPort = 1455,
    this._callbackTimeout = const Duration(minutes: 5),
  }) : _client = client ?? http.Client(),
       _now = now ?? DateTime.now;

  static const agentName = 'Speaking Coach';
  static const sessionRef = 'chatgpt.session';
  static const registrationRef = 'chatgpt.registration';

  static const _issuer = 'https://auth.openai.com';
  static const _resource = 'https://api.openai.com/v1';
  static const _planScope = 'chatgpt.tokens.use.direct';
  static const _scopes =
      'openid profile email offline_access resource.invoke $_planScope';
  static final _authorizeUrl = Uri.parse('$_issuer/api/accounts/authorize');
  static final _tokenUrl = Uri.parse('$_issuer/api/accounts/oauth/token');
  static const _refreshMargin = Duration(minutes: 2);
  static const _terminalRefreshErrors = {
    'invalid_grant',
    'invalid_refresh_token',
    'token_expired',
    'refresh_token_expired',
    'refresh_token_invalidated',
    'refresh_token_reused',
  };
  static const _log = AppLogger('chatgpt.auth');

  final CredentialVault _vault;
  final Future<void> Function(Uri url) _openBrowser;
  final http.Client _client;
  final DateTime Function() _now;
  final int _preferredPort;
  final Duration _callbackTimeout;
  final _random = Random.secure();
  Future<String>? _refreshing;

  @override
  Future<bool> isSignedIn() async => await _vault.read(sessionRef) != null;

  /// Opens the browser for consent and completes the OAuth flow. Throws
  /// [ProviderException] (`signInRequired`, `planNotEligible`, `network`).
  @override
  Future<void> signIn() async {
    final registration = await _readJson(registrationRef);
    final savedClientId = registration?['client_id'] as String?;
    final hostId = registration?['host_id'] as String? ?? _randomString(32);
    final verifier = _randomString(64);
    final state = _randomString(32);
    final nonce = _randomString(32);

    final server = await _bindLoopback();
    try {
      final redirectUri = 'http://127.0.0.1:${server.port}/auth/callback';
      // Listen before opening the browser so the callback can't be missed.
      final callback = _awaitCallback(server);
      await _openBrowser(
        _authorizeUrl.replace(
          queryParameters: {
            'client_id': savedClientId ?? 'dynamic_agent_client',
            if (savedClientId == null) 'agent_name_hint': agentName,
            'ext_agent_host_id': hostId,
            'response_type': 'code',
            'redirect_uri': redirectUri,
            'scope': _scopes,
            'resource': _resource,
            'state': state,
            'nonce': nonce,
            'code_challenge': _challenge(verifier),
            'code_challenge_method': 'S256',
          },
        ),
      );
      final q = await callback.timeout(
        _callbackTimeout,
        onTimeout: () => _fail('callback timed out'),
      );

      if (q['state'] != state) _fail('state mismatch');
      final code = q['code'];
      if (code == null) _fail('no code (${q['error'] ?? 'unknown'})');
      final returnedClientId = q['client_id'];
      if (savedClientId != null &&
          returnedClientId != null &&
          returnedClientId != savedClientId) {
        _fail('client id changed');
      }
      final clientId = savedClientId ?? returnedClientId;
      if (clientId == null) _fail('no client id issued');

      final tokens = await _tokenRequest({
        'grant_type': 'authorization_code',
        'client_id': clientId,
        'code': code,
        'code_verifier': verifier,
        'redirect_uri': redirectUri,
        'resource': _resource,
      });
      _checkIdToken(tokens['id_token'], nonce: nonce, clientId: clientId);
      if (!_scopeOf(tokens).contains(_planScope)) {
        throw const ProviderException(ProviderFailure.planNotEligible);
      }

      await _vault.write(
        registrationRef,
        jsonEncode({'client_id': clientId, 'host_id': hostId}),
      );
      await _saveSession(tokens, previous: null);
    } finally {
      await server.close(force: true);
    }
  }

  /// A valid access token, refreshed when close to expiry. Concurrent callers
  /// share one refresh because refresh tokens rotate.
  Future<String> accessToken() async {
    final session = await _readJson(sessionRef);
    if (session == null) {
      throw const ProviderException(ProviderFailure.signInRequired);
    }
    final expiresAt = DateTime.fromMillisecondsSinceEpoch(
      session['expires_at'] as int,
      isUtc: true,
    );
    if (_now().isBefore(expiresAt.subtract(_refreshMargin))) {
      return session['access_token'] as String;
    }
    return _refreshing ??= _refresh(session)
        .whenComplete(() => _refreshing = null);
  }

  /// Revokes the refresh token and forgets the session. The registration
  /// (client id) is kept for the next sign-in. Returns false when remote
  /// revocation couldn't be confirmed.
  @override
  Future<bool> signOut() async {
    final session = await _readJson(sessionRef);
    final registration = await _readJson(registrationRef);
    var revoked = session == null;
    if (session != null && registration != null) {
      try {
        final config = await _client.get(
          Uri.parse('$_issuer/.well-known/openid-configuration'),
        );
        final endpoint =
            (jsonDecode(config.body) as Map)['revocation_endpoint'] as String;
        final res = await _client.post(
          Uri.parse(endpoint),
          body: {
            'token': session['refresh_token'] as String,
            'token_type_hint': 'refresh_token',
            'client_id': registration['client_id'] as String,
          },
        );
        revoked = res.statusCode == 200;
      } on Exception catch (e) {
        _log.warning('revocation failed: ${e.runtimeType}');
      }
    }
    await _vault.delete(sessionRef);
    return revoked;
  }

  Future<String> _refresh(Map<String, Object?> session) async {
    final registration = await _readJson(registrationRef);
    final clientId = registration?['client_id'] as String?;
    if (clientId == null) {
      await _vault.delete(sessionRef);
      throw const ProviderException(ProviderFailure.signInRequired);
    }
    try {
      final tokens = await _tokenRequest({
        'grant_type': 'refresh_token',
        'client_id': clientId,
        'refresh_token': session['refresh_token'] as String,
        'resource': _resource,
      });
      return await _saveSession(tokens, previous: session);
    } on _TokenError catch (e) {
      // Only a confirmed-unusable refresh token ends the session; outages keep
      // credentials (errors-and-recovery guide).
      if (_terminalRefreshErrors.contains(e.code)) {
        await _vault.delete(sessionRef);
        throw const ProviderException(ProviderFailure.signInRequired);
      }
      throw const ProviderException(ProviderFailure.unknown);
    }
  }

  Future<String> _saveSession(
    Map<String, Object?> tokens, {
    required Map<String, Object?>? previous,
  }) async {
    final access = tokens['access_token'] as String;
    final expiresIn = (tokens['expires_in'] as num?)?.toInt() ?? 3600;
    await _vault.write(
      sessionRef,
      jsonEncode({
        'access_token': access,
        'refresh_token':
            tokens['refresh_token'] as String? ?? previous?['refresh_token'],
        'id_token': tokens['id_token'] ?? previous?['id_token'],
        'expires_at': _now()
            .add(Duration(seconds: expiresIn))
            .millisecondsSinceEpoch,
      }),
    );
    return access;
  }

  Future<Map<String, Object?>> _tokenRequest(Map<String, String> form) async {
    final http.Response res;
    try {
      res = await _client
          .post(_tokenUrl, body: form)
          .timeout(const Duration(seconds: 30));
    } on Exception {
      throw const ProviderException(ProviderFailure.network);
    }
    Object? json;
    try {
      json = jsonDecode(res.body);
    } on FormatException {
      json = null;
    }
    if (res.statusCode != 200 || json is! Map) {
      throw _TokenError(json is Map ? json['error']?.toString() : null);
    }
    return json.cast<String, Object?>();
  }

  /// Checks nonce, issuer and audience. The signature isn't verified: the
  /// token comes directly from the token endpoint over TLS (OIDC Core
  /// 3.1.3.7).
  void _checkIdToken(
    Object? idToken, {
    required String nonce,
    required String clientId,
  }) {
    if (idToken is! String) _fail('no id token');
    final parts = idToken.split('.');
    if (parts.length != 3) _fail('malformed id token');
    final claims = jsonDecode(
      utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))),
    ) as Map;
    final aud = claims['aud'];
    final audiences = aud is List ? aud : [aud];
    if (claims['nonce'] != nonce ||
        claims['iss'] != _issuer ||
        !audiences.contains(clientId)) {
      _fail('id token claims mismatch');
    }
  }

  Future<HttpServer> _bindLoopback() async {
    try {
      return await HttpServer.bind(
        InternetAddress.loopbackIPv4,
        _preferredPort,
      );
    } on SocketException {
      // The port may differ between sign-ins; only scheme/host/path are fixed.
      return HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    }
  }

  static Future<Map<String, String>> _awaitCallback(HttpServer server) async {
    await for (final req in server) {
      if (req.uri.path != '/auth/callback') {
        req.response.statusCode = HttpStatus.notFound;
        await req.response.close();
        continue;
      }
      req.response
        ..statusCode = HttpStatus.ok
        ..headers.contentType = ContentType.html
        ..write(_donePage);
      await req.response.close();
      return req.uri.queryParameters;
    }
    throw StateError('loopback server closed');
  }

  Future<Map<String, Object?>?> _readJson(String ref) async {
    final raw = await _vault.read(ref);
    return raw == null
        ? null
        : (jsonDecode(raw) as Map).cast<String, Object?>();
  }

  String _randomString(int length) {
    const chars =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._~';
    return String.fromCharCodes(
      List.generate(
        length,
        (_) => chars.codeUnitAt(_random.nextInt(chars.length)),
      ),
    );
  }

  static String _challenge(String verifier) => base64Url
      .encode(sha256.convert(ascii.encode(verifier)).bytes)
      .replaceAll('=', '');

  static Set<String> _scopeOf(Map<String, Object?> tokens) =>
      (tokens['scope'] as String? ?? '').split(' ').toSet();

  static Never _fail(String reason) {
    _log.warning('sign-in failed: $reason');
    throw const ProviderException(ProviderFailure.signInRequired);
  }

  static const _donePage =
      '<!doctype html><meta charset="utf-8"><title>Speaking Coach</title>'
      '<body style="font-family:sans-serif;text-align:center;padding:48px">'
      '<h2>로그인 완료</h2><p>이 창을 닫고 앱으로 돌아가세요.</p>'
      '<p>Signed in. You can close this window.</p></body>';
}

final class _TokenError implements Exception {
  const _TokenError(this.code);

  final String? code;
}
