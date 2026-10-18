import 'package:flutter_tts/flutter_tts.dart';

import '../../core/platform/platform_info.dart';
import '../../domain/audio/speech_io.dart';

/// [SpeechOutput] through the platform's built-in voices (free).
class OsSpeechOutput implements SpeechOutput {
  final FlutterTts _tts = FlutterTts();
  Future<void>? _setup;

  Future<void> _ensureSetup() => _setup ??= () async {
    await _tts.setLanguage('en-US');
    await _tts.awaitSpeakCompletion(true);
    if (PlatformInfo.isIOS) {
      // Shared with the recognizer: without this, replies after listening
      // play quietly through the earpiece, and Bluetooth is ignored.
      await _tts.setSharedInstance(true);
      await _tts.setIosAudioCategory(
        IosTextToSpeechAudioCategory.playAndRecord,
        [
          IosTextToSpeechAudioCategoryOptions.defaultToSpeaker,
          IosTextToSpeechAudioCategoryOptions.allowBluetooth,
          IosTextToSpeechAudioCategoryOptions.allowBluetoothA2DP,
        ],
      );
    }
  }();

  // flutter_tts treats 0.5 as the platform's normal rate.
  static const _normalRate = 0.5;
  static const _slowRate = 0.38;

  @override
  Future<void> speak(String text, {bool slow = false}) async {
    if (text.trim().isEmpty) return;
    await _ensureSetup();
    await _tts.setSpeechRate(slow ? _slowRate : _normalRate);
    await _tts.speak(text);
  }

  @override
  Future<void> stop() async {
    await _tts.stop();
  }
}
