import 'package:flutter_test/flutter_test.dart';
import 'package:speaking_coach/domain/feedback/feedback.dart';
import 'package:speaking_coach/domain/learning/focus.dart';
import 'package:speaking_coach/domain/sessions/growth_stats.dart';

void main() {
  final now = DateTime(2026, 10, 18, 12);
  List<CorrectionStat> many(ErrorCategory? c, int n, {int daysAgo = 1}) => [
    for (var i = 0; i < n; i++)
      CorrectionStat(now.subtract(Duration(days: daysAgo)), c),
  ];

  group('focusArea', () {
    test('needs at least three in the last two weeks', () {
      expect(focusArea(many(ErrorCategory.grammar, 2), now), isNull);
      expect(
        focusArea(many(ErrorCategory.grammar, 3), now),
        ErrorCategory.grammar,
      );
      expect(
        focusArea(many(ErrorCategory.grammar, 5, daysAgo: 20), now),
        isNull,
      );
    });

    test('most frequent wins; unclassified ignored', () {
      expect(
        focusArea([
          ...many(ErrorCategory.grammar, 3),
          ...many(ErrorCategory.wordChoice, 4),
          ...many(null, 9),
        ], now),
        ErrorCategory.wordChoice,
      );
    });
  });

  group('usedExpression', () {
    test('matches whole words, ignoring case and punctuation', () {
      expect(
        usedExpression('That reminds me of my trip!', 'That reminds me of...'),
        isTrue,
      );
      expect(
        usedExpression('i booked a room for two', 'I booked a room for'),
        isTrue,
      );
      expect(
        usedExpression('It reminds me of home', 'That reminds me of'),
        isFalse,
      );
      expect(usedExpression('anything', '...'), isFalse);
    });
  });
}
