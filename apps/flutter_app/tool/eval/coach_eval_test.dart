// Evaluation set against the real model (P1-C1, spec §16.1), run from the
// command line — no Xcode or app needed:
//   dart run tool/eval/sign_in.dart          (once: ChatGPT sign-in)
//   flutter test tool/eval                    (ChatGPT plan, no API charges)
//   AI=gemini GEMINI_API_KEY=… flutter test tool/eval   (free Gemini key)
// Per mode, the coach asks one question at a time and follows up; feedback
// comes back as valid, transcript-backed JSON with word-order checks.
import 'package:flutter_test/flutter_test.dart';
import 'package:speaking_coach/core/logging/app_logger.dart';
import 'package:speaking_coach/domain/conversation/prompt_composer.dart';
import 'package:speaking_coach/domain/conversation/session_enums.dart';
import 'package:speaking_coach/domain/feedback/feedback.dart';
import 'package:speaking_coach/domain/feedback/feedback_service.dart';
import 'package:speaking_coach/domain/learning/learner_level.dart';
import 'package:speaking_coach/domain/learning/mini_lesson.dart';
import 'package:speaking_coach/domain/learning/placement.dart';
import 'package:speaking_coach/domain/providers/ai_provider.dart';
import 'package:speaking_coach/domain/sessions/session_records.dart';

import 'backend.dart';

const _log = AppLogger('eval');

final _answers = {
  SessionMode.daily: 'I went to the park yesterday.',
  SessionMode.theme: 'I like traveling to small towns.',
  SessionMode.roleplay: 'Hi, I have a reservation under Kim.',
  SessionMode.random: 'I would choose to be invisible.',
  SessionMode.storytelling: 'Last summer I got lost in Tokyo.',
  SessionMode.opinion: 'I think remote work is better.',
};

const _setups = {
  SessionMode.daily: PromptContext(
    mode: SessionMode.daily,
    level: LearnerLevel.l2,
  ),
  SessionMode.theme: PromptContext(
    mode: SessionMode.theme,
    level: LearnerLevel.l3,
    topic: 'Travel',
  ),
  SessionMode.roleplay: PromptContext(
    mode: SessionMode.roleplay,
    level: LearnerLevel.l3,
    role: 'hotel front desk clerk',
    topic: 'Checking in at a hotel late at night',
    goal: 'Get a quiet room for two nights',
  ),
  SessionMode.random: PromptContext(
    mode: SessionMode.random,
    level: LearnerLevel.l3,
  ),
  SessionMode.storytelling: PromptContext(
    mode: SessionMode.storytelling,
    level: LearnerLevel.l3,
    topic: 'A memorable trip',
  ),
  SessionMode.opinion: PromptContext(
    mode: SessionMode.opinion,
    level: LearnerLevel.l4,
    topic: 'Remote work vs. the office',
  ),
};

int _questions(String s) => '?'.allMatches(s).length;
int _sentences(String s) => RegExp(r'[^.!?]+[.!?]+')
    .allMatches(
      s.trim().replaceAllMapped(RegExp(r'\b(Mr|Ms|Mrs|Dr|St)\.'), (m) => m[1]!),
    )
    .length;

