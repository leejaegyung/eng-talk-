import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../domain/sessions/review_schedule.dart';
import '../../domain/sessions/session_records.dart';

final class ReviewState {
  const ReviewState({this.items, this.heard = const {}, this.listeningTo});

  /// Null while loading.
  final List<ReviewItem>? items;
  final Map<int, String> heard;
  final int? listeningTo;

  ReviewState copyWith({
    List<ReviewItem>? items,
    Map<int, String>? heard,
    int? listeningTo,
    bool clearListening = false,
  }) => ReviewState(
    items: items ?? this.items,
    heard: heard ?? this.heard,
    listeningTo: clearListening ? null : listeningTo ?? this.listeningTo,
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
    final items = await ref
        .read(sessionRepositoryProvider)
        .dueReviews(ref.read(clockProvider)());
    if (ref.mounted) state = state.copyWith(items: items);
  }

  Future<void> practice(int id) async {
    final mic = ref.read(speechInputProvider);
    if (state.listeningTo != null || !await mic.ensureAvailable()) return;
    if (!ref.mounted) return;
    state = state.copyWith(listeningTo: id);
    final heard = await mic.listenOnce();
    if (!ref.mounted) return;
    state = state.copyWith(
      heard: {...state.heard, id: heard.trim()},
      clearListening: true,
    );
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
