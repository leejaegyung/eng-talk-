import 'dart:typed_data';

/// Microphone capture as PCM16 little-endian mono at [sampleRate].
abstract interface class AudioInput {
  int get sampleRate;

  /// Requests permission if needed. False means the UI should offer text
  /// mode instead (spec §11).
  Future<bool> ensurePermission();

  Future<Stream<Uint8List>> start();

  Future<void> stop();

  Future<void> dispose();
}

/// Plays encoded audio held in memory. Raw audio must not outlive playback
/// on disk (docs/security.md S4).
abstract interface class AudioOutput {
  /// Completes when playback finishes or [stop] is called.
  Future<void> play(Uint8List bytes, {required String fileExtension});

  Future<void> stop();

  Future<void> dispose();
}
