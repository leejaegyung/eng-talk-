import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:speaking_coach/data/speech/os_speech_input.dart';
import 'package:speech_to_text_platform_interface/speech_to_text_platform_interface.dart';

/// One recognizer session: partial texts, then a final result with
/// (text, confidence) alternates, or nothing until stopped.
typedef Segment = ({List<String> partials, List<(String, double)>? finals});

/// A final result that only arrives after the session said "done", by
/// listen number.
final lateFinals = <int, List<(String, double)>>{};

class FakePlatform extends SpeechToTextPlatform
    with MockPlatformInterfaceMixin {
  final segments = <Segment>[];
  int listens = 0;
  bool _listening = false;

  void _result(List<(String, double)> alts, {required bool last}) =>
      onTextRecognition?.call(
        jsonEncode({
          'alternates': [
            for (final (t, c) in alts) {'recognizedWords': t, 'confidence': c},
          ],
          'resultType': last ? 2 : 0,
        }),
      );

  @override
  Future<bool> initialize({
    debugLogging = false,
    List<SpeechConfigOption>? options,
  }) async => true;

  @override
  Future<bool> hasPermission() async => true;

  @override
  Future<bool> listen({
    String? localeId,
    partialResults = true,
    onDevice = false,
    int listenMode = 0,
    sampleRate = 0,
    SpeechListenOptions? options,
  }) async {
    listens++;
    _listening = true;
    onStatus?.call('listening');
    final segment = segments.isEmpty ? null : segments.removeAt(0);
    if (segment != null) {
      scheduleMicrotask(() async {
        for (final p in segment.partials) {
          _result([(p, -1)], last: false);
          await Future<void>.delayed(Duration.zero);
        }
        final finals = segment.finals;
        final late = lateFinals.remove(listens);
        if (late != null) {
          _listening = false;
          onStatus?.call('notListening');
          onStatus?.call('done');
          await Future<void>.delayed(const Duration(milliseconds: 100));
          _result(late, last: true);
          return;
        }
        if (finals != null) {
          // Android order: "not listening" first, the final result later.
          _listening = false;
          onStatus?.call('notListening');
          await Future<void>.delayed(const Duration(milliseconds: 20));
          _result(finals, last: true);
          onStatus?.call('done');
        }
      });
    }
    return true;
  }

  @override
  Future<void> stop() async {
    if (!_listening) return;
    _listening = false;
    onStatus?.call('notListening');
    onStatus?.call('done');
  }

  @override
  Future<void> cancel() => stop();

  @override
  Future<List<dynamic>> locales() async => const [];
}

void main() {
  // SpeechToText is a singleton that registers its callbacks on the first
  // initialize, so one fake platform serves every test.
  final platform = FakePlatform();
  late OsSpeechInput mic;

  setUpAll(() => SpeechToTextPlatform.instance = platform);
  setUp(() {
    lateFinals.clear();
    platform
      ..segments.clear()
      ..listens = 0;
    mic = OsSpeechInput();
  });
  tearDown(() => debugDefaultTargetPlatformOverride = null);

  test('waits for the final result after "not listening"', () async {
    platform.segments.add((
      partials: ['I went', 'I went to the'],
      finals: [('I went to the park yesterday', 0.8)],
    ));
    expect(await mic.listenOnce(), 'I went to the park yesterday');
  });

  test('picks the alternate that fits the coach\'s question', () async {
    platform.segments.add((
      partials: ['I prefer'],
      finals: [
        ('I prefer biking on weekend', 0.6),
        ('I prefer hiking on weekends', 0.55),
      ],
    ));
    expect(
      await mic.listenOnce(hints: ['Do you like hiking on weekends?']),
      'I prefer hiking on weekends',
    );
  });

  test('Android: keeps listening after a pause and joins the parts', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    platform.segments.addAll([
      (partials: ['I usually'], finals: [('I usually go hiking', 0.8)]),
      (partials: ['with my'], finals: [('with my friends', 0.8)]),
      // Then nothing: the resume window closes the turn.
    ]);
    final partials = <String>[];
    final text = await mic.listenOnce(onPartial: partials.add);
    expect(text, 'I usually go hiking with my friends');
    expect(partials, contains('I usually go hiking with my'));
    expect(platform.listens, 3);
    expect(mic.lastIssue, isNull);
  });

  test(
    'Android: a stop by the learner ends it after the current part',
    () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      platform.segments.add((partials: ['Hello'], finals: null));
      final listening = mic.listenOnce();
      await Future<void>.delayed(const Duration(milliseconds: 10));
      await mic.stop();
      expect(await listening, 'Hello');
      expect(platform.listens, 1);
    },
  );

  test(
    'Apple: one segment (its own 3 s pause already allows thinking)',
    () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      platform.segments.addAll([
        (partials: <String>[], finals: [('First part', 0.8)]),
        (partials: <String>[], finals: [('second part', 0.8)]),
      ]);
      expect(await mic.listenOnce(), 'First part');
      expect(platform.listens, 1);
    },
  );

  test(
    'Android: a late final updates its own part, not the next one',
    () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      platform.segments.addAll([
        (partials: ['I went to', 'I went to the'], finals: null),
        (partials: ['and we'], finals: [('and we had lunch', 0.8)]),
      ]);
      lateFinals[1] = [('I went to the park yesterday', 0.9)];
      expect(
        await mic.listenOnce(),
        'I went to the park yesterday and we had lunch',
      );
    },
  );

  test(
    'a result list that restarts mid-session keeps the earlier words',
    () async {
      platform.segments.add((
        partials: ['I went to the park', 'and we played soccer'],
        finals: [('and we played soccer', 0.8)],
      ));
      expect(await mic.listenOnce(), 'I went to the park and we played soccer');
    },
  );

  test('an ordinary revision is not mistaken for a restart', () async {
    platform.segments.add((
      partials: ['I went to the', 'Hi went to the park'],
      finals: [('Hi, I went to the park', 0.8)],
    ));
    expect(await mic.listenOnce(), 'Hi, I went to the park');
  });

  test(
    'thinking time: no words yet does not stop before the timeout',
    () async {
      // Nothing is said: the session stays open until the start timeout.
      platform.segments.add((partials: <String>[], finals: null));
      final clock = Stopwatch()..start();
      final text = await mic.listenOnce(
        startTimeout: const Duration(milliseconds: 600),
      );
      expect(text, isEmpty);
      expect(clock.elapsedMilliseconds, greaterThanOrEqualTo(550));
    },
  );

  test(
    'after words, a 2.5 s silence ends the turn (Apple keeps the session open)',
    () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      // Words, then the session never ends by itself.
      platform.segments.add((partials: ['I like hiking'], finals: null));
      final clock = Stopwatch()..start();
      expect(await mic.listenOnce(), 'I like hiking');
      expect(clock.elapsedMilliseconds, inInclusiveRange(2300, 5000));
    },
  );

  test(
    'recognizer gives up early on silence: restarted within the thinking time',
    () async {
      // First session ends by itself with nothing (like Chrome's no-speech),
      // the learner starts talking in the second.
      platform.segments.addAll([
        (partials: <String>[], finals: <(String, double)>[]),
        (partials: ['I am ready'], finals: [('I am ready now', 0.9)]),
      ]);
      final text = await mic.listenOnce(
        startTimeout: const Duration(seconds: 5),
      );
      expect(text, 'I am ready now');
      expect(platform.listens, greaterThanOrEqualTo(2), reason: 'restarted');
    },
  );
}
