/// Speaks text with an on-device voice (free path, ADR-011).
abstract interface class SpeechOutput {
  /// Completes when speaking finishes or [stop] is called. [slow] lowers
  /// the speaking rate for the "slower" action.
  Future<void> speak(String text, {bool slow = false});

  Future<void> stop();
}

/// On-device recognition of one utterance at a time (free path, ADR-011).
abstract interface class SpeechInput {
  /// Permission and recognizer availability. False means the UI should offer
  /// typing instead (spec §11).
  Future<bool> ensureAvailable();

  /// Listens until the learner pauses and returns the final transcript, or
  /// an empty string when nothing was recognized.
  Future<String> listenOnce({void Function(String partial)? onPartial});

  /// Ends listening early; [listenOnce] completes with what was heard.
  Future<void> stop();
}
