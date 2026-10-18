import 'dart:async';

import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../../core/logging/app_logger.dart';
import '../../domain/audio/speech_io.dart';

/// [SpeechInput] through the platform recognizer (free). Recognition may run
/// on the OS vendor's servers depending on platform settings.
class OsSpeechInput implements SpeechInput {
  static const _log = AppLogger('speech.input');

  /// Learners pause mid-sentence; end the turn only after a longer silence.
  static const _pauseFor = Duration(seconds: 3);
  static const _listenFor = Duration(seconds: 60);

  final SpeechToText _stt = SpeechToText();
  Completer<String>? _done;
  String _last = '';

  @override
  Future<bool> ensureAvailable() async {
    try {
      return await _stt.initialize(onError: _onError, onStatus: _onStatus);
    } on Exception catch (e) {
      _log.warning('speech recognizer unavailable: ${e.runtimeType}');
      return false;
    }
  }

  @override
  Future<String> listenOnce({
    void Function(String partial)? onPartial,
    List<String> hints = const [],
  }) async {
    if (!await ensureAvailable()) return '';
    final done = _done = Completer<String>();
    _last = '';
    await _stt.listen(
      onResult: (SpeechRecognitionResult r) {
        _last = r.recognizedWords;
        onPartial?.call(_last);
        if (r.finalResult) _finish();
      },
      listenOptions: SpeechListenOptions(
        localeId: 'en_US',
        listenMode: ListenMode.dictation,
        partialResults: true,
        cancelOnError: true,
        pauseFor: _pauseFor,
        listenFor: _listenFor,
        // Apple: contextualStrings; Android 13+: biasing strings.
        contextualPhrases: hints.isEmpty ? null : hints,
        autoPunctuation: true,
      ),
    );
    return done.future;
  }

  @override
  Future<void> stop() async {
    await _stt.stop();
  }

  void _onStatus(String status) {
    if (status == SpeechToText.doneStatus ||
        status == SpeechToText.notListeningStatus) {
      _finish();
    }
  }

  /// "No match" and timeouts end the turn with whatever was heard.
  void _onError(SpeechRecognitionError error) {
    _log.info('recognition ended: ${error.errorMsg}');
    _finish();
  }

  void _finish() {
    final done = _done;
    if (done != null && !done.isCompleted) done.complete(_last.trim());
  }
}
