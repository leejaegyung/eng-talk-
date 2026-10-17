import 'dart:typed_data';

/// Wraps little-endian PCM16 samples in a WAV container (for playback and
/// STT upload).
Uint8List pcm16ToWav(
  Uint8List pcm, {
  required int sampleRate,
  int channels = 1,
}) {
  const bytesPerSample = 2;
  final header = ByteData(44)
    ..setUint32(0, 0x52494646) // "RIFF"
    ..setUint32(4, 36 + pcm.lengthInBytes, Endian.little)
    ..setUint32(8, 0x57415645) // "WAVE"
    ..setUint32(12, 0x666d7420) // "fmt "
    ..setUint32(16, 16, Endian.little)
    ..setUint16(20, 1, Endian.little) // PCM
    ..setUint16(22, channels, Endian.little)
    ..setUint32(24, sampleRate, Endian.little)
    ..setUint32(28, sampleRate * channels * bytesPerSample, Endian.little)
    ..setUint16(32, channels * bytesPerSample, Endian.little)
    ..setUint16(34, 16, Endian.little)
    ..setUint32(36, 0x64617461) // "data"
    ..setUint32(40, pcm.lengthInBytes, Endian.little);
  return (BytesBuilder(copy: false)
        ..add(header.buffer.asUint8List())
        ..add(pcm))
      .takeBytes();
}

/// Playback length of [byteCount] bytes of PCM16.
Duration pcm16Duration(
  int byteCount, {
  required int sampleRate,
  int channels = 1,
}) =>
    Duration(microseconds: byteCount * 1000000 ~/ (sampleRate * channels * 2));
