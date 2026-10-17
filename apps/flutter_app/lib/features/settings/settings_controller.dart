import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/logging/app_logger.dart';
import '../../domain/credentials/provider_account.dart';
import '../../domain/providers/provider_failure.dart';
import '../../domain/settings/settings_store.dart';

final class SettingsState {
  const SettingsState({
    this.signedIn,
    this.busy = false,
    this.model,
    this.failure,
    this.speakReplies = true,
  });

  /// Null until the stored session has been checked.
  final bool? signedIn;
  final bool busy;

  /// Plan model picked automatically; set once the connection is verified.
  final String? model;
  final ProviderFailure? failure;
  final bool speakReplies;

  static const _unset = Object();

  SettingsState copyWith({
    bool? signedIn,
    bool? busy,
    Object? model = _unset,
    Object? failure = _unset,
    bool? speakReplies,
  }) => SettingsState(
    signedIn: signedIn ?? this.signedIn,
    busy: busy ?? this.busy,
    model: identical(model, _unset) ? this.model : model as String?,
    failure: identical(failure, _unset)
        ? this.failure
        : failure as ProviderFailure?,
    speakReplies: speakReplies ?? this.speakReplies,
  );
}

final settingsProvider =
    NotifierProvider.autoDispose<SettingsController, SettingsState>(
      SettingsController.new,
    );

/// S02/S11: AI connection (ChatGPT plan, ADR-011) and preferences.
class SettingsController extends Notifier<SettingsState> {
  static const _log = AppLogger('settings');

  late ProviderAccount _account;
  late SettingsStore _store;
  late Future<String> Function() _selectModel;

  @override
  SettingsState build() {
    _account = ref.watch(chatGptAccountProvider);
    _store = ref.watch(settingsStoreProvider);
    _selectModel = ref.watch(chatGptModelSelectorProvider);
    unawaited(_load());
    return const SettingsState();
  }

  Future<void> _load() async {
    final speak = await _store.read(SettingKeys.speakReplies) != 'false';
    final signedIn = await _account.isSignedIn();
    if (!ref.mounted) return;
    state = state.copyWith(signedIn: signedIn, speakReplies: speak);
    if (signedIn) await checkConnection();
  }

  /// Verifies the plan works by picking a model (spec S02 connection test).
  Future<void> checkConnection() async {
    state = state.copyWith(busy: true, failure: null);
    try {
      final model = await _selectModel();
      if (ref.mounted) state = state.copyWith(model: model);
    } on ProviderException catch (e) {
      _log.warning('connection check failed: $e');
      if (!ref.mounted) return;
      state = e.failure == ProviderFailure.signInRequired
          ? state.copyWith(signedIn: false, model: null, failure: e.failure)
          : state.copyWith(failure: e.failure);
    } finally {
      if (ref.mounted) state = state.copyWith(busy: false);
    }
  }

  Future<void> signIn() async {
    if (state.busy) return;
    state = state.copyWith(busy: true, failure: null);
    try {
      await _account.signIn();
      if (!ref.mounted) return;
      state = state.copyWith(signedIn: true);
      await checkConnection();
    } on ProviderException catch (e) {
      _log.warning('sign-in failed: $e');
      if (ref.mounted) state = state.copyWith(failure: e.failure);
    } finally {
      if (ref.mounted) state = state.copyWith(busy: false);
    }
  }

  Future<void> signOut() async {
    await _account.signOut();
    if (ref.mounted) {
      state = state.copyWith(signedIn: false, model: null, failure: null);
    }
  }

  Future<void> setSpeakReplies(bool on) async {
    state = state.copyWith(speakReplies: on);
    await _store.write(SettingKeys.speakReplies, '$on');
  }
}
