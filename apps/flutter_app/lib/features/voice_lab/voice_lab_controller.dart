import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/logging/app_logger.dart';
import '../../domain/audio/amplitude_vad.dart';
import '../../domain/audio/audio_io.dart';
import '../../domain/audio/wav.dart';
import '../../domain/credentials/credential_vault.dart';
import '../../domain/providers/ai_provider.dart';
import '../../domain/providers/provider_failure.dart';

enum VoicePhase { idle, listening, transcribing, thinking, speaking }

/// One measured exchange (P0-T6 evidence). All values are measured; nothing
/// here is an estimate.
final class RoundTrip {
  const RoundTrip({
    required this.stt,
    required this.firstToken,
    required this.ttsFirstByte,
    required this.total,
    required this.audioSent,
    required this.inputTokens,
    required this.outputTokens,
    required this.speechChars,
  });

  /// End of speech → transcript received.
  final Duration stt;

  /// Transcript → first chat token.
  final Duration firstToken;

  /// Reply complete → first synthesized audio byte.
  final Duration ttsFirstByte;

  /// End of speech → playback starts.
  final Duration total;

  /// Length of the audio uploaded for transcription.
  final Duration audioSent;
  final int inputTokens;
  final int outputTokens;

  /// Characters sent for speech synthesis.
  final int speechChars;
}

final class VoiceLabState {
  const VoiceLabState({
    this.keyStored,
    this.checking = false,
    this.models,
    this.failure,
    this.micDenied = false,
    this.phase = VoicePhase.idle,
    this.heard = '',
    this.reply = '',
    this.runs = const [],
  });

  /// Null until the vault has been read.
  final bool? keyStored;
  final bool checking;
  final ModelSelection? models;
  final ProviderFailure? failure;
  final bool micDenied;
  final VoicePhase phase;
  final String heard;
  final String reply;
  final List<RoundTrip> runs;

  static const _unset = Object();

  VoiceLabState copyWith({
    bool? keyStored,
    bool? checking,
    Object? models = _unset,
    Object? failure = _unset,
    bool? micDenied,
    VoicePhase? phase,
    String? heard,
    String? reply,
    List<RoundTrip>? runs,
  }) => VoiceLabState(
    keyStored: keyStored ?? this.keyStored,
    checking: checking ?? this.checking,
    models: identical(models, _unset) ? this.models : models as ModelSelection?,
    failure: identical(failure, _unset)
        ? this.failure
        : failure as ProviderFailure?,
    micDenied: micDenied ?? this.micDenied,
    phase: phase ?? this.phase,
    heard: heard ?? this.heard,
    reply: reply ?? this.reply,
    runs: runs ?? this.runs,
  );
}

final voiceLabProvider =
    NotifierProvider.autoDispose<VoiceLabController, VoiceLabState>(
      VoiceLabController.new,
    );

/// P0-T6 PoC: BYOK key → mic → STT → streaming chat → TTS → playback, with
/// per-stage latency. Prompting here is a placeholder for PromptComposer
/// (P1-A3).
class VoiceLabController extends Notifier<VoiceLabState> {
  static const _log = AppLogger('voice.lab');
  static const _systemPrompt =
      'You are a friendly English speaking coach. Reply in one or two short, '
      'natural sentences, then ask one simple follow-up question.';
  static const _maxListen = Duration(seconds: 30);
  static const _historyTurns = 10;

  late CredentialVault _vault;
  late AudioInput _input;
  late AudioOutput _output;
  late LlmProvider _llm;
  late VoiceProvider _voice;
  late Future<ModelSelection> Function() _selectModels;

  final _history = <ChatMessage>[];
  StreamSubscription<Uint8List>? _sub;
  Completer<void>? _listening;

  @override
  VoiceLabState build() {
    _vault = ref.watch(credentialVaultProvider);
    _input = ref.watch(audioInputProvider);
    _output = ref.watch(audioOutputProvider);
    _llm = ref.watch(llmProviderProvider);
    _voice = ref.watch(voiceProviderProvider);
    _selectModels = ref.watch(modelSelectorProvider);
    ref.onDispose(() {
      if (_sub != null) {
        unawaited(_sub!.cancel());
        unawaited(_input.stop());
      }
      unawaited(_output.stop());
      _history.clear();
    });
    unawaited(_loadKeyState());
    return const VoiceLabState();
  }

  Future<void> _loadKeyState() async {
    final stored = await _vault.read(openAiKeyRef) != null;
    if (!ref.mounted) return;
    state = state.copyWith(keyStored: stored);
    if (stored) await testConnection();
  }

  Future<void> saveKey(String key) async {
    final trimmed = key.trim();
    if (trimmed.isEmpty) return;
    await _vault.write(openAiKeyRef, trimmed);
    state = state.copyWith(keyStored: true, models: null, failure: null);
    await testConnection();
  }

