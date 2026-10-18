import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:speaking_coach/domain/feedback/feedback.dart';
import 'package:speaking_coach/domain/learning/mini_lesson.dart';
import 'package:speaking_coach/domain/providers/ai_provider.dart';

import '../../helpers/fakes.dart';

void main() {
  const mistakes = [
    CorrectionExample(
      original: 'I go there yesterday',
      suggested: 'I went there yesterday.',
    ),
    CorrectionExample(
      original: 'She go to school',
      suggested: 'She goes to school.',
    ),
  ];

  String lessonJson({int examples = 3}) => jsonEncode({
    'title_ko': '과거의 일은 과거형으로',
    'explanation_ko': '어제 일처럼 끝난 일은 동사를 과거형으로 바꿔요.',
    'examples': [
      for (var i = 0; i < examples; i++)
        {'en': 'I walked to work $i.', 'ko': '걸어서 출근했어요 $i.'},
    ],
  });

  test('a valid lesson is parsed; examples capped at 3', () async {
    final ai = FakeAi()..reply = [TextDelta(lessonJson(examples: 5))];
    final lesson = await MiniLessonService(ai)
        .write(model: 'm', category: ErrorCategory.grammar, mistakes: mistakes);
    expect(lesson!.titleKo, '과거의 일은 과거형으로');
    expect(lesson.examples, hasLength(3));
    final request = ai.chats.single;
    expect(request.first.content, contains('grammar'));
    expect(request.last.content, contains('I went there yesterday.'));
  });

  test('invalid JSON is retried once, then gives up', () async {
    final ai = FakeAi()..reply = const [TextDelta('Sorry, no JSON here.')];
    final lesson = await MiniLessonService(
      ai,
    ).write(model: 'm', category: ErrorCategory.structure, mistakes: mistakes);
    expect(lesson, isNull);
    expect(ai.chats, hasLength(2));
  });

  test('a lesson without examples is not accepted', () {
    expect(
      MiniLesson.fromJson({
        'title_ko': 't',
        'explanation_ko': 'e',
        'examples': <Object>[],
      }),
      isNull,
    );
  });
}
