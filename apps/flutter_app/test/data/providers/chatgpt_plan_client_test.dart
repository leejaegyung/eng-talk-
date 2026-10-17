import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:speaking_coach/data/providers/chatgpt/chatgpt_plan_client.dart';
import 'package:speaking_coach/data/providers/chatgpt/provider_catalog.dart';
import 'package:speaking_coach/domain/providers/ai_provider.dart';
import 'package:speaking_coach/domain/providers/provider_failure.dart';

String sse(List<Map<String, Object>> events) =>
    [for (final e in events) 'event: ${e['type']}\ndata: ${jsonEncode(e)}\n\n']
        .join();

http.StreamedResponse streamed(int status, String body, {int piece = 9}) {
  final bytes = utf8.encode(body);
  return http.StreamedResponse(
    Stream.fromIterable([
      for (var i = 0; i < bytes.length; i += piece)
        bytes.sublist(i, i + piece > bytes.length ? bytes.length : i + piece),
    ]),
    status,
  );
}

void main() {
  late List<http.BaseRequest> requests;
  late List<Map<Object?, Object?>> bodies;

  ChatGptPlanClient client(int status, String body) => ChatGptPlanClient(
    accessToken: () async => 'access-xyz',
    client: MockClient.streaming((req, stream) async {
      requests.add(req);
      final raw = await stream.bytesToString();
      if (raw.isNotEmpty) bodies.add(jsonDecode(raw) as Map);
      return streamed(status, body);
    }),
  );

  setUp(() {
    requests = [];
    bodies = [];
  });

  const messages = [
    ChatMessage(ChatRole.system, 'Be a coach.'),
    ChatMessage(ChatRole.user, 'Hi'),
    ChatMessage(ChatRole.assistant, 'Hello! How are you?'),
    ChatMessage(ChatRole.user, 'Good.'),
  ];

  test('request follows the plan-usage contract', () async {
    await client(
      200,
      sse([
        {'type': 'response.completed', 'response': <String, Object>{}},
      ]),
    ).streamChat(model: 'plan-model', messages: messages).toList();

    final req = requests.single;
    expect(req.url.toString(), 'https://api.openai.com/v1/responses');
    expect(req.headers['Authorization'], 'Bearer access-xyz');
    final body = bodies.single;
    expect(body['model'], 'plan-model');
    expect(body['stream'], isTrue);
    expect(body['store'], isFalse);
    expect(body['instructions'], 'Be a coach.');
    final input = body['input']! as List;
    expect(input.map((m) => (m as Map)['role']), ['user', 'assistant', 'user']);
    expect((input.last as Map)['content'], 'Good.');
    // Rejected or unsupported fields must not be sent.
    for (final f in [
      'max_output_tokens',
      'temperature',
      'previous_response_id',
    ]) {
      expect(body.containsKey(f), isFalse, reason: f);
    }
  });

  test('streams text deltas and reports usage on completion', () async {
    final chunks = await client(
      200,
      sse([
        {'type': 'response.created', 'response': <String, Object>{}},
        {'type': 'response.output_text.delta', 'delta': 'Nice '},
        {'type': 'response.output_text.delta', 'delta': 'to meet you!'},
        {
          'type': 'response.completed',
          'response': {
            'usage': {'input_tokens': 21, 'output_tokens': 5},
          },
        },
      ]),
    ).streamChat(model: 'm', messages: messages).toList();

    expect(
      chunks.whereType<TextDelta>().map((d) => d.text).join(),
      'Nice to meet you!',
    );
    final usage = chunks.whereType<ChatUsage>().single;
    expect(usage.inputTokens, 21);
    expect(usage.outputTokens, 5);
  });

  group('errors', () {
    test('usage limit inside the stream → planUsageLimit', () async {
      final stream = client(
        200,
        sse([
          {'type': 'response.output_text.delta', 'delta': 'Hel'},
          {
            'type': 'response.failed',
            'response': {
              'error': {'code': 'subscription_sharing_usage_limit_exceeded'},
            },
          },
        ]),
      ).streamChat(model: 'm', messages: messages);
      await expectLater(
        stream.toList(),
        throwsFailure(ProviderFailure.planUsageLimit),
      );
    });

    test('error event → mapped failure', () async {
      final stream = client(
        200,
        sse([
          {'type': 'error', 'code': 'subscription_sharing_invalid_user'},
        ]),
      ).streamChat(model: 'm', messages: messages);
      await expectLater(
        stream.toList(),
        throwsFailure(ProviderFailure.signInRequired),
      );
    });

    final http = <String, (int, String, ProviderFailure)>{
      '403 not eligible': (
        403,
        jsonEncode({
          'error': {'code': 'subscription_sharing_user_not_eligible'},
        }),
        ProviderFailure.planNotEligible,
      ),
      '429 limit': (
        429,
        jsonEncode({
          'error': {'code': 'subscription_sharing_usage_limit_exceeded'},
        }),
        ProviderFailure.planUsageLimit,
      ),
      '401 detail body': (
        401,
        jsonEncode({'detail': 'identity not accepted'}),
        ProviderFailure.signInRequired,
      ),
      '503 unavailable': (
        503,
        jsonEncode({
          'error': {'code': 'subscription_sharing_usage_unavailable'},
        }),
        ProviderFailure.unknown,
      ),
    };
    http.forEach((name, c) {
      final (status, body, failure) = c;
      test(name, () async {
        final stream = client(
          status,
          body,
        ).streamChat(model: 'm', messages: messages);
        await expectLater(stream.toList(), throwsFailure(failure));
      });
    });

    test('auth failure before the request is propagated', () async {
      final c = ChatGptPlanClient(
        accessToken: () async =>
            throw const ProviderException(ProviderFailure.signInRequired),
        client: MockClient((_) async => fail('must not send')),
      );
      await expectLater(
        c.streamChat(model: 'm', messages: messages).toList(),
        throwsFailure(ProviderFailure.signInRequired),
      );
    });
  });

  test('planModels parses the plan format', () async {
    final models = await client(
      200,
      jsonEncode({
        'models': [
          {
            'slug': 'big',
            'priority': 1,
            'description': 'Workhorse model.',
            'visibility': 'list',
            'supported_in_api': true,
          },
          {'slug': 'hidden', 'priority': 2, 'visibility': 'hide'},
        ],
      }),
    ).planModels();
    expect(models.map((m) => m.slug), ['big', 'hidden']);
    expect(models.first.priority, 1);
    expect(models.first.description, 'Workhorse model.');
    expect(models.last.listed, isFalse);
    expect(requests.single.method, 'GET');
  });

  test('listModels returns listed slugs; API-key format also works', () async {
    final models = await client(
      200,
      jsonEncode({
        'data': [
          {'id': 'z-model', 'visibility': 'list'},
          {'id': 'hidden', 'visibility': 'hide'},
          {'id': 'a-model'},
        ],
      }),
    ).listModels();
    expect(models, ['z-model', 'a-model']);
  });

  group('selectChatGptPlanModel', () {
    const big = PlanModel(slug: 'big', priority: 1, description: 'Workhorse.');
    const fastNew = PlanModel(
      slug: 'fast-new',
      priority: 4,
      description: 'Fast and affordable model for easier tasks.',
    );
    const fastOld = PlanModel(
      slug: 'fast-old',
      priority: 9,
      description: 'Older fast and efficient model.',
    );

    test('prefers the highest-priority model described as fast', () {
      expect(selectChatGptPlanModel([big, fastOld, fastNew]), 'fast-new');
    });

    test('falls back to the highest-priority usable model', () {
      expect(
        selectChatGptPlanModel([
          const PlanModel(slug: 'second', priority: 2),
          big,
        ]),
        'big',
      );
    });

    test('skips hidden and API-unsupported models', () {
      expect(
        selectChatGptPlanModel([
          const PlanModel(
            slug: 'h',
            priority: 0,
            description: 'fast',
            listed: false,
          ),
          const PlanModel(
            slug: 'n',
            priority: 0,
            description: 'fast',
            supportedInApi: false,
          ),
          big,
        ]),
        'big',
      );
    });

    test('no usable models → modelUnavailable', () {
      expect(
        () => selectChatGptPlanModel([]),
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
