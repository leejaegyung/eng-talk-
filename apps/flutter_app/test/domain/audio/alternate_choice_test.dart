import 'package:flutter_test/flutter_test.dart';
import 'package:speaking_coach/domain/audio/alternate_choice.dart';

void main() {
  const hints = ['Do you prefer hiking or swimming on weekends?', 'Weekends'];

  test('a candidate that fits the question beats a sound-alike', () {
    expect(
      chooseAlternate([
        ('I prefer biking on weekend', 0.62),
        ('I prefer hiking on weekends', 0.58),
      ], hints),
      'I prefer hiking on weekends',
    );
  });

  test('the top one stays when nothing fits better', () {
    expect(
      chooseAlternate([
        ('I like reading books', 0.7),
        ('I like eating books', 0.6),
      ], hints),
      'I like reading books',
    );
  });

  test('a near-certain top result is kept', () {
    expect(
      chooseAlternate([
        ('I prefer biking', 0.95),
        ('I prefer hiking', 0.4),
      ], hints),
      'I prefer biking',
    );
  });

  test('no hints, one candidate or nothing', () {
    expect(chooseAlternate([('a', 0.1), ('b hiking', 0.1)], const []), 'a');
    expect(chooseAlternate([('only', -1)], hints), 'only');
    expect(chooseAlternate(const [], hints), '');
  });
}
