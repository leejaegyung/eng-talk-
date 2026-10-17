import 'package:flutter_tts/flutter_tts.dart';

import '../../domain/audio/speech_io.dart';

/// [SpeechOutput] through the platform's built-in voices (free).
class OsSpeechOutput implements SpeechOutput {
  final FlutterTts _tts = FlutterTts();
  Future<void>? _setup;

  Future<void> _ensureSetup() => _setup ??= () async {
    await _tts.setLanguage('en-US');
    await _tts.awaitSpeakCompletion(true);
  }();

  @override
  Future<void> speak(String text) async {
    if (text.trim().isEmpty) return;
    await _ensureSetup();
    await _tts.speak(text);
  }

  @override
  Future<void> stop() async {
    await _tts.stop();
  }
}
