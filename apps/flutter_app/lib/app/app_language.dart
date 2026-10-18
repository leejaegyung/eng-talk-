import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/settings/settings_store.dart';
import 'providers.dart';

/// App language (spec §3.1, S11): null follows the device.
final appLanguageProvider = AsyncNotifierProvider<AppLanguage, Locale?>(
  AppLanguage.new,
);

class AppLanguage extends AsyncNotifier<Locale?> {
  static const supported = ['ko', 'en'];

  @override
  Future<Locale?> build() async {
    final code = await ref
        .watch(settingsStoreProvider)
        .read(SettingKeys.appLanguage);
    return supported.contains(code) ? Locale(code!) : null;
  }

  /// [code] is 'ko', 'en' or null for the device language.
  Future<void> set(String? code) async {
    state = AsyncData(supported.contains(code) ? Locale(code!) : null);
    await ref
        .read(settingsStoreProvider)
        .write(SettingKeys.appLanguage, code ?? 'system');
  }
}
