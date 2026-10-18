/// Speaks text with an on-device voice (free path, ADR-011).
abstract interface class SpeechOutput {
  /// Completes when speaking finishes or [stop] is called. [slow] lowers
  /// the speaking rate for the "slower" action.
  Future<void> speak(String text, {bool slow = false});

  Future<void> stop();
}

/// Why the last listen heard nothing (P2-5). [noSpeech] is the normal
/// silent case; the others need the learner to fix something or type.
enum SpeechIssue { noSpeech, permission, network, audio, busy, other }

/// On-device recognition of one utterance at a time (free path, ADR-011).
abstract interface class SpeechInput {
  /// Permission and recognizer availability. False means the UI should offer
  /// typing instead (spec §11).
  Future<bool> ensureAvailable();

  /// Listens until the learner pauses and returns the final transcript, or
  /// an empty string when nothing was recognized. [hints] are words the
  /// learner is likely to say, used to bias recognition where supported.
  ///
  /// [onLevel] gets the input level as the platform reports it (scale
  /// differs by platform; see VoicedTimeMeter).
  Future<String> listenOnce({
    void Function(String partial)? onPartial,
    void Function(double level)? onLevel,
    List<String> hints = const [],
  });

  /// Ends listening early; [listenOnce] completes with what was heard.
  Future<void> stop();

  /// Set when the last [listenOnce] ended on an error; null otherwise.
  SpeechIssue? get lastIssue;
}
