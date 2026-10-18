import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../domain/feedback/feedback.dart';
import '../../domain/learning/word_order.dart';
import '../../domain/sessions/review_schedule.dart';
import '../../domain/sessions/session_records.dart';
import '../../domain/settings/settings_store.dart';

final class ReviewState {
  const ReviewState({
    this.items,
    this.heard = const {},
    this.listeningTo,
    this.expressions = const [],
    this.expressionHeard = const {},
    this.listeningToExpression,
    this.repeats = 5,
    this.checks = const {},
  });

  /// Null while loading.
  final List<ReviewItem>? items;
  final Map<int, String> heard;
  final int? listeningTo;

  /// Recently suggested expressions to say in a sentence (P2-4).
  final List<Expression> expressions;

  /// By index in [expressions].
  final Map<int, String> expressionHeard;
  final int? listeningToExpression;

  /// Repetitions per sentence (setting), and the boxes ticked so far by
  /// review item id — kept while this screen is open.
  final int repeats;
  final Map<int, List<bool>> checks;

  List<bool> checksOf(int id) => checks[id] ?? List.filled(repeats, false);
  int doneCount(int id) => checksOf(id).where((c) => c).length;
  bool repeatedEnough(int id) => doneCount(id) >= repeats;

  bool get busy => listeningTo != null || listeningToExpression != null;

  ReviewState copyWith({
    List<ReviewItem>? items,
    Map<int, String>? heard,
    int? listeningTo,
    List<Expression>? expressions,
    Map<int, String>? expressionHeard,
    int? listeningToExpression,
    int? repeats,
    Map<int, List<bool>>? checks,
    bool clearListening = false,
  }) => ReviewState(
    items: items ?? this.items,
    heard: heard ?? this.heard,
    listeningTo: clearListening ? null : listeningTo ?? this.listeningTo,
    expressions: expressions ?? this.expressions,
    expressionHeard: expressionHeard ?? this.expressionHeard,
    listeningToExpression: clearListening
        ? null
        : listeningToExpression ?? this.listeningToExpression,
    repeats: repeats ?? this.repeats,
    checks: checks ?? this.checks,
  );
}

final reviewProvider =
    NotifierProvider.autoDispose<ReviewController, ReviewState>(
      ReviewController.new,
    );

/// Spaced "say it again" review of past corrections (spec §12.3).
class ReviewController extends Notifier<ReviewState> {
  @override
  ReviewState build() {
    final mic = ref.watch(speechInputProvider);
    ref.onDispose(() => unawaited(mic.stop()));
    unawaited(_load());
    return const ReviewState();
  }

  Future<void> _load() async {
    final repo = ref.read(sessionRepositoryProvider);
    final items = await repo.dueReviews(ref.read(clockProvider)());
    final expressions = await repo.recentExpressions(limit: 5);
    final repeats = int.tryParse(
      await ref.read(settingsStoreProvider).read(SettingKeys.reviewRepeats) ??
          '',
    );
    if (ref.mounted) {
      state = state.copyWith(
        items: items,
        expressions: expressions,
        repeats: reviewRepeatOptions.contains(repeats)
            ? repeats
            : reviewRepeatOptions.first,
      );
    }
  }

  /// Ticks or unticks box [index] by hand (e.g. when recognition misheard).
  void toggleCheck(int id, int index) {
    final boxes = [...state.checksOf(id)];
    boxes[index] = !boxes[index];
    state = state.copyWith(checks: {...state.checks, id: boxes});
  }

  /// One repetition said as corrected: the next empty box is ticked.
  void _countRepetition(int id) {
    final boxes = [...state.checksOf(id)];
    final next = boxes.indexOf(false);
    if (next < 0) return;
    boxes[next] = true;
    state = state.copyWith(checks: {...state.checks, id: boxes});
  }

  /// Say a sentence with expression [index]; shows what was heard.
  Future<void> useExpression(int index) async {
    final mic = ref.read(speechInputProvider);
    if (state.busy || !await mic.ensureAvailable()) return;
    if (!ref.mounted) return;
    state = state.copyWith(listeningToExpression: index);
    final heard = await mic.listenOnce(
      hints: [state.expressions[index].phrase],
    );
    if (!ref.mounted) return;
    state = state.copyWith(
      expressionHeard: {...state.expressionHeard, index: heard.trim()},
      clearListening: true,
    );
  }

  Future<void> practice(int id) async {
    final mic = ref.read(speechInputProvider);
    if (state.busy || !await mic.ensureAvailable()) return;
    if (!ref.mounted) return;
    state = state.copyWith(listeningTo: id);
    final heard = await mic.listenOnce();
    if (!ref.mounted) return;
    state = state.copyWith(
      heard: {...state.heard, id: heard.trim()},
      clearListening: true,
    );
    final item = state.items?.where((i) => i.id == id).firstOrNull;
    if (item != null && saidAsCorrected(heard, item.suggested)) {
      _countRepetition(id);
    }
  }

  /// Said it again: next review after a longer interval.
  Future<void> done(ReviewItem item) =>
      _save(ReviewSchedule.practiced(item, ref.read(clockProvider)()));

  /// Not now: back tomorrow.
  Future<void> later(ReviewItem item) =>
      _save(ReviewSchedule.later(item, ref.read(clockProvider)()));

  Future<void> _save(ReviewItem updated) async {
    await ref.read(sessionRepositoryProvider).saveReview(updated);
    if (!ref.mounted) return;
    state = state.copyWith(
      items: [
        for (final i in state.items ?? const <ReviewItem>[])
          if (i.id != updated.id) i,
      ],
    );
  }
}