  Future<void> deleteKey() async {
    await _vault.delete(openAiKeyRef);
    _history.clear();
    state = const VoiceLabState(keyStored: false);
  }

  Future<void> testConnection() async {
    state = state.copyWith(checking: true, failure: null);
    try {
      final models = await _selectModels();
      if (ref.mounted) state = state.copyWith(models: models);
    } on ProviderException catch (e) {
      _log.warning('connection test failed: $e');
      if (ref.mounted) state = state.copyWith(models: null, failure: e.failure);
    } finally {
      if (ref.mounted) state = state.copyWith(checking: false);
    }
  }

  /// Listens until the VAD detects the end of an utterance (or
  /// [stopListening]), then runs one round trip.
  Future<void> talk() async {
    final models = state.models;
    if (models == null || state.phase != VoicePhase.idle) return;
    if (!await _input.ensurePermission()) {
      state = state.copyWith(micDenied: true);
      return;
    }

    final pcm = BytesBuilder(copy: false);
    final vad = AmplitudeVad();
    final listening = _listening = Completer<void>();
    state = state.copyWith(
      phase: VoicePhase.listening,
      micDenied: false,
      failure: null,
      heard: '',
      reply: '',
    );
    _sub = (await _input.start()).listen((chunk) {
      pcm.add(chunk);
      final event = vad.add(
        pcm16Dbfs(chunk),
        pcm16Duration(chunk.lengthInBytes, sampleRate: _input.sampleRate),
      );
      if (event is VadSpeechEnd && !listening.isCompleted) listening.complete();
    });

    await listening.future.timeout(_maxListen, onTimeout: () {});
    await _input.stop();
    await _sub?.cancel();
    _sub = null;
    _listening = null;
    vad.flush();

    final audio = pcm.takeBytes();
    if (vad.userSpeech == Duration.zero || !ref.mounted) {
      if (ref.mounted) state = state.copyWith(phase: VoicePhase.idle);
      return;
    }
    await _roundTrip(models, audio);
  }

  Future<void> stopListening() async {
    final listening = _listening;
    if (listening != null && !listening.isCompleted) listening.complete();
  }

  Future<void> _roundTrip(ModelSelection models, Uint8List pcm) async {
    final clock = Stopwatch()..start();
    try {
      state = state.copyWith(phase: VoicePhase.transcribing);
      final heard = await _voice.transcribe(
        model: models.transcription,
        wav: pcm16ToWav(pcm, sampleRate: _input.sampleRate),
      );
      final stt = clock.elapsed;
      if (!ref.mounted) return;
      if (heard.isEmpty) return;
      _history.add(ChatMessage(ChatRole.user, heard));
      state = state.copyWith(heard: heard, phase: VoicePhase.thinking);

      final reply = StringBuffer();
      Duration? firstToken;
      var usage = const ChatUsage(inputTokens: 0, outputTokens: 0);
      await for (final chunk in _llm.streamChat(
        model: models.chat,
        messages: [
          const ChatMessage(ChatRole.system, _systemPrompt),
          ..._history.skip(
            _history.length > _historyTurns * 2
                ? _history.length - _historyTurns * 2
                : 0,
          ),
        ],
      )) {
        switch (chunk) {
          case TextDelta(:final text):
            firstToken ??= clock.elapsed - stt;
            reply.write(text);
            if (ref.mounted) state = state.copyWith(reply: reply.toString());
          case ChatUsage():
            usage = chunk;
        }
      }
      final replyText = reply.toString().trim();
      if (!ref.mounted || replyText.isEmpty) return;
      _history.add(ChatMessage(ChatRole.assistant, replyText));

      final ttsStart = clock.elapsed;
      Duration? firstByte;
      final speech = BytesBuilder(copy: false);
      await for (final chunk in _voice.synthesize(
        model: models.speech,
        text: replyText,
      )) {
        firstByte ??= clock.elapsed - ttsStart;
        speech.add(chunk);
      }
      if (!ref.mounted) return;

      state = state.copyWith(
        phase: VoicePhase.speaking,
        runs: [
          ...state.runs,
          RoundTrip(
            stt: stt,
            firstToken: firstToken ?? Duration.zero,
            ttsFirstByte: firstByte ?? Duration.zero,
            total: clock.elapsed,
            audioSent: pcm16Duration(
              pcm.lengthInBytes,
              sampleRate: _input.sampleRate,
            ),
            inputTokens: usage.inputTokens,
            outputTokens: usage.outputTokens,
            speechChars: replyText.length,
          ),
        ],
      );
      await _output.play(
        speech.takeBytes(),
        fileExtension: _voice.speechFileExtension,
      );
    } on ProviderException catch (e) {
      _log.warning('round trip failed: $e');
      if (ref.mounted) state = state.copyWith(failure: e.failure);
    } finally {
      if (ref.mounted) state = state.copyWith(phase: VoicePhase.idle);
    }
  }
}
