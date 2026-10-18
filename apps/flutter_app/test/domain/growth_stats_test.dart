import 'package:flutter_test/flutter_test.dart';
import 'package:speaking_coach/domain/conversation/session_enums.dart';
import 'package:speaking_coach/domain/feedback/feedback.dart';
import 'package:speaking_coach/domain/learning/learner_level.dart';
import 'package:speaking_coach/domain/sessions/growth_stats.dart';
import 'package:speaking_coach/domain/sessions/progress_stats.dart';
import 'package:speaking_coach/domain/sessions/session_records.dart';

void main() {
  final now = DateTime(2026, 10, 17, 20);

  SessionSummary session(
    int daysAgo, {
    int minutes = 10,
    SessionStatus status = SessionStatus.completed,
    bool measured = true,
    SessionMode mode = SessionMode.daily,
    int turns = 2,
    int words = 20,
  }) {
    final start = now.subtract(Duration(days: daysAgo, hours: 1));
    return SessionSummary(
      id: daysAgo,
      setup: SessionSetup(mode: mode),
      startedAt: start,
      endedAt: start.add(Duration(minutes: minutes)),
      status: status,
      userTurns: turns,
      userWords: words,
      stats: SpeechStats(
        userMs: 60000,
        assistantMs: 1000,
        turnCount: turns,
        confidence: measured ? 0.5 : null,
      ),
    );
  }

  GrowthStats stats(
    List<SessionSummary> sessions, {
    List<CorrectionStat> corrections = const [],
    List<LevelPoint> levels = const [],
    int days = 7,
  }) => GrowthStats.from(
    sessions: sessions,
    corrections: corrections,
    levels: levels,
    now: now,
    days: days,
  );

  test('one entry per day, oldest first, today last', () {
    final g = stats([]);
    expect(g.days, hasLength(7));
    expect(g.days.last.day, DateTime(2026, 10, 17));
    expect(g.days.first.day, DateTime(2026, 10, 11));
    expect(g.practice, Duration.zero);
    expect(g.speech, isNull);
    expect(g.avgAnswerWords, isNull);
  });

  test('practice is measured session time inside the period', () {
    final g = stats([
      session(0, minutes: 12),
      session(0, minutes: 8, status: SessionStatus.abandoned),
      session(2, minutes: 30),
      session(7, minutes: 99),
      session(0, minutes: 50, status: SessionStatus.active),
      session(0, minutes: 50, mode: SessionMode.assessment),
    ]);
    expect(g.days.last.practice, const Duration(minutes: 20));
    expect(g.days[4].practice, const Duration(minutes: 30));
    expect(g.practice, const Duration(minutes: 50));
    expect(g.sessions, 3);
  });

  test('speaking time only where estimated', () {
    final g = stats([session(0), session(1, measured: false)]);
    expect(g.days.last.speech, const Duration(minutes: 1));
    expect(g.days[5].speech, isNull);
    expect(g.speech, const Duration(minutes: 1));
  });

  test('weak areas: counted in the period, most frequent first', () {
    final g = stats(
      [],
      corrections: [
        CorrectionStat(now, ErrorCategory.wordChoice),
        CorrectionStat(now, ErrorCategory.grammar),
        CorrectionStat(now, ErrorCategory.grammar),
        CorrectionStat(now, null),
        CorrectionStat(
          now.subtract(const Duration(days: 9)),
          ErrorCategory.structure,
        ),
      ],
    );
    expect(g.weakAreas, [
      (ErrorCategory.grammar, 2),
      (ErrorCategory.wordChoice, 1),
    ]);
  });

  test('30-day period and level history in date order', () {
    final g = stats(
      [session(20)],
      levels: [
        LevelPoint(now, LearnerLevel.l3),
        LevelPoint(now.subtract(const Duration(days: 40)), LearnerLevel.l2),
      ],
      days: 30,
    );
    expect(g.days, hasLength(30));
    expect(g.sessions, 1);
    expect(g.levels.map((l) => l.level), [LearnerLevel.l2, LearnerLevel.l3]);
  });

  test('home: today practice counts finished sessions only', () {
    final p = ProgressStats.from(
      [
        session(0, minutes: 12),
        session(0, minutes: 5, status: SessionStatus.active),
        session(1, minutes: 30),
      ],
      now: now,
      reviewsDue: 0,
    );
    expect(p.todayPractice, const Duration(minutes: 12));
  });
}
