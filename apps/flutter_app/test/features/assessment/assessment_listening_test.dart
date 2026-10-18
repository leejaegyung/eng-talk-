import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:speaking_coach/features/assessment/assessment_controller.dart';

import '../../helpers/app_harness.dart';

void main() {
  late Harness h;
  late ProviderContainer c;

  AssessmentController ctrl() => c.read(assessmentProvider.notifier);
  AssessmentState state() => c.read(assessmentProvider);

  setUp(() async {
    h = Harness();
    c = ProviderContainer(overrides: h.overrides)
      ..listen(assessmentProvider, (_, _) {});
    addTearDown(c.dispose);
    await ctrl().next(); // to question 1
  });

  test('keeps listening across pauses and joins the parts', () async {
    h.mic.queue.addAll(['I live in Seoul', 'and I work at a bank']);
    await ctrl().talk();
    expect(state().currentAnswer, 'I live in Seoul and I work at a bank');
    expect(state().listening, isFalse);
    expect(h.mic.hints, hasLength(3), reason: 'two parts, then silence');
    expect(h.mic.hints[1], contains('Seoul'), reason: 'earlier words hint');
  });

  test('stop ends it after the current part', () async {
    h.mic.queue.addAll(['First part', 'never heard']);
    final talking = ctrl().talk();
    await ctrl().stopListening();
    await talking;
    expect(state().currentAnswer, 'First part');
    expect(h.mic.queue, ['never heard']);
  });

  test('what was typed stays in front of what is said', () async {
    ctrl().setAnswer('My name is Kim.');
    h.mic.queue.add('I like hiking');
    await ctrl().talk();
    expect(state().currentAnswer, 'My name is Kim. I like hiking');
  });
}
