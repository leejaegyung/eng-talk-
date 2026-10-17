/// Nearest-rank percentile of [samples]; [p] in (0, 100].
Duration percentile(List<Duration> samples, double p) {
  if (samples.isEmpty) throw ArgumentError('no samples');
  if (p <= 0 || p > 100) throw ArgumentError.value(p, 'p');
  final sorted = [...samples]..sort();
  final rank = (p / 100 * sorted.length).ceil();
  return sorted[rank - 1];
}
