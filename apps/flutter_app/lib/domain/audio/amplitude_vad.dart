import 'dart:math' as math;
import 'dart:typed_data';

/// Level reported for digital silence (log of zero).
const silenceFloorDb = -120.0;

/// RMS level of little-endian PCM16 samples in dBFS.
double pcm16Dbfs(Uint8List bytes) {
  final n = bytes.lengthInBytes ~/ 2;
  if (n == 0) return silenceFloorDb;
  final data = ByteData.sublistView(bytes);
  var sumSquares = 0.0;
  for (var i = 0; i < n; i++) {
    final s = data.getInt16(i * 2, Endian.little) / 32768;
    sumSquares += s * s;
  }
  final rms = math.sqrt(sumSquares / n);
  if (rms == 0) return silenceFloorDb;
  return math.max(silenceFloorDb, 20 * math.log(rms) / math.ln10);
}

sealed class VadEvent {
  const VadEvent(this.at);

  /// Offset from the first frame fed to the detector.
  final Duration at;
}

final class VadSpeechStart extends VadEvent {
  const VadSpeechStart(super.at);
}

final class VadSpeechEnd extends VadEvent {
  const VadSpeechEnd(super.at, this.duration);

  /// Voiced span of the utterance, excluding the trailing silence.
  final Duration duration;
}

/// Energy-based voice activity detector (ADR-007, first pass).
///
/// Speech starts after [minSpeech] above [startThresholdDb] and ends after
/// [endSilence] below [endThresholdDb]; pauses shorter than [endSilence]
/// stay inside the utterance. Time comes only from the frame durations fed
/// in, so results are deterministic.
class AmplitudeVad {
  AmplitudeVad({
    this.startThresholdDb = -40,
    this.endThresholdDb = -45,
    this.minSpeech = const Duration(milliseconds: 150),
    this.endSilence = const Duration(milliseconds: 900),
  }) {
    if (endThresholdDb > startThresholdDb) {
      throw ArgumentError('endThresholdDb must be <= startThresholdDb');
    }
  }

  final double startThresholdDb;
  final double endThresholdDb;
  final Duration minSpeech;
  final Duration endSilence;

  Duration _now = Duration.zero;
  Duration? _onset;
  Duration? _lastVoiced;
  bool _speaking = false;
  Duration _userSpeech = Duration.zero;

  bool get speaking => _speaking;

  /// Total voiced time of completed utterances (spec §7.4 `user_speech_ms`).
  Duration get userSpeech => _userSpeech;

  VadEvent? add(double dbfs, Duration frame) {
    final start = _now;
    _now += frame;

    if (_speaking) {
      if (dbfs >= endThresholdDb) {
        _lastVoiced = _now;
      } else if (_now - _lastVoiced! >= endSilence) {
        return _end();
      }
      return null;
    }

    if (dbfs < startThresholdDb) {
      _onset = null;
      return null;
    }
    _onset ??= start;
    _lastVoiced = _now;
    if (_now - _onset! >= minSpeech) {
      _speaking = true;
      return VadSpeechStart(_onset!);
    }
    return null;
  }

  /// Ends an open utterance (e.g. recording stopped mid-speech).
  VadSpeechEnd? flush() => _speaking ? _end() : null;

  VadSpeechEnd _end() {
    final duration = _lastVoiced! - _onset!;
    _userSpeech += duration;
    _speaking = false;
    _onset = null;
    return VadSpeechEnd(_lastVoiced!, duration);
  }
}
