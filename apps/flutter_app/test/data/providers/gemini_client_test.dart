import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:speaking_coach/data/providers/gemini/gemini_client.dart';
import 'package:speaking_coach/data/providers/gemini/provider_catalog.dart';
import 'package:speaking_coach/domain/providers/ai_provider.dart';
import 'package:speaking_coach/domain/providers/provider_failure.dart';

import '../../helpers/fakes.dart';

const fakeKey = 'FAKE-gemini-test-key-0000000000';
const ref = 'provider.gemini';

http.StreamedResponse respond(
  int status,
  Object body, {
  Map<String, String> headers = const {},
}) => http.StreamedResponse(
  Stream.value(utf8.encode(body is String ? body : jsonEncode(body))),
  status,
  headers: headers,
);

String sse(List<Map<String, Object>> events) =>
    [for (final e in events) 'data: ${jsonEncode(e)}\r\n'].join('\r\n');

Map<String, Object> textEvent(String text, {Map<String, Object>? usage}) => {
  'candidates': [
    {
      'content': {
        'role': 'model',
        'parts': [
          {'text': text},
        ],
      },
    },
  ],
  'usageMetadata': ?usage,
};

void main() {
  late MemoryVault vault;
  late List<(http.BaseRequest, List<int>)> requests;

  GeminiClient client(
    FutureOr<http.StreamedResponse> Function(http.BaseRequest) handler,
  ) => GeminiClient(
    vault: vault,
    keyRef: ref,
    client: MockClient.streaming((req, body) async {
      requests.add((req, await body.toBytes()));
      return handler(req);
    }),
  );

  setUp(() {
    vault = MemoryVault()..values[ref] = fakeKey;
    requests = [];
  });

  test('the key goes in a header, never the URL', () async {
    await client((_) => respond(200, {'models': <Object>[]})).listModels();
    final req = requests.single.$1;
    expect(req.headers['x-goog-api-key'], fakeKey);
    expect(req.url.toString(), isNot(contains(fakeKey)));
    expect(req.url.queryParameters.containsKey('key'), isFalse);
  });

  test('missing key fails as invalidKey without a request', () async {
    vault.values.clear();
    await expectLater(
      client((_) => respond(200, {})).listModels(),
      throwsA(
        isA<ProviderException>().having(
          (e) => e.failure,
          'failure',
          ProviderFailure.invalidKey,
        ),
      ),
    );
    expect(requests, isEmpty);
  });

  test('lists text models without the models/ prefix', () async {
    final ids = await client(
      (_) => respond(200, {
        'models': [
          {
            'name': 'models/gemini-3.5-flash-lite',
            'supportedGenerationMethods': ['generateContent', 'countTokens'],
          },
          {
            'name': 'models/gemini-embedding-2',
            'supportedGenerationMethods': ['embedContent'],
          },
        ],
      }),
    ).listModels();
    expect(ids, ['gemini-3.5-flash-lite']);
  });

  test('streams text (no thoughts) and measured usage', () async {
    final chunks =
        await client(
              (_) => respond(
                200,
                sse([
                  {
                    'candidates': [
                      {
                        'content': {
                          'parts': [
                            {'text': 'thinking…', 'thought': true},
                          ],
                        },
                      },
                    ],
                  },
                  textEvent('Nice! '),
                  textEvent(
                    'Where to?',
                    usage: {
                      'promptTokenCount': 120,
                      'candidatesTokenCount': 6,
                      'thoughtsTokenCount': 4,
                    },
                  ),
                ]),
              ),
            )
            .streamChat(
              model: 'gemini-3.5-flash-lite',
              messages: const [
                ChatMessage(ChatRole.system, 'Be a coach.'),
                ChatMessage(ChatRole.user, 'Hi'),
              ],
            )
            .toList();
    expect(
      [
        for (final c in chunks)
          if (c is TextDelta) c.text,
      ],
      ['Nice! ', 'Where to?'],
    );
    final usage = chunks.whereType<ChatUsage>().single;
    expect(usage.inputTokens, 120);
    expect(usage.outputTokens, 10);

    final req = requests.single.$1;
    expect(
      req.url.path,
      endsWith('models/gemini-3.5-flash-lite:streamGenerateContent'),
    );
    expect(req.url.queryParameters['alt'], 'sse');
    final body = jsonDecode(utf8.decode(requests.single.$2)) as Map;
    expect(body['systemInstruction'], {
      'parts': [
        {'text': 'Be a coach.'},
      ],
    });
    expect((body['generationConfig'] as Map)['maxOutputTokens'], 200);
    expect(body['contents'], [
      {
        'role': 'user',
        'parts': [
          {'text': 'Hi'},
        ],
      },
    ]);
  });

  test('contents start with the user and alternate', () {
    final contents = GeminiClient.toContents(const [
      ChatMessage(ChatRole.system, 'rules'),
      ChatMessage(ChatRole.assistant, 'What did you do?'),
      ChatMessage(ChatRole.user, 'Could you give me a hint?'),
      ChatMessage(ChatRole.user, 'I went hiking.'),
    ]);
    expect(contents.map((c) => c['role']), ['user', 'model', 'user']);
    expect(contents.last['parts'], [
      {'text': 'Could you give me a hint?\n\nI went hiking.'},
    ]);
  });

  group('errors', () {
    Future<ProviderFailure> failureOf(int status, Object body) async {
      try {
        await client((_) => respond(status, body)).listModels();
      } on ProviderException catch (e) {
        expect(e.toString(), isNot(contains(fakeKey)));
        return e.failure;
      }
      fail('no error');
    }

    Map<String, Object> error(int code, String status, [String? reason]) => {
      'error': {
        'code': code,
        'message': 'API key not valid: $fakeKey',
        'status': status,
        if (reason != null)
          'details': [
            {'reason': reason},
          ],
      },
    };

    test('mapped to the shared failures', () async {
      expect(
        await failureOf(400, error(400, 'INVALID_ARGUMENT', 'API_KEY_INVALID')),
        ProviderFailure.invalidKey,
      );
      expect(
        await failureOf(403, error(403, 'PERMISSION_DENIED')),
        ProviderFailure.invalidKey,
      );
      expect(
        await failureOf(404, error(404, 'NOT_FOUND')),
        ProviderFailure.modelUnavailable,
      );
      expect(
        await failureOf(429, error(429, 'RESOURCE_EXHAUSTED')),
        ProviderFailure.rateLimited,
      );
      expect(await failureOf(500, 'oops'), ProviderFailure.unknown);
    });
  });

  group('model choice (free tier only)', () {
    test('fastest free model offered', () {
      expect(
        selectGeminiModel(['gemini-2.5-flash-lite', 'gemini-3.5-flash-lite']),
        'gemini-3.5-flash-lite',
      );
      expect(
        selectGeminiModel(['gemini-2.5-flash-lite']),
        'gemini-2.5-flash-lite',
      );
    });

    test('paid-only or unknown models are never picked', () {
      expect(
        () => selectGeminiModel(['gemini-3.1-pro-preview']),
        throwsA(isA<ProviderException>()),
      );
    });
  });
}
