/// Session behaviour that isn't the model's job (spec §4.2
/// ConversationPolicyEngine): the hint ladder, quick actions, correction
/// timing and the time-boxed session phases. Produces notes for
/// PromptComposer; pure and clock-free (callers pass elapsed time).
library;

enum HintStage { word, sentenceStarter, korean, example }

/// Quick actions on the live screen (spec §3.3).
enum CoachAction { hint, repeat, slower, correctLast, changeTopic }

/// spec §2.4: warm-up → expression activation → focused talk → wrap-up.
enum LessonStage { warmUp, activation, focus, wrapUp }

/// What to send for an action: a visible learner line plus notes for the
/// next request.
final class ActionRequest {
  const ActionRequest(this.userText, this.notes, {this.hintStage});

  final String userText;
  final List<String> notes;
  final HintStage? hintStage;
}

class ConversationPolicy {
  ConversationPolicy({
    this.length = const Duration(minutes: 30),
    this.correctionInterval,
    this.hintAfterSilence = const Duration(seconds: 20),
  });

  final Duration length;

  /// Null = corrections only at the end or on request (default).
  final Duration? correctionInterval;
  final Duration hintAfterSilence;

  HintStage? _hint;
  bool _slower = false;
  Duration _lastCorrection = Duration.zero;

  bool get slower => _slower;

  ActionRequest act(CoachAction action) => switch (action) {
    CoachAction.hint => _nextHint(),
    CoachAction.repeat => const ActionRequest('Could you say that again?', [
      'Repeat your last question in simpler words. Do not add anything new.',
    ]),
    CoachAction.slower => _slowDown(),
    CoachAction.correctLast => const ActionRequest(
      'Could you correct my last sentence?',
      [
        'Correct only the last learner message before this request: give the '
            'natural version and a very short reason, then repeat your '
            'question so they can try again.',
      ],
    ),
    CoachAction.changeTopic => const ActionRequest(
      'Can we talk about something else?',
      ['Move to a different topic that suits the mode and ask one question.'],
    ),
  };

  ActionRequest _nextHint() {
    final i = _hint == null ? 0 : _hint!.index + 1;
    final stage = HintStage.values[i.clamp(0, HintStage.values.length - 1)];
    _hint = stage;
    return ActionRequest('Could you give me a hint?', [
      _hintNotes[stage]!,
    ], hintStage: stage);
  }

  ActionRequest _slowDown() {
    _slower = true;
    return const ActionRequest('Could you speak more slowly and simply?', [
      'Repeat your last question more slowly with simpler words.',
    ]);
  }

  /// A real learner answer ends the current hint ladder.
  void learnerSpoke() => _hint = null;

  /// Notes for every request at [elapsed] into the session.
  List<String> standingNotes(Duration elapsed) => [
    if (_slower) 'For the rest of the session use shorter, simpler sentences.',
    ?_stageNote(stageAt(elapsed)),
    if (correctionDue(elapsed))
      'At a natural pause, briefly point out at most one important mistake '
          'from recent learner messages, then continue the conversation.',
  ];

  bool correctionDue(Duration elapsed) {
    final every = correctionInterval;
    return every != null && elapsed - _lastCorrection >= every;
  }

  void correctionGiven(Duration elapsed) => _lastCorrection = elapsed;

  LessonStage stageAt(Duration elapsed) {
    final f = elapsed.inMilliseconds / length.inMilliseconds;
    // 3 / 4 / 18 / 5 out of 30 minutes.
    if (f < 3 / 30) return LessonStage.warmUp;
    if (f < 7 / 30) return LessonStage.activation;
    if (f < 25 / 30) return LessonStage.focus;
    return LessonStage.wrapUp;
  }

  bool suggestHint(Duration silence) => silence >= hintAfterSilence;

  static String? _stageNote(LessonStage p) => switch (p) {
    LessonStage.warmUp =>
      'Warm-up: ask easy, familiar questions to get them talking.',
    LessonStage.activation =>
      'Expression activation: naturally model one or two useful expressions '
          'for this topic and invite the learner to use them.',
    LessonStage.focus =>
      'Focused practice: maximize learner talk with follow-up questions.',
    LessonStage.wrapUp =>
      'Time to wrap up: within one or two turns, close the conversation '
          'warmly. Detailed feedback is given separately.',
  };

  static const _hintNotes = {
    HintStage.word:
        'Hint level 1: give only a single key word or short phrase they '
        'could use. Do not answer for them.',
    HintStage.sentenceStarter:
        'Hint level 2: give the first few words of a possible answer as a '
        'sentence starter.',
    HintStage.korean:
        'Hint level 3: explain in one short Korean sentence what they could '
        'say, then ask the question again in English.',
    HintStage.example:
        'Hint level 4: give one short example answer, then ask them to say '
        'it in their own words.',
  };
}
