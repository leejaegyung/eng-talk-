import 'dart:convert';

import 'package:drift/drift.dart';

import '../../domain/conversation/session_enums.dart';
import '../../domain/feedback/feedback.dart' as fb;
import '../../domain/learning/learner_level.dart';
import '../../domain/sessions/session_repository.dart';
import '../db/app_database.dart';
import 'drift_session_repository.dart' show decodeFeedback, encodeFeedback;

/// Backup file contents (spec §9.2, §16.2 backup/restore). Version 2 keeps
/// everything a restore needs: turn ids that corrections point to, the
/// review schedule and the full setup. Never credentials.
class Backup {
  Backup(this._db);

  static const format = 'speaking-coach-export';
  static const version = 2;

  final AppDatabase _db;

  Future<Map<String, Object?>> export() async {
    final sessions = <Object?>[];
    final rows = await (_db.select(
      _db.sessions,
    )..orderBy([(s) => OrderingTerm.desc(s.startedAt)])).get();
    for (final s in rows) {
      final turns =
          await (_db.select(_db.turns)
                ..where((t) => t.sessionId.equals(s.id))
                ..orderBy([(t) => OrderingTerm.asc(t.id)]))
              .get();
      final metrics = await (_db.select(
        _db.speechMetrics,
      )..where((m) => m.sessionId.equals(s.id))).getSingleOrNull();
      final reviews = await (_db.select(_db.corrections).join([
        leftOuterJoin(
          _db.reviewQueue,
          _db.reviewQueue.correctionId.equalsExp(_db.corrections.id),
        ),
      ])..where(_db.corrections.sessionId.equals(s.id))).get();
      sessions.add({
        'id': s.id,
        'mode': s.mode.name,
        'level': s.level,
        'topic': s.topic,
        'goal': s.goal,
        'role': s.role,
        'length_minutes': s.lengthMinutes,
        'started_at': s.startedAt.toUtc().toIso8601String(),
        'ended_at': s.endedAt?.toUtc().toIso8601String(),
        'status': s.status.name,
        if (metrics != null)
          'speech_metrics': {
            'user_ms': metrics.userMs,
            'assistant_ms': metrics.assistantMs,
            'turn_count': metrics.turnCount,
            'confidence': metrics.confidence,
          },
        'turns': [
          for (final t in turns)
            {
              'id': t.id,
              'speaker': t.speaker.name,
              'text': t.transcript,
              'at': t.startedAt.toUtc().toIso8601String(),
              if (t.endedAt case final e?)
                'ended_at': e.toUtc().toIso8601String(),
              if (t.isRequest) 'quick_action': true,
              'speech_ms': ?t.speechMs,
            },
        ],
        if (s.feedbackJson case final f?) 'feedback': jsonDecode(f),
        'reviews': [
          for (final r in reviews)
            {
              'turn_id': r.readTable(_db.corrections).turnId,
              'original': r.readTable(_db.corrections).original,
              'suggested': r.readTable(_db.corrections).suggested,
              'practiced': r.readTable(_db.corrections).practiced,
              if (r.readTableOrNull(_db.reviewQueue) case final q?) ...{
                'due_at': q.dueAt.toUtc().toIso8601String(),
                'interval_days': q.intervalDays,
                'repetitions': q.repetitions,
              },
            },
        ],
      });
    }
    final assessments = await _db.select(_db.assessments).get();
    return {
      'format': format,
      'version': version,
      'sessions': sessions,
      'assessments': [
        for (final a in assessments)
          {
            'level': a.level,
            'assessed_at': a.assessedAt.toUtc().toIso8601String(),
            'rubric': jsonDecode(a.rubricJson),
          },
      ],
    };
  }

  /// Adds the backup's sessions and assessments to what is here. Sessions
  /// already present (same start time and mode) are skipped, so restoring
  /// twice changes nothing. Throws [FormatException] for a file that isn't
  /// a backup.
  Future<ImportResult> import(Map<String, Object?> data, DateTime now) async {
    if (data['format'] != format || data['version'] is! int) {
      throw const FormatException('not a Speaking Coach backup');
    }
    var added = 0;
    var skipped = 0;
    await _db.transaction(() async {
      for (final raw in (data['sessions'] as List? ?? const [])) {
        if (raw is! Map) continue;
        final s = raw.cast<String, Object?>();
        final mode = SessionMode.values.asNameMap()[s['mode']];
        final startedAt = _time(s['started_at']);
        final status = SessionStatus.values.asNameMap()[s['status']];
        if (mode == null || startedAt == null || status == null) continue;
        final exists =
            await (_db.select(_db.sessions)..where(
                  (x) =>
                      x.startedAt.equals(startedAt) & x.mode.equalsValue(mode),
                ))
                .getSingleOrNull();
        if (exists != null) {
          skipped++;
          continue;
        }
        await _importSession(s, mode, startedAt, status, now);
        added++;
      }
      for (final raw in (data['assessments'] as List? ?? const [])) {
        if (raw is! Map) continue;
        final at = _time(raw['assessed_at']);
        final level = _level(raw['level']);
        if (at == null || level == null) continue;
        final exists = await (_db.select(
          _db.assessments,
        )..where((a) => a.assessedAt.equals(at))).getSingleOrNull();
        if (exists != null) continue;
        await _db
            .into(_db.assessments)
            .insert(
              AssessmentsCompanion.insert(
                rubricJson: jsonEncode(raw['rubric'] ?? const {}),
                level: level.name,
                assessedAt: at,
              ),
            );
      }
    });
    return ImportResult(added: added, skipped: skipped);
  }

