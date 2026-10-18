import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/logging/app_logger.dart';
import '../../domain/providers/ai_choice.dart';
import '../../domain/providers/provider_failure.dart';
import '../../domain/settings/settings_store.dart';

final class ClaudeSettingsState {
  const ClaudeSettingsState({
    this.choice = AiChoice.chatGpt,
    this.hasKey,
    this.model,
    this.busy = false,
    this.failure,
  });

  final AiChoice choice;

  /// Null until the vault has been checked.
  final bool? hasKey;

  /// Picked from the account's models once the key works.
  final String? model;
  final bool busy;
  final ProviderFailure? failure;
}

final claudeSettingsProvider =
    NotifierProvider.autoDispose<ClaudeSettingsController, ClaudeSettingsState>(
      ClaudeSettingsController.new,
    );

/// Which AI coaches, and the Anthropic key for Claude (ADR-014). The key
/// goes straight to the vault; it is never kept in state or shown again.
class ClaudeSettingsController extends Notifier<ClaudeSettingsState> {
  static const _log = AppLogger('settings.claude');

  @override
  ClaudeSettingsState build() {
    unawaited(_load());
    return const ClaudeSettingsState();
  }

  Future<void> _load() async {
    final saved = await ref
        .read(settingsStoreProvider)
        .read(SettingKeys.aiProvider);
    final hasKey = await ref.read(claudeAccountProvider).isSignedIn();
    if (!ref.mounted) return;
    state = ClaudeSettingsState(
      choice: AiChoice.values.asNameMap()[saved] ?? AiChoice.chatGpt,
      hasKey: hasKey,
    );
    if (hasKey) await check();
  }

  Future<void> choose(AiChoice choice) async {
    state = _copy(choice: choice);
    await ref
        .read(settingsStoreProvider)
        .write(SettingKeys.aiProvider, choice.name);
  }

  Future<void> saveKey(String key) async {
    final trimmed = key.trim();
    if (trimmed.isEmpty || state.busy) return;
    await ref.read(credentialVaultProvider).write(claudeKeyRef, trimmed);
    if (!ref.mounted) return;
    state = _copy(hasKey: true);
    await check();
  }

  /// Verifies the key by picking a model from the account's list (no
  /// message is sent, so nothing is billed).
  Future<void> check() async {
    state = _copy(busy: true, clearFailure: true);
    try {
      final model = await ref.read(claudeModelSelectorProvider)();
      if (ref.mounted) state = _copy(model: model, busy: false);
    } on ProviderException catch (e) {
      _log.warning('claude check failed: $e');
      if (ref.mounted) {
        state = _copy(busy: false, failure: e.failure, clearModel: true);
      }
    }
  }

  Future<void> removeKey() async {
    await ref.read(claudeAccountProvider).signOut();
    if (!ref.mounted) return;
    state = _copy(hasKey: false, clearModel: true, clearFailure: true);
  }

  ClaudeSettingsState _copy({
    AiChoice? choice,
    bool? hasKey,
    String? model,
    bool? busy,
    ProviderFailure? failure,
    bool clearModel = false,
    bool clearFailure = false,
  }) => ClaudeSettingsState(
    choice: choice ?? state.choice,
    hasKey: hasKey ?? state.hasKey,
    model: clearModel ? null : model ?? state.model,
    busy: busy ?? state.busy,
    failure: clearFailure ? null : failure ?? state.failure,
  );
}
