import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:speaking_coach/domain/settings/settings_store.dart';
import 'package:speaking_coach/features/setup/setup_screen.dart';

import '../helpers/app_harness.dart';
import '../helpers/fakes.dart';

/// Accessibility guidelines (spec §3.3, §16.2) on every main screen:
/// labeled tap targets, minimum target size, text contrast.
void main() {
  Future<Harness> boot(WidgetTester tester) async {
    final h = Harness(
      settings: MemorySettings({
        SettingKeys.onboardingDone: 'true',
        SettingKeys.handsFree: 'false',
        SettingKeys.learningGoal: 'everyday',
        SettingKeys.dailyGoalMinutes: '20',
      }),
    );
    await h.boot(tester);
    return h;
  }

  Future<void> check(WidgetTester tester, String screen) async {
    final failures = <String>[];
    for (final (name, guideline) in [
      ('labeled', labeledTapTargetGuideline),
      ('android tap target', androidTapTargetGuideline),
      ('text contrast', textContrastGuideline),
    ]) {
      final result = await guideline.evaluate(tester);
      if (!result.passed) failures.add('[$screen/$name] ${result.reason}');
    }
    expect(failures, isEmpty, reason: failures.join('\n\n'));
  }

  Future<void> open(WidgetTester tester, Finder f) async {
    // Lazily built lists: drag the top screen's list until it exists.
    for (var i = 0; i < 20 && f.evaluate().isEmpty; i++) {
      await tester.drag(find.byType(ListView).last, const Offset(0, -300));
      await settle(tester);
    }
    await tester.ensureVisible(f.first);
    await tester.pump();
    await tester.tap(f.first);
    await settle(tester);
  }

  testWidgets('home', (tester) async {
    final handle = tester.ensureSemantics();
    await boot(tester);
    await check(tester, 'home');
    handle.dispose();
  });

  testWidgets('setup and conversation', (tester) async {
    final handle = tester.ensureSemantics();
    await boot(tester);
    await open(tester, find.text('대화 시작'));
    await check(tester, 'setup');
    await open(tester, find.widgetWithText(FilledButton, '대화 시작'));
    await check(tester, 'conversation');
    handle.dispose();
  });

  testWidgets('growth, history, settings, review', (tester) async {
    final handle = tester.ensureSemantics();
    await boot(tester);
    for (final (tooltip, name) in [('성장 기록', 'growth'), ('학습 기록', 'history')]) {
      await open(tester, find.byTooltip(tooltip));
      await check(tester, name);
      await open(tester, find.byType(BackButton));
    }
    await open(tester, find.byIcon(Icons.settings_outlined));
    await check(tester, 'settings');
    await open(tester, find.byType(BackButton));
    await open(tester, find.text('복습할 문장'));
    await check(tester, 'review');
    handle.dispose();
  });

  testWidgets('placement', (tester) async {
    final handle = tester.ensureSemantics();
    await boot(tester);
    await open(tester, find.text('진단 시작'));
    await check(tester, 'placement');
    handle.dispose();
  });

  testWidgets('dark mode: contrast on home and conversation', (tester) async {
    final handle = tester.ensureSemantics();
    tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
    addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
    await boot(tester);
    await check(tester, 'home (dark)');
    await open(tester, find.text('대화 시작'));
    await open(tester, find.widgetWithText(FilledButton, '대화 시작'));
    await check(tester, 'conversation (dark)');
    handle.dispose();
  });

  testWidgets('large text (2x) at phone width: nothing overflows', (
    tester,
  ) async {
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await boot(tester);
    tester.view.physicalSize = const Size(390, 844);
    await settle(tester);
    await open(tester, find.byTooltip('성장 기록'));
    await open(tester, find.byType(BackButton));
    await open(tester, find.text('대화 시작'));
    // The setup's own start button, not the home hero below it.
    final start = find.descendant(
      of: find.byType(SetupScreen),
      matching: find.text('대화 시작'),
    );
    await open(tester, start);
    expect(find.text('Nice! Where do you hike?'), findsOneWidget);
  });

  testWidgets('screen reader: who said each line, live status', (tester) async {
    final handle = tester.ensureSemantics();
    await boot(tester);
    await open(tester, find.text('대화 시작'));
    await open(
      tester,
      find.descendant(
        of: find.byType(SetupScreen),
        matching: find.text('대화 시작'),
      ),
    );
    expect(
      find.bySemanticsLabel('코치: Nice! Where do you hike?'),
      findsOneWidget,
    );
    await tester.enterText(find.byType(TextField), 'I like hiking.');
    await tester.tap(find.text('보내기'));
    await settle(tester);
    expect(find.bySemanticsLabel('나: I like hiking.'), findsOneWidget);
    final status = tester.getSemantics(find.textContaining('내 차례예요'));
    expect(status.flagsCollection.isLiveRegion, isTrue);
    handle.dispose();
  });
}
