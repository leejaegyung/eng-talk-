import 'dart:convert';

import 'package:drift/drift.dart';

import '../../domain/conversation/session_enums.dart';
import '../../domain/feedback/feedback.dart' as fb;
import '../../domain/learning/learner_level.dart';
import '../../domain/learning/mini_lesson.dart';
import '../../domain/sessions/growth_stats.dart';
import '../../domain/sessions/session_records.dart';
import '../../domain/sessions/session_repository.dart';
import '../db/app_database.dart';
import 'backup.dart';

class DriftSessionRepository implements SessionRepository {
  DriftSessionRepository(this._db);

  final AppDatabase _db;

  @override
  Future<int> start(SessionSetup setup, DateTime at) => _db
      .into(_db.sessions)
      .insert(
        SessionsCompanion.insert(
          mode: setup.mode,
          topic: Value(setup.topic),
          level: Value(setup.level.name),
          goal: Value(setup.goal),
          role: Value(setup.role),
          lengthMinutes: Value(setup.length.inMinutes),
          startedAt: at,
          status: SessionStatus.active,
        ),
      );

  @override
  Future<int> addTurn(int sessionId, TurnRecord turn) => _db
      .into(_db.turns)
      .insert(
        TurnsCompanion.insert(
          sessionId: sessionId,
          speaker: turn.speaker,
          transcript: turn.text,
          startedAt: turn.startedAt,
          endedAt: Value(turn.endedAt),
          wordCount: Value(turn.wordCount),
          isRequest: Value(turn.isRequest),
          speechMs: Value(turn.speechMs),
        ),
      );

  @override
  Future<void> finish(
    int sessionId, {
    required SessionStatus status,
    required DateTime endedAt,
    SpeechStats? stats,
  }) => _db.transaction(() async {
    await (_db.update(
      _db.sessions,
    )..where((s) => s.id.equals(sessionId))).write(
      SessionsCompanion(status: Value(status), endedAt: Value(endedAt)),
    );
    if (stats != null) {
      await _db
          .into(_db.speechMetrics)
          .insertOnConflictUpdate(
            SpeechMetricsCompanion.insert(
              sessionId: Value(sessionId),
              userMs: Value(stats.userMs),
              assistantMs: Value(stats.assistantMs),
              turnCount: Value(stats.turnCount),
              confidence: Value(stats.confidence),
            ),
          );
    }
  });

  @override
  Future<void> saveFeedback(
    int sessionId,
    fb.FeedbackResult f,
    DateTime now,
  ) => _db.transaction(() async {
    await (_db.update(_db.sessions)..where((s) => s.id.equals(sessionId)))
        .write(SessionsCompanion(feedbackJson: Value(encodeFeedback(f))));
    for (final c in f.corrections) {
      final id = await _db
          .into(_db.corrections)
          .insert(
            CorrectionsCompanion.insert(
              sessionId: sessionId,
              turnId: c.turnId,
              original: c.original,
              suggested: c.suggested,
              explanation: Value(c.explanationKo),
              severity: Value(c.severity.name),
              practicePrompt: Value(c.practicePrompt),
              category: Value(c.category?.wire),
            ),
          );
      await _db
          .into(_db.reviewQueue)
          .insert(ReviewQueueCompanion.insert(correctionId: id, dueAt: now));
    }
    for (final w in wordOrderReviews(f)) {
      final id = await _db
          .into(_db.corrections)
          .insert(
            CorrectionsCompanion.insert(
              sessionId: sessionId,
              turnId: w.turnId,
              original: w.original,
              suggested: w.corrected!,
              explanation: Value(w.explanationKo),
              category: Value(fb.ErrorCategory.structure.wire),
              kind: Value(ReviewKind.wordOrder.name),
            ),
          );
      await _db
          .into(_db.reviewQueue)
          .insert(ReviewQueueCompanion.insert(correctionId: id, dueAt: now));
    }
    for (final e in f.expressions) {
      await _db
          .into(_db.expressions)
          .insert(
            ExpressionsCompanion.insert(
              phrase: e.phrase,
              meaningKo: Value(e.meaningKo),
              sourceSessionId: sessionId,
            ),
          );
    }
  });

