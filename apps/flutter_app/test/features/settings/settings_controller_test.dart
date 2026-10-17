import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:speaking_coach/app/providers.dart';
import 'package:speaking_coach/domain/providers/provider_failure.dart';
import 'package:speaking_coach/domain/settings/settings_store.dart';
import 'package:speaking_coach/features/settings/settings_controller.dart';

import '../../helpers/fakes.dart';

void main() {
  late FakeAccount account;
  late MemorySettings settings;
  late ProviderContainer container;
  Object? modelError;

  SettingsController ctrl() => container.read(settingsProvider.notifier);
  SettingsState state() => container.read(settingsProvider);

  ProviderContainer make() {
    final c = ProviderContainer(
      overrides: [
        chatGptAccountProvider.overrideWithValue(account),
        settingsStoreProvider.overrideWithValue(settings),
        chatGptModelSelectorProvider.overrideWithValue(() async {
          if (modelError != null) throw modelError!;
          return 'plan-model';
        }),
      ],
    )..listen(settingsProvider, (_, _) {});
    addTearDown(c.dispose);
    return c;
  }

  setUp(() async {
    account = FakeAccount();
    settings = MemorySettings();
    modelError = null;
    container = make();
    await pumpEventQueue();
  });

  test('loads account status and defaults', () {
    expect(state().signedIn, isFalse);
    expect(state().speakReplies, isTrue);
    expect(state().model, isNull);
  });

  test('signed-in account is checked on open', () async {
    account.signedIn = true;
    container = make();
    await pumpEventQueue();
    expect(state().signedIn, isTrue);
    expect(state().model, 'plan-model');
  });

  test('sign in then out', () async {
    await ctrl().signIn();
    expect(state().signedIn, isTrue);
    expect(state().model, 'plan-model');
    await ctrl().signOut();
    expect(state().signedIn, isFalse);
    expect(state().model, isNull);
    expect(account.signOuts, 1);
  });

  test('connection check reports the plan failure', () async {
    account.signedIn = true;
    modelError = const ProviderException(ProviderFailure.planUsageLimit);
    container = make();
    await pumpEventQueue();
    expect(state().failure, ProviderFailure.planUsageLimit);

    modelError = null;
    await ctrl().checkConnection();
    expect(state().failure, isNull);
    expect(state().model, 'plan-model');
  });

  test('expired sign-in shows signed out', () async {
    account.signedIn = true;
    modelError = const ProviderException(ProviderFailure.signInRequired);
    container = make();
    await pumpEventQueue();
    expect(state().signedIn, isFalse);
    expect(state().failure, ProviderFailure.signInRequired);
  });

  test('read-aloud preference is saved and restored', () async {
    await ctrl().setSpeakReplies(false);
    expect(settings.values[SettingKeys.speakReplies], 'false');
    container = make();
    await pumpEventQueue();
    expect(state().speakReplies, isFalse);
  });
}
