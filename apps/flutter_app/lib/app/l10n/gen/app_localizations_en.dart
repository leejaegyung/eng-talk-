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

  @override
  String get homeVoiceLab => 'Voice chat test (dev)';

  @override
  String get voiceLabTitle => 'Voice chat test';

  @override
  String get voiceLabKeyTitle => 'OpenAI API key';

  @override
  String get voiceLabKeyHint =>
      'The key is kept only in this device\'s secure storage (e.g. Keychain) and is sent only to OpenAI. Usage is billed to your own OpenAI account.';

  @override
  String get voiceLabKeyField => 'Key starting with sk-';

  @override
  String get voiceLabKeySave => 'Save';

  @override
  String get voiceLabKeyStored => 'Key saved';

  @override
  String get voiceLabKeyDelete => 'Delete key';

  @override
  String get voiceLabTest => 'Test connection';

  @override
  String get voiceLabChecking => 'Checking…';

  @override
  String voiceLabModels(String chat, String stt, String tts) {
    return 'Models — chat: $chat · speech-to-text: $stt · text-to-speech: $tts';
  }

  @override
  String get voiceLabTalk => 'Speak';

  @override
  String get voiceLabStopListening => 'Done';

  @override
  String get voiceLabPhaseListening =>
      'Listening… it sends when you stop talking';

  @override
  String get voiceLabPhaseTranscribing => 'Transcribing…';

  @override
  String get voiceLabPhaseThinking => 'Thinking…';

  @override
  String get voiceLabPhaseSpeaking => 'Speaking…';

  @override
  String voiceLabHeard(String text) {
    return 'You: $text';
  }

  @override
  String voiceLabReply(String text) {
    return 'AI: $text';
  }

  @override
  String voiceLabRunsTitle(int count) {
    return 'Measurements ($count)';
  }

  @override
  String voiceLabRunRow(int n, int stt, int token, int tts, int total) {
    return '#$n STT $stt · first token $token · TTS first byte $tts · total $total (ms)';
  }

  @override
  String voiceLabStats(String stt, String token, String tts, String total) {
    return 'p50 / p95 — STT $stt · first token $token · TTS first byte $tts · total $total (ms)';
  }

  @override
  String voiceLabUsage(int input, int output, String seconds, int chars) {
    return 'Measured usage — input tokens $input · output tokens $output · audio uploaded ${seconds}s · characters synthesized $chars';
  }

  @override
  String get failureInvalidKey =>
      'The API key is not valid. Check it and enter it again.';

  @override
  String get failureInsufficientQuota =>
      'Your OpenAI account has no available credit. Check payment or credits under Billing at platform.openai.com.';

  @override
  String get failureRateLimited =>
      'Too many requests. Please try again shortly.';

  @override
  String get failureModelUnavailable =>
      'A required model isn\'t available on this account.';

  @override
  String get failureNetwork =>
      'Can\'t reach the network. Check your internet connection.';

  @override
  String get failureUnknown =>
      'Something went wrong. Please try again shortly.';
}
