import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:speaking_coach/domain/providers/provider_failure.dart';
import 'package:speaking_coach/domain/settings/settings_store.dart';

import '../../helpers/app_harness.dart';
import '../../helpers/fakes.dart';

void main() {
  final onboarded = {SettingKeys.onboardingDone: 'true'};

  Future<void> openSettings(
    WidgetTester tester, {
    FakeAccount? account,
    Future<String> Function()? selectModel,
  }) async {
    await bootApp(
      tester,
      settings: MemorySettings(onboarded),
      account: account,
      selectModel: selectModel,
    );
    await tester.tap(find.byTooltip('설정'));
    await tester.pumpAndSettle();
  }

  testWidgets('home → settings shows the account and voice sections', (
    tester,
  ) async {
    await openSettings(tester);
    expect(find.text('설정'), findsOneWidget);
    expect(find.text('ChatGPT로 로그인'), findsOneWidget);
    expect(find.text('답변 소리로 듣기'), findsOneWidget);
  });

  testWidgets('signed in shows the model and sign out', (tester) async {
    await openSettings(
      tester,
      account: FakeAccount()..signedIn = true,
      selectModel: () async => 'plan-model',
    );
    expect(find.textContaining('plan-model'), findsOneWidget);
    await tester.tap(find.text('로그아웃'));
    await tester.pumpAndSettle();
    expect(find.text('ChatGPT로 로그인'), findsOneWidget);
  });

  // spec §11: distinguish the failure kinds in the message.
  for (final (failure, text) in [
    (ProviderFailure.signInRequired, '다시 로그인'),
    (ProviderFailure.planNotEligible, 'Plus 또는 Pro'),
    (ProviderFailure.planUsageLimit, '사용 한도'),
    (ProviderFailure.network, '네트워크'),
  ]) {
    testWidgets('connection failure: ${failure.name}', (tester) async {
      await openSettings(
        tester,
        account: FakeAccount()..signedIn = true,
        selectModel: () async => throw ProviderException(failure),
      );
      expect(find.textContaining(text), findsOneWidget);
    });
  }

  testWidgets('licenses page opens', (tester) async {
    await openSettings(tester);
    await tester.scrollUntilVisible(find.text('오픈소스 라이선스'), 100);
    await tester.ensureVisible(find.text('오픈소스 라이선스'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('오픈소스 라이선스'));
    await tester.pumpAndSettle();
    expect(find.byType(LicensePage), findsOneWidget);
  });
}