  @override
  Future<List<SessionSummary>> list({String? query}) async {
    final q = _db.select(_db.sessions)
      ..orderBy([
        (s) => OrderingTerm.desc(s.startedAt),
        (s) => OrderingTerm.desc(s.id),
      ]);
    final text = query?.trim();
    if (text != null && text.isNotEmpty) {
      final like = '%$text%';
      q.where(
        (s) =>
            s.topic.like(like) |
            existsQuery(
              _db.select(_db.turns)..where(
                (t) => t.sessionId.equalsExp(s.id) & t.transcript.like(like),
              ),
            ),
      );
    }
    return Future.wait((await q.get()).map(_summary));
  }

  Future<SessionSummary> _summary(Session s) async {
    final count = _db.turns.id.count();
    final words = _db.turns.wordCount.sum();
    final (userTurns, userWords) =
        await (_db.selectOnly(_db.turns)
              ..addColumns([count, words])
              ..where(
                _db.turns.sessionId.equals(s.id) &
                    _db.turns.speaker.equalsValue(Speaker.user) &
                    _db.turns.isRequest.equals(false),
              ))
            .map((r) => (r.read(count) ?? 0, r.read(words) ?? 0))
            .getSingle();
    final m = await (_db.select(
      _db.speechMetrics,
    )..where((x) => x.sessionId.equals(s.id))).getSingleOrNull();
    return SessionSummary(
      id: s.id,
      setup: SessionSetup(
        mode: s.mode,
        level:
            LearnerLevel.values.asNameMap()[s.level] ??
            const SessionSetup().level,
        topic: s.topic,
        goal: s.goal,
        role: s.role,
        length: Duration(minutes: s.lengthMinutes),
      ),
      startedAt: s.startedAt,
      endedAt: s.endedAt,
      status: s.status,
      userTurns: userTurns,
      userWords: userWords,
      nextTopic: s.feedbackJson == null
          ? null
          : decodeFeedback(s.feedbackJson!).nextTopic,
      stats: m == null
          ? null
          : SpeechStats(
              userMs: m.userMs,
              assistantMs: m.assistantMs,
              turnCount: m.turnCount,
              confidence: m.confidence,
            ),
    );
  }

  @override
  Future<SessionDetail?> load(int sessionId) async {
    final s = await (_db.select(
      _db.sessions,
    )..where((x) => x.id.equals(sessionId))).getSingleOrNull();
    if (s == null) return null;
    final turns =
        await (_db.select(_db.turns)
              ..where((t) => t.sessionId.equals(sessionId))
              ..orderBy([(t) => OrderingTerm.asc(t.id)]))
            .get();
    return SessionDetail(
      summary: await _summary(s),
      turns: [
        for (final t in turns)
          TurnRecord(
            id: t.id,
            speaker: t.speaker,
            text: t.transcript,
            startedAt: t.startedAt,
            endedAt: t.endedAt,
            isRequest: t.isRequest,
            speechMs: t.speechMs,
          ),
      ],
      feedback: s.feedbackJson == null ? null : decodeFeedback(s.feedbackJson!),
    );
  }

  @override
  Future<SessionSummary?> unfinished() async {
    final s =
        await (_db.select(_db.sessions)
              ..where(
                (x) => x.status.isInValues([
                  SessionStatus.active,
                  SessionStatus.paused,
                ]),
              )
              ..orderBy([(x) => OrderingTerm.desc(x.startedAt)])
              ..limit(1))
            .getSingleOrNull();
    return s == null ? null : _summary(s);
  }

  @override
  Future<void> delete(int sessionId) =>
      (_db.delete(_db.sessions)..where((s) => s.id.equals(sessionId))).go();

