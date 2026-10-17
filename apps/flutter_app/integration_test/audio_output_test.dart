// Real playback on the desktop audio stack (P0-T3) and S4 cleanup check.
//   flutter test integration_test/audio_output_test.dart -d macos
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:path_provider/path_provider.dart';
import 'package:speaking_coach/data/audio/temp_file_audio_output.dart';
import 'package:speaking_coach/domain/audio/wav.dart';

/// 0.3 s, 440 Hz, quiet sine tone.
Uint8List tone() {
  const rate = 16000;
  final data = ByteData(rate * 3 ~/ 10 * 2);
  for (var i = 0; i < data.lengthInBytes ~/ 2; i++) {
    final v = (math.sin(2 * math.pi * 440 * i / rate) * 3000).round();
    data.setInt16(i * 2, v, Endian.little);
  }
  return pcm16ToWav(data.buffer.asUint8List(), sampleRate: rate);
}

Future<Directory> playbackDir() async => Directory(
  '${(await getTemporaryDirectory()).path}/${TempFileAudioOutput.dirName}',
).create(recursive: true);

Future<List<String>> leftovers() async {
  final dir = await playbackDir();
  return [
    for (final e in dir.listSync())
      if (e.uri.pathSegments.last.startsWith('playback_')) e.path,
  ];
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  test('plays to completion and leaves no temp audio behind', () async {
    final output = TempFileAudioOutput();
    addTearDown(output.dispose);

    final watch = Stopwatch()..start();
    await output.play(tone(), fileExtension: 'wav');
    watch.stop();

    expect(watch.elapsedMilliseconds, greaterThanOrEqualTo(250));
    expect(await leftovers(), isEmpty);
  });

  test('stop ends playback early and still deletes the file', () async {
    final output = TempFileAudioOutput();
    addTearDown(output.dispose);

    final playing = output.play(
      pcm16ToWav(Uint8List(16000 * 2 * 5), sampleRate: 16000),
      fileExtension: 'wav',
    );
    await Future<void>.delayed(const Duration(milliseconds: 300));
    await output.stop();
    await playing.timeout(const Duration(seconds: 2));

    expect(await leftovers(), isEmpty);
  });

  test('sweeps files left by an earlier crash', () async {
    final dir = await playbackDir();
    await File('${dir.path}/playback_crashed.wav').writeAsBytes([0]);

    final output = TempFileAudioOutput();
    addTearDown(output.dispose);
    await output.play(tone(), fileExtension: 'wav');

    expect(await leftovers(), isEmpty);
  });
}
