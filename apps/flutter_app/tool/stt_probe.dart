// Real microphone recognition check on macOS (P1-B1a). Launched with
// `open` so macOS attributes the speech permission to the app itself
// (a test runner launched from a terminal is killed by TCC instead):
//   flutter build macos --debug -t tool/stt_probe.dart
//   open build/macos/Build/Products/Debug/speaking_coach.app
//   say "I would like to book a quiet room"
// Results go to stt_probe.txt in the app's support directory.
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:path_provider/path_provider.dart';
import 'package:speaking_coach/data/speech/os_speech_input.dart';
import 'package:speaking_coach/domain/audio/recognition_hints.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final dir = await getApplicationSupportDirectory();
  await dir.create(recursive: true);
  final out = File('${dir.path}/stt_probe.txt')..writeAsStringSync('');
  void log(String line) =>
      out.writeAsStringSync('$line\n', mode: FileMode.append);

  final mic = OsSpeechInput();
  final available = await mic.ensureAvailable();
  log('available: $available');
  if (available) {
    final hints = recognitionHints(
      phrases: ['Hotel check-in'],
      texts: ['Welcome! Would you like a quiet room or a room with a view?'],
    );
    log('ready');
    final end = DateTime.now().add(const Duration(seconds: 60));
    var heard = 0;
    while (heard < 2 && DateTime.now().isBefore(end)) {
      final text = await mic.listenOnce(hints: hints);
      if (text.isNotEmpty) {
        heard++;
        log('heard: $text');
      }
    }
  }
  log('done');
  exit(0);
}
