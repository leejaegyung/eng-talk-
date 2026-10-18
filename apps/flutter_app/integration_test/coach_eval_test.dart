// Evaluation set against the real model (P1-C1, spec §16.1): per mode, the
// coach asks one question at a time and follows up after a one-sentence
// answer; session feedback comes back as valid, transcript-backed JSON.
// Uses the signed-in ChatGPT plan (no API charges):
//   flutter test integration_test/coach_eval_test.dart -d macos
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:speaking_coach/app/providers.dart';
import 'package:speaking_coach/core/logging/app_logger.dart';
import 'package:speaking_coach/domain/conversation/prompt_composer.dart';
import 'package:speaking_coach/domain/conversation/session_enums.dart';
import 'package:speaking_coach/domain/feedback/feedback_service.dart';
import 'package:speaking_coach/domain/learning/learner_level.dart';
import 'package:speaking_coach/domain/learning/placement.dart';
import 'package:speaking_coach/domain/providers/ai_provider.dart';
import 'package:speaking_coach/domain/sessions/session_records.dart';

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
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  late ProviderContainer c;
  late LlmProvider llm;
  late String model;

  setUpAll(() async {
    c = ProviderContainer();
    expect(
      await c.read(chatGptAccountProvider).isSignedIn(),
      isTrue,
      reason: 'sign in with ChatGPT in the app first',
    );
    llm = c.read(chatGptLlmProvider);
    model = await c.read(chatGptModelSelectorProvider)();
  });
  tearDownAll(() => c.dispose());

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
    ];
    final f = await FeedbackService(llm)
        .evaluate(model: model, setup: const SessionSetup(), turns: turns);
    _log.info(
      'feedback: strengths=${f.strengths} corrections=${[for (final c in f.corrections) '${c.original} → ${c.suggested} (${c.category?.wire})']} next=${f.nextTopic}',
    );
    expect(f.reduced, isFalse);
    expect(f.corrections, isNotEmpty);
    for (final c in f.corrections) {
      expect([2, 4], contains(c.turnId));
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
