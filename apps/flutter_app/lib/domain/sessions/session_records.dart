import '../conversation/session_enums.dart';
import '../feedback/feedback.dart';
import '../learning/learner_level.dart';

/// How a session was set up (S04/S05).
final class SessionSetup {
  const SessionSetup({
    this.mode = SessionMode.daily,
    this.level = LearnerLevel.l2,
    this.topic,
    this.goal,
    this.role,
    this.length = const Duration(minutes: 30),
  });

  final SessionMode mode;
  final LearnerLevel level;
  final String? topic;
  final String? goal;

  /// The AI's character in roleplay.
  final String? role;
  final Duration length;

  SessionSetup copyWith({
    SessionMode? mode,
    LearnerLevel? level,
    String? topic,
    String? goal,
    String? role,
    Duration? length,
    bool clearScenario = false,
  }) => SessionSetup(
    mode: mode ?? this.mode,
    level: level ?? this.level,
    topic: clearScenario ? topic : topic ?? this.topic,
    goal: clearScenario ? goal : goal ?? this.goal,
    role: clearScenario ? role : role ?? this.role,
    length: length ?? this.length,
  );
}

final class TurnRecord {
  const TurnRecord({
    this.id,
    required this.speaker,
    required this.text,
    required this.startedAt,
    this.endedAt,
    this.isRequest = false,
    this.speechMs,
  });

  final int? id;
  final Speaker speaker;
  final String text;
  final DateTime startedAt;
  final DateTime? endedAt;

  /// Quick-action line, not the learner's own answer.
  final bool isRequest;

  /// Measured or estimated speaking time of this turn; null if unknown.
  final int? speechMs;

  int get wordCount =>
      text.trim().isEmpty ? 0 : text.trim().split(RegExp(r'\s+')).length;
}

/// spec §7.4. Values are estimates; [confidence] is null when not measured.
final class SpeechStats {
  const SpeechStats({
    required this.userMs,
    required this.assistantMs,
    required this.turnCount,
    this.confidence,
  });

  final int userMs;
  final int assistantMs;
  final int turnCount;
  final double? confidence;

  /// User share of speaking time only — not of the whole session.
  double? get speakingRatio {
    final total = userMs + assistantMs;
    return total == 0 ? null : userMs / total;
  }
}

final class SessionSummary {
  const SessionSummary({
    required this.id,
    required this.setup,
    required this.startedAt,
    this.endedAt,
    required this.status,
    this.userTurns = 0,
    this.userWords = 0,
    this.stats,
    this.nextTopic,
  });

  final int id;
  final SessionSetup setup;
  final DateTime startedAt;
  final DateTime? endedAt;
  final SessionStatus status;
  final int userTurns;

  /// Words in the learner's own answers (exact, from the transcript).
  final int userWords;
  final SpeechStats? stats;

  /// From the session's feedback, if any.
  final String? nextTopic;

  Duration get duration => (endedAt ?? startedAt).difference(startedAt);
}

final class SessionDetail {
  const SessionDetail({
    required this.summary,
    required this.turns,
    this.feedback,
  });

  final SessionSummary summary;
  final List<TurnRecord> turns;
  final FeedbackResult? feedback;
}

/// A correction to say again later (spec §12.3), spaced by
/// [intervalDays].
final class ReviewItem {
  const ReviewItem({
    required this.id,
    required this.original,
    required this.suggested,
    this.explanationKo,
    required this.dueAt,
    required this.intervalDays,
    required this.repetitions,
  });

  final int id;
  final String original;
  final String suggested;
  final String? explanationKo;
  final DateTime dueAt;
  final int intervalDays;
  final int repetitions;
}
