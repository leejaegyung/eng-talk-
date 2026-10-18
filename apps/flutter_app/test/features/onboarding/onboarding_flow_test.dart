import 'package:flutter_test/flutter_test.dart';
import 'package:speaking_coach/domain/providers/provider_failure.dart';
import 'package:speaking_coach/domain/settings/settings_store.dart';

import '../../helpers/app_harness.dart';
import '../../helpers/fakes.dart';

void main() {
  late MemorySettings settings;
  late FakeAccount account;

  setUp(() {
    settings = MemorySettings();
    account = FakeAccount();
  });

  Future<void> toConnectStep(
    WidgetTester tester, {
    Future<void> Function()? onGoals,
  }) async {
    await bootApp(tester, settings: settings, account: account);
    expect(find.text('말하면서 배우는 영어 코치'), findsOneWidget);
    await tester.tap(find.text('다음'));
    await tester.pumpAndSettle();
    expect(find.text('데이터는 이렇게 다뤄요'), findsOneWidget);
    expect(find.textContaining('녹음 원본은 저장하지 않아요'), findsOneWidget);
    await tester.tap(find.text('확인했어요'));
    await tester.pumpAndSettle();
    expect(find.text('학습 목표'), findsOneWidget);
    await onGoals?.call();
    await tester.tap(find.text('다음'));
    await tester.pumpAndSettle();
    expect(find.text('AI 연결'), findsOneWidget);
  }

  testWidgets('fresh install: skip connecting → home, flag saved', (
    tester,
  ) async {
    await toConnectStep(tester);
    await tester.tap(find.text('나중에 할게요'));
    await tester.pumpAndSettle();

    expect(find.text('오늘도 영어로 말해볼까요?'), findsOneWidget);
    expect(settings.values[SettingKeys.onboardingDone], 'true');
  });

  testWidgets('connect with ChatGPT, then start', (tester) async {
    await toConnectStep(tester);
    await tester.tap(find.text('ChatGPT로 로그인'));
    await tester.pumpAndSettle();
    expect(account.signedIn, isTrue);
    expect(find.text('연결됐어요'), findsOneWidget);

    await tester.tap(find.text('시작하기'));
    await tester.pumpAndSettle();
    expect(find.text('오늘도 영어로 말해볼까요?'), findsOneWidget);
  });

  testWidgets('failed sign-in stays on the step and explains', (tester) async {
    account.signInError = const ProviderException(ProviderFailure.network);
    await toConnectStep(tester);
    await tester.tap(find.text('ChatGPT로 로그인'));
    await tester.pumpAndSettle();

    expect(find.textContaining('네트워크'), findsOneWidget);
    expect(find.text('AI 연결'), findsOneWidget);
    expect(settings.values, isEmpty);
  });

  testWidgets('already signed in shows connected', (tester) async {
    account.signedIn = true;
    await toConnectStep(tester);
    expect(find.text('연결됐어요'), findsOneWidget);
  });

  testWidgets('back returns to the previous step', (tester) async {
    await toConnectStep(tester);
    await tester.tap(find.text('이전'));
    await tester.pumpAndSettle();
    expect(find.text('학습 목표'), findsOneWidget);
  });

  testWidgets('goals: saved, then shown on home with a suggested mode', (
    tester,
  ) async {
    await toConnectStep(
      tester,
      onGoals: () async {
        await tester.tap(find.text('여행'));
        await tester.tap(find.text('20분'));
        await tester.pumpAndSettle();
      },
    );
    expect(settings.values[SettingKeys.learningGoal], 'travel');
    expect(settings.values[SettingKeys.dailyGoalMinutes], '20');

    await tester.tap(find.text('나중에 할게요'));
    await tester.pumpAndSettle();
    expect(find.text('오늘 0분 / 목표 20분'), findsOneWidget);
    expect(find.text('여행 목표 추천: 상황 역할극'), findsOneWidget);
  });

  testWidgets('goals can be skipped: no target on home', (tester) async {
    await toConnectStep(tester);
    await tester.tap(find.text('나중에 할게요'));
    await tester.pumpAndSettle();
    expect(find.textContaining('목표'), findsNothing);
    expect(settings.values.containsKey(SettingKeys.learningGoal), isFalse);
  });
}