  Future<void> _importSession(
    Map<String, Object?> s,
    SessionMode mode,
    DateTime startedAt,
    SessionStatus status,
    DateTime now,
  ) async {
    final id = await _db
        .into(_db.sessions)
        .insert(
          SessionsCompanion.insert(
            mode: mode,
            topic: Value(s['topic'] as String?),
            level: Value(_level(s['level'])?.name),
            goal: Value(s['goal'] as String?),
            role: Value(s['role'] as String?),
            lengthMinutes: Value((s['length_minutes'] as num?)?.toInt() ?? 30),
            startedAt: startedAt,
            endedAt: Value(_time(s['ended_at'])),
            status: status,
          ),
        );

    // Old turn id (v2) or position (v1) → new id.
    final turnIds = <int, int>{};
    final userTurns = <(int, String)>[];
    for (final (i, raw) in (s['turns'] as List? ?? const []).indexed) {
      if (raw is! Map) continue;
      final speaker = Speaker.values.asNameMap()[raw['speaker']];
      final text = raw['text'];
      final at = _time(raw['at']);
      if (speaker == null || text is! String || at == null) continue;
      final newId = await _db
          .into(_db.turns)
          .insert(
            TurnsCompanion.insert(
              sessionId: id,
              speaker: speaker,
              transcript: text,
              startedAt: at,
              endedAt: Value(_time(raw['ended_at'])),
              wordCount: Value(_words(text)),
              isRequest: Value(raw['quick_action'] == true),
              speechMs: Value((raw['speech_ms'] as num?)?.toInt()),
            ),
          );
      turnIds[(raw['id'] as num?)?.toInt() ?? i] = newId;
      if (speaker == Speaker.user && raw['quick_action'] != true) {
        userTurns.add((newId, text));
      }
    }

    if (s['speech_metrics'] case final Map<Object?, Object?> m) {
      await _db
          .into(_db.speechMetrics)
          .insert(
            SpeechMetricsCompanion.insert(
              sessionId: Value(id),
              userMs: Value((m['user_ms'] as num?)?.toInt() ?? 0),
              assistantMs: Value((m['assistant_ms'] as num?)?.toInt() ?? 0),
              turnCount: Value((m['turn_count'] as num?)?.toInt() ?? 0),
              confidence: Value((m['confidence'] as num?)?.toDouble()),
            ),
          );
    }

    final feedbackJson = s['feedback'];
    if (feedbackJson is! Map) return;
    final f = decodeFeedback(jsonEncode(feedbackJson));
    final reviews = [
      for (final r in (s['reviews'] as List? ?? const []))
        if (r is Map) r.cast<String, Object?>(),
    ];
    final corrections = <fb.Correction>[];
    for (final c in f.corrections) {
      // v2 maps by id; v1 had no turn ids, so find the learner line.
      final turn =
          turnIds[c.turnId] ??
          userTurns
              .where(
                (t) => t.$2.toLowerCase().contains(c.original.toLowerCase()),
              )
              .firstOrNull
              ?.$1;
      if (turn == null) continue;
      corrections.add(
        fb.Correction(
          turnId: turn,
          original: c.original,
          suggested: c.suggested,
          explanationKo: c.explanationKo,
          severity: c.severity,
          practicePrompt: c.practicePrompt,
          category: c.category,
        ),
      );
      final review = reviews
          .where(
            (r) => r['original'] == c.original && r['suggested'] == c.suggested,
          )
          .firstOrNull;
      final correctionId = await _db
          .into(_db.corrections)
          .insert(
            CorrectionsCompanion.insert(
              sessionId: id,
              turnId: turn,
              original: c.original,
              suggested: c.suggested,
              explanation: Value(c.explanationKo),
              severity: Value(c.severity.name),
              practicePrompt: Value(c.practicePrompt),
              category: Value(c.category?.wire),
              practiced: Value(review?['practiced'] == true),
            ),
          );
      await _db
          .into(_db.reviewQueue)
          .insert(
            ReviewQueueCompanion.insert(
              correctionId: correctionId,
              dueAt: _time(review?['due_at']) ?? now,
              intervalDays: Value(
                (review?['interval_days'] as num?)?.toInt() ?? 0,
              ),
              repetitions: Value(
                (review?['repetitions'] as num?)?.toInt() ?? 0,
              ),
            ),
          );
    }
    for (final e in f.expressions) {
      await _db
          .into(_db.expressions)
          .insert(
            ExpressionsCompanion.insert(
              phrase: e.phrase,
              meaningKo: Value(e.meaningKo),
              sourceSessionId: id,
            ),
          );
    }
    await (_db.update(_db.sessions)..where((x) => x.id.equals(id))).write(
      SessionsCompanion(
        feedbackJson: Value(
          encodeFeedback(
            fb.FeedbackResult(
              strengths: f.strengths,
              corrections: corrections,
              expressions: f.expressions,
              nextTopic: f.nextTopic,
              reduced: f.reduced,
            ),
          ),
        ),
      ),
    );
  }

  static DateTime? _time(Object? v) =>
      v is String ? DateTime.tryParse(v) : null;

  /// v2 stores the name ('l3'), v1 the label ('L3').
  static LearnerLevel? _level(Object? v) =>
      LearnerLevel.values.where((l) => l.name == v || l.label == v).firstOrNull;

  static int _words(String text) =>
      text.trim().isEmpty ? 0 : text.trim().split(RegExp(r'\s+')).length;
}
