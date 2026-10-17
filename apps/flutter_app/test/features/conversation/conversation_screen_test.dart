import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:speaking_coach/app/app.dart';
import 'package:speaking_coach/app/providers.dart';
import 'package:speaking_coach/domain/settings/settings_store.dart';

import '../../helpers/fakes.dart';

void main() {
  late FakeAi ai;

  Future<void> start(WidgetTester tester, {bool signedIn = true}) async {
    tester.platformDispatcher.localesTestValue = const [Locale('ko')];
    addTearDown(tester.platformDispatcher.clearLocalesTestValue);
    ai = FakeAi();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          settingsStoreProvider.overrideWithValue(
            MemorySettings({SettingKeys.onboardingDone: 'true'}),
          ),
          chatGptAccountProvider.overrideWithValue(
            FakeAccount()..signedIn = signedIn,
          ),
          chatGptLlmProvider.overrideWithValue(ai),
          chatGptModelSelectorProvider.overrideWithValue(() async => 'm'),
          speechInputProvider.overrideWithValue(FakeSpeechInput()),
          speechOutputProvider.overrideWithValue(FakeSpeechOutput()),
        ],
        child: const SpeakingCoachApp(),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('대화 시작'));
    // The session ticker keeps scheduling frames; pump instead of settle.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
  }

  testWidgets('home → conversation: AI opens, quick actions, no score', (
    tester,
  ) async {
    await start(tester);
    expect(find.text('일상 대화 · L2'), findsOneWidget);
    expect(find.text('Nice! Where do you hike?'), findsOneWidget);
    for (final label in ['힌트', '다시 말해줘', '천천히', '이 문장 교정', '주제 변경']) {
      expect(find.text(label), findsOneWidget, reason: label);
    }
    expect(find.textContaining('점수'), findsNothing);

    await tester.tap(find.widgetWithText(ActionChip, '힌트'));
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('Could you give me a hint?'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'I like mountains.');
    await tester.tap(find.text('보내기'));
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('I like mountains.'), findsOneWidget);

    await tester.tap(find.text('종료'));
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('대화를 마쳤어요'), findsOneWidget);
    expect(find.textContaining('내 답변 1회'), findsOneWidget);
  });

  testWidgets('subtitles can be hidden', (tester) async {
    await start(tester);
    await tester.tap(find.byTooltip('자막 숨기기'));
    await tester.pump();
    expect(find.text('Nice! Where do you hike?'), findsNothing);
    expect(find.textContaining('자막을 숨겼어요'), findsOneWidget);
    await tester.tap(find.text('종료'));
    await tester.pump();
  });

  testWidgets('not connected → points to settings', (tester) async {
    await start(tester, signedIn: false);
    expect(find.text('대화하려면 AI 연결이 필요해요.'), findsOneWidget);
    await tester.tap(find.text('설정에서 연결하기'));
    await tester.pumpAndSettle();
    expect(find.text('ChatGPT 구독'), findsOneWidget);
  });
}
