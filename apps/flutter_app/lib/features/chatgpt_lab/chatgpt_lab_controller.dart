import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/logging/app_logger.dart';
import '../../domain/audio/speech_io.dart';
import '../../domain/credentials/provider_account.dart';
import '../../domain/providers/ai_provider.dart';
import '../../domain/providers/provider_failure.dart';

final class ChatGptLabState {
  const ChatGptLabState({
    this.signedIn,
    this.busy = false,
    this.model,
    this.failure,
    this.turns = const [],
    this.streaming = false,
    this.firstTokens = const [],
    this.inputTokens = 0,
    this.outputTokens = 0,
    this.speakReplies = true,
    this.listening = false,
    this.partial = '',
    this.speaking = false,
    this.speechUnavailable = false,
  });

  /// Null until the stored session has been checked.
  final bool? signedIn;
  final bool busy;
  final String? model;
  final ProviderFailure? failure;

  /// User and assistant messages shown on screen (no system prompt).
  final List<ChatMessage> turns;
  final bool streaming;

  /// Send → first token, per reply (measured).
  final List<Duration> firstTokens;
  final int inputTokens;
  final int outputTokens;

  /// Read replies aloud with the on-device voice.
  final bool speakReplies;
  final bool listening;

  /// Words recognized so far while listening.
  final String partial;
  final bool speaking;
  final bool speechUnavailable;

  static const _unset = Object();

  ChatGptLabState copyWith({
    bool? signedIn,
    bool? busy,
    Object? model = _unset,
    Object? failure = _unset,
    List<ChatMessage>? turns,
    bool? streaming,
    List<Duration>? firstTokens,
    int? inputTokens,
    int? outputTokens,
    bool? speakReplies,
    bool? listening,
    String? partial,
    bool? speaking,
    bool? speechUnavailable,
  }) => ChatGptLabState(
    signedIn: signedIn ?? this.signedIn,
    busy: busy ?? this.busy,
    model: identical(model, _unset) ? this.model : model as String?,
    failure: identical(failure, _unset)
        ? this.failure
        : failure as ProviderFailure?,
    turns: turns ?? this.turns,
    streaming: streaming ?? this.streaming,
    firstTokens: firstTokens ?? this.firstTokens,
    inputTokens: inputTokens ?? this.inputTokens,
    outputTokens: outputTokens ?? this.outputTokens,
    speakReplies: speakReplies ?? this.speakReplies,
    listening: listening ?? this.listening,
    partial: partial ?? this.partial,
    speaking: speaking ?? this.speaking,
    speechUnavailable: speechUnavailable ?? this.speechUnavailable,
  );
}

final chatGptLabProvider =
    NotifierProvider.autoDispose<ChatGptLabController, ChatGptLabState>(
      ChatGptLabController.new,
    );

/// ADR-011 PoC: GPT through the user's ChatGPT plan, text only. Prompting is
/// a placeholder for PromptComposer (P1-A3).
class ChatGptLabController extends Notifier<ChatGptLabState> {
  static const _log = AppLogger('chatgpt.lab');
  static const _systemPrompt =
      'You are a friendly English speaking coach. Reply in one or two short, '
      'natural sentences, then ask one simple follow-up question.';
  static const _historyMessages = 20;

  late ProviderAccount _account;
  late LlmProvider _llm;
  late Future<String> Function() _selectModel;
  late SpeechInput _mic;
  late SpeechOutput _voice;

  @override
  ChatGptLabState build() {
    _account = ref.watch(chatGptAccountProvider);
    _llm = ref.watch(chatGptLlmProvider);
    _selectModel = ref.watch(chatGptModelSelectorProvider);
    _mic = ref.watch(speechInputProvider);
    _voice = ref.watch(speechOutputProvider);
    ref.onDispose(() {
      unawaited(_mic.stop());
      unawaited(_voice.stop());
    });
    unawaited(_restore());
    return const ChatGptLabState();
  }

  Future<void> _restore() async {
    final signedIn = await _account.isSignedIn();
    if (!ref.mounted) return;
    state = state.copyWith(signedIn: signedIn);
    if (signedIn) await _pickModel();
  }

