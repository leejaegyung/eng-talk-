import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:speaking_coach/data/providers/anthropic/anthropic_client.dart';
import 'package:speaking_coach/data/providers/anthropic/provider_catalog.dart';
import 'package:speaking_coach/domain/providers/ai_provider.dart';
import 'package:speaking_coach/domain/providers/provider_failure.dart';

import '../../helpers/fakes.dart';

const fakeKey = 'sk-FAKE-anthropic-test-key-000';
const ref = 'provider.anthropic';

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
    [for (final e in events) 'event: ${e['type']}\ndata: ${jsonEncode(e)}\n']
        .join('\n');

void main() {
  late MemoryVault vault;
  late List<(http.BaseRequest, List<int>)> requests;

  AnthropicClient client(
    FutureOr<http.StreamedResponse> Function(http.BaseRequest) handler,
  ) => AnthropicClient(
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

  test('sends the vault key and API version headers', () async {
    await client((_) => respond(200, {'data': <Object>[]})).listModels();
    final req = requests.single.$1;
    expect(req.headers['x-api-key'], fakeKey);
    expect(req.headers['anthropic-version'], '2023-06-01');
    expect(req.headers.containsKey('Authorization'), isFalse);
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

  test('lists model ids', () async {
    final ids = await client(
      (_) => respond(200, {
        'data': [
          {'id': 'claude-sonnet-5-5'},
          {'id': 'claude-haiku-5-5'},
        ],
      }),
    ).listModels();
    expect(ids, ['claude-haiku-5-5', 'claude-sonnet-5-5']);
  });

  test('streams text and measured usage', () async {
    final chunks =
        await client(
              (_) => respond(
                200,
                sse([
                  {
                    'type': 'message_start',
                    'message': {
                      'usage': {'input_tokens': 120, 'output_tokens': 1},
                    },
                  },
                  {
                    'type': 'content_block_delta',
                    'delta': {'type': 'text_delta', 'text': 'Nice! '},
                  },
                  {'type': 'ping'},
                  {
                    'type': 'content_block_delta',
                    'delta': {'type': 'text_delta', 'text': 'Where to?'},
                  },
                  {
                    'type': 'message_delta',
                    'usage': {'output_tokens': 9},
                  },
                  {'type': 'message_stop'},
                ]),
              ),
            )
            .streamChat(
              model: 'claude-haiku-5-5',
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
    expect(usage.outputTokens, 9);

    final body = jsonDecode(utf8.decode(requests.single.$2)) as Map;
    expect(body['system'], 'Be a coach.');
    expect(body['stream'], isTrue);
    expect(body['max_tokens'], 200);
    expect(body['messages'], [
      {'role': 'user', 'content': 'Hi'},
    ]);
  });

  test('turns start with the user and alternate', () {
    final turns = AnthropicClient.toTurns(const [
      ChatMessage(ChatRole.system, 'rules'),
      ChatMessage(ChatRole.assistant, 'What did you do?'),
      ChatMessage(ChatRole.user, 'Could you give me a hint?'),
      ChatMessage(ChatRole.user, 'I went hiking.'),
    ]);
    expect(turns.map((t) => t['role']), ['user', 'assistant', 'user']);
    expect(
      turns.last['content'],
      'Could you give me a hint?\n\nI went hiking.',
    );
  });

  group('errors', () {
    Future<ProviderFailure> failureOf(
      int status,
      Object body, {
      Map<String, String> headers = const {},
    }) async {
      try {
        await client((_) => respond(status, body, headers: headers))
            .listModels();
      } on ProviderException catch (e) {
        expect(e.toString(), isNot(contains(fakeKey)));
        return e.failure;
      }
      fail('no error');
    }

    Map<String, Object> error(String type, [String message = '']) => {
      'type': 'error',
      'error': {'type': type, 'message': message},
    };

    test('mapped to the shared failures', () async {
      expect(
        await failureOf(401, error('authentication_error')),
        ProviderFailure.invalidKey,
      );
      expect(
        await failureOf(404, error('not_found_error')),
        ProviderFailure.modelUnavailable,
      );
      expect(
        await failureOf(429, error('rate_limit_error')),
        ProviderFailure.rateLimited,
      );
      expect(
        await failureOf(529, error('overloaded_error')),
        ProviderFailure.rateLimited,
      );
      expect(
        await failureOf(
          400,
          error('invalid_request_error', 'Your credit balance is too low'),
        ),
        ProviderFailure.insufficientQuota,
      );
      expect(await failureOf(500, 'oops'), ProviderFailure.unknown);
    });

    test('an error event mid-stream is raised', () async {
      final stream =
          client(
            (_) => respond(
              200,
              sse([
                {
                  'type': 'error',
                  'error': {'type': 'overloaded_error'},
                },
              ]),
            ),
          ).streamChat(
            model: 'm',
            messages: const [ChatMessage(ChatRole.user, 'Hi')],
          );
      await expectLater(
        stream.toList(),
        throwsA(
          isA<ProviderException>().having(
            (e) => e.failure,
            'failure',
            ProviderFailure.rateLimited,
          ),
        ),
      );
    });
  });

  group('model choice', () {
    test('preferred fast model when offered', () {
      expect(
        selectClaudeModel(['claude-sonnet-5-5', 'claude-haiku-5-5']),
        'claude-haiku-5-5',
      );
    });

    test('falls back to the newest of a family', () {
      expect(
        selectClaudeModel(['claude-haiku-4-5', 'claude-haiku-6-0', 'other']),
        'claude-haiku-6-0',
      );
      expect(selectClaudeModel(['claude-sonnet-4-5']), 'claude-sonnet-4-5');
    });

    test('nothing usable', () {
      expect(
        () => selectClaudeModel(['gpt-x']),
        throwsA(isA<ProviderException>()),
      );
    });
  });
}
