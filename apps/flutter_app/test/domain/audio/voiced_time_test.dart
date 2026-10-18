import 'package:flutter_test/flutter_test.dart';
import 'package:speaking_coach/domain/audio/voiced_time.dart';

void main() {
  final t0 = DateTime(2026, 10, 18, 9);

  /// Levels every 100 ms.
  VoicedTimeMeter meter(List<double> levels) {
    final m = VoicedTimeMeter();
    for (final (i, level) in levels.indexed) {
      m.add(t0.add(Duration(milliseconds: 100 * i)), level);
    }
    return m;
  }

  test('Apple dB scale: loud stretch counts as voiced', () {
    final m = meter([
      ...List.filled(5, -55.0), // silence
      ...List.filled(10, -22.0), // 1 s of speech
      ...List.filled(5, -54.0),
    ]);
    expect(m.voiced, const Duration(milliseconds: 1000));
  });

  test('Android RMS scale: same idea on a small range', () {
    final m = meter([
      ...List.filled(4, -2.0),
      ...List.filled(6, 7.5),
      0.0,
      ...List.filled(4, 6.0),
      -1.5,
    ]);
    expect(m.voiced, const Duration(milliseconds: 1000));
  });

  test('flat noise: no measurement instead of a guess', () {
    expect(meter(List.filled(20, -40.0)).voiced, isNull);
    expect(
      meter([for (var i = 0; i < 20; i++) i.isEven ? -40.0 : -39.0]).voiced,
      isNull,
    );
  });

  test('too few reports: no measurement', () {
    expect(meter([-50, -20, -20]).voiced, isNull);
  });

  test('long gaps between reports are not counted', () {
    final m = VoicedTimeMeter();
    for (var i = 0; i < 6; i++) {
      m.add(t0.add(Duration(milliseconds: 100 * i)), -50);
    }
    m
      ..add(t0.add(const Duration(milliseconds: 600)), -20)
      ..add(t0.add(const Duration(seconds: 5)), -20) // after a stall
      ..add(t0.add(const Duration(milliseconds: 5100)), -20);
    expect(m.voiced, const Duration(milliseconds: 200));
  });
}
