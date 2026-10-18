import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:speaking_coach/app/app.dart';
import 'package:speaking_coach/app/notifying_session_repository.dart';
import 'package:speaking_coach/app/providers.dart';
import 'package:speaking_coach/data/sessions/drift_session_repository.dart';
import 'package:speaking_coach/domain/settings/settings_store.dart';

import 'fakes.dart';

/// Everything the app touches, faked or in memory.
class Harness {
  Harness({MemorySettings? settings, FakeAccount? account})
    : settings =
          settings ??
          MemorySettings({
            SettingKeys.onboardingDone: 'true',
            SettingKeys.handsFree: 'false',
          }),
      account = account ?? (FakeAccount()..signedIn = true) {
    ai.responder = smartReplies;
    final (db, repo) = memoryRepository();
    this.repo = repo;
    addTearDown(db.close);
  }

  final MemorySettings settings;
  final FakeAccount account;
  final ai = FakeAi();
  final mic = FakeSpeechInput();
  final voice = FakeSpeechOutput();
  final vault = MemoryVault();
  final exporter = CapturingExporter();
  late final DriftSessionRepository repo;
  DateTime now = DateTime(2026, 10, 17, 9);
  Future<String> Function() selectModel = () async => 'plan-model';

  List<Override> get overrides => [
    settingsStoreProvider.overrideWithValue(settings),
    chatGptAccountProvider.overrideWithValue(account),
    chatGptLlmProvider.overrideWithValue(ai),
    chatGptModelSelectorProvider.overrideWith(
      (ref) =>
          () => selectModel(),
    ),
    speechInputProvider.overrideWithValue(mic),
    speechOutputProvider.overrideWithValue(voice),
    credentialVaultProvider.overrideWithValue(vault),
    dataExporterProvider.overrideWithValue(exporter),
    clockProvider.overrideWithValue(() => now),
    sessionRepositoryProvider.overrideWith(
      (ref) => NotifyingSessionRepository(
        repo,
        () => ref.read(dataVersionProvider.notifier).bump(),
      ),
    ),
  ];

  /// Pumps the whole app in Korean.
  Future<void> boot(WidgetTester tester) async {
    tester.platformDispatcher.localesTestValue = const [Locale('ko')];
    addTearDown(tester.platformDispatcher.clearLocalesTestValue);
    tester.view.physicalSize = const Size(1000, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ProviderScope(overrides: overrides, child: const SpeakingCoachApp()),
    );
    await settle(tester);
  }
}

/// Like pumpAndSettle, but finite: the conversation clock ticks forever.
Future<void> settle(WidgetTester tester) async {
  for (var i = 0; i < 20; i++) {
    await tester.pump(const Duration(milliseconds: 50));
  }
}

/// Boots with the given settings and account (signed out by default).
Future<Harness> bootApp(
  WidgetTester tester, {
  required MemorySettings settings,
  FakeAccount? account,
  Future<String> Function()? selectModel,
}) async {
  final h = Harness(settings: settings, account: account ?? FakeAccount());
  if (selectModel != null) h.selectModel = selectModel;
  await h.boot(tester);
  return h;
}
