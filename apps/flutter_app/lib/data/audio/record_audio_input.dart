import 'dart:io';
import 'dart:typed_data';

import 'package:record/record.dart';

import '../../domain/audio/audio_io.dart';

class RecordAudioInput implements AudioInput {
  RecordAudioInput() : _recorder = AudioRecorder();

  final AudioRecorder _recorder;

  @override
  int get sampleRate => 16000;

  @override
  Future<bool> ensurePermission() => _recorder.hasPermission();

  @override
  Future<Stream<Uint8List>> start() => _recorder.startStream(
    RecordConfig(
      encoder: AudioEncoder.pcm16bits,
      sampleRate: sampleRate,
      numChannels: 1,
      // Keeps the assistant's voice out of the mic for barge-in. On macOS the
      // voice-processing path of record_macos 2.1.1 delivers only zeros, so
      // it stays off there (headphones needed for barge-in, PROGRESS).
      echoCancel: !Platform.isMacOS,
    ),
  );

  @override
  Future<void> stop() async {
    await _recorder.stop();
  }

  @override
  Future<void> dispose() => _recorder.dispose();
}
