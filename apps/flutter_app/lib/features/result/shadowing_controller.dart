import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../domain/conversation/session_enums.dart';
import '../../domain/learning/sentences.dart';
import '../../domain/learning/word_order.dart';
import '../../domain/settings/settings_store.dart';

final class ShadowingState {
  const ShadowingState({
    this.sentences = const [],
    this.repeats = 5,
    this.heard = const {},
    this.checks = const {},
    this.listeningTo,
    this.playing,
  });

  /// The coach's sentences from the session, to listen to and repeat.
  final List<String> sentences;
  final int repeats;

  /// By sentence index.
  final Map<int, String> heard;
  final Map<int, List<bool>> checks;
  final int? listeningTo;
  final int? playing;

  bool get busy => listeningTo != null;
  List<bool> checksOf(int i) => checks[i] ?? List.filled(repeats, false);

  ShadowingState copyWith({
    List<String>? sentences,
    int? repeats,
    Map<int, String>? heard,
    Map<int, List<bool>>? checks,
    int? listeningTo,
    int? playing,
    bool clearListening = false,
    bool clearPlaying = false,
  }) => ShadowingState(
    sentences: sentences ?? this.sentences,
    repeats: repeats ?? this.repeats,
    heard: heard ?? this.heard,
    checks: checks ?? this.checks,
    listeningTo: clearListening ? null : listeningTo ?? this.listeningTo,
    playing: clearPlaying ? null : playing ?? this.playing,
  );
}

final shadowingProvider = NotifierProvider.autoDispose
    .family<ShadowingController, ShadowingState, int>(ShadowingController.new);

/// Listen to the coach's sentences and say them back (user request
/// 2026-10-18), with the same repeat boxes as review.
class ShadowingController extends Notifier<ShadowingState> {
  ShadowingController(this.sessionId);

  final int sessionId;

  @override
  ShadowingState build() {
    final mic = ref.watch(speechInputProvider);
    final voice = ref.watch(speechOutputProvider);
    ref.onDispose(() {
      unawaited(mic.stop());
      unawaited(voice.stop());
    });
    unawaited(_load());
    return const ShadowingState();
  }

  Future<void> _load() async {
    final detail = await ref.read(sessionRepositoryProvider).load(sessionId);
    final repeats = int.tryParse(
      await ref.read(settingsStoreProvider).read(SettingKeys.reviewRepeats) ??
          '',
    );
    if (!ref.mounted || detail == null) return;
    state = state.copyWith(
      sentences: shadowingSentences([
        for (final t in detail.turns)
          if (t.speaker == Speaker.assistant) t.text,
      ]),
      repeats: reviewRepeatOptions.contains(repeats)
          ? repeats
          : reviewRepeatOptions.first,
    );
  }

  /// Reads sentence [i] aloud, normally or slowly.
  Future<void> play(int i, {bool slow = false}) async {
    if (state.busy) return;
    final voice = ref.read(speechOutputProvider);
    await voice.stop();
    state = state.copyWith(playing: i);
    await voice.speak(state.sentences[i], slow: slow);
    if (ref.mounted) state = state.copyWith(clearPlaying: true);
  }

  /// Say sentence [i] back; a word-for-word repeat fills a box. No hints,
  /// so the check isn't helped along.
  Future<void> practice(int i) async {
    final mic = ref.read(speechInputProvider);
    if (state.busy || !await mic.ensureAvailable()) return;
    if (!ref.mounted) return;
    await ref.read(speechOutputProvider).stop();
    state = state.copyWith(listeningTo: i, clearPlaying: true);
    final heard = (await mic.listenOnce()).trim();
    if (!ref.mounted) return;
    state = state.copyWith(
      heard: {...state.heard, i: heard},
      clearListening: true,
    );
    if (saidAsCorrected(heard, state.sentences[i])) {
      final boxes = [...state.checksOf(i)];
      final next = boxes.indexOf(false);
      if (next >= 0) boxes[next] = true;
      state = state.copyWith(checks: {...state.checks, i: boxes});
    }
  }

  void toggle(int i, int box) {
    final boxes = [...state.checksOf(i)];
    boxes[box] = !boxes[box];
    state = state.copyWith(checks: {...state.checks, i: boxes});
  }
}
