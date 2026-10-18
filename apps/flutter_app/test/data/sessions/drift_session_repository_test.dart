import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:speaking_coach/data/db/app_database.dart' hide Correction;
import 'package:speaking_coach/data/sessions/drift_session_repository.dart';
import 'package:speaking_coach/domain/conversation/session_enums.dart';
import 'package:speaking_coach/domain/feedback/feedback.dart';
import 'package:speaking_coach/domain/learning/learner_level.dart';
import 'package:speaking_coach/domain/sessions/review_schedule.dart';
import 'package:speaking_coach/domain/sessions/session_records.dart';

void main() {
  late AppDatabase db;
  late DriftSessionRepository repo;
  final t0 = DateTime.utc(2026, 10, 17, 9);

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = DriftSessionRepository(db);
  });
  tearDown(() => db.close());

  Future<(int, int)> sessionWithTurns({String? topic}) async {
    final id = await repo.start(
      SessionSetup(
        mode: SessionMode.theme,
        level: LearnerLevel.l3,
        topic: topic,
      ),
      t0,
    );
    await repo.addTurn(
      id,
      TurnRecord(
        speaker: Speaker.assistant,
        text: 'What did you do?',
        startedAt: t0,
      ),
    );
    final userTurn = await repo.addTurn(
      id,
      TurnRecord(
        speaker: Speaker.user,
        text: 'I go there yesterday',
        startedAt: t0,
        speechMs: 1800,
      ),
    );
    await repo.addTurn(
      id,
      TurnRecord(
        speaker: Speaker.user,
        text: 'Could you give me a hint?',
        startedAt: t0,
        isRequest: true,
      ),
    );
    return (id, userTurn);
  }

  const feedback = FeedbackResult(
    strengths: ['Clear answers'],
    expressions: [Expression('That reminds me of...', meaningKo: '그러고 보니...')],
    nextTopic: 'Weekend plans',
  );

  test('session round trip with setup, turns and summary', () async {
    final (id, _) = await sessionWithTurns(topic: 'Travel');
    await repo.finish(
      id,
      status: SessionStatus.completed,
      endedAt: t0.add(const Duration(minutes: 12)),
      stats: const SpeechStats(
        userMs: 6000,
        assistantMs: 2000,
        turnCount: 1,
        confidence: 0.5,
      ),
    );
    final d = (await repo.load(id))!;
    expect(d.summary.setup.mode, SessionMode.theme);
    expect(d.summary.setup.level, LearnerLevel.l3);
    expect(d.summary.setup.topic, 'Travel');
    expect(d.summary.status, SessionStatus.completed);
    expect(d.summary.duration, const Duration(minutes: 12));
    expect(d.summary.userTurns, 1, reason: 'quick actions are not answers');
    expect(d.summary.stats!.speakingRatio, 0.75);
    expect(d.turns.map((t) => t.isRequest), [false, false, true]);
    expect(d.turns[1].speechMs, 1800);
  });

  test('feedback stores corrections, expressions and queues review', () async {
    final (id, turn) = await sessionWithTurns();
    await repo.saveFeedback(
      id,
      FeedbackResult(
        strengths: feedback.strengths,
        expressions: feedback.expressions,
        nextTopic: feedback.nextTopic,
        corrections: [
          Correction(
            turnId: turn,
            original: 'I go there yesterday',
            suggested: 'I went there yesterday.',
            explanationKo: '과거라서 went',
          ),
        ],
      ),
      t0,
    );
    final d = (await repo.load(id))!;
    expect(d.feedback!.strengths, ['Clear answers']);
    expect(d.feedback!.corrections.single.turnId, turn);
    expect(d.feedback!.nextTopic, 'Weekend plans');
    expect(await db.select(db.expressions).get(), hasLength(1));

    final due = await repo.dueReviews(t0);
    expect(due.single.suggested, 'I went there yesterday.');
    await repo.saveReview(ReviewSchedule.practiced(due.single, t0));
    expect(await repo.dueReviews(t0), isEmpty);
    expect(
      await repo.dueReviews(t0.add(const Duration(days: 1))),
      hasLength(1),
    );
    expect((await db.select(db.corrections).getSingle()).practiced, isTrue);
  });

  test(
    'growth: correction categories by session date, level history',
    () async {
      final (id, turn) = await sessionWithTurns();
      await repo.saveFeedback(
        id,
        FeedbackResult(
          corrections: [
            Correction(
              turnId: turn,
              original: 'I go there yesterday',
              suggested: 'I went there yesterday.',
              category: ErrorCategory.grammar,
            ),
          ],
        ),
        t0,
      );
      final stats = await repo.correctionStats(since: t0);
      expect(stats.single.category, ErrorCategory.grammar);
      expect(stats.single.at.isAtSameMomentAs(t0), isTrue);
      expect(
        await repo.correctionStats(since: t0.add(const Duration(days: 1))),
        isEmpty,
      );
      expect(
        (await repo.load(id))!.feedback!.corrections.single.category,
        ErrorCategory.grammar,
      );

      for (final (days, level) in [
        (5, LearnerLevel.l3),
        (0, LearnerLevel.l2),
      ]) {
        await repo.saveAssessment(
          sessionId: null,
          rubricJson: '{}',
          level: level,
          at: t0.subtract(Duration(days: days)),
        );
      }
      expect((await repo.levelHistory()).map((p) => p.level), [
        LearnerLevel.l3,
        LearnerLevel.l2,
      ]);
    },
  );

  test('recent expressions: newest first, one per phrase', () async {
    final (a, _) = await sessionWithTurns();
    await repo.saveFeedback(
      a,
      const FeedbackResult(
        expressions: [
          Expression('That reminds me of'),
          Expression('By the way'),
        ],
      ),
      t0,
    );
    final (b, _) = await sessionWithTurns();
    await repo.saveFeedback(
      b,
      const FeedbackResult(
        expressions: [Expression('that reminds me of', meaningKo: '그러고 보니')],
      ),
      t0,
    );
    final recent = await repo.recentExpressions();
    expect(recent.map((e) => e.phrase), ['that reminds me of', 'By the way']);
    expect(await repo.recentExpressions(limit: 1), hasLength(1));
  });

  test('search matches topic or transcript; newest first', () async {
    await sessionWithTurns(topic: 'Travel');
    final (second, _) = await sessionWithTurns(topic: 'Food');
    expect((await repo.list()).first.id, second);
    expect((await repo.list(query: 'Food')).single.id, second);
    expect(await repo.list(query: 'yesterday'), hasLength(2));
    expect(await repo.list(query: 'nothing-like-this'), isEmpty);
  });

  test('unfinished session is found for recovery', () async {
    expect(await repo.unfinished(), isNull);
    final (id, _) = await sessionWithTurns();
    expect((await repo.unfinished())!.id, id);
    await repo.finish(id, status: SessionStatus.abandoned, endedAt: t0);
    expect(await repo.unfinished(), isNull);
  });

  test('delete cascades to turns, corrections and review', () async {
    final (id, turn) = await sessionWithTurns();
    await repo.saveFeedback(
      id,
      FeedbackResult(
        expressions: feedback.expressions,
        corrections: [
          Correction(turnId: turn, original: 'I go', suggested: 'I went'),
        ],
      ),
      t0,
    );
    await repo.delete(id);
    expect(await db.select(db.turns).get(), isEmpty);
    expect(await db.select(db.corrections).get(), isEmpty);
    expect(await db.select(db.reviewQueue).get(), isEmpty);
    expect(await db.select(db.expressions).get(), isEmpty);
  });

  test('delete all also clears assessments', () async {
    await sessionWithTurns();
    await repo.saveAssessment(
      sessionId: null,
      rubricJson: '{}',
      level: LearnerLevel.l2,
      at: t0,
    );
    await repo.deleteAll();
    expect(await repo.list(), isEmpty);
    expect(await db.select(db.assessments).get(), isEmpty);
  });

  test('export holds the transcript and feedback as JSON', () async {
    final (id, _) = await sessionWithTurns(topic: 'Travel');
    await repo.saveFeedback(id, feedback, t0);
    final out = await repo.exportAll();
    final encoded = jsonEncode(out);
    expect(encoded, contains('I go there yesterday'));
    expect(encoded, contains('Weekend plans'));
    expect(encoded, isNot(contains('vault')));
  });
}
