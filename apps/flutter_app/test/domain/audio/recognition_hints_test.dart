import 'package:flutter_test/flutter_test.dart';
import 'package:speaking_coach/domain/audio/recognition_hints.dart';

void main() {
  test('short phrases are kept whole, then their words', () {
    expect(recognitionHints(phrases: ['Hotel check-in']), [
      'Hotel check-in',
      'Hotel',
      'check-in',
    ]);
  });

  test('long phrases contribute only their words', () {
    final hints = recognitionHints(
      phrases: ['Ask the front desk for a late checkout'],
    );
    expect(hints, isNot(contains('Ask the front desk for a late checkout')));
    expect(hints, containsAll(['front', 'desk', 'late', 'checkout']));
  });

  test('content words from coach lines, without common or short words', () {
    final hints = recognitionHints(
      texts: ['That sounds fun! What kind of hiking trails do you like?'],
    );
    expect(hints, ['sounds', 'kind', 'hiking', 'trails']);
  });

  test('deduplicated ignoring case, capped, in priority order', () {
    final hints = recognitionHints(
      texts: ['Seoul hiking', 'seoul Hiking mountains'],
      max: 2,
    );
    expect(hints, ['Seoul', 'hiking']);
  });

  test('blank input gives no hints', () {
    expect(recognitionHints(phrases: ['  '], texts: ['', 'a to I']), isEmpty);
  });
}
