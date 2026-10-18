import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/conversation/session_enums.dart';
import '../domain/feedback/feedback.dart';
import '../domain/learning/learner_level.dart';
import '../domain/sessions/growth_stats.dart';
import '../domain/sessions/session_records.dart';
import '../domain/sessions/session_repository.dart';

/// Bumped after every write so screens showing saved data (home, history,
/// review) reload.
final dataVersionProvider = NotifierProvider<DataVersion, int>(DataVersion.new);

class DataVersion extends Notifier<int> {
  @override
  int build() => 0;

  void bump() => state++;
}

class NotifyingSessionRepository implements SessionRepository {
  NotifyingSessionRepository(this._inner, this._changed);

  final SessionRepository _inner;
  final void Function() _changed;

  Future<T> _write<T>(Future<T> f) async {
    final r = await f;
    _changed();
    return r;
  }

  @override
  Future<int> start(SessionSetup setup, DateTime at) =>
      _write(_inner.start(setup, at));

  @override
  Future<int> addTurn(int sessionId, TurnRecord turn) =>
      _inner.addTurn(sessionId, turn);

  @override
  Future<void> finish(
    int sessionId, {
    required SessionStatus status,
    required DateTime endedAt,
    SpeechStats? stats,
  }) => _write(
    _inner.finish(sessionId, status: status, endedAt: endedAt, stats: stats),
  );

  @override
  Future<void> saveFeedback(int sessionId, FeedbackResult f, DateTime now) =>
      _write(_inner.saveFeedback(sessionId, f, now));

  @override
  Future<List<SessionSummary>> list({String? query}) =>
      _inner.list(query: query);

  @override
  Future<SessionDetail?> load(int sessionId) => _inner.load(sessionId);

  @override
  Future<SessionSummary?> unfinished() => _inner.unfinished();

  @override
  Future<void> delete(int sessionId) => _write(_inner.delete(sessionId));

  @override
  Future<void> deleteAll() => _write(_inner.deleteAll());

  @override
  Future<List<ReviewItem>> dueReviews(DateTime now) => _inner.dueReviews(now);

  @override
  Future<int> reviewCount(DateTime now) => _inner.reviewCount(now);

  @override
  Future<List<CorrectionStat>> correctionStats({required DateTime since}) =>
      _inner.correctionStats(since: since);

  @override
  Future<List<LevelPoint>> levelHistory() => _inner.levelHistory();

  @override
  Future<void> saveReview(ReviewItem updated) =>
      _write(_inner.saveReview(updated));

  @override
  Future<void> saveAssessment({
    required int? sessionId,
    required String rubricJson,
    required LearnerLevel level,
    required DateTime at,
  }) => _write(
    _inner.saveAssessment(
      sessionId: sessionId,
      rubricJson: rubricJson,
      level: level,
      at: at,
    ),
  );

  @override
  Future<Map<String, Object?>> exportAll() => _inner.exportAll();
}
