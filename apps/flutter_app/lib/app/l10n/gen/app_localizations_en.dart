// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'AI English Speaking Coach';

  @override
  String get homeHeadline => 'Ready to speak English today?';

  @override
  String get homeStartButton => 'Start conversation';

  @override
  String get homeAudioLab => 'Audio test (dev)';

  @override
  String get audioLabTitle => 'Audio test';

  @override
  String get audioLabHint =>
      'Press Record, say a few words in English, then Stop and Play. The recording stays in memory and is discarded when you leave this screen.';

  @override
  String get audioLabRecord => 'Record';

  @override
  String get audioLabStop => 'Stop';

  @override
  String get audioLabPlay => 'Play back';

  @override
  String audioLabLevel(String db) {
    return 'Input level $db dBFS';
  }

  @override
  String get audioLabSpeaking => 'Speaking';

  @override
  String get audioLabSilent => 'Silent';

  @override
  String audioLabSpeechTotal(String seconds) {
    return 'Detected speech ${seconds}s';
  }

  @override
  String audioLabRecorded(String seconds) {
    return 'Recorded ${seconds}s';
  }

  @override
  String get audioLabMicDenied =>
      'Microphone access is off, so voice mode is unavailable. Allow the microphone in system settings, or continue by text.';

  @override
  String get audioLabFailed =>
      'Couldn\'t open the audio device. Check that a microphone is connected.';

  @override
  String get audioLabNoSignal =>
      'No microphone signal. Check that the laptop lid is open and the input device isn\'t muted.';
}
