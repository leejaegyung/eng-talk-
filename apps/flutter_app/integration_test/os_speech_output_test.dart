// On-device TTS really speaks and awaits completion (ADR-011 free voice).
//   flutter test integration_test/os_speech_output_test.dart -d macos
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:speaking_coach/data/speech/os_speech_output.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  test('speaks a sentence and completes when done', () async {
    final voice = OsSpeechOutput();
    final watch = Stopwatch()..start();
    await voice.speak('Hello! Nice to meet you.');
    watch.stop();
    // A real utterance of five words takes well over half a second.
    expect(watch.elapsedMilliseconds, greaterThan(600));
  });

  test('stop cuts a long utterance short', () async {
    final voice = OsSpeechOutput();
    final watch = Stopwatch()..start();
    final speaking = voice.speak(
      'This is a long sentence that would take several seconds to finish '
      'reading out loud if nobody stopped it early.',
    );
    await Future<void>.delayed(const Duration(milliseconds: 700));
    await voice.stop();
    await speaking.timeout(const Duration(seconds: 3));
    expect(watch.elapsedMilliseconds, lessThan(3000));
  });
}
