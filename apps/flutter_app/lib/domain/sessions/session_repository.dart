import '../conversation/session_enums.dart';
import '../feedback/feedback.dart';
import '../learning/learner_level.dart';
import 'growth_stats.dart';
import 'session_records.dart';

/// Local store for sessions, transcripts, feedback and review (spec §9).
abstract interface class SessionRepository {
  Future<int> start(SessionSetup setup, DateTime at);

  /// Returns the stored turn id.
  Future<int> addTurn(int sessionId, TurnRecord turn);

  Future<void> finish(
    int sessionId, {
    required SessionStatus status,
    required DateTime endedAt,
    SpeechStats? stats,
  });

  /// Stores feedback, its corrections and expressions, and queues each
  /// correction for review starting [now].
  Future<void> saveFeedback(int sessionId, FeedbackResult f, DateTime now);

  /// Most recent first; [query] matches topic or transcript text.
  Future<List<SessionSummary>> list({String? query});

  Future<SessionDetail?> load(int sessionId);

  /// A session left active or paused (app closed or crashed).
  Future<SessionSummary?> unfinished();

  Future<void> delete(int sessionId);

  Future<void> deleteAll();

  Future<List<ReviewItem>> dueReviews(DateTime now);

  Future<int> reviewCount(DateTime now);

  Future<void> saveReview(ReviewItem updated);

  Future<void> saveAssessment({
    required int? sessionId,
    required String rubricJson,
    required LearnerLevel level,
    required DateTime at,
  });

  /// Corrections from sessions started at or after [since] (S10).
  Future<List<CorrectionStat>> correctionStats({required DateTime since});

  /// Suggested expressions from feedback, newest first, one per phrase.
  Future<List<Expression>> recentExpressions({int limit = 10});

  /// Assessed levels, oldest first (S10).
  Future<List<LevelPoint>> levelHistory();

  /// Everything except credentials, for export (spec §9.2).
  Future<Map<String, Object?>> exportAll();

  /// Restores a backup from [exportAll], merging: sessions already here are
  /// skipped. Throws `FormatException` for anything else.
  Future<ImportResult> importAll(Map<String, Object?> data, DateTime now);
}

final class ImportResult {
  const ImportResult({required this.added, required this.skipped});

  final int added;

  /// Already present (same start time and mode).
  final int skipped;
}
