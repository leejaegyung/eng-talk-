import 'dart:async';

import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../../core/logging/app_logger.dart';
import '../../core/platform/platform_info.dart';
import '../../domain/audio/alternate_choice.dart';
import '../../domain/audio/speech_io.dart';

/// [SpeechInput] through the platform recognizer (free). Recognition may run
/// on the OS vendor's servers depending on platform settings.
class OsSpeechInput implements SpeechInput {
  static const _log = AppLogger('speech.input');

  /// After the first words, this much silence ends the turn. The plugin's
  /// own pause timer isn't used: it also counts the thinking time before the
  /// first word, so the mic went off before learners started (user report
  /// 2026-10-18).
  static const _endSilence = Duration(milliseconds: 2500);
  static const _listenFor = Duration(seconds: 60);

  /// Android reports "not listening" before the final result arrives; the
  /// final one is more accurate (and has the last words), so wait for it.
  static const _finalGrace = Duration(milliseconds: 1500);

  /// Android ends recognition after a second or two of silence, whatever
  /// was asked, which cuts learners off mid-thought. After such a stop the
  /// recognizer is started again; the turn ends only if no new words come
  /// within this window.
  static const _resumeWindow = Duration(milliseconds: 1800);

  final SpeechToText _stt = SpeechToText();

  /// SpeechToText is a singleton that keeps the status and error handlers
  /// from its first initialize; they forward to whichever instance listens.
  static OsSpeechInput? _active;
  static void _status(String status) => _active?._onStatus(status);
  static void _error(SpeechRecognitionError error) => _active?._onError(error);
  _Segment? _current;
  int _segments = 0;
  DateTime _lastStatusAt = DateTime.fromMillisecondsSinceEpoch(0);
  Timer? _grace;
  bool _stopRequested = false;

  @override
  SpeechIssue? lastIssue;

  @override
  Future<bool> ensureAvailable() async {
    try {
      return await _stt.initialize(onError: _error, onStatus: _status);
    } on Exception catch (e) {
      _log.warning('speech recognizer unavailable: ${e.runtimeType}');
      return false;
    }
  }

  @override
  Future<String> listenOnce({
    void Function(String partial)? onPartial,
    void Function(double level)? onLevel,
    List<String> hints = const [],
    Duration startTimeout = const Duration(seconds: 8),
  }) async {
    if (!await ensureAvailable()) return '';
    _active = this;
    _stopRequested = false;
    lastIssue = null;
    final parts = <String>[];
    String joined([String current = '']) =>
        [...parts, if (current.isNotEmpty) current].join(' ');

    var resuming = false;
    // Thinking time is ours to give: recognizers give up on silence sooner
    // (Chrome ~8 s, Android ~5 s), so they are restarted until it's used up.
    final waitUntil = DateTime.now().add(startTimeout);
    while (true) {
      final remaining = waitUntil.difference(DateTime.now());
      final segment = await _listenSegment(
        onPartial: (p) => onPartial?.call(joined(p)),
        onLevel: onLevel,
        hints: [...hints, ...parts],
        // Resuming after a stop the recognizer made itself: nothing new
        // within the window means the learner has finished.
        startWithin: resuming ? _resumeWindow : remaining,
      );
      // Let the recognizer wind down before listening again: a late final
      // result still updates this part, and a late "done" can't end the
      // next one.
      await _settle();
      final text = segment.text;
      if (text.isNotEmpty) parts.add(text);
      final stillWaiting =
          parts.isEmpty &&
          !_stopRequested &&
          (lastIssue == null || lastIssue == SpeechIssue.noSpeech) &&
          waitUntil.difference(DateTime.now()) >
              const Duration(milliseconds: 500);
      if (stillWaiting) {
        lastIssue = null;
        continue;
      }
      final keepGoing =
          (PlatformInfo.isAndroid || PlatformInfo.isWeb) &&
          text.isNotEmpty &&
          !_stopRequested &&
          // Our own silence timer already waited out the learner.
          !segment.endedBySilence &&
          (lastIssue == null || lastIssue == SpeechIssue.noSpeech);
      if (!keepGoing) break;
      // A silence after real words is not a problem to report.
      lastIssue = null;
      resuming = true;
    }
    if (parts.isNotEmpty && lastIssue == SpeechIssue.noSpeech) {
      lastIssue = null;
    }
    return joined().trim();
  }

