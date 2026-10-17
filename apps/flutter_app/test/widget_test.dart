import 'package:flutter_test/flutter_test.dart';
import 'package:speaking_coach/domain/settings/settings_store.dart';

import 'helpers/app_harness.dart';
import 'helpers/fakes.dart';

void main() {
  final onboarded = {SettingKeys.onboardingDone: 'true'};

  testWidgets('onboarded app boots to the home screen in Korean', (
    tester,
  ) async {
    await bootApp(tester, settings: MemorySettings(onboarded));

    expect(find.text('오늘도 영어로 말해볼까요?'), findsOneWidget);
    expect(find.text('대화 시작'), findsOneWidget);
  });

  testWidgets('home opens the audio test screen', (tester) async {
    await bootApp(tester, settings: MemorySettings(onboarded));
    await tester.tap(find.text('오디오 테스트 (개발용)'));
    await tester.pumpAndSettle();

    expect(find.text('오디오 테스트'), findsOneWidget);
    expect(find.text('녹음'), findsOneWidget);
  });
}
