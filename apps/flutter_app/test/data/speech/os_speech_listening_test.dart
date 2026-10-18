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
}
