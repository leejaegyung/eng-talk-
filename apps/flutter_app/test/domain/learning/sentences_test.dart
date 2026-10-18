import 'package:flutter_test/flutter_test.dart';
import 'package:speaking_coach/domain/learning/sentences.dart';

void main() {
  test('splits on sentence ends, keeps abbreviations', () {
    expect(
      splitSentences("Nice to meet you, Mr. Kim! Where are you from? I'm Ann."),
      ['Nice to meet you, Mr. Kim!', 'Where are you from?', "I'm Ann."],
    );
  });

  test('shadowing keeps longer sentences once, capped', () {
    final s = shadowingSentences([
      'Great! What did you do last weekend?',
      'Oh nice. What did you do last weekend? Tell me more about the trip.',
    ], max: 2);
    expect(s, [
      'What did you do last weekend?',
      'Tell me more about the trip.',
    ]);
  });
}
