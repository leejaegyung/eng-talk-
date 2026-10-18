import 'dart:async';
import 'dart:typed_data';

import '../../core/logging/app_logger.dart';
import '../../domain/audio/amplitude_vad.dart';
import '../../domain/audio/audio_io.dart';
import '../../domain/audio/speech_io.dart';
import '../../domain/audio/wav.dart';
import '../../domain/providers/provider_failure.dart';

/// Turns recorded speech into text with a model (Gemini free key, user
/// request 2026-10-18: "like GPT hears audio"). Device recognizers mishear
/// names and accents ("Oasis music" → "watch this music").
typedef Transcriber = Future<String> Function(
  Uint8List wav, {
  List<String> context,
});

/// [SpeechInput] that records the learner, finds the end of the answer
/// with a level-based voice detector, and sends the recording to a model
/// for transcription. Audio lives only in memory for that request (S4).
class RecordedSpeechInput implements SpeechInput {
  RecordedSpeechInput({required this._audio, required this._transcribe});

  static const _log = AppLogger('speech.recorded');

  /// Silence after speech that ends the answer.
  static const _endSilence = Duration(milliseconds: 2500);
  static const _maxLength = Duration(seconds: 60);

  final AudioInput _audio;
  final Transcriber _transcribe;
  Completer<void>? _stopped;
  bool _stopTapped = false;

  @override
  SpeechIssue? lastIssue;

  @override
  Future<bool> ensureAvailable() => _audio.ensurePermission();

  @override
  Future<String> listenOnce({
    void Function(String partial)? onPartial,
    void Function(double level)? onLevel,
    List<String> hints = const [],
    Duration startTimeout = const Duration(seconds: 8),
  }) async {
    lastIssue = null;
    _stopTapped = false;
    final stopped = _stopped = Completer<void>();
    // A little more sensitive than the default: phone mics are often quiet.
    final vad = AmplitudeVad(
      startThresholdDb: -45,
      endThresholdDb: -50,
      endSilence: _endSilence,
    );
    final pcm = BytesBuilder(copy: false);
    Duration frameOf(int bytes) =>
        Duration(microseconds: bytes * 1000000 ~/ (_audio.sampleRate * 2));
    var heardSpeech = false;
    var recorded = Duration.zero;

    final Stream<Uint8List> stream;
    try {
      stream = await _audio.start();
    } on Object catch (e) {
      _log.warning('recording failed: ${e.runtimeType}');
      lastIssue = SpeechIssue.audio;
      return '';
    }
    final noSpeech = Timer(startTimeout, () {
      if (!heardSpeech && !stopped.isCompleted) stopped.complete();
    });
    final sub = stream.listen((chunk) {
      if (stopped.isCompleted) return;
      pcm.add(chunk);
      final frame = frameOf(chunk.lengthInBytes);
      recorded += frame;
      final level = pcm16Dbfs(chunk);
      onLevel?.call(level);
      switch (vad.add(level, frame)) {
        case VadSpeechStart():
          heardSpeech = true;
          onPartial?.call('…');
        case VadSpeechEnd():
          if (!stopped.isCompleted) stopped.complete();
        case null:
          break;
      }
      if (recorded >= _maxLength && !stopped.isCompleted) stopped.complete();
    });
    await stopped.future;
    noSpeech.cancel();
    await sub.cancel();
    await _audio.stop();
    _stopped = null;

    // A quiet voice may stay under the detector's threshold; when the
    // learner taps stop, what was recorded is still sent.
    final tappedWithAudio =
        _stopTapped && recorded > const Duration(milliseconds: 600);
    if (!heardSpeech && !tappedWithAudio) {
      lastIssue = SpeechIssue.noSpeech;
      return '';
    }
    final wav = pcm16ToWav(pcm.takeBytes(), sampleRate: _audio.sampleRate);
    try {
      return (await _transcribe(wav, context: hints)).trim();
    } on ProviderException catch (e) {
      _log.warning('transcription failed: $e');
      lastIssue = e.failure == ProviderFailure.network
          ? SpeechIssue.network
          : SpeechIssue.other;
      return '';
    }
  }

  /// Ends the recording now; what was said so far is transcribed.
  @override
  Future<void> stop() async {
    final stopped = _stopped;
    if (stopped != null && !stopped.isCompleted) {
      _stopTapped = true;
      stopped.complete();
    }
  }
}
