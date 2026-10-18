import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:speaking_coach/app/active_speech.dart';
import 'package:speaking_coach/data/speech/gemini_speech_input.dart';
import 'package:speaking_coach/domain/audio/speech_io.dart';
import 'package:speaking_coach/domain/providers/provider_failure.dart';

import '../../helpers/fakes.dart';

void main() {
  late FakeInput audio;
  late List<(Uint8List, List<String>)> sent;
  Object? failWith;

  RecordedSpeechInput input() => RecordedSpeechInput(
    audio: audio,
    transcribe: (wav, {context = const []}) async {
      sent.add((wav, context));
      if (failWith != null) throw failWith!;
      return ' I really like Oasis music. ';
    },
  );

  /// [seconds] of 50 ms chunks at [sample] level.
  Future<void> feed(int sample, double seconds) async {
    for (var i = 0; i < seconds * 20; i++) {
      if (audio.chunks.isClosed) return; // recording already ended
      audio.chunks.add(pcmChunk(sample));
      await Future<void>.delayed(Duration.zero);
    }
  }

  setUp(() {
    audio = FakeInput();
    sent = [];
    failWith = null;
  });

  test('speech then 2.5 s of silence: the recording is transcribed', () async {
    final mic = input();
    final partials = <String>[];
    final result = mic.listenOnce(
      hints: ['Who is your favourite band?'],
      onPartial: partials.add,
    );
    await Future<void>.delayed(Duration.zero);
    await feed(6000, 1.5); // talking
    await feed(0, 3); // done
    expect(await result, 'I really like Oasis music.');
    expect(sent.single.$2, ['Who is your favourite band?']);
    final wav = sent.single.$1;
    expect(String.fromCharCodes(wav.sublist(0, 4)), 'RIFF');
    expect(partials, isNotEmpty, reason: 'shows that it is hearing speech');
    expect(audio.stopped, isTrue);
  });

  test('a pause shorter than 2.5 s stays in the same answer', () async {
    final mic = input();
    final result = mic.listenOnce();
    await Future<void>.delayed(Duration.zero);
    await feed(6000, 1);
    await feed(0, 1.5); // thinking mid-answer
    await feed(6000, 1);
    await feed(0, 3);
    await result;
    expect(sent, hasLength(1), reason: 'one recording, not two');
    // Two seconds of speech plus the pauses went into it.
    expect(sent.single.$1.lengthInBytes, greaterThan(32000 * 3));
  });

  test('nothing said before the start timeout: nothing is sent', () async {
    final mic = input();
    final result = mic.listenOnce(
      startTimeout: const Duration(milliseconds: 200),
    );
    await Future<void>.delayed(Duration.zero);
    unawaited(feed(0, 1));
    expect(await result, isEmpty);
    expect(mic.lastIssue, SpeechIssue.noSpeech);
    expect(sent, isEmpty);
  });

  test('stop with a quiet voice still sends what was recorded', () async {
    final mic = input();
    final result = mic.listenOnce();
    await Future<void>.delayed(Duration.zero);
    await feed(40, 1); // under the detector's threshold
    await mic.stop();
    expect(await result, 'I really like Oasis music.');
  });

  test('a failed transcription reports a network problem', () async {
    failWith = const ProviderException(ProviderFailure.network);
    final mic = input();
    final result = mic.listenOnce();
    await Future<void>.delayed(Duration.zero);
    await feed(6000, 1);
    await feed(0, 3);
    expect(await result, isEmpty);
    expect(mic.lastIssue, SpeechIssue.network);
  });

  test('the engine follows the setting at each listen', () async {
    final device = FakeSpeechInput()..queue.add('from the device');
    final recorded = FakeSpeechInput()..queue.add('from Gemini');
    var useGemini = false;
    final mic = SwitchingSpeechInput(
      device: device,
      recorded: recorded,
      useRecorded: () async => useGemini,
    );
    expect(await mic.listenOnce(), 'from the device');
    useGemini = true;
    expect(await mic.listenOnce(), 'from Gemini');
  });
}
