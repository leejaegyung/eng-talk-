import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/logging/app_logger.dart';
import '../../domain/providers/ai_choice.dart';
import '../../domain/providers/provider_failure.dart';
import '../../domain/settings/settings_store.dart';

final class AiChoiceState {
  const AiChoiceState({
    this.choice = AiChoice.chatGpt,
    this.hasKey,
    this.model,
    this.busy = false,
    this.failure,
    this.geminiSpeech = false,
  });

  final AiChoice choice;

  /// Speech recognized by Gemini from the recording instead of the device.
  final bool geminiSpeech;

  /// The key is needed for chatting with Gemini or for its recognition.
  bool get needsKey => choice == AiChoice.gemini || geminiSpeech;

  /// Null until the vault has been checked.
  final bool? hasKey;

  /// Picked from the account's models once the key works.
  final String? model;
  final bool busy;
  final ProviderFailure? failure;
}

final aiChoiceProvider =
    NotifierProvider.autoDispose<AiChoiceController, AiChoiceState>(
      AiChoiceController.new,
    );

/// Which AI coaches, and the Gemini key (ADR-015). The key
/// goes straight to the vault; it is never kept in state or shown again.
class AiChoiceController extends Notifier<AiChoiceState> {
  static const _log = AppLogger('settings.ai');

  @override
  AiChoiceState build() {
    unawaited(_load());
    return const AiChoiceState();
  }

  Future<void> _load() async {
    final saved = await ref
        .read(settingsStoreProvider)
        .read(SettingKeys.aiProvider);
    final hasKey = await ref.read(geminiAccountProvider).isSignedIn();
    final engine = await ref
        .read(settingsStoreProvider)
        .read(SettingKeys.speechEngine);
    if (!ref.mounted) return;
    state = AiChoiceState(
      choice: AiChoice.values.asNameMap()[saved] ?? AiChoice.chatGpt,
      hasKey: hasKey,
      geminiSpeech: engine == 'gemini',
    );
    if (hasKey) await check();
  }

  Future<void> choose(AiChoice choice) async {
    state = _copy(choice: choice);
    await ref
        .read(settingsStoreProvider)
        .write(SettingKeys.aiProvider, choice.name);
  }

  Future<void> setGeminiSpeech(bool on) async {
    state = _copy(geminiSpeech: on);
    await ref
        .read(settingsStoreProvider)
        .write(SettingKeys.speechEngine, on ? 'gemini' : 'device');
  }

  Future<void> saveKey(String key) async {
    final trimmed = key.trim();
    if (trimmed.isEmpty || state.busy) return;
    await ref.read(credentialVaultProvider).write(geminiKeyRef, trimmed);
    if (!ref.mounted) return;
    state = _copy(hasKey: true);
    await check();
  }

  /// Verifies the key by picking a model from the account's list (no
  /// message is sent, so nothing is billed).
  Future<void> check() async {
    state = _copy(busy: true, clearFailure: true);
    try {
      final model = await ref.read(geminiModelSelectorProvider)();
      if (ref.mounted) state = _copy(model: model, busy: false);
    } on ProviderException catch (e) {
      _log.warning('gemini check failed: $e');
      if (ref.mounted) {
        state = _copy(busy: false, failure: e.failure, clearModel: true);
      }
    }
  }

  Future<void> removeKey() async {
    await ref.read(geminiAccountProvider).signOut();
    if (!ref.mounted) return;
    state = _copy(hasKey: false, clearModel: true, clearFailure: true);
  }

  AiChoiceState _copy({
    AiChoice? choice,
    bool? hasKey,
    String? model,
    bool? busy,
    ProviderFailure? failure,
    bool? geminiSpeech,
    bool clearModel = false,
    bool clearFailure = false,
  }) => AiChoiceState(
    geminiSpeech: geminiSpeech ?? state.geminiSpeech,
    choice: choice ?? state.choice,
    hasKey: hasKey ?? state.hasKey,
    model: clearModel ? null : model ?? state.model,
    busy: busy ?? state.busy,
    failure: clearFailure ? null : failure ?? state.failure,
  );
}