  /// One recognizer session. Results are tied to it, so a result arriving
  /// after the next session started can't overwrite or end that one.
  Future<_Segment> _listenSegment({
    required void Function(String partial) onPartial,
    void Function(double level)? onLevel,
    required List<String> hints,
    required Duration startWithin,
  }) async {
    final segment = _current = _Segment(++_segments, hints);
    _grace?.cancel();
    // Waiting for the first words, then for the end of a silence.
    var timer = Timer(startWithin, () => unawaited(_stt.stop()));
    await _stt.listen(
      onResult: (SpeechRecognitionResult r) {
        if (identical(segment, _current) && r.recognizedWords.isNotEmpty) {
          timer.cancel();
          timer = Timer(_endSilence, () {
            segment.endedBySilence = true;
            unawaited(_stt.stop());
          });
        }
        segment.update(
          r.finalResult
              ? chooseAlternate([
                  for (final a in r.alternates)
                    (a.recognizedWords, a.confidence),
                ], segment.hints)
              : r.recognizedWords,
        );
        if (!identical(segment, _current)) return;
        onPartial(segment.text);
        if (r.finalResult) _finish();
      },
      onSoundLevelChange: onLevel,
      listenOptions: SpeechListenOptions(
        localeId: 'en_US',
        listenMode: ListenMode.dictation,
        partialResults: true,
        cancelOnError: true,
        listenFor: _listenFor,
        // Apple: contextualStrings; Android 13+: biasing strings.
        contextualPhrases: hints.isEmpty ? null : hints,
        autoPunctuation: true,
      ),
    );
    await segment.done.future;
    timer.cancel();
    return segment;
  }

  /// Waits until the recognizer has stopped and gone quiet (at most 2 s).
  Future<void> _settle() async {
    final until = DateTime.now().add(const Duration(seconds: 2));
    while (DateTime.now().isBefore(until)) {
      final quiet =
          DateTime.now().difference(_lastStatusAt) >
          const Duration(milliseconds: 250);
      if (!_stt.isListening && quiet) return;
      await Future<void>.delayed(const Duration(milliseconds: 50));
    }
  }

  @override
  Future<void> stop() async {
    _stopRequested = true;
    await _stt.stop();
  }

  void _onStatus(String status) {
    _lastStatusAt = DateTime.now();
    if (status == SpeechToText.doneStatus) {
      _finish();
    } else if (status == SpeechToText.notListeningStatus) {
      // The final result usually follows; finish without it only if it
      // doesn't come.
      _grace?.cancel();
      _grace = Timer(_finalGrace, _finish);
    }
  }

  /// "No match" and timeouts end the turn with whatever was heard; other
  /// errors are kept so the UI can say what to fix.
  void _onError(SpeechRecognitionError error) {
    _log.info('recognition ended: ${error.errorMsg}');
    lastIssue = issueFor(error.errorMsg);
    _finish();
  }

  /// Platform error codes to what the learner can do: native codes from
  /// the speech_to_text docs, and the browser's Web Speech codes.
  static SpeechIssue issueFor(String code) => switch (code) {
    'error_no_match' ||
    'error_speech_timeout' ||
    'no-speech' ||
    'aborted' => SpeechIssue.noSpeech,
    'error_permission' ||
    'error_insufficient_permissions' ||
    'not-allowed' ||
    'service-not-allowed' => SpeechIssue.permission,
    'error_network' ||
    'error_network_timeout' ||
    'error_server' ||
    'error_server_disconnected' ||
    'network' => SpeechIssue.network,
    'error_audio_error' ||
    'error_audio' ||
    'audio-capture' => SpeechIssue.audio,
    'error_busy' || 'error_recognizer_busy' => SpeechIssue.busy,
    _ => SpeechIssue.other,
  };

  void _finish() {
    _grace?.cancel();
    final done = _current?.done;
    if (done != null && !done.isCompleted) done.complete();
  }
}

/// Text of one recognizer session. Some recognizers (Safari) restart their
/// result list after a pause within a session; the earlier words are kept
/// instead of being replaced by the new sentence.
class _Segment {
  _Segment(this.id, this.hints);

  final int id;
  final List<String> hints;
  final done = Completer<void>();

  /// Ended by our silence timer (the learner stopped), not the recognizer.
  bool endedBySilence = false;
  String _committed = '';
  String _current = '';

  String get text =>
      [_committed, _current].where((t) => t.isNotEmpty).join(' ').trim();

  void update(String words) {
    final next = words.trim();
    if (_restarted(_current, next)) {
      _committed = [_committed, _current].where((t) => t.isNotEmpty).join(' ');
    }
    _current = next;
  }

  /// A result that starts differently and shares few words with the
  /// previous one is a new list; a revision keeps most of the words.
  static bool _restarted(String previous, String next) {
    List<String> words(String t) => [
      for (final w in t.toLowerCase().split(RegExp(r"[^a-z0-9']+")))
        if (w.isNotEmpty) w,
    ];
    final a = words(previous);
    final b = words(next);
    if (a.length < 3 || b.isEmpty || a.first == b.first) return false;
    final shared = b.where(a.toSet().contains).length;
    return shared / b.length < 0.5;
  }
}
