import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/settings/settings_store.dart';
import 'providers.dart';

/// Whether first-run onboarding (S01) has been completed. The router
/// redirects on it.
final onboardingDoneProvider = AsyncNotifierProvider<OnboardingGate, bool>(
  OnboardingGate.new,
);

class OnboardingGate extends AsyncNotifier<bool> {
  @override
  Future<bool> build() async =>
      await ref.watch(settingsStoreProvider).read(SettingKeys.onboardingDone) ==
      'true';

  Future<void> complete() async {
    await ref
        .read(settingsStoreProvider)
        .write(SettingKeys.onboardingDone, 'true');
    state = const AsyncData(true);
  }
}
