import 'dart:async';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/logging/app_logger.dart';
import '../../domain/credentials/provider_account.dart';
import '../../domain/providers/provider_failure.dart';
import '../../domain/sessions/export.dart';
import '../../domain/settings/settings_store.dart';

final class SettingsState {
  const SettingsState({
    this.signedIn,
    this.busy = false,
    this.model,
    this.failure,
    this.speakReplies = true,
    this.handsFree = true,
    this.confirmSpeech = false,
    this.autoBargeIn = false,
    this.exportedTo,
    this.cleared = false,
    this.errorCount = 0,
  });

  /// Null until the stored session has been checked.
  final bool? signedIn;
  final bool busy;

  /// Plan model picked automatically; set once the connection is verified.
  final String? model;
  final ProviderFailure? failure;
  final bool speakReplies;
  final bool handsFree;
  final bool confirmSpeech;
  final bool autoBargeIn;

  /// Where the last export was saved.
  final String? exportedTo;
  final bool cleared;

  /// Entries in the local error journal.
  final int errorCount;

  static const _unset = Object();

  SettingsState copyWith({
    bool? signedIn,
    bool? busy,
    Object? model = _unset,
    Object? failure = _unset,
    bool? speakReplies,
    bool? handsFree,
    bool? confirmSpeech,
    bool? autoBargeIn,
    String? exportedTo,
    bool? cleared,
    int? errorCount,
  }) => SettingsState(
    signedIn: signedIn ?? this.signedIn,
    busy: busy ?? this.busy,
    model: identical(model, _unset) ? this.model : model as String?,
    failure: identical(failure, _unset)
        ? this.failure
        : failure as ProviderFailure?,
    speakReplies: speakReplies ?? this.speakReplies,
    handsFree: handsFree ?? this.handsFree,
    confirmSpeech: confirmSpeech ?? this.confirmSpeech,
    autoBargeIn: autoBargeIn ?? this.autoBargeIn,
    exportedTo: exportedTo ?? this.exportedTo,
    cleared: cleared ?? this.cleared,
    errorCount: errorCount ?? this.errorCount,
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
    final handsFree = await _store.read(SettingKeys.handsFree) != 'false';
    final confirm = await _store.read(SettingKeys.confirmSpeech) == 'true';
    final bargeIn = await _store.read(SettingKeys.autoBargeIn) == 'true';
    final signedIn = await _account.isSignedIn();
    final errors = (await ref.read(errorJournalProvider).entries()).length;
    if (!ref.mounted) return;
    state = state.copyWith(
      signedIn: signedIn,
      speakReplies: speak,
      handsFree: handsFree,
      confirmSpeech: confirm,
      autoBargeIn: bargeIn,
      errorCount: errors,
    );
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

  /// JSON + CSV of all sessions; credentials are never included (S1).
  Future<void> exportData() async {
    final data = await ref.read(sessionRepositoryProvider).exportAll();
    final at = await ref.read(dataExporterProvider).export(exportFiles(data));
    if (ref.mounted) state = state.copyWith(exportedTo: at);
  }

  /// The local error journal as a text file (no conversations or keys).
  Future<void> exportDiagnostics() async {
    final entries = await ref.read(errorJournalProvider).entries();
    final text = [
      'Speaking Coach diagnostics',
      'generated: ${DateTime.now().toUtc().toIso8601String()}',
      'platform: ${Platform.operatingSystem} ${Platform.operatingSystemVersion}',
      'errors: ${entries.length}',
      '',
      for (final e in entries) ...[
        '[${e.at.toUtc().toIso8601String()}] ${e.source} ${e.type}: ${e.message}',
        for (final f in e.frames) '    at $f',
      ],
    ].join('\n');
    final at = await ref.read(dataExporterProvider).export({
      'speaking-coach-diagnostics.txt': text,
    });
    if (ref.mounted) state = state.copyWith(exportedTo: at);
  }

  Future<void> clearErrors() async {
    await ref.read(errorJournalProvider).clear();
    if (ref.mounted) state = state.copyWith(errorCount: 0);
  }

  /// Deletes every session, transcript, correction, review and assessment.
  /// Sign-in and preferences are kept.
  Future<void> deleteAllData() async {
    await ref.read(sessionRepositoryProvider).deleteAll();
    if (ref.mounted) state = state.copyWith(cleared: true);
  }

  Future<void> setHandsFree(bool on) async {
    state = state.copyWith(handsFree: on);
    await _store.write(SettingKeys.handsFree, '$on');
  }

  Future<void> setAutoBargeIn(bool on) async {
    state = state.copyWith(autoBargeIn: on);
    await _store.write(SettingKeys.autoBargeIn, '$on');
  }

  Future<void> setConfirmSpeech(bool on) async {
    state = state.copyWith(confirmSpeech: on);
    await _store.write(SettingKeys.confirmSpeech, '$on');
  }

  Future<void> setSpeakReplies(bool on) async {
    state = state.copyWith(speakReplies: on);
    await _store.write(SettingKeys.speakReplies, '$on');
  }
}
