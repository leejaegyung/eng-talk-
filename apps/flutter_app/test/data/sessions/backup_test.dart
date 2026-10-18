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
  final t0 = DateTime.utc(2026, 10, 17, 9);
  final dbs = <AppDatabase>[];
  tearDown(() async {
    for (final db in dbs) {
      await db.close();
    }
    dbs.clear();
  });

  DriftSessionRepository repo() {
    final db = AppDatabase(NativeDatabase.memory());
    dbs.add(db);
    return DriftSessionRepository(db);
  }

  Future<Map<String, Object?>> backupOf(DriftSessionRepository r) async =>
      // Through JSON, as a file would be.
      jsonDecode(jsonEncode(await r.exportAll())) as Map<String, Object?>;

  test(
    'round trip keeps sessions, feedback, review schedule, metrics',
    () async {
      final a = repo();
      final id = await a.start(
        const SessionSetup(
          mode: SessionMode.roleplay,
          level: LearnerLevel.l3,
          topic: 'Hotel',
          role: 'clerk',
          goal: 'quiet room',
          length: Duration(minutes: 20),
        ),
        t0,
      );
      await a.addTurn(
        id,
        TurnRecord(speaker: Speaker.assistant, text: 'Hello?', startedAt: t0),
      );
      final turn = await a.addTurn(
        id,
        TurnRecord(
          speaker: Speaker.user,
          text: 'I want room for two night',
          startedAt: t0,
          speechMs: 1500,
        ),
      );
      await a.finish(
        id,
        status: SessionStatus.completed,
        endedAt: t0.add(const Duration(minutes: 12)),
        stats: const SpeechStats(
          userMs: 1500,
          assistantMs: 900,
          turnCount: 1,
          confidence: 0.7,
        ),
      );
      await a.saveFeedback(
        id,
        FeedbackResult(
          strengths: const ['Polite'],
          corrections: [
            Correction(
              turnId: turn,
              original: 'I want room for two night',
              suggested: 'I would like a room for two nights.',
              category: ErrorCategory.grammar,
            ),
          ],
          expressions: const [Expression('I booked a room for')],
          nextTopic: 'Room service',
          wordOrder: [
            WordOrderCheck(
              turnId: turn,
              original: 'I want room for two night',
              ok: false,
              corrected: 'For two night I want room',
            ),
          ],
        ),
        t0,
      );
      final due = (await a.dueReviews(t0)).first;
      await a.saveReview(ReviewSchedule.practiced(due, t0));
      await a.saveAssessment(
        sessionId: null,
        rubricJson: '{"relevance": 4}',
        level: LearnerLevel.l3,
        at: t0,
      );

      final backup = await backupOf(a);
      expect(backup['version'], 2);
      expect(jsonEncode(backup), isNot(contains('sk-')));

      final b = repo();
      final result = await b.importAll(backup, t0);
      expect(result.added, 1);
      final s = (await b.list()).single;
      final d = (await b.load(s.id))!;
      expect(d.summary.setup.mode, SessionMode.roleplay);
      expect(d.summary.setup.role, 'clerk');
      expect(d.summary.setup.goal, 'quiet room');
      expect(d.summary.setup.length, const Duration(minutes: 20));
      expect(d.summary.duration, const Duration(minutes: 12));
      expect(d.summary.stats!.confidence, 0.7);
      expect(d.turns.map((t) => t.text), [
        'Hello?',
        'I want room for two night',
      ]);
      expect(d.turns[1].speechMs, 1500);
      final c = d.feedback!.corrections.single;
      expect(c.turnId, d.turns[1].id, reason: 'points at the restored turn');
      expect(c.category, ErrorCategory.grammar);
      expect((await b.dueReviews(t0)).map((r) => r.kind), [
        ReviewKind.wordOrder,
      ], reason: 'the practised one keeps its schedule');
      expect(await b.dueReviews(t0.add(const Duration(days: 1))), hasLength(2));
      expect(d.feedback!.wordOrder.single.turnId, d.turns[1].id);
      expect(
        (await b.recentExpressions()).single.phrase,
        'I booked a room for',
      );
      expect((await b.levelHistory()).single.level, LearnerLevel.l3);
      expect(await b.correctionStats(since: t0), hasLength(2));

      final again = await b.importAll(backup, t0);
      expect(again.added, 0);
      expect(again.skipped, 1);
      expect(await b.list(), hasLength(1));
      expect(await b.levelHistory(), hasLength(1));
    },
  );

  test('v1 backups restore as far as they go', () async {
    final b = repo();
    final result = await b.importAll({
      'format': 'speaking-coach-export',
      'version': 1,
      'sessions': [
        {
          'id': 7,
          'mode': 'daily',
          'level': 'L2',
          'topic': null,
          'started_at': t0.toIso8601String(),
          'ended_at': t0.add(const Duration(minutes: 5)).toIso8601String(),
          'status': 'completed',
          'turns': [
            {'speaker': 'assistant', 'text': 'Hi!', 'at': t0.toIso8601String()},
            {
              'speaker': 'user',
              'text': 'I go to park yesterday',
              'at': t0.toIso8601String(),
            },
          ],
          'feedback': {
            'strengths': <String>[],
            'corrections': [
              {
                'turn_id': 99,
                'original': 'I go to park',
                'suggested': 'I went to the park',
                'severity': 'high',
              },
            ],
            'expressions': <Object>[],
          },
        },
      ],
      'assessments': <Object>[],
    }, t0);
    expect(result.added, 1);
    final d = (await b.load((await b.list()).single.id))!;
    expect(d.summary.setup.level, LearnerLevel.l2);
    expect(d.feedback!.corrections.single.turnId, d.turns[1].id);
    expect(await b.dueReviews(t0), hasLength(1));
  });

  test('anything else is rejected', () async {
    expect(
      () => repo().importAll({'hello': 'world'}, t0),
      throwsA(isA<FormatException>()),
    );
  });
}
