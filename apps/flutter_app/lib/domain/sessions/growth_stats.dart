import '../conversation/session_enums.dart';
import '../feedback/feedback.dart';
import '../learning/learner_level.dart';
import 'session_records.dart';

/// A correction's date and kind, for weak areas.
final class CorrectionStat {
  const CorrectionStat(this.at, this.category);

  final DateTime at;
  final ErrorCategory? category;
}

/// A level set by an assessment.
final class LevelPoint {
  const LevelPoint(this.at, this.level);

  final DateTime at;
  final LearnerLevel level;
}

final class DayTotal {
  const DayTotal(this.day, {this.practice = Duration.zero, this.speech});

  /// Local midnight.
  final DateTime day;

  /// Active session time (measured).
  final Duration practice;

  /// Estimated speaking time; null when none of the day's sessions has one.
  final Duration? speech;
}

/// Growth dashboard (spec §3.2 S10) over the last [days] days, from
/// recorded data only: practice time is measured, speaking time is an
/// estimate and shown only where one exists (rule 5).
final class GrowthStats {
  const GrowthStats({
    required this.days,
    required this.sessions,
    required this.avgAnswerWords,
    required this.weakAreas,
    required this.levels,
  });

  /// One per day, oldest first, today last.
  final List<DayTotal> days;
  final int sessions;

  /// Null when there are no answers in the period.
  final double? avgAnswerWords;

  /// Corrections per category in the period, most frequent first.
  /// Unclassified corrections are left out.
  final List<(ErrorCategory, int)> weakAreas;

  /// All assessments, oldest first.
  final List<LevelPoint> levels;

  Duration get practice =>
      days.fold(Duration.zero, (sum, d) => sum + d.practice);

  /// Null when no session in the period has an estimate.
  Duration? get speech => days.any((d) => d.speech != null)
      ? days.fold<Duration>(
          Duration.zero,
          (sum, d) => sum + (d.speech ?? Duration.zero),
        )
      : null;

  static GrowthStats from({
    required List<SessionSummary> sessions,
    required List<CorrectionStat> corrections,
    required List<LevelPoint> levels,
    required DateTime now,
    required int days,
  }) {
    final today = _day(now);
    // Calendar days, not 24h steps, so DST shifts don't skip a day.
    DateTime dayAt(int i) => DateTime(today.year, today.month, today.day - i);
    final first = dayAt(days - 1);
    final practice = <DateTime, Duration>{};
    final speech = <DateTime, Duration>{};
    var count = 0;
    var answers = 0;
    var words = 0;
    for (final s in sessions) {
      if (s.setup.mode == SessionMode.assessment) continue;
      if (s.status != SessionStatus.completed &&
          s.status != SessionStatus.abandoned) {
        continue;
      }
      final day = _day(s.startedAt.toLocal());
      if (day.isBefore(first) || day.isAfter(today)) continue;
      count++;
      answers += s.userTurns;
      words += s.userWords;
      practice[day] = (practice[day] ?? Duration.zero) + s.duration;
      final stats = s.stats;
      if (stats != null && stats.confidence != null) {
        speech[day] =
            (speech[day] ?? Duration.zero) +
            Duration(milliseconds: stats.userMs);
      }
    }

    final counts = <ErrorCategory, int>{};
    for (final c in corrections) {
      final day = _day(c.at.toLocal());
      final category = c.category;
      if (category == null || day.isBefore(first) || day.isAfter(today)) {
        continue;
      }
      counts[category] = (counts[category] ?? 0) + 1;
    }
    final weak = [for (final e in counts.entries) (e.key, e.value)]
      // Ties keep the enum order so the list is stable.
      ..sort((a, b) => b.$2 != a.$2 ? b.$2 - a.$2 : a.$1.index - b.$1.index);

    return GrowthStats(
      days: [
        for (var i = days - 1; i >= 0; i--)
          DayTotal(
            dayAt(i),
            practice: practice[dayAt(i)] ?? Duration.zero,
            speech: speech[dayAt(i)],
          ),
      ],
      sessions: count,
      avgAnswerWords: answers == 0 ? null : words / answers,
      weakAreas: weak,
      levels: [...levels]..sort((a, b) => a.at.compareTo(b.at)),
    );
  }

  static DateTime _day(DateTime t) => DateTime(t.year, t.month, t.day);
}
