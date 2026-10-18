import '../conversation/session_enums.dart';
import 'session_records.dart';

/// Home KPIs (spec §12.1), computed only from recorded data. Speaking time
/// counts only sessions where it was estimated (confidence set).
final class ProgressStats {
  const ProgressStats({
    required this.todaySpeech,
    this.todayPractice = Duration.zero,
    required this.weekSpeech,
    required this.speechMeasured,
    required this.completed,
    required this.finished,
    required this.avgAnswerWords,
    required this.streakDays,
    required this.reviewsDue,
  });

  final Duration todaySpeech;

  /// Active time of today's finished sessions (measured), for the daily
  /// goal.
  final Duration todayPractice;
  final Duration weekSpeech;

  /// False when no session has a speaking-time estimate yet.
  final bool speechMeasured;
  final int completed;

  /// Completed + abandoned (for the completion rate).
  final int finished;

  /// Null when there are no answers yet.
  final double? avgAnswerWords;
  final int streakDays;
  final int reviewsDue;

  double? get completionRate => finished == 0 ? null : completed / finished;

  static ProgressStats from(
    List<SessionSummary> sessions, {
    required DateTime now,
    required int reviewsDue,
  }) {
    final today = _day(now);
    var todayMs = 0;
    var todayPractice = Duration.zero;
    var weekMs = 0;
    var measured = false;
    var completed = 0;
    var finished = 0;
    var answers = 0;
    var words = 0;
    final practiceDays = <DateTime>{};
    for (final s in sessions) {
      if (s.setup.mode == SessionMode.assessment) continue;
      final day = _day(s.startedAt.toLocal());
      final stats = s.stats;
      if (stats != null && stats.confidence != null) {
        measured = true;
        if (day == today) todayMs += stats.userMs;
        if (today.difference(day).inDays < 7) weekMs += stats.userMs;
      }
      switch (s.status) {
        case SessionStatus.completed:
          if (day == today) todayPractice += s.duration;
          completed++;
          finished++;
          practiceDays.add(day);
        case SessionStatus.abandoned:
          if (day == today) todayPractice += s.duration;
          finished++;
        case SessionStatus.active || SessionStatus.paused:
          break;
      }
      answers += s.userTurns;
      words += s.userWords;
    }
    var streak = 0;
    // A streak still counts if today's practice hasn't happened yet.
    var day = practiceDays.contains(today)
        ? today
        : today.subtract(const Duration(days: 1));
    while (practiceDays.contains(day)) {
      streak++;
      day = day.subtract(const Duration(days: 1));
    }
    return ProgressStats(
      todaySpeech: Duration(milliseconds: todayMs),
      todayPractice: todayPractice,
      weekSpeech: Duration(milliseconds: weekMs),
      speechMeasured: measured,
      completed: completed,
      finished: finished,
      avgAnswerWords: answers == 0 ? null : words / answers,
      streakDays: streak,
      reviewsDue: reviewsDue,
    );
  }

  static DateTime _day(DateTime t) => DateTime(t.year, t.month, t.day);
}
