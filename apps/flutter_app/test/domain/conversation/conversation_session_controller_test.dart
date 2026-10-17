import 'package:flutter_test/flutter_test.dart';
import 'package:speaking_coach/domain/conversation/conversation_session_controller.dart';
import 'package:speaking_coach/domain/conversation/session_types.dart';

/// Drives [c] through events that must all be accepted.
void drive(ConversationSessionController c, List<SessionEvent> events) {
  for (final e in events) {
    final r = c.dispatch(e);
    expect(r, isA<Accepted>(), reason: 'expected $e to be accepted: $r');
  }
}

/// Starts a session and leaves it listening.
ConversationSessionController listening() {
  final c = ConversationSessionController();
  drive(c, const [StartRequested(), Connected()]);
  return c;
}

void main() {
  group('happy path', () {
    test('idle → connecting → listening → user → processing → ai → listening '
        '→ paused → ended', () {
      final c = ConversationSessionController();
      expect(c.state.phase, SessionPhase.idle);

      final phases = <SessionPhase>[];
      for (final e in <SessionEvent>[
        const StartRequested(),
        const Connected(),
        const SpeechStarted(),
        const SpeechEnded(),
        const ResponseStarted(turn: 1),
        const ResponseEnded(turn: 1),
        const PauseRequested(),
        const EndRequested(),
      ]) {
        phases.add((c.dispatch(e) as Accepted).to.phase);
      }

      expect(phases, [
        SessionPhase.connecting,
        SessionPhase.listening,
        SessionPhase.userSpeaking,
        SessionPhase.processing,
        SessionPhase.aiSpeaking,
        SessionPhase.listening,
        SessionPhase.paused,
        SessionPhase.ended,
      ]);
    });

    test('text input goes listening → processing', () {
      final c = listening();
      final r = c.dispatch(const TextSubmitted()) as Accepted;
      expect(r.to.phase, SessionPhase.processing);
      expect(r.to.turn, 1);
    });

    test('assistant-initiated turn (opening question) goes to processing', () {
      final c = listening();
      drive(c, const [
        AssistantTurnRequested(),
        ResponseStarted(turn: 1),
        ResponseEnded(turn: 1),
      ]);
      expect(c.state.phase, SessionPhase.listening);
    });
  });

  group('sequence and turn ids', () {
    test('seq increases by one per accepted transition only', () {
      final c = ConversationSessionController();
      expect(c.state.seq, 0);
      drive(c, const [StartRequested(), Connected()]);
      expect(c.state.seq, 2);

      c.dispatch(const SpeechEnded()); // rejected: not speaking
      expect(c.state.seq, 2);
    });

    test('each new user or assistant turn gets the next turn number', () {
      final c = listening();
      drive(c, const [
        SpeechStarted(),
        SpeechEnded(),
        ResponseStarted(turn: 1),
        ResponseEnded(turn: 1),
        TextSubmitted(),
      ]);
      expect(c.state.turn, 2);
    });

    test('response for a superseded turn is rejected as stale', () {
      final c = listening();
      // Turn 1 is cancelled by barge-in before the AI starts speaking.
      drive(c, const [
        SpeechStarted(),
        SpeechEnded(),
        SpeechStarted(),
        SpeechEnded(),
      ]);
      expect(c.state.turn, 2);

      final late = c.dispatch(const ResponseStarted(turn: 1));
      expect(late, isA<Rejected>());
      expect((late as Rejected).reason, contains('stale'));
      expect(c.state.phase, SessionPhase.processing);

      expect(c.dispatch(const ResponseStarted(turn: 2)), isA<Accepted>());
    });

    test('response from before a pause is rejected after resume', () {
      final c = listening();
      drive(c, const [TextSubmitted(), PauseRequested(), ResumeRequested()]);
      expect(c.dispatch(const ResponseStarted(turn: 1)), isA<Rejected>());
    });
  });

  group('barge-in and interruption', () {
    test('user speech during AI output interrupts the assistant', () {
      final c = listening();
      drive(c, const [TextSubmitted(), ResponseStarted(turn: 1)]);

      final r = c.dispatch(const SpeechStarted()) as Accepted;
      expect(r.to.phase, SessionPhase.userSpeaking);
      expect(r.interruptsAssistant, isTrue);
    });

    test('user speech while processing cancels the pending response', () {
      final c = listening();
      drive(c, const [TextSubmitted()]);

      final r = c.dispatch(const SpeechStarted()) as Accepted;
      expect(r.to.phase, SessionPhase.userSpeaking);
      expect(r.interruptsAssistant, isTrue);
    });

    test('normal response completion is not an interruption', () {
      final c = listening();
      drive(c, const [TextSubmitted()]);
      final started = c.dispatch(const ResponseStarted(turn: 1)) as Accepted;
      final ended = c.dispatch(const ResponseEnded(turn: 1)) as Accepted;
      expect(started.interruptsAssistant, isFalse);
      expect(ended.interruptsAssistant, isFalse);
    });

    for (final e in const <SessionEvent>[
      PauseRequested(),
      ConnectionLost(),
      EndRequested(),
    ]) {
      test('$e during AI output interrupts the assistant', () {
        final c = listening();
        drive(c, const [TextSubmitted(), ResponseStarted(turn: 1)]);
        expect((c.dispatch(e) as Accepted).interruptsAssistant, isTrue);
      });
    }
  });

  group('pause and connection loss', () {
    test('user pause resumes to listening', () {
      final c = listening();
      drive(c, const [SpeechStarted()]);
      final paused = c.dispatch(const PauseRequested()) as Accepted;
      expect(paused.to.pauseReason, PauseReason.user);

      final resumed = c.dispatch(const ResumeRequested()) as Accepted;
      expect(resumed.to.phase, SessionPhase.listening);
      expect(resumed.to.pauseReason, isNull);
    });

    test('connection loss resumes by reconnecting', () {
      final c = listening();
      final lost = c.dispatch(const ConnectionLost()) as Accepted;
      expect(lost.to.phase, SessionPhase.paused);
      expect(lost.to.pauseReason, PauseReason.connectionLost);

      final resumed = c.dispatch(const ResumeRequested()) as Accepted;
      expect(resumed.to.phase, SessionPhase.connecting);
    });

    test('connection loss while connecting can be retried', () {
      final c = ConversationSessionController();
      drive(c, const [StartRequested(), ConnectionLost(), ResumeRequested()]);
      expect(c.state.phase, SessionPhase.connecting);
    });
  });

  group('rejected transitions', () {
    final cases = <String, (List<SessionEvent>, SessionEvent)>{
      'AI output while the user is speaking': (
        const [SpeechStarted()],
        const ResponseStarted(turn: 0),
      ),
      'AI output while listening': (const [], const ResponseStarted(turn: 0)),
      'response end without a response': (
        const [TextSubmitted()],
        const ResponseEnded(turn: 1),
      ),
      'speech end without speech': (const [], const SpeechEnded()),
      'text while the user is speaking': (
        const [SpeechStarted()],
        const TextSubmitted(),
      ),
      'connect twice': (const [], const Connected()),
      'start twice': (const [], const StartRequested()),
      'resume when not paused': (const [], const ResumeRequested()),
      'pause twice': (const [PauseRequested()], const PauseRequested()),
      'speech while paused': (const [PauseRequested()], const SpeechStarted()),
      'connection lost while paused': (
        const [PauseRequested()],
        const ConnectionLost(),
      ),
    };

    cases.forEach((name, c) {
      final (setup, event) = c;
      test(name, () {
        final ctrl = listening();
        drive(ctrl, setup);
        final before = ctrl.state;

        final r = ctrl.dispatch(event);

        expect(r, isA<Rejected>());
        expect(ctrl.state, same(before), reason: 'state must not change');
      });
    });

    test('nothing but start and end is accepted from idle', () {
      for (final e in const <SessionEvent>[
        Connected(),
        SpeechStarted(),
        TextSubmitted(),
        AssistantTurnRequested(),
        PauseRequested(),
        ResumeRequested(),
        ConnectionLost(),
      ]) {
        expect(ConversationSessionController().dispatch(e), isA<Rejected>());
      }
    });

    test('user pause is not allowed before connecting finishes', () {
      final c = ConversationSessionController();
      drive(c, const [StartRequested()]);
      expect(c.dispatch(const PauseRequested()), isA<Rejected>());
    });

    test('ended is terminal', () {
      final c = listening();
      drive(c, const [EndRequested()]);
      for (final e in const <SessionEvent>[
        StartRequested(),
        Connected(),
        ResumeRequested(),
        EndRequested(),
      ]) {
        expect(c.dispatch(e), isA<Rejected>());
      }
      expect(c.state.phase, SessionPhase.ended);
    });

    test('end is accepted from idle', () {
      final c = ConversationSessionController();
      expect(c.dispatch(const EndRequested()), isA<Accepted>());
    });
  });
}