void main() {
  late LlmProvider llm;
  late String model;

  setUpAll(() async {
    (llm, model) = await evalBackend();
    // ignore: avoid_print
    print('AI under test: $model');
  });

  Future<String> ask(List<ChatMessage> messages) async {
    final out = StringBuffer();
    await for (final chunk in llm.streamChat(
      model: model,
      messages: messages,
    )) {
      if (chunk case TextDelta(:final text)) out.write(text);
    }
    return out.toString().trim();
  }

  const composer = PromptComposer();

  for (final mode in _answers.keys) {
    test('${mode.name}: one question, then a follow-up', () async {
      final ctx = _setups[mode]!;
      final opening = await ask(
        composer.compose(
          ctx,
          const [
            ChatMessage(ChatRole.user, '[The learner has joined the session.]'),
          ],
          policyNotes: const [
            'The session is starting: greet the learner in a few words and '
                'ask your first question.',
          ],
        ),
      );
      final reply = await ask(
        composer.compose(ctx, [
          ChatMessage(ChatRole.assistant, opening),
          ChatMessage(ChatRole.user, _answers[mode]!),
        ]),
      );
      _log.info(
        '[${mode.name}] AI: $opening | learner: ${_answers[mode]} | AI: $reply',
      );

      expect(_questions(opening), 1, reason: 'opening: $opening');
      expect(_questions(reply), 1, reason: 'follow-up: $reply');
      expect(_sentences(reply), lessThanOrEqualTo(3), reason: 'short: $reply');
      expect(reply, isNot(contains('*')), reason: 'no markdown: $reply');
    }, timeout: const Timeout(Duration(minutes: 2)));
  }

  test('focus area: the mistake is recast, not lectured (P2-4)', () async {
    const ctx = PromptContext(
      mode: SessionMode.daily,
      level: LearnerLevel.l2,
      focusArea: ErrorCategory.grammar,
      reviewExpressions: ['That reminds me of'],
    );
    const answer = 'Yesterday I go to the park and I eat sandwich.';
    final reply = await ask(
      composer.compose(ctx, const [
        ChatMessage(ChatRole.assistant, 'What did you do yesterday?'),
        ChatMessage(ChatRole.user, answer),
      ]),
    );
    _log.info('[focus] learner: $answer | AI: $reply');
    expect(_questions(reply), 1, reason: 'follow-up: $reply');
    expect(_sentences(reply), lessThanOrEqualTo(3), reason: 'short: $reply');
    final lower = reply.toLowerCase();
    expect(
      lower.contains('went') || lower.contains('ate'),
      isTrue,
      reason: 'recasts the past tense: $reply',
    );
    for (final lecture in ['should be', 'correct form', 'mistake', 'grammar']) {
      expect(lower, isNot(contains(lecture)), reason: 'no lecture: $reply');
    }
  }, timeout: const Timeout(Duration(minutes: 2)));

  test('random topic: one question, a named topic, varied', () async {
    final openings = <String>[];
    for (final (mode, seed) in [
      (SessionMode.daily, 1111),
      (SessionMode.theme, 52817),
      (SessionMode.roleplay, 90210),
    ]) {
      final opening = await ask(
        composer.compose(
          PromptContext(
            mode: mode,
            level: LearnerLevel.l3,
            aiTopic: true,
            topicSeed: seed,
            avoidTopics: const ['Travel', 'Hobbies'],
          ),
          const [
            ChatMessage(ChatRole.user, '[The learner has joined the session.]'),
          ],
          policyNotes: const [
            'The session is starting: greet the learner in a few words and '
                'ask your first question.',
          ],
        ),
      );
      openings.add(opening);
      _log.info('[random ${mode.name}] $opening');
      // ignore: avoid_print
      print('RANDOM ${mode.name}: $opening');
      expect(_questions(opening), 1, reason: opening);
    }
    expect(openings.toSet(), hasLength(3));
  }, timeout: const Timeout(Duration(minutes: 3)));

  test('mini lesson: one rule in Korean, three short examples', () async {
    final lesson = await MiniLessonService(llm).write(
      model: model,
      category: ErrorCategory.grammar,
      mistakes: const [
        CorrectionExample(
          original: 'Yesterday I go to the park',
          suggested: 'Yesterday I went to the park.',
        ),
        CorrectionExample(
          original: 'Last week we eat pizza',
          suggested: 'Last week we ate pizza.',
        ),
        CorrectionExample(
          original: 'She call me two days ago',
          suggested: 'She called me two days ago.',
        ),
      ],
    );
    // ignore: avoid_print
    print(
      'LESSON: ${lesson?.titleKo} | ${lesson?.explanationKo} | '
      '${[for (final e in lesson?.examples ?? const <LessonExample>[]) e.en]}',
    );
    expect(lesson, isNotNull);
    expect(lesson!.examples, hasLength(3));
    expect(RegExp('[가-힣]').hasMatch(lesson.explanationKo), isTrue);
    for (final e in lesson.examples) {
      expect(e.en.split(' ').length, lessThanOrEqualTo(12), reason: e.en);
      expect(e.en, isNot(contains('*')));
    }
  }, timeout: const Timeout(Duration(minutes: 2)));

  test('feedback: valid JSON, corrections quote the learner', () async {
    final t0 = DateTime.now();
    final turns = [
      TurnRecord(
        id: 1,
        speaker: Speaker.assistant,
        text: 'What did you do last weekend?',
        startedAt: t0,
      ),
      TurnRecord(
        id: 2,
        speaker: Speaker.user,
        text: 'I go to the beach with my friends and we eat many seafood.',
        startedAt: t0,
      ),
      TurnRecord(
        id: 3,
        speaker: Speaker.assistant,
        text: 'Nice! What was the best part?',
        startedAt: t0,
      ),
      TurnRecord(
        id: 4,
        speaker: Speaker.user,
        text: 'The best part was swim in the sea. It was very relax.',
        startedAt: t0,
      ),
      TurnRecord(
        id: 5,
        speaker: Speaker.assistant,
        text: 'Sounds lovely. What did you like about the food?',
        startedAt: t0,
      ),
      TurnRecord(
        id: 6,
        speaker: Speaker.user,
        text: 'Very much I like the seafood there.',
        startedAt: t0,
      ),
    ];
    final f = await FeedbackService(llm)
        .evaluate(model: model, setup: const SessionSetup(), turns: turns);
    _log.info(
      'feedback: strengths=${f.strengths} corrections=${[for (final c in f.corrections) '${c.original} → ${c.suggested} (${c.category?.wire})']} next=${f.nextTopic}',
    );
    expect(f.reduced, isFalse);
    expect(f.corrections, isNotEmpty);
    // ignore: avoid_print
    print(
      'WORD ORDER: ${[for (final w in f.wordOrder) '${w.turnId} ${w.ok} ${w.corrected ?? ''}']}',
    );
    final scrambled = f.wordOrder.where((w) => w.turnId == 6).single;
    expect(scrambled.ok, isFalse, reason: 'wrong order is caught');
    expect(scrambled.corrected!.toLowerCase(), startsWith('i like'));
    for (final c in f.corrections) {
      expect([2, 4, 6], contains(c.turnId));
      expect(c.explanationKo, isNotNull);
      expect(c.category, isNotNull, reason: 'classified for S10');
    }
  }, timeout: const Timeout(Duration(minutes: 2)));

  test('placement rubric is parsed', () async {
    final r = await PlacementService(llm).evaluate(
      model: model,
      answers: [
        for (final q in placementQuestions)
          (
            q,
            'I am office worker. I like movie because it is fun and I watch every weekend with my wife.',
          ),
      ],
    );
    _log.info('rubric: ${r?.toJson()}');
    expect(r, isNotNull);
  }, timeout: const Timeout(Duration(minutes: 2)));
}
