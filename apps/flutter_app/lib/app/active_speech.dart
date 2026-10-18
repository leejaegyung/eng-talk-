import '../domain/audio/speech_io.dart';

/// The speech recognizer the learner picked (device or Gemini), decided on
/// each listen so a settings change applies at once. Falls back to the
/// device when the Gemini engine isn't usable (no key).
class SwitchingSpeechInput implements SpeechInput {
  SwitchingSpeechInput({
    required this.device,
    required this.recorded,
    required this.useRecorded,
  });

  final SpeechInput device;
  final SpeechInput recorded;
  final Future<bool> Function() useRecorded;
  SpeechInput? _last;

  Future<SpeechInput> _pick() async => await useRecorded() ? recorded : device;

  @override
  Future<bool> ensureAvailable() async => (await _pick()).ensureAvailable();

  @override
  Future<String> listenOnce({
    void Function(String partial)? onPartial,
    void Function(double level)? onLevel,
    List<String> hints = const [],
    Duration startTimeout = const Duration(seconds: 8),
  }) async {
    final input = _last = await _pick();
    return input.listenOnce(
      onPartial: onPartial,
      onLevel: onLevel,
      hints: hints,
      startTimeout: startTimeout,
    );
  }

  @override
  Future<void> stop() async => (_last ?? device).stop();

  @override
  SpeechIssue? get lastIssue => _last?.lastIssue;
}
