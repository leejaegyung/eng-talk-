import 'session_records.dart';

/// Spaced repetition for "say it again" review: 1 → 3 → 7 → 14 → 30 days.
/// No scoring — saying it again counts as a repetition; "again later"
/// brings it back tomorrow.
abstract final class ReviewSchedule {
  static const intervals = [1, 3, 7, 14, 30];

  static ReviewItem practiced(ReviewItem item, DateTime now) {
    final i = item.repetitions.clamp(0, intervals.length - 1);
    final days = intervals[i];
    return _with(item, now, days, item.repetitions + 1);
  }

  static ReviewItem later(ReviewItem item, DateTime now) =>
      _with(item, now, 1, item.repetitions);

  static ReviewItem _with(ReviewItem i, DateTime now, int days, int reps) =>
      ReviewItem(
        id: i.id,
        kind: i.kind,
        original: i.original,
        suggested: i.suggested,
        explanationKo: i.explanationKo,
        dueAt: now.add(Duration(days: days)),
        intervalDays: days,
        repetitions: reps,
      );
}
