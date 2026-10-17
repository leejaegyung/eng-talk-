import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/logging/app_logger.dart';
import '../../domain/audio/speech_io.dart';
import '../../domain/conversation/conversation_policy.dart';
import '../../domain/conversation/prompt_composer.dart';
import '../../domain/conversation/session_enums.dart';
import '../../domain/credentials/provider_account.dart';
import '../../domain/learning/learner_level.dart';
import '../../domain/providers/ai_provider.dart';
import '../../domain/providers/provider_failure.dart';
import '../../domain/settings/settings_store.dart';

/// One line of the transcript. [isRequest] marks quick-action lines
/// ("Could you give me a hint?"), which aren't the learner's own answers.
final class ConversationTurn {
  const ConversationTurn(this.speaker, this.text, {this.isRequest = false});

  final Speaker speaker;
  final String text;
  final bool isRequest;
}

final class ConversationState {
  const ConversationState({
    this.signedIn,
    this.mode = SessionMode.daily,
    this.level = LearnerLevel.l2,
    this.length = const Duration(minutes: 30),
    this.active = false,
    this.ended = false,
    this.elapsed = Duration.zero,
    this.turns = const [],
    this.streaming = false,
    this.listening = false,
    this.partial = '',
    this.speaking = false,
    this.speechUnavailable = false,
    this.hintSuggested = false,
    this.subtitles = true,
    this.failure,
  });

  /// Null until the account has been checked.
  final bool? signedIn;
  final SessionMode mode;
  final LearnerLevel level;
  final Duration length;
  final bool active;
  final bool ended;
  final Duration elapsed;
  final List<ConversationTurn> turns;

  /// Waiting for or receiving the AI reply ("thinking").
  final bool streaming;
  final bool listening;
  final String partial;
  final bool speaking;
  final bool speechUnavailable;
  final bool hintSuggested;
  final bool subtitles;
  final ProviderFailure? failure;

  bool get busy => streaming || listening;

  static const _unset = Object();

  ConversationState copyWith({
    bool? signedIn,
    LearnerLevel? level,
    bool? active,
    bool? ended,
    Duration? elapsed,
    List<ConversationTurn>? turns,
    bool? streaming,
    bool? listening,
    String? partial,
    bool? speaking,
    bool? speechUnavailable,
    bool? hintSuggested,
    bool? subtitles,
    Object? failure = _unset,
  }) => ConversationState(
    signedIn: signedIn ?? this.signedIn,
    mode: mode,
    level: level ?? this.level,
    length: length,
    active: active ?? this.active,
    ended: ended ?? this.ended,
    elapsed: elapsed ?? this.elapsed,
    turns: turns ?? this.turns,
    streaming: streaming ?? this.streaming,
    listening: listening ?? this.listening,
    partial: partial ?? this.partial,
    speaking: speaking ?? this.speaking,
    speechUnavailable: speechUnavailable ?? this.speechUnavailable,
    hintSuggested: hintSuggested ?? this.hintSuggested,
    subtitles: subtitles ?? this.subtitles,
    failure: identical(failure, _unset)
        ? this.failure
        : failure as ProviderFailure?,
  );
}

final conversationProvider =
    NotifierProvider.autoDispose<ConversationController, ConversationState>(
      ConversationController.new,
    );

/// S06 live conversation (slice A: Daily mode, ChatGPT plan, OS voice).
/// Sessions are kept in memory until P1-A7 persists them.
class ConversationController extends Notifier<ConversationState> {
  static const _log = AppLogger('conversation');
  static const _composer = PromptComposer();

  /// Stands in for the learner's first message so the AI can open; never
  /// shown or stored.
  static const _kickoff = '[The learner has joined the session.]';
  static const _openingNote =
      'The session is starting: greet the learner in a few words and ask '
      'your first question.';

  late ProviderAccount _account;
  late LlmProvider _llm;
  late Future<String> Function() _selectModel;
  late SpeechInput _mic;
  late SpeechOutput _voice;
  late SettingsStore _settings;
  late DateTime Function() _now;

  late ConversationPolicy _policy;
  String? _model;
  bool _speakReplies = true;
  DateTime? _startedAt;
  DateTime? _quietSince;
  Timer? _ticker;

  @override
  ConversationState build() {
    _account = ref.watch(chatGptAccountProvider);
    _llm = ref.watch(chatGptLlmProvider);
    _selectModel = ref.watch(chatGptModelSelectorProvider);
    _mic = ref.watch(speechInputProvider);
    _voice = ref.watch(speechOutputProvider);
    _settings = ref.watch(settingsStoreProvider);
    _now = ref.watch(clockProvider);
    ref.onDispose(() {
      _ticker?.cancel();
      unawaited(_mic.stop());
      unawaited(_voice.stop());
    });
    const initial = ConversationState();
    _policy = ConversationPolicy(length: initial.length);
    unawaited(_start());
    return initial;
  }

