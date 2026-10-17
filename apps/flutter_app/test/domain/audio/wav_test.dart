import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:speaking_coach/domain/audio/wav.dart';

void main() {
  test('wraps PCM16 mono in a 44-byte RIFF/WAVE header', () {
    final pcm = Uint8List.fromList([1, 2, 3, 4]);
    final wav = pcm16ToWav(pcm, sampleRate: 16000);
    final h = ByteData.sublistView(wav);

    expect(wav.lengthInBytes, 44 + 4);
    expect(ascii.decode(wav.sublist(0, 4)), 'RIFF');
    expect(h.getUint32(4, Endian.little), 36 + 4);
    expect(ascii.decode(wav.sublist(8, 16)), 'WAVEfmt ');
    expect(h.getUint16(20, Endian.little), 1); // PCM
    expect(h.getUint16(22, Endian.little), 1); // channels
    expect(h.getUint32(24, Endian.little), 16000);
    expect(h.getUint32(28, Endian.little), 32000); // byte rate
    expect(h.getUint16(32, Endian.little), 2); // block align
    expect(h.getUint16(34, Endian.little), 16); // bits
    expect(ascii.decode(wav.sublist(36, 40)), 'data');
    expect(h.getUint32(40, Endian.little), 4);
    expect(wav.sublist(44), pcm);
  });

  test('pcm16Duration', () {
    expect(pcm16Duration(32000, sampleRate: 16000), const Duration(seconds: 1));
    expect(
      pcm16Duration(1600, sampleRate: 16000),
      const Duration(milliseconds: 50),
    );
  });
}
