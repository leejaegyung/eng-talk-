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

  test('said as corrected: same words, same order', () {
    const target = 'I like the seafood there very much.';
    expect(
      saidAsCorrected('i like the seafood there very much', target),
      isTrue,
    );
    expect(
      saidAsCorrected('Very much I like the seafood there', target),
      isFalse,
    );
    expect(saidAsCorrected('', target), isFalse);
  });

  test('shared words tell a reorder from a rewrite', () {
    expect(
      sharedWords('I went to the park yesterday', 'Yesterday I went park to'),
      greaterThan(0.8),
    );
    expect(sharedWords('She likes cats', 'I went to the park'), lessThan(0.3));
  });
}
