import 'package:flutter_test/flutter_test.dart';
import 'package:speaking_coach/domain/metrics/latency_stats.dart';

List<Duration> ms(List<int> v) => [
  for (final x in v) Duration(milliseconds: x),
];

void main() {
  test('nearest-rank p50 and p95 over 10 samples', () {
    final s = ms([900, 100, 800, 200, 700, 300, 600, 400, 500, 1000]);
    expect(percentile(s, 50), const Duration(milliseconds: 500));
    expect(percentile(s, 95), const Duration(milliseconds: 1000));
  });

  test('single sample is every percentile', () {
    expect(percentile(ms([42]), 50), const Duration(milliseconds: 42));
    expect(percentile(ms([42]), 95), const Duration(milliseconds: 42));
  });

  test('does not reorder the input', () {
    final s = ms([3, 1, 2]);
    percentile(s, 50);
    expect(s, ms([3, 1, 2]));
  });

  test('rejects empty input and out-of-range p', () {
    expect(() => percentile([], 50), throwsArgumentError);
    expect(() => percentile(ms([1]), 0), throwsArgumentError);
    expect(() => percentile(ms([1]), 101), throwsArgumentError);
  });
}
