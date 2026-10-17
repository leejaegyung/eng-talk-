import 'package:flutter_test/flutter_test.dart';
import 'package:speaking_coach/domain/conversation/session_enums.dart';
import 'package:speaking_coach/domain/sessions/progress_stats.dart';
import 'package:speaking_coach/domain/sessions/session_records.dart';

void main() {
  final now = DateTime(2026, 10, 17, 20);

  SessionSummary session(
    int daysAgo, {
    SessionStatus status = SessionStatus.completed,
    int userMs = 60000,
    bool measured = true,
    int turns = 2,
    int words = 20,
    SessionMode mode = SessionMode.daily,
  }) => SessionSummary(
    id: daysAgo,
    setup: SessionSetup(mode: mode),
    startedAt: now.subtract(Duration(days: daysAgo, hours: 1)),
    status: status,
    userTurns: turns,
    userWords: words,
    stats: SpeechStats(
      userMs: userMs,
      assistantMs: 1000,
      turnCount: turns,
      confidence: measured ? 0.5 : null,
    ),
  );

  test('speaking time today and over 7 days, estimates only', () {
    final s = ProgressStats.from(
      [
        session(0),
        session(0, measured: false, userMs: 999999),
        session(3),
        session(8),
      ],
      now: now,
      reviewsDue: 2,
    );
    expect(s.todaySpeech, const Duration(minutes: 1));
    expect(s.weekSpeech, const Duration(minutes: 2));
    expect(s.speechMeasured, isTrue);
    expect(s.reviewsDue, 2);
  });

  test('nothing measured is reported as such', () {
    final s = ProgressStats.from(
      [session(0, measured: false)],
      now: now,
      reviewsDue: 0,
    );
    expect(s.speechMeasured, isFalse);
    expect(s.todaySpeech, Duration.zero);
  });

  test('completion rate and average answer length', () {
    final s = ProgressStats.from(
      [
        session(0, words: 30, turns: 3),
        session(1, status: SessionStatus.abandoned, turns: 0, words: 0),
        session(2, status: SessionStatus.active, turns: 1, words: 10),
      ],
      now: now,
      reviewsDue: 0,
    );
    expect(s.completed, 1);
    expect(s.completionRate, 0.5);
    expect(s.avgAnswerWords, 10);
  });

  test('streak counts consecutive practice days up to today or yesterday', () {
    expect(
      ProgressStats.from(
        [session(0), session(1), session(2), session(4)],
        now: now,
        reviewsDue: 0,
      ).streakDays,
      3,
    );
    expect(
      ProgressStats.from(
        [session(1), session(2)],
        now: now,
        reviewsDue: 0,
      ).streakDays,
      2,
    );
    expect(
      ProgressStats.from([session(2)], now: now, reviewsDue: 0).streakDays,
      0,
    );
  });

  test('placement sessions are left out; empty is empty', () {
    final s = ProgressStats.from(
      [session(0, mode: SessionMode.assessment)],
      now: now,
      reviewsDue: 0,
    );
    expect(s.completed, 0);
    expect(s.avgAnswerWords, isNull);
    expect(s.completionRate, isNull);
  });
}
