import 'package:flutter_test/flutter_test.dart';
import 'package:speaking_coach/domain/conversation/conversation_policy.dart';

void main() {
  late ConversationPolicy policy;
  setUp(() => policy = ConversationPolicy());

  group('hint ladder (spec §8.2)', () {
    test('escalates word → starter → Korean → example, then stays', () {
      final stages = [for (var i = 0; i < 5; i++) policy.act(CoachAction.hint)];
      expect(stages.map((r) => r.hintStage), [
        HintStage.word,
        HintStage.sentenceStarter,
        HintStage.korean,
        HintStage.example,
        HintStage.example,
      ]);
      expect(stages[0].notes.single, contains('single key word'));
      expect(stages[2].notes.single, contains('Korean'));
    });

    test('the learner speaking resets the ladder', () {
      policy
        ..act(CoachAction.hint)
        ..act(CoachAction.hint)
        ..learnerSpoke();
      expect(policy.act(CoachAction.hint).hintStage, HintStage.word);
    });
  });

  test('every action sends a natural English request the learner can see', () {
    for (final action in CoachAction.values) {
      final r = ConversationPolicy().act(action);
      expect(r.userText, isNotEmpty, reason: action.name);
      expect(r.notes, isNotEmpty, reason: action.name);
    }
  });

  test('slower stays on for the rest of the session', () {
    expect(
      policy.standingNotes(Duration.zero).join(),
      isNot(contains('simpler')),
    );
    policy.act(CoachAction.slower);
    expect(policy.slower, isTrue);
    policy.learnerSpoke();
    expect(policy.standingNotes(Duration.zero).join(), contains('simpler'));
  });

  test('correct-now asks for one correction of the last learner turn', () {
    final r = policy.act(CoachAction.correctLast);
    expect(r.notes.single, contains('last learner message'));
  });

  group('correction timing', () {
    test('default: no mid-session corrections', () {
      expect(
        policy.standingNotes(const Duration(minutes: 25)).join(),
        isNot(contains('mistake')),
      );
    });

    test('with an interval, one brief correction is due once per interval', () {
      policy = ConversationPolicy(
        correctionInterval: const Duration(minutes: 5),
      );
      expect(policy.correctionDue(const Duration(minutes: 4)), isFalse);
      expect(policy.correctionDue(const Duration(minutes: 5)), isTrue);
      policy.correctionGiven(const Duration(minutes: 5));
      expect(policy.correctionDue(const Duration(minutes: 8)), isFalse);
      expect(policy.correctionDue(const Duration(minutes: 10)), isTrue);
    });
  });

  group('session phases (spec §2.4)', () {
    test('30-minute preset: 3 / 4 / 18 / 5', () {
      final p = ConversationPolicy(length: const Duration(minutes: 30));
      expect(p.stageAt(Duration.zero), LessonStage.warmUp);
      expect(p.stageAt(const Duration(minutes: 3)), LessonStage.activation);
      expect(p.stageAt(const Duration(minutes: 7)), LessonStage.focus);
      expect(
        p.stageAt(const Duration(minutes: 24, seconds: 59)),
        LessonStage.focus,
      );
      expect(p.stageAt(const Duration(minutes: 25)), LessonStage.wrapUp);
      expect(p.stageAt(const Duration(minutes: 40)), LessonStage.wrapUp);
    });

    test('other lengths scale proportionally', () {
      final p = ConversationPolicy(length: const Duration(minutes: 20));
      expect(p.stageAt(const Duration(minutes: 2)), LessonStage.activation);
      expect(p.stageAt(const Duration(minutes: 17)), LessonStage.wrapUp);
    });

    test('each phase adds its own note', () {
      final p = ConversationPolicy(length: const Duration(minutes: 30));
      final notes = {
        for (final m in [0, 4, 10, 26])
          p.standingNotes(Duration(minutes: m)).join(),
      };
      expect(notes, hasLength(4));
      expect(
        p.standingNotes(const Duration(minutes: 26)).join(),
        contains('wrap up'),
      );
    });
  });

  test('a long silence suggests a hint, a short one does not (spec §7.3)', () {
    expect(policy.suggestHint(const Duration(seconds: 5)), isFalse);
    expect(policy.suggestHint(const Duration(seconds: 20)), isTrue);
  });
}