  Future<void> _start() async {
    final signedIn = await _account.isSignedIn();
    final levelName = await _settings.read(SettingKeys.learnerLevel);
    _speakReplies = await _settings.read(SettingKeys.speakReplies) != 'false';
    if (!ref.mounted) return;
    final level = LearnerLevel.values.asNameMap()[levelName] ?? state.level;
    state = state.copyWith(signedIn: signedIn, level: level);
    if (!signedIn) return;

    try {
      _model = await _selectModel();
    } on ProviderException catch (e) {
      _onFailure(e);
      return;
    }
    if (!ref.mounted) return;
    _startedAt = _now();
    state = state.copyWith(active: true);
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => tick());
    await _reply(notes: const [_openingNote]);
  }

  /// Learner's own answer, typed or recognized.
  Future<void> send(String text) async {
    final message = text.trim();
    if (message.isEmpty || !state.active || state.streaming) return;
    _policy.learnerSpoke();
    _addTurn(ConversationTurn(Speaker.user, message));
    await _reply();
  }

  /// Quick action (hint, repeat, slower, correct, change topic).
  Future<void> act(CoachAction action) async {
    if (!state.active || state.streaming) return;
    await _voice.stop();
    final request = _policy.act(action);
    _addTurn(ConversationTurn(Speaker.user, request.userText, isRequest: true));
    await _reply(notes: request.notes);
  }

  /// Listens for one utterance with the on-device recognizer and sends it.
  Future<void> talk() async {
    if (!state.active || state.busy) return;
    // Barge-in: the learner talking takes precedence over the AI voice.
    await _voice.stop();
    if (!await _mic.ensureAvailable()) {
      if (ref.mounted) state = state.copyWith(speechUnavailable: true);
      return;
    }
    if (!ref.mounted) return;
    state = state.copyWith(
      listening: true,
      partial: '',
      speaking: false,
      speechUnavailable: false,
      hintSuggested: false,
      failure: null,
    );
    final heard = await _mic.listenOnce(
      onPartial: (p) {
        if (ref.mounted) state = state.copyWith(partial: p);
      },
    );
    if (!ref.mounted) return;
    state = state.copyWith(listening: false, partial: '');
    _quietSince = _now();
    await send(heard);
  }

  Future<void> stopListening() => _mic.stop();

  void toggleSubtitles() => state = state.copyWith(subtitles: !state.subtitles);

  /// Updates the timer and the silence-based hint suggestion.
  void tick() {
    if (!state.active) return;
    final now = _now();
    final quiet = _quietSince;
    state = state.copyWith(
      elapsed: now.difference(_startedAt!),
      hintSuggested:
          quiet != null &&
          !state.busy &&
          !state.speaking &&
          _policy.suggestHint(now.difference(quiet)),
    );
  }

  Future<void> end() async {
    if (state.ended) return;
    _ticker?.cancel();
    await _mic.stop();
    await _voice.stop();
    if (!ref.mounted) return;
    state = state.copyWith(
      active: false,
      ended: true,
      elapsed: _startedAt == null
          ? Duration.zero
          : _now().difference(_startedAt!),
      listening: false,
      speaking: false,
      hintSuggested: false,
    );
  }

  void _addTurn(ConversationTurn turn) => state = state.copyWith(
    turns: [...state.turns, turn],
    hintSuggested: false,
    failure: null,
  );

  Future<void> _reply({List<String> notes = const []}) async {
    final model = _model;
    if (model == null) return;
    final elapsed = _now().difference(_startedAt!);
    final history = [
      for (final t in state.turns)
        ChatMessage(
          t.speaker == Speaker.user ? ChatRole.user : ChatRole.assistant,
          t.text,
        ),
    ];
    final messages = _composer.compose(
      PromptContext(mode: state.mode, level: state.level),
      [
        if (history.isEmpty) const ChatMessage(ChatRole.user, _kickoff),
        ...history,
      ],
      policyNotes: [..._policy.standingNotes(elapsed), ...notes],
    );

    final before = state.turns;
    state = state.copyWith(streaming: true, failure: null);
    final reply = StringBuffer();
    try {
      await for (final chunk in _llm.streamChat(
        model: model,
        messages: messages,
      )) {
        if (!ref.mounted || state.ended) return;
        if (chunk case TextDelta(:final text)) {
          reply.write(text);
          state = state.copyWith(
            turns: [
              ...before,
              ConversationTurn(Speaker.assistant, reply.toString()),
            ],
          );
        }
      }
      if (_policy.correctionDue(elapsed)) _policy.correctionGiven(elapsed);
      final text = reply.toString().trim();
      if (ref.mounted && _speakReplies && text.isNotEmpty && !state.ended) {
        state = state.copyWith(streaming: false, speaking: true);
        await _voice.speak(text, slow: _policy.slower);
      }
    } on ProviderException catch (e) {
      _onFailure(e);
    } finally {
      if (ref.mounted) {
        state = state.copyWith(streaming: false, speaking: false);
        _quietSince = _now();
      }
    }
  }

  void _onFailure(ProviderException e) {
    _log.warning('request failed: $e');
    if (!ref.mounted) return;
    state = e.failure == ProviderFailure.signInRequired
        ? state.copyWith(signedIn: false, active: false, failure: e.failure)
        : state.copyWith(failure: e.failure);
  }
}
