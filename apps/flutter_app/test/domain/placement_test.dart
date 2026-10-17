import 'package:flutter_test/flutter_test.dart';
import 'package:speaking_coach/domain/learning/learner_level.dart';
import 'package:speaking_coach/domain/learning/placement.dart';

import 'feedback_service_test.dart' show ScriptedLlm;

Rubric rubric(int all) => Rubric(
  relevance: all,
  sentenceFormation: all,
  vocabulary: all,
  continuity: all,
);

void main() {
  test('five placement questions', () {
    expect(placementQuestions, hasLength(5));
  });

  group('rubric → level', () {
    test('average maps to L1..L5 with long answers', () {
      expect([
        for (final s in [1, 2, 3, 4, 5])
          placementLevel(rubric(s), avgWords: 40),
      ], LearnerLevel.values);
    });

    test('boundaries', () {
      const mixed = Rubric(
        relevance: 3,
        sentenceFormation: 3,
        vocabulary: 3,
        continuity: 4,
      );
      expect(placementLevel(mixed, avgWords: 40), LearnerLevel.l4);
    });

    test('short answers cap the level', () {
      expect(placementLevel(rubric(5), avgWords: 3), LearnerLevel.l1);
      expect(placementLevel(rubric(5), avgWords: 8), LearnerLevel.l2);
      expect(placementLevel(rubric(5), avgWords: 15), LearnerLevel.l3);
      expect(placementLevel(rubric(2), avgWords: 15), LearnerLevel.l2);
    });
  });

  group('PlacementService', () {
    const answers = [('Q one?', 'I am a designer. I like hiking.')];
    const good =
        '{"relevance": 4, "sentence_formation": 3, "vocabulary": 3, '
        '"continuity": 2, "comment_ko": "좋아요"}';

    test('parses the rubric', () async {
      final llm = ScriptedLlm([good]);
      final r = await PlacementService(llm)
          .evaluate(model: 'm', answers: answers);
      expect(r!.relevance, 4);
      expect(r.commentKo, '좋아요');
      expect(
        llm.requests.single.last.content,
        contains('A1: I am a designer.'),
      );
    });

    test('out-of-range score → retry; twice invalid → null', () async {
      final bad = good.replaceFirst('4', '9');
      final llm = ScriptedLlm([bad, 'nope']);
      expect(
        await PlacementService(llm).evaluate(model: 'm', answers: answers),
        isNull,
      );
      expect(llm.requests, hasLength(2));
    });

    test('retry can recover', () async {
      final llm = ScriptedLlm(['x', good]);
      expect(
        await PlacementService(llm).evaluate(model: 'm', answers: answers),
        isNotNull,
      );
    });
  });
}
