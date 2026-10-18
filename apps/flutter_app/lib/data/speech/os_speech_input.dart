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

  /// Learners pause mid-sentence; end the turn only after a longer silence.
  static const _pauseFor = Duration(seconds: 3);
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
  }) async {
    if (!await ensureAvailable()) return '';
    _active = this;
    _stopRequested = false;
    lastIssue = null;
    final parts = <String>[];
    String joined([String current = '']) =>
        [...parts, if (current.isNotEmpty) current].join(' ');

    var resuming = false;
    while (true) {
      Timer? watchdog;
      if (resuming) {
        // Nothing new within the window: the learner has finished.
        watchdog = Timer(_resumeWindow, () => unawaited(_stt.stop()));
      }
      final segment = await _listenSegment(
        onPartial: (p) {
          if (p.isNotEmpty) watchdog?.cancel();
          onPartial?.call(joined(p));
        },
        onLevel: onLevel,
        hints: [...hints, ...parts],
      );
      watchdog?.cancel();
      // Let the recognizer wind down before listening again: a late final
      // result still updates this part, and a late "done" can't end the
      // next one.
      await _settle();
      final text = segment.text;
      if (text.isNotEmpty) parts.add(text);
      final keepGoing =
          (PlatformInfo.isAndroid || PlatformInfo.isWeb) &&
          text.isNotEmpty &&
          !_stopRequested &&
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
  }) async {
    final segment = _current = _Segment(++_segments, hints);
    _grace?.cancel();
    await _stt.listen(
      onResult: (SpeechRecognitionResult r) {
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
        pauseFor: _pauseFor,
        listenFor: _listenFor,
        // Apple: contextualStrings; Android 13+: biasing strings.
        contextualPhrases: hints.isEmpty ? null : hints,
        autoPunctuation: true,
      ),
    );
    await segment.done.future;
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

  /// Platform error codes (speech_to_text docs) to what the learner can do.
  static SpeechIssue issueFor(String code) => switch (code) {
    'error_no_match' || 'error_speech_timeout' => SpeechIssue.noSpeech,
    'error_permission' ||
    'error_insufficient_permissions' => SpeechIssue.permission,
    'error_network' ||
    'error_network_timeout' ||
    'error_server' ||
    'error_server_disconnected' => SpeechIssue.network,
    'error_audio_error' || 'error_audio' => SpeechIssue.audio,
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