  @override
  Future<void> deleteAll() => _db.transaction(() async {
    await _db.delete(_db.assessments).go();
    await _db.delete(_db.sessions).go();
  });

  @override
  Future<List<ReviewItem>> dueReviews(DateTime now) async {
    final rows =
        await (_db.select(_db.reviewQueue).join([
                innerJoin(
                  _db.corrections,
                  _db.corrections.id.equalsExp(_db.reviewQueue.correctionId),
                ),
              ])
              ..where(_db.reviewQueue.dueAt.isSmallerOrEqualValue(now))
              ..orderBy([OrderingTerm.asc(_db.reviewQueue.dueAt)]))
            .get();
    return [
      for (final r in rows)
        ReviewItem(
          id: r.readTable(_db.reviewQueue).id,
          kind:
              ReviewKind.values.asNameMap()[r
                  .readTable(_db.corrections)
                  .kind] ??
              ReviewKind.say,
          original: r.readTable(_db.corrections).original,
          suggested: r.readTable(_db.corrections).suggested,
          explanationKo: r.readTable(_db.corrections).explanation,
          dueAt: r.readTable(_db.reviewQueue).dueAt,
          intervalDays: r.readTable(_db.reviewQueue).intervalDays,
          repetitions: r.readTable(_db.reviewQueue).repetitions,
        ),
    ];
  }

  @override
  Future<int> reviewCount(DateTime now) async => (await dueReviews(now)).length;

  @override
  Future<void> saveReview(ReviewItem updated) => _db.transaction(() async {
    final row = await (_db.select(
      _db.reviewQueue,
    )..where((r) => r.id.equals(updated.id))).getSingle();
    await (_db.update(
      _db.reviewQueue,
    )..where((r) => r.id.equals(updated.id))).write(
      ReviewQueueCompanion(
        dueAt: Value(updated.dueAt),
        intervalDays: Value(updated.intervalDays),
        repetitions: Value(updated.repetitions),
      ),
    );
    if (updated.repetitions > row.repetitions) {
      await (_db.update(_db.corrections)
            ..where((c) => c.id.equals(row.correctionId)))
          .write(const CorrectionsCompanion(practiced: Value(true)));
    }
  });

  @override
  Future<void> saveAssessment({
    required int? sessionId,
    required String rubricJson,
    required LearnerLevel level,
    required DateTime at,
  }) => _db
      .into(_db.assessments)
      .insert(
        AssessmentsCompanion.insert(
          sessionId: Value(sessionId),
          rubricJson: rubricJson,
          level: level.name,
          assessedAt: at,
        ),
      );

  @override
  Future<List<CorrectionStat>> correctionStats({
    required DateTime since,
  }) async {
    final c = _db.corrections;
    final s = _db.sessions;
    final rows = await (_db.select(c).join([
      innerJoin(s, s.id.equalsExp(c.sessionId)),
    ])..where(s.startedAt.isBiggerOrEqualValue(since))).get();
    return [
      for (final r in rows)
        CorrectionStat(
          r.readTable(s).startedAt,
          fb.ErrorCategory.fromWire(r.readTable(c).category),
        ),
    ];
  }

  @override
  Future<List<fb.Expression>> recentExpressions({int limit = 10}) async {
    final rows = await (_db.select(
      _db.expressions,
    )..orderBy([(e) => OrderingTerm.desc(e.id)])).get();
    final seen = <String>{};
    return [
      for (final r in rows)
        if (seen.add(r.phrase.trim().toLowerCase()))
          fb.Expression(r.phrase, meaningKo: r.meaningKo),
    ].take(limit).toList();
  }

  @override
  Future<List<CorrectionExample>> recentCorrections(
    fb.ErrorCategory category, {
    int limit = 6,
  }) async {
    final rows =
        await (_db.select(_db.corrections)
              ..where((c) => c.category.equals(category.wire))
              ..orderBy([(c) => OrderingTerm.desc(c.id)])
              ..limit(limit * 2))
            .get();
    final seen = <String>{};
    return [
      for (final r in rows)
        if (seen.add(r.suggested.toLowerCase()))
          CorrectionExample(
            original: r.original,
            suggested: r.suggested,
            explanationKo: r.explanation,
          ),
    ].take(limit).toList();
  }