  Future<void> signIn() async {
    if (state.busy) return;
    state = state.copyWith(busy: true, failure: null);
    try {
      await _account.signIn();
      if (!ref.mounted) return;
      state = state.copyWith(signedIn: true);
      await _pickModel();
    } on ProviderException catch (e) {
      _log.warning('sign-in failed: $e');
      if (ref.mounted) state = state.copyWith(failure: e.failure);
    } finally {
      if (ref.mounted) state = state.copyWith(busy: false);
    }
  }

  Future<void> signOut() async {
    await _voice.stop();
    await _account.signOut();
    if (ref.mounted) state = const ChatGptLabState(signedIn: false);
  }

  void setSpeakReplies(bool on) {
    state = state.copyWith(speakReplies: on);
    if (!on) unawaited(_voice.stop());
  }

  /// Listens for one utterance with the on-device recognizer and sends it.
  Future<void> talk() async {
    if (state.model == null || state.streaming || state.listening) return;
    // Barge-in: the learner talking takes precedence over the AI voice.
    await _voice.stop();
    if (!await _mic.ensureAvailable()) {
      if (ref.mounted) state = state.copyWith(speechUnavailable: true);
      return;
    }
    state = state.copyWith(
      listening: true,
      partial: '',
      speaking: false,
      speechUnavailable: false,
      failure: null,
    );
    final heard = await _mic.listenOnce(
      onPartial: (p) {
        if (ref.mounted) state = state.copyWith(partial: p);
      },
    );
    if (!ref.mounted) return;
    state = state.copyWith(listening: false, partial: '');
    await send(heard);
  }

  Future<void> stopListening() => _mic.stop();

  Future<void> _pickModel() async {
    try {
      final model = await _selectModel();
      if (ref.mounted) state = state.copyWith(model: model);
    } on ProviderException catch (e) {
      _onFailure(e);
    }
  }

  Future<void> send(String text) async {
    final message = text.trim();
    final model = state.model;
    if (message.isEmpty || model == null || state.streaming) return;

    final history = [...state.turns, ChatMessage(ChatRole.user, message)];
    state = state.copyWith(turns: history, streaming: true, failure: null);
    final clock = Stopwatch()..start();
    Duration? firstToken;
    final reply = StringBuffer();
    try {
      await for (final chunk in _llm.streamChat(
        model: model,
        messages: [
          const ChatMessage(ChatRole.system, _systemPrompt),
          ...history.skip(
            history.length > _historyMessages
                ? history.length - _historyMessages
                : 0,
          ),
        ],
      )) {
        if (!ref.mounted) return;
        switch (chunk) {
          case TextDelta(:final text):
            firstToken ??= clock.elapsed;
            reply.write(text);
            state = state.copyWith(
              turns: [
                ...history,
                ChatMessage(ChatRole.assistant, reply.toString()),
              ],
            );
          case ChatUsage(:final inputTokens, :final outputTokens):
            state = state.copyWith(
              inputTokens: state.inputTokens + inputTokens,
              outputTokens: state.outputTokens + outputTokens,
            );
        }
      }
      if (ref.mounted && firstToken != null) {
        state = state.copyWith(firstTokens: [...state.firstTokens, firstToken]);
      }
      final replyText = reply.toString().trim();
      if (ref.mounted && state.speakReplies && replyText.isNotEmpty) {
        state = state.copyWith(streaming: false, speaking: true);
        await _voice.speak(replyText);
      }
    } on ProviderException catch (e) {
      _onFailure(e);
    } finally {
      if (ref.mounted) {
        state = state.copyWith(streaming: false, speaking: false);
      }
    }
  }

  void _onFailure(ProviderException e) {
    _log.warning('request failed: $e');
    if (!ref.mounted) return;
    state = e.failure == ProviderFailure.signInRequired
        ? state.copyWith(signedIn: false, model: null, failure: e.failure)
        : state.copyWith(failure: e.failure);
  }
}
