import 'session_types.dart';

/// Pure turn-taking state machine (spec §7.3). Audio, network and UI layers
/// report events through [dispatch]; invalid or stale events are rejected
/// without changing state.
class ConversationSessionController {
  SessionSnapshot _state = SessionSnapshot.initial;

  SessionSnapshot get state => _state;

  DispatchResult dispatch(SessionEvent event) {
    final from = _state;

    if (from.phase == SessionPhase.ended) {
      return Rejected(event: event, state: from, reason: 'session ended');
    }
    if (event case ResponseEvent(:final turn) when turn != from.turn) {
      return Rejected(
        event: event,
        state: from,
        reason: 'stale turn $turn (current ${from.turn})',
      );
    }

    final to = _next(from, event);
    if (to == null) {
      return Rejected(event: event, state: from, reason: 'invalid transition');
    }

    final startsTurn =
        to == SessionPhase.processing && from.phase != SessionPhase.processing;
    _state = SessionSnapshot(
      phase: to,
      seq: from.seq + 1,
      turn: startsTurn ? from.turn + 1 : from.turn,
      pauseReason: switch ((to, event)) {
        (SessionPhase.paused, ConnectionLost()) => PauseReason.connectionLost,
        (SessionPhase.paused, PauseRequested(inBackground: true)) =>
          PauseReason.background,
        (SessionPhase.paused, _) => PauseReason.user,
        _ => null,
      },
    );

    return Accepted(
      event: event,
      from: from,
      to: _state,
      interruptsAssistant:
          _assistantActive(from.phase) && event is! ResponseEvent,
    );
  }

  static bool _assistantActive(SessionPhase p) =>
      p == SessionPhase.processing || p == SessionPhase.aiSpeaking;

  static bool _inConversation(SessionPhase p) =>
      p == SessionPhase.listening ||
      p == SessionPhase.userSpeaking ||
      _assistantActive(p);

  static SessionPhase? _next(SessionSnapshot s, SessionEvent event) {
    final p = s.phase;
    return switch (event) {
      StartRequested() when p == SessionPhase.idle => SessionPhase.connecting,
      Connected() when p == SessionPhase.connecting => SessionPhase.listening,
      // From processing/aiSpeaking this is barge-in.
      SpeechStarted() when p == SessionPhase.listening || _assistantActive(p) =>
        SessionPhase.userSpeaking,
      SpeechEnded() when p == SessionPhase.userSpeaking =>
        SessionPhase.processing,
      SpeechDiscarded() when p == SessionPhase.userSpeaking =>
        SessionPhase.listening,
      TextSubmitted() || AssistantTurnRequested()
          when p == SessionPhase.listening =>
        SessionPhase.processing,
      ResponseStarted() when p == SessionPhase.processing =>
        SessionPhase.aiSpeaking,
      ResponseEnded() when p == SessionPhase.aiSpeaking =>
        SessionPhase.listening,
      ResponseFailed() when _assistantActive(p) => SessionPhase.listening,
      PauseRequested() when _inConversation(p) => SessionPhase.paused,
      ConnectionLost()
          when p == SessionPhase.connecting || _inConversation(p) =>
        SessionPhase.paused,
      ResumeRequested() when p == SessionPhase.paused =>
        s.pauseReason == PauseReason.connectionLost
            ? SessionPhase.connecting
            : SessionPhase.listening,
      EndRequested() => SessionPhase.ended,
      _ => null,
    };
  }
}
