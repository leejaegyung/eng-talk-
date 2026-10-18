import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/app_language.dart';
import '../../app/providers.dart';
import '../../core/logging/app_logger.dart';
import '../../core/platform/platform_info.dart';
import '../../domain/credentials/provider_account.dart';
import '../../domain/providers/provider_failure.dart';
import '../../domain/sessions/export.dart';
import '../../domain/sessions/session_repository.dart';
import '../../domain/settings/settings_store.dart';
import '../common/goals_controller.dart';
import '../setup/setup_controller.dart';

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
    this.reviewRepeats = 5,
    this.exportedTo,
    this.cleared = false,
    this.errorCount = 0,
    this.restored,
    this.restoreFailed = false,
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
  final int reviewRepeats;

  /// Where the last export was saved.
  final String? exportedTo;
  final bool cleared;

  /// Entries in the local error journal.
  final int errorCount;

  /// Result of the last restore, if any.
  final ImportResult? restored;
  final bool restoreFailed;

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
    int? reviewRepeats,
    String? exportedTo,
    bool? cleared,
    int? errorCount,
    ImportResult? restored,
    bool? restoreFailed,
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
    reviewRepeats: reviewRepeats ?? this.reviewRepeats,
    exportedTo: exportedTo ?? this.exportedTo,
    cleared: cleared ?? this.cleared,
    errorCount: errorCount ?? this.errorCount,
    restored: restored ?? this.restored,
    restoreFailed: restoreFailed ?? this.restoreFailed,
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
    final repeats = int.tryParse(
      await _store.read(SettingKeys.reviewRepeats) ?? '',
    );
    final signedIn = await _account.isSignedIn();
    final errors = (await ref.read(errorJournalProvider).entries()).length;
    if (!ref.mounted) return;
    state = state.copyWith(
      signedIn: signedIn,
      speakReplies: speak,
      handsFree: handsFree,
      confirmSpeech: confirm,
      autoBargeIn: bargeIn,
      reviewRepeats: reviewRepeatOptions.contains(repeats)
          ? repeats
          : reviewRepeatOptions.first,
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
    final data = {
      ...await ref.read(sessionRepositoryProvider).exportAll(),
      'settings': {
        for (final key in backupSettingKeys) key: ?await _store.read(key),
      },
    };
    final at = await ref.read(dataExporterProvider).export(exportFiles(data));
    if (ref.mounted) state = state.copyWith(exportedTo: at);
  }

  /// Restores a backup made by [exportData] (merging; nothing is
  /// overwritten except the listed preferences).
  Future<void> restoreBackup() async {
    final text = await ref.read(backupPickerProvider).pick();
    if (text == null || !ref.mounted) return;
    try {
      // The JSON backup, or the turns CSV (conversations only).
      final json = text.replaceFirst('\uFEFF', '').trimLeft().startsWith('{')
          ? jsonDecode(text.replaceFirst('\uFEFF', ''))
          : backupFromTurnsCsv(text);
      if (json is! Map<String, Object?>) throw const FormatException();
      final result = await ref
          .read(sessionRepositoryProvider)
          .importAll(json, ref.read(clockProvider)());
      if (json['settings'] case final Map<Object?, Object?> saved) {
        for (final key in backupSettingKeys) {
          if (saved[key] case final String value) {
            await _store.write(key, value);
          }
        }
        ref
          ..invalidate(goalsProvider)
          ..invalidate(appLanguageProvider)
          ..invalidate(setupProvider);
      }
      if (ref.mounted) {
        state = state.copyWith(restored: result, restoreFailed: false);
      }
    } on FormatException {
      if (ref.mounted) state = state.copyWith(restoreFailed: true);
    }
  }

  /// The local error journal as a text file (no conversations or keys).
  Future<void> exportDiagnostics() async {
    final entries = await ref.read(errorJournalProvider).entries();
    final text = [
      'Speaking Coach diagnostics',
      'generated: ${DateTime.now().toUtc().toIso8601String()}',
      'platform: ${PlatformInfo.label}',
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

  Future<void> setReviewRepeats(int n) async {
    state = state.copyWith(reviewRepeats: n);
    await _store.write(SettingKeys.reviewRepeats, '$n');
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
