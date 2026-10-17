import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/logging/app_logger.dart';
import '../../domain/audio/amplitude_vad.dart';
import '../../domain/audio/audio_io.dart';
import '../../domain/audio/wav.dart';

enum LabStatus { idle, recording, playing, micDenied, failed }

final class AudioLabState {
  const AudioLabState({
    this.status = LabStatus.idle,
    this.levelDb = silenceFloorDb,
    this.speaking = false,
    this.userSpeech = Duration.zero,
    this.recorded = Duration.zero,
    this.hasRecording = false,
    this.noSignal = false,
  });

  final LabStatus status;
  final double levelDb;
  final bool speaking;
  final Duration userSpeech;
  final Duration recorded;
  final bool hasRecording;

  /// Only digital silence so far: lid closed, muted or blocked input.
  final bool noSignal;

  AudioLabState copyWith({
    LabStatus? status,
    double? levelDb,
    bool? speaking,
    Duration? userSpeech,
    Duration? recorded,
    bool? hasRecording,
    bool? noSignal,
  }) => AudioLabState(
    status: status ?? this.status,
    levelDb: levelDb ?? this.levelDb,
    speaking: speaking ?? this.speaking,
    userSpeech: userSpeech ?? this.userSpeech,
    recorded: recorded ?? this.recorded,
    hasRecording: hasRecording ?? this.hasRecording,
    noSignal: noSignal ?? this.noSignal,
  );
}

final audioLabProvider =
    NotifierProvider.autoDispose<AudioLabController, AudioLabState>(
      AudioLabController.new,
    );

/// P0-T3 PoC: mic → in-memory PCM → VAD → playback. The recording lives only
/// in memory and is dropped when the screen closes (S4).
class AudioLabController extends Notifier<AudioLabState> {
  static const _log = AppLogger('audio.lab');

  /// A real microphone never yields exact zeros for this long.
  static const _noSignalAfter = Duration(seconds: 2);

  late AudioInput _input;
  late AudioOutput _output;
  final _pcm = BytesBuilder(copy: false);
  Uint8List? _recording;
  StreamSubscription<Uint8List>? _sub;
  AmplitudeVad _vad = AmplitudeVad();
  bool _signalSeen = false;

  @override
  AudioLabState build() {
    _input = ref.watch(audioInputProvider);
    _output = ref.watch(audioOutputProvider);
    ref.onDispose(() {
      // `state` can't be read here; the subscription marks an open recording.
      if (_sub != null) {
        unawaited(_sub!.cancel());
        unawaited(_input.stop());
      }
      _pcm.clear();
      _recording = null;
    });
    return const AudioLabState();
  }

  Future<void> startRecording() async {
    if (state.status == LabStatus.recording ||
        state.status == LabStatus.playing) {
      return;
    }
    try {
      if (!await _input.ensurePermission()) {
        state = const AudioLabState(status: LabStatus.micDenied);
        return;
      }
      _vad = AmplitudeVad();
      _signalSeen = false;
      _pcm.clear();
      _recording = null;
      final stream = await _input.start();
      state = const AudioLabState(status: LabStatus.recording);
      _sub = stream.listen(_onChunk);
    } on Exception catch (e) {
      _log.warning('recording failed: ${e.runtimeType}');
      state = const AudioLabState(status: LabStatus.failed);
    }
  }

  void _onChunk(Uint8List chunk) {
    _pcm.add(chunk);
    final db = pcm16Dbfs(chunk);
    if (db > silenceFloorDb) _signalSeen = true;
    _vad.add(
      db,
      pcm16Duration(chunk.lengthInBytes, sampleRate: _input.sampleRate),
    );
    final recorded = pcm16Duration(_pcm.length, sampleRate: _input.sampleRate);
    state = state.copyWith(
      levelDb: db,
      speaking: _vad.speaking,
      userSpeech: _vad.userSpeech,
      recorded: recorded,
      noSignal: !_signalSeen && recorded >= _noSignalAfter,
    );
  }

  Future<void> stopRecording() async {
    if (state.status != LabStatus.recording) return;
    await _input.stop();
    await _sub?.cancel();
    _sub = null;
    _vad.flush();
    _recording = _pcm.takeBytes();
    state = state.copyWith(
      status: LabStatus.idle,
      levelDb: silenceFloorDb,
      speaking: false,
      userSpeech: _vad.userSpeech,
      hasRecording: _recording!.isNotEmpty,
    );
  }

  Future<void> play() async {
    final pcm = _recording;
    if (pcm == null || pcm.isEmpty || state.status != LabStatus.idle) return;
    state = state.copyWith(status: LabStatus.playing);
    try {
      await _output.play(
        pcm16ToWav(pcm, sampleRate: _input.sampleRate),
        fileExtension: 'wav',
      );
    } on Exception catch (e) {
      _log.warning('playback failed: ${e.runtimeType}');
    } finally {
      if (ref.mounted) state = state.copyWith(status: LabStatus.idle);
    }
  }

  Future<void> stopPlayback() => _output.stop();
}
