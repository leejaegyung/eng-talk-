import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:speaking_coach/domain/learning/word_order.dart';

void main() {
  test('tiles drop punctuation and keep contractions', () {
    expect(wordTiles("Yesterday, I'm going to the park!"), [
      'Yesterday',
      "I'm",
      'going',
      'to',
      'the',
      'park',
    ]);
  });

  test('shuffled tiles differ from the answer when they can', () {
    final tiles = wordTiles('I went to the park yesterday');
    for (var seed = 0; seed < 20; seed++) {
      final s = shuffledTiles(tiles, Random(seed));
      expect(s..sort(), [...tiles]..sort());
    }
    expect(
      shuffledTiles(tiles, Random(1)).join(' '),
      isNot('I went to the park yesterday'),
    );
    expect(shuffledTiles(['Hi'], Random(1)), ['Hi']);
  });

  test('answer is checked ignoring case and punctuation', () {
    const sentence = 'I went to the park yesterday.';
    expect(
      wordOrderCorrect([
        'i',
        'went',
        'to',
        'the',
        'park',
        'yesterday',
      ], sentence),
      isTrue,
    );
    expect(
      wordOrderCorrect([
        'I',
        'to',
        'went',
        'the',
        'park',
        'yesterday',
      ], sentence),
      isFalse,
    );
    expect(wordOrderCorrect(['I', 'went'], sentence), isFalse);
  });

  test('shared words tell a reorder from a rewrite', () {
    expect(
      sharedWords('I went to the park yesterday', 'Yesterday I went park to'),
      greaterThan(0.8),
    );
    expect(sharedWords('She likes cats', 'I went to the park'), lessThan(0.3));
  });
}
