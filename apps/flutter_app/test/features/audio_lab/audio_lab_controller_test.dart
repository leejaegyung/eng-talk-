import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:speaking_coach/app/providers.dart';
import 'package:speaking_coach/features/audio_lab/audio_lab_controller.dart';

import '../../helpers/fakes.dart';

void main() {
  late FakeInput input;
  late FakeOutput output;
  late ProviderContainer container;

  AudioLabController ctrl() => container.read(audioLabProvider.notifier);
  AudioLabState state() => container.read(audioLabProvider);

  Future<void> send(int sample, int n) async {
    for (var i = 0; i < n; i++) {
      input.chunks.add(pcmChunk(sample));
    }
    await pumpEventQueue();
  }

  ProviderContainer make() => ProviderContainer(
    overrides: [
      audioInputProvider.overrideWithValue(input),
      audioOutputProvider.overrideWithValue(output),
    ],
  );

  setUp(() {
    input = FakeInput();
    output = FakeOutput();
    container = make();
    container.listen(audioLabProvider, (_, _) {});
  });
  tearDown(() => container.dispose());

  test('denied permission shows text-mode guidance', () async {
    input = FakeInput(permitted: false);
    container = make()..listen(audioLabProvider, (_, _) {});
    await ctrl().startRecording();
    expect(state().status, LabStatus.micDenied);
  });

  test('records, detects speech and accumulates speech time', () async {
    await ctrl().startRecording();
    expect(state().status, LabStatus.recording);

    await send(8000, 20); // ~-12 dBFS for 1 s
    expect(state().speaking, isTrue);
    expect(state().levelDb, greaterThan(-20));

    await send(0, 20); // silence ends the utterance
    expect(state().speaking, isFalse);
    expect(state().userSpeech, const Duration(seconds: 1));
    expect(state().recorded, const Duration(seconds: 2));

    await ctrl().stopRecording();
    expect(input.stopped, isTrue);
    expect(state().status, LabStatus.idle);
    expect(state().hasRecording, isTrue);
  });

  test('stopping mid-utterance counts the open utterance', () async {
    await ctrl().startRecording();
    await send(8000, 10);
    await ctrl().stopRecording();
    expect(state().userSpeech, const Duration(milliseconds: 500));
  });

  test('playback sends the recording as WAV', () async {
    await ctrl().startRecording();
    await send(8000, 4);
    await ctrl().stopRecording();

    await ctrl().play();

    final (bytes, ext) = output.played.single;
    expect(ext, 'wav');
    expect(bytes.lengthInBytes, 44 + 4 * 1600);
    expect(state().status, LabStatus.idle);
  });

  test('play without a recording does nothing', () async {
    await ctrl().play();
    expect(output.played, isEmpty);
  });

  test('all-zero input for 2 s is reported as no signal', () async {
    await ctrl().startRecording();
    await send(0, 39); // 1.95 s
    expect(state().noSignal, isFalse);
    await send(0, 1);
    expect(state().noSignal, isTrue);
  });

  test('any non-zero sample means the mic is live', () async {
    await ctrl().startRecording();
    await send(1, 1); // -90 dBFS: quiet, but a real signal
    await send(0, 60);
    expect(state().noSignal, isFalse);
  });
}