  @override
  Future<List<LevelPoint>> levelHistory() async {
    final rows = await (_db.select(
      _db.assessments,
    )..orderBy([(a) => OrderingTerm.asc(a.assessedAt)])).get();
    return [
      for (final r in rows)
        if (LearnerLevel.values.asNameMap()[r.level] case final level?)
          LevelPoint(r.assessedAt, level),
    ];
  }

  @override
  Future<Map<String, Object?>> exportAll() => Backup(_db).export();

  @override
  Future<ImportResult> importAll(Map<String, Object?> data, DateTime now) =>
      Backup(_db).import(data, now);
}

String encodeFeedback(fb.FeedbackResult f) => jsonEncode({
  'strengths': f.strengths,
  'corrections': [
    for (final c in f.corrections)
      {
        'turn_id': c.turnId,
        'original': c.original,
        'suggested': c.suggested,
        'explanation_ko': c.explanationKo,
        'severity': c.severity.name,
        'practice_prompt': c.practicePrompt,
        'category': c.category?.wire,
      },
  ],
  'expressions': [
    for (final e in f.expressions)
      {'phrase': e.phrase, 'meaning_ko': e.meaningKo},
  ],
  'next_topic': f.nextTopic,
  'reduced': f.reduced,
  'word_order': [
    for (final w in f.wordOrder)
      {
        'turn_id': w.turnId,
        'original': w.original,
        'ok': w.ok,
        'corrected': w.corrected,
        'explanation_ko': w.explanationKo,
      },
  ],
});

/// Word-order mistakes to practise, except where a correction already asks
/// the learner to say the same sentence.
List<fb.WordOrderCheck> wordOrderReviews(fb.FeedbackResult f) {
  String norm(String s) =>
      s.toLowerCase().replaceAll(RegExp(r"[^a-z0-9' ]"), '').trim();
  final said = {
    for (final c in f.corrections) '${c.turnId}|${norm(c.suggested)}',
  };
  return [
    for (final w in f.wordOrder)
      if (!w.ok &&
          w.corrected != null &&
          !said.contains('${w.turnId}|${norm(w.corrected!)}'))
        w,
  ];
}

fb.FeedbackResult decodeFeedback(String raw) {
  final j = jsonDecode(raw) as Map<String, Object?>;
  return fb.FeedbackResult(
    strengths: [...(j['strengths'] as List? ?? const []).cast<String>()],
    corrections: [
      for (final c
          in (j['corrections'] as List? ?? const [])
              .cast<Map<String, Object?>>())
        fb.Correction(
          turnId: c['turn_id'] as int,
          original: c['original'] as String,
          suggested: c['suggested'] as String,
          explanationKo: c['explanation_ko'] as String?,
          severity:
              fb.Severity.values.asNameMap()[c['severity']] ??
              fb.Severity.medium,
          practicePrompt: c['practice_prompt'] as String?,
          category: fb.ErrorCategory.fromWire(c['category']),
        ),
    ],
    expressions: [
      for (final e
          in (j['expressions'] as List? ?? const [])
              .cast<Map<String, Object?>>())
        fb.Expression(
          e['phrase'] as String,
          meaningKo: e['meaning_ko'] as String?,
        ),
    ],
    nextTopic: j['next_topic'] as String?,
    reduced: j['reduced'] as bool? ?? false,
    wordOrder: [
      for (final w
          in (j['word_order'] as List? ?? const [])
              .cast<Map<String, Object?>>())
        fb.WordOrderCheck(
          turnId: w['turn_id'] as int,
          original: w['original'] as String,
          ok: w['ok'] as bool,
          corrected: w['corrected'] as String?,
          explanationKo: w['explanation_ko'] as String?,
        ),
    ],
  );
}
