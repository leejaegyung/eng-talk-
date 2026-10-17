import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:speaking_coach/app/app.dart';
import 'package:speaking_coach/app/providers.dart';

import 'fakes.dart';

/// Pumps the whole app in Korean with in-memory settings and account.
Future<void> bootApp(
  WidgetTester tester, {
  required MemorySettings settings,
  FakeAccount? account,
}) async {
  tester.platformDispatcher.localesTestValue = const [Locale('ko')];
  addTearDown(tester.platformDispatcher.clearLocalesTestValue);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        settingsStoreProvider.overrideWithValue(settings),
        chatGptAccountProvider.overrideWithValue(account ?? FakeAccount()),
      ],
      child: const SpeakingCoachApp(),
    ),
  );
  await tester.pumpAndSettle();
}
