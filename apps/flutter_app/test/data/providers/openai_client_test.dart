import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:speaking_coach/data/providers/openai/openai_client.dart';
import 'package:speaking_coach/data/providers/openai/provider_catalog.dart';
import 'package:speaking_coach/domain/providers/ai_provider.dart';
import 'package:speaking_coach/domain/providers/provider_failure.dart';

import '../../helpers/fakes.dart';

const fakeKey = 'sk-FAKE-openai-test-key-000000';
const ref = 'provider.openai';

http.StreamedResponse respond(
  int status,
  Object body, {
  Map<String, String> headers = const {},
}) => http.StreamedResponse(
  Stream.value(utf8.encode(body is String ? body : jsonEncode(body))),
  status,
  headers: headers,
);

Map<String, Object> apiError(String code) => {
  'error': {'message': 'Incorrect API key provided: $fakeKey', 'code': code},
};

void main() {
  late MemoryVault vault;
  late List<http.BaseRequest> requests;

  OpenAiClient client(
    FutureOr<http.StreamedResponse> Function(http.BaseRequest, List<int>)
    handler,
  ) => OpenAiClient(
    vault: vault,
    keyRef: ref,
    client: MockClient.streaming((req, body) async {
      requests.add(req);
      return handler(req, await body.toBytes());
    }),
  );

  setUp(() {
    vault = MemoryVault()..values[ref] = fakeKey;
    requests = [];
  });

  group('auth', () {
    test('sends the vault key as a bearer token', () async {
      await client((_, _) => respond(200, {'data': <Object>[]})).listModels();
      expect(requests.single.headers['Authorization'], 'Bearer $fakeKey');
    });

    test('missing key fails as invalidKey without a request', () async {
      vault.values.clear();
      final c = client((_, _) => respond(200, {'data': <Object>[]}));
      await expectLater(
        c.listModels(),
        throwsFailure(ProviderFailure.invalidKey),
      );
      expect(requests, isEmpty);
    });
  });

  group('error normalization', () {
    final cases = <String, (int, Object, Map<String, String>, ProviderFailure)>{
      '401': (401, apiError('invalid_api_key'), {}, ProviderFailure.invalidKey),
      '429 quota': (
        429,
        apiError('insufficient_quota'),
        {},
        ProviderFailure.insufficientQuota,
      ),
      '429 rate': (
        429,
        apiError('rate_limit_exceeded'),
        {'retry-after': '7'},
        ProviderFailure.rateLimited,
      ),
      '404 model': (
        404,
        apiError('model_not_found'),
        {},
        ProviderFailure.modelUnavailable,
      ),
      '400 model_not_found': (
        400,
        apiError('model_not_found'),
        {},
        ProviderFailure.modelUnavailable,
      ),
      '500': (500, 'oops', {}, ProviderFailure.unknown),
    };

    cases.forEach((name, c) {
      final (status, body, headers, failure) = c;
      test(name, () async {
        final call = client((_, _) => respond(status, body, headers: headers))
            .listModels();
        await expectLater(call, throwsFailure(failure));
      });
    });

    test('retry-after is parsed for rate limits', () async {
      try {
        await client(
          (_, _) => respond(
            429,
            apiError('rate_limit_exceeded'),
            headers: {'retry-after': '7'},
          ),
        ).listModels();
        fail('expected ProviderException');
      } on ProviderException catch (e) {
        expect(e.retryAfter, const Duration(seconds: 7));
      }
    });

    test('socket errors are network failures', () async {
      final call = client((_, _) => throw const SocketException('no route'))
          .listModels();
      await expectLater(call, throwsFailure(ProviderFailure.network));
    });

    test(
      'exceptions never contain the key, even if the body echoes it',
      () async {
        try {
          await client((_, _) => respond(401, apiError('invalid_api_key')))
              .listModels();
          fail('expected ProviderException');
        } on ProviderException catch (e) {
          expect(e.toString(), isNot(contains(fakeKey)));
        }
      },
    );
  });

  test('listModels returns sorted ids', () async {
    final models = await client(
      (_, _) => respond(200, {
        'data': [
          {'id': 'b-model'},
          {'id': 'a-model'},
        ],
      }),
    ).listModels();
    expect(models, ['a-model', 'b-model']);
  });

  test(
    'transcribe uploads the WAV as multipart and returns the text',
    () async {
      final text = await client((req, body) {
        expect(req.url.path, '/v1/audio/transcriptions');
        final s = latin1.decode(body);
        expect(s, contains('name="model"\r\n\r\nstt-model'));
        expect(s, contains('name="language"\r\n\r\nen'));
        expect(s, contains('filename="speech.wav"'));
        return respond(200, {'text': 'I went to the park.'});
      }).transcribe(model: 'stt-model', wav: Uint8List.fromList([1, 2, 3]));
      expect(text, 'I went to the park.');
    },
  );

  group('streamChat', () {
    test('parses SSE deltas split across chunks and reports usage', () async {
      const sse =
          'data: {"choices":[{"delta":{"role":"assistant"}}]}\n\n'
          'data: {"choices":[{"delta":{"content":"Hel"}}]}\n\n'
          'data: {"choices":[{"delta":{"content":"lo!"}}]}\n\n'
          'data: {"choices":[],"usage":{"prompt_tokens":12,"completion_tokens":3}}\n\n'
          'data: [DONE]\n\n';
      final bytes = utf8.encode(sse);
      final c = OpenAiClient(
        vault: vault,
        keyRef: ref,
        client: MockClient.streaming((req, body) async {
          final sent = jsonDecode(await body.bytesToString()) as Map;
          expect(sent['stream'], isTrue);
          expect(sent['model'], 'chat-model');
          expect(sent['max_completion_tokens'], 200);
          expect((sent['messages'] as List).first, {
            'role': 'system',
            'content': 'be brief',
          });
          // Deliver in 7-byte pieces to cross line boundaries.
          return http.StreamedResponse(
            Stream.fromIterable([
              for (var i = 0; i < bytes.length; i += 7)
                bytes.sublist(i, i + 7 > bytes.length ? bytes.length : i + 7),
            ]),
            200,
          );
        }),
      );

      final chunks = await c
          .streamChat(
            model: 'chat-model',
            messages: const [
              ChatMessage(ChatRole.system, 'be brief'),
              ChatMessage(ChatRole.user, 'hi'),
            ],
          )
          .toList();

      final text = chunks.whereType<TextDelta>().map((d) => d.text).join();
      expect(text, 'Hello!');
      final usage = chunks.whereType<ChatUsage>().single;
      expect(usage.inputTokens, 12);
      expect(usage.outputTokens, 3);
    });

    test('HTTP errors surface as ProviderException on the stream', () async {
      final stream = client(
        (_, _) => respond(429, apiError('insufficient_quota')),
      ).streamChat(model: 'm', messages: const []);
      await expectLater(
        stream.toList(),
        throwsFailure(ProviderFailure.insufficientQuota),
      );
    });
  });

  test('synthesize streams the audio body', () async {
    final audio = await client((req, body) {
      expect(req.url.path, '/v1/audio/speech');
      final sent = jsonDecode(utf8.decode(body)) as Map;
      expect(sent['input'], 'Hello');
      expect(sent['response_format'], 'mp3');
      expect(sent['voice'], openAiDefaultVoice);
      return http.StreamedResponse(
        Stream.fromIterable([
          [1, 2],
          [3],
        ]),
        200,
      );
    }).synthesize(model: 'tts-model', text: 'Hello').toList();
    expect(audio.expand((c) => c), [1, 2, 3]);
  });

  group('selectOpenAiModels', () {
    test('picks the first preferred model that the account has', () {
      final s = selectOpenAiModels([
        ...openAiChatPreference.skip(1),
        openAiTranscriptionPreference.last,
        ...openAiSpeechPreference,
      ]);
      expect(s.chat, openAiChatPreference[1]);
      expect(s.transcription, openAiTranscriptionPreference.last);
      expect(s.speech, openAiSpeechPreference.first);
    });

    test('missing capability is modelUnavailable', () {
      expect(
        () => selectOpenAiModels(openAiChatPreference),
        throwsA(
          isA<ProviderException>().having(
            (e) => e.failure,
            'failure',
            ProviderFailure.modelUnavailable,
          ),
        ),
      );
    });
  });
}

Matcher throwsFailure(ProviderFailure f) =>
    throwsA(isA<ProviderException>().having((e) => e.failure, 'failure', f));
