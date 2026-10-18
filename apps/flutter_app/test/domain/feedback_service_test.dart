import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:speaking_coach/domain/conversation/session_enums.dart';
import 'package:speaking_coach/domain/feedback/feedback.dart';
import 'package:speaking_coach/domain/feedback/feedback_service.dart';
import 'package:speaking_coach/domain/providers/ai_provider.dart';
import 'package:speaking_coach/domain/providers/provider_failure.dart';
import 'package:speaking_coach/domain/sessions/session_records.dart';

class ScriptedLlm implements LlmProvider {
  ScriptedLlm(this.replies);

  final List<Object> replies;
  final requests = <List<ChatMessage>>[];

  @override
  Future<List<String>> listModels() async => const [];

  @override
  Stream<ChatChunk> streamChat({
    required String model,
    required List<ChatMessage> messages,
    int maxOutputTokens = 200,
  }) async* {
    requests.add(messages);
    final r = replies.removeAt(0);
    if (r is Exception) throw r;
    final text = r as String;
    // Split to make sure the service joins deltas.
    yield TextDelta(text.substring(0, text.length ~/ 2));
    yield TextDelta(text.substring(text.length ~/ 2));
  }
}

void main() {
  final t0 = DateTime.utc(2026, 10, 17);
  final turns = [
    TurnRecord(
      id: 1,
      speaker: Speaker.assistant,
      text: 'What did you do yesterday?',
      startedAt: t0,
    ),
    TurnRecord(
      id: 2,
      speaker: Speaker.user,
      text: 'I go to the park yesterday with my friend.',
      startedAt: t0,
    ),
    TurnRecord(
      id: 3,
      speaker: Speaker.user,
      text: 'Could you give me a hint?',
      startedAt: t0,
      isRequest: true,
    ),
    TurnRecord(
      id: 4,
      speaker: Speaker.user,
      text: 'We play soccer. It was fun.',
      startedAt: t0,
    ),
  ];

  String json({
    List<Object> corrections = const [],
    List<Object> expressions = const ['That reminds me of...'],
  }) => jsonEncode({
    'strengths': ['Answered every question'],
    'corrections': corrections,
    'expressions': expressions,
    'next_topic': 'Weekend plans',
  });

  Map<String, Object> correction(
    int turn,
    String original, {
    String? severity,
    String? category,
  }) => {
    'turn_id': turn,
    'original': original,
    'suggested': '$original (fixed)',
    'explanation_ko': '설명',
    'severity': ?severity,
    'category': ?category,
    'practice_prompt': 'Tell me again.',
  };

  Future<(FeedbackResult, ScriptedLlm)> run(List<Object> replies) async {
    final llm = ScriptedLlm(replies);
    final result = await FeedbackService(llm)
        .evaluate(model: 'm', setup: const SessionSetup(), turns: turns);
    return (result, llm);
  }

  test('valid feedback is parsed and linked to learner turns', () async {
    final (f, llm) = await run([
      json(
        corrections: [
          correction(2, 'I go to the park yesterday', severity: 'high'),
        ],
      ),
    ]);
    expect(f.reduced, isFalse);
    expect(f.strengths, ['Answered every question']);
    final c = f.corrections.single;
    expect(c.turnId, 2);
    expect(c.severity, Severity.high);
    expect(c.explanationKo, '설명');
    expect(f.expressions.single.phrase, 'That reminds me of...');
    expect(f.nextTopic, 'Weekend plans');
    expect(llm.requests, hasLength(1));
  });

  test('category is parsed; unknown or missing is left empty', () async {
    final (f, _) = await run([
      json(
        corrections: [
          correction(
            2,
            'I go to the park',
            severity: 'high',
            category: 'grammar',
          ),
          correction(4, 'I', severity: 'medium', category: 'spelling'),
        ],
      ),
    ]);
    expect(f.corrections.map((c) => c.category), [ErrorCategory.grammar, null]);
  });

  test('transcript is sent with turn ids; quick actions marked', () async {
    final (_, llm) = await run([json()]);
    final transcript = llm.requests.single.last.content;
    expect(transcript, contains('[t2] learner: I go to the park yesterday'));
    expect(transcript, contains('[t1] coach:'));
    expect(transcript, isNot(contains('[t3]')));
    expect(llm.requests.single.first.role, ChatRole.system);
    expect(llm.requests.single.first.content, contains('"corrections"'));
  });

  group('rejects corrections not backed by the transcript', () {
    test('original not said in that turn', () async {
      final (f, _) = await run([
        json(corrections: [correction(2, 'I eated pizza')]),
      ]);
      expect(f.corrections, isEmpty);
    });

    test('turn is the coach or a quick action or unknown', () async {
      final (f, _) = await run([
        json(
          corrections: [
            correction(1, 'What did you do'),
            correction(3, 'Could you give me a hint'),
            correction(99, 'I go'),
          ],
        ),
      ]);
      expect(f.corrections, isEmpty);
    });

    test('matching ignores case, spacing and end punctuation', () async {
      final (f, _) = await run([
        json(corrections: [correction(4, 'we  play soccer')]),
      ]);
      expect(f.corrections.single.turnId, 4);
    });
  });

  test('at most 3 corrections (most severe first) and 5 expressions', () async {
    final (f, _) = await run([
      json(
        corrections: [
          correction(2, 'I go', severity: 'low'),
          correction(2, 'to the park', severity: 'high'),
          correction(4, 'We play soccer', severity: 'medium'),
          correction(2, 'with my friend', severity: 'low'),
        ],
        expressions: [
          for (var i = 0; i < 8; i++) {'phrase': 'p$i', 'meaning_ko': 'm$i'},
        ],
      ),
    ]);
    expect(f.corrections.map((c) => c.severity), [
      Severity.high,
      Severity.medium,
      Severity.low,
    ]);
    expect(f.expressions, hasLength(5));
    expect(f.expressions.first.meaningKo, 'm0');
  });

  test('JSON inside a code fence is accepted', () async {
    final (f, _) = await run(['Here you go:\n```json\n${json()}\n```']);
    expect(f.reduced, isFalse);
    expect(f.strengths, isNotEmpty);
  });

  test('invalid JSON → one retry, then success', () async {
    final (f, llm) = await run(['not json at all', json()]);
    expect(f.reduced, isFalse);
    expect(llm.requests, hasLength(2));
    expect(llm.requests.last.last.content, contains('only the JSON'));
  });

  test('invalid twice → safe reduced result, no third call', () async {
    final (f, llm) = await run(['nope', '{"strengths": "wrong type"}']);
    expect(f.reduced, isTrue);
    expect(f.isEmpty, isTrue);
    expect(llm.requests, hasLength(2));
  });

  test('no learner answers → nothing to evaluate, no call', () async {
    final llm = ScriptedLlm([]);
    final f = await FeedbackService(llm).evaluate(
      model: 'm',
      setup: const SessionSetup(),
      turns: [turns.first, turns[2]],
    );
    expect(f.isEmpty, isTrue);
    expect(llm.requests, isEmpty);
  });

  test('provider failures propagate for the UI to explain', () async {
    final llm = ScriptedLlm([const ProviderException(ProviderFailure.network)]);
    expect(
      () =>
          FeedbackService(llm)
              .evaluate(model: 'm', setup: const SessionSetup(), turns: turns),
      throwsA(isA<ProviderException>()),
    );
  });
}
