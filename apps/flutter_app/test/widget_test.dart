import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:speaking_coach/domain/learning/learner_level.dart';
import 'package:speaking_coach/domain/settings/settings_store.dart';

import 'helpers/app_harness.dart';

void main() {
  testWidgets('home: start button, placement card, no data yet', (
    tester,
  ) async {
    await Harness().boot(tester);
    expect(find.text('오늘도 영어로 말해볼까요?'), findsOneWidget);
    expect(find.text('대화 시작'), findsOneWidget);
    expect(find.text('레벨 진단부터 해볼까요?'), findsOneWidget);
    expect(find.text('오늘 말한 시간 (추정)'), findsOneWidget);
    expect(find.text('—'), findsWidgets, reason: 'nothing measured yet');
    expect(find.text('끝나지 않은 대화가 있어요'), findsNothing);
  });

  testWidgets('picking a level by hand settles placement; the test stays', (
    tester,
  ) async {
    final h = Harness();
    await h.boot(tester);
    final pick = find.widgetWithText(OutlinedButton, LearnerLevel.l3.label);
    await tester.ensureVisible(pick);
    await tester.tap(pick);
    await settle(tester);

    expect(h.settings.values[SettingKeys.learnerLevel], 'l3');
    expect(find.text('레벨 진단부터 해볼까요?'), findsNothing);
    await tester.ensureVisible(find.text('레벨 다시 진단'));
    expect(find.text('레벨 다시 진단'), findsOneWidget);
  });

  testWidgets('developer tests (debug builds only) are tucked away', (
    tester,
  ) async {
    await Harness().boot(tester);
    expect(find.text('오디오 테스트 (개발용)'), findsNothing);
    await tester.ensureVisible(find.text('개발용 테스트'));
    await tester.tap(find.text('개발용 테스트'));
    await settle(tester);
    await tester.tap(find.text('오디오 테스트 (개발용)'));
    await settle(tester);
    expect(find.text('녹음'), findsOneWidget);
  });

  testWidgets('home → settings and history', (tester) async {
    await Harness().boot(tester);
    await tester.tap(find.byTooltip('학습 기록'));
    await settle(tester);
    expect(find.text('아직 기록이 없어요.'), findsOneWidget);
    await tester.tap(find.byType(BackButton));
    await settle(tester);
    await tester.tap(find.byIcon(Icons.settings_outlined));
    await settle(tester);
    expect(find.text('ChatGPT 구독'), findsOneWidget);
  });
}
