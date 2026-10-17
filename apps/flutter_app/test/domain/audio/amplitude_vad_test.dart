import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:speaking_coach/domain/audio/amplitude_vad.dart';

const frame = Duration(milliseconds: 50);
const loud = -20.0;
const quiet = -60.0;

/// Feeds [n] frames at [db] and returns the non-null events.
List<VadEvent> feed(AmplitudeVad vad, double db, int n) => [
  for (var i = 0; i < n; i++) ?vad.add(db, frame),
];

Uint8List pcm16(List<int> samples) {
  final data = ByteData(samples.length * 2);
  for (var i = 0; i < samples.length; i++) {
    data.setInt16(i * 2, samples[i], Endian.little);
  }
  return data.buffer.asUint8List();
}

void main() {
  group('pcm16Dbfs', () {
    test('full-scale square wave is ~0 dBFS', () {
      final db = pcm16Dbfs(pcm16([32767, -32768, 32767, -32768]));
      expect(db, closeTo(0, 0.01));
    });

    test('half amplitude is ~-6 dBFS', () {
      expect(pcm16Dbfs(pcm16([16384, -16384])), closeTo(-6.02, 0.01));
    });

    test('digital silence is clamped to the floor', () {
      expect(pcm16Dbfs(pcm16([0, 0, 0])), silenceFloorDb);
    });

    test('empty buffer is the floor', () {
      expect(pcm16Dbfs(Uint8List(0)), silenceFloorDb);
    });
  });

  group('AmplitudeVad', () {
    late AmplitudeVad vad;
    setUp(() => vad = AmplitudeVad());

    test('silence produces no events', () {
      expect(feed(vad, quiet, 100), isEmpty);
      expect(vad.speaking, isFalse);
      expect(vad.userSpeech, Duration.zero);
    });

    test('a click shorter than minSpeech is ignored', () {
      expect(feed(vad, loud, 2), isEmpty); // 100 ms < 150 ms
      expect(feed(vad, quiet, 40), isEmpty);
      expect(vad.userSpeech, Duration.zero);
    });

    test('speech start is reported at the onset, not at confirmation', () {
      feed(vad, quiet, 10); // 0..500 ms
      final events = feed(vad, loud, 3); // onset at 500 ms
      expect(events, hasLength(1));
      final start = events.single as VadSpeechStart;
      expect(start.at, const Duration(milliseconds: 500));
      expect(vad.speaking, isTrue);
    });

    test('speech ends after endSilence and counts only the voiced span', () {
      feed(vad, loud, 20); // 0..1000 ms voiced
      expect(feed(vad, quiet, 17), isEmpty); // 850 ms < 900 ms
      final events = feed(vad, quiet, 1); // 900 ms of silence
      final end = events.single as VadSpeechEnd;
      expect(end.at, const Duration(milliseconds: 1000));
      expect(end.duration, const Duration(milliseconds: 1000));
      expect(vad.speaking, isFalse);
      expect(vad.userSpeech, const Duration(milliseconds: 1000));
    });

    test('short pauses inside an utterance do not split it', () {
      feed(vad, loud, 10);
      feed(vad, quiet, 10); // 500 ms pause < 900 ms
      feed(vad, loud, 10);
      final events = feed(vad, quiet, 18);
      expect(events.single, isA<VadSpeechEnd>());
      expect(
        (events.single as VadSpeechEnd).duration,
        const Duration(milliseconds: 1500),
      );
    });

    test('userSpeech accumulates across utterances', () {
      feed(vad, loud, 10);
      feed(vad, quiet, 18);
      feed(vad, loud, 4);
      feed(vad, quiet, 18);
      expect(vad.userSpeech, const Duration(milliseconds: 700));
    });

    test('hysteresis: level between end and start thresholds keeps speech', () {
      feed(vad, loud, 10);
      // -43 dB is below start (-40) but above end (-45): still speaking.
      expect(feed(vad, -43, 30), isEmpty);
      expect(vad.speaking, isTrue);
    });

    test('flush ends an open utterance', () {
      feed(vad, loud, 10);
      final end = vad.flush();
      expect(end, isA<VadSpeechEnd>());
      expect(vad.userSpeech, const Duration(milliseconds: 500));
      expect(vad.flush(), isNull);
    });

    test('rejects inverted thresholds', () {
      expect(
        () => AmplitudeVad(startThresholdDb: -50, endThresholdDb: -40),
        throwsArgumentError,
      );
    });
  });
}
