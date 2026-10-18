/// Speaking time measured from the recognizer's input level (P2-3).
///
/// Platforms report the level on different scales (dB on Apple, an
/// unspecified RMS value on Android), so nothing absolute is assumed: the
/// quietest level heard is the noise floor, the loudest the speech peak,
/// and time spent in the upper part of that range counts as voiced. When
/// the range is too narrow to tell speech from noise, [voiced] is null and
/// callers fall back to another estimate rather than guess (rule 5).
class VoicedTimeMeter {
  /// Gaps longer than this between level reports are not counted.
  static const maxGap = Duration(milliseconds: 250);

  /// Share of the floor→peak range a level must exceed to count as voice.
  static const threshold = 0.4;

  /// Smallest floor→peak range (in the platform's units) that shows
  /// speech above the noise.
  static const minRange = 3.0;

  static const _minSamples = 8;

  final _samples = <(DateTime, double)>[];

  void add(DateTime at, double level) {
    if (level.isFinite) _samples.add((at, level));
  }

  int get samples => _samples.length;

  /// Measured voiced time, or null when the levels can't support one.
  Duration? get voiced {
    if (_samples.length < _minSamples) return null;
    var floor = double.infinity;
    var peak = double.negativeInfinity;
    for (final (_, level) in _samples) {
      if (level < floor) floor = level;
      if (level > peak) peak = level;
    }
    if (peak - floor < minRange) return null;
    final cut = floor + (peak - floor) * threshold;
    var total = Duration.zero;
    for (var i = 1; i < _samples.length; i++) {
      final (at, level) = _samples[i];
      if (level < cut) continue;
      final gap = at.difference(_samples[i - 1].$1);
      if (gap > Duration.zero && gap <= maxGap) total += gap;
    }
    return total;
  }
}
