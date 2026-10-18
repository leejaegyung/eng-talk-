/// Turn-taking states of a conversation session (spec §7.3).
enum SessionPhase {
  idle,
  connecting,
  listening,
  userSpeaking,
  processing,
  aiSpeaking,
  paused,
  ended,
}

/// [background]: the app was hidden (another app, screen locked), spec §3.3.
enum PauseReason { user, background, connectionLost }

/// Immutable view of the session. [seq] grows by one per accepted transition;
/// [turn] identifies the exchange the assistant is expected to answer.
final class SessionSnapshot {
  const SessionSnapshot({
    required this.phase,
    required this.seq,
    required this.turn,
    this.pauseReason,
  });

  static const initial = SessionSnapshot(
    phase: SessionPhase.idle,
    seq: 0,
    turn: 0,
  );

  final SessionPhase phase;
  final int seq;
  final int turn;
  final PauseReason? pauseReason;

  @override
  String toString() =>
      'SessionSnapshot($phase, seq: $seq, turn: $turn'
      '${pauseReason == null ? '' : ', paused: $pauseReason'})';
}

sealed class SessionEvent {
  const SessionEvent();

  @override
  String toString() => runtimeType.toString();
}

final class StartRequested extends SessionEvent {
  const StartRequested();
}

final class Connected extends SessionEvent {
  const Connected();
}

/// VAD detected the learner starting to speak.
final class SpeechStarted extends SessionEvent {
  const SpeechStarted();
}

/// VAD detected the end of the learner's utterance.
final class SpeechEnded extends SessionEvent {
  const SpeechEnded();
}

/// Speech ended but nothing usable was recognized; no turn is taken.
final class SpeechDiscarded extends SessionEvent {
  const SpeechDiscarded();
}

/// The learner sent a typed message instead of speaking.
final class TextSubmitted extends SessionEvent {
  const TextSubmitted();
}

/// The assistant takes the turn without learner input (opening question,
/// requested hint).
final class AssistantTurnRequested extends SessionEvent {
  const AssistantTurnRequested();
}

/// Assistant output events carry the [turn] they answer, so output that
/// arrives after the turn was superseded is rejected.
sealed class ResponseEvent extends SessionEvent {
  const ResponseEvent({required this.turn});

  final int turn;

  @override
  String toString() => '$runtimeType(turn: $turn)';
}

final class ResponseStarted extends ResponseEvent {
  const ResponseStarted({required super.turn});
}

final class ResponseEnded extends ResponseEvent {
  const ResponseEnded({required super.turn});
}

/// The request failed (other than a lost connection); the learner keeps
/// the turn.
final class ResponseFailed extends ResponseEvent {
  const ResponseFailed({required super.turn});
}

final class PauseRequested extends SessionEvent {
  const PauseRequested({this.inBackground = false});

  /// The app was hidden rather than the learner tapping pause.
  final bool inBackground;
}

final class ResumeRequested extends SessionEvent {
  const ResumeRequested();
}

final class ConnectionLost extends SessionEvent {
  const ConnectionLost();
}

final class EndRequested extends SessionEvent {
  const EndRequested();
}

sealed class DispatchResult {
  const DispatchResult();
}

final class Accepted extends DispatchResult {
  const Accepted({
    required this.event,
    required this.from,
    required this.to,
    required this.interruptsAssistant,
  });

  final SessionEvent event;
  final SessionSnapshot from;
  final SessionSnapshot to;

  /// True when pending or playing assistant output must be cancelled
  /// (barge-in, pause, connection loss or end during processing/aiSpeaking).
  final bool interruptsAssistant;

  @override
  String toString() => 'Accepted($event: ${from.phase} → ${to.phase})';
}

final class Rejected extends DispatchResult {
  const Rejected({
    required this.event,
    required this.state,
    required this.reason,
  });

  final SessionEvent event;
  final SessionSnapshot state;
  final String reason;

  @override
  String toString() => 'Rejected($event in ${state.phase}: $reason)';
}
