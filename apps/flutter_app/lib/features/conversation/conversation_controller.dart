import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/logging/app_logger.dart';
import '../../domain/audio/recognition_hints.dart';
import '../../domain/audio/speech_io.dart';
import '../../domain/conversation/conversation_policy.dart';
import '../../domain/conversation/conversation_session_controller.dart';
import '../../domain/conversation/prompt_composer.dart';
import '../../domain/conversation/session_enums.dart';
import '../../domain/conversation/session_types.dart';
import '../../domain/credentials/provider_account.dart';
import '../../domain/providers/ai_provider.dart';
import '../../domain/providers/provider_failure.dart';
import '../../domain/sessions/session_records.dart';
import '../../domain/sessions/session_repository.dart';
import '../../domain/settings/settings_store.dart';
import 'conversation_request.dart';

/// One line of the transcript. [isRequest] marks quick-action lines
/// ("Could you give me a hint?"), which aren't the learner's own answers.
final class ConversationTurn {
  const ConversationTurn(
    this.speaker,
    this.text, {
    this.isRequest = false,
    this.id,
  });

  final Speaker speaker;
  final String text;
  final bool isRequest;

  /// Stored turn id, once saved.
  final int? id;
}

final class ConversationState {
  const ConversationState({
    this.signedIn,
    this.setup = const SessionSetup(),
    this.sessionId,
    this.phase = SessionPhase.idle,
    this.pauseReason,
    this.elapsed = Duration.zero,
    this.turns = const [],
    this.partial = '',
    this.speechUnavailable = false,
    this.hintSuggested = false,
    this.subtitles = true,
    this.failure,
  });

  /// Null until the account has been checked.
  final bool? signedIn;
  final SessionSetup setup;
  final int? sessionId;

  /// Turn-taking state from [ConversationSessionController] (spec §7.3).
  final SessionPhase phase;
  final PauseReason? pauseReason;

  /// Active (unpaused) time.
  final Duration elapsed;
  final List<ConversationTurn> turns;
  final String partial;
  final bool speechUnavailable;
  final bool hintSuggested;
  final bool subtitles;
  final ProviderFailure? failure;

  bool get active => switch (phase) {
    SessionPhase.listening ||
    SessionPhase.userSpeaking ||
    SessionPhase.processing ||
    SessionPhase.aiSpeaking => true,
    _ => false,
  };
  bool get ended => phase == SessionPhase.ended;
  bool get paused => phase == SessionPhase.paused;
  bool get connectionLost =>
      paused && pauseReason == PauseReason.connectionLost;

  /// Learner can type, act or start talking.
  bool get learnerCanAct =>
      phase == SessionPhase.listening || phase == SessionPhase.aiSpeaking;

  int get learnerAnswers =>
      turns.where((t) => t.speaker == Speaker.user && !t.isRequest).length;

  static const _unset = Object();

  ConversationState copyWith({
    bool? signedIn,
    SessionSetup? setup,
    int? sessionId,
    SessionPhase? phase,
    Object? pauseReason = _unset,
    Duration? elapsed,
    List<ConversationTurn>? turns,
    String? partial,
    bool? speechUnavailable,
    bool? hintSuggested,
    bool? subtitles,
    Object? failure = _unset,
  }) => ConversationState(
    signedIn: signedIn ?? this.signedIn,
    setup: setup ?? this.setup,
    sessionId: sessionId ?? this.sessionId,
    phase: phase ?? this.phase,
    pauseReason: identical(pauseReason, _unset)
        ? this.pauseReason
        : pauseReason as PauseReason?,
    elapsed: elapsed ?? this.elapsed,
    turns: turns ?? this.turns,
    partial: partial ?? this.partial,
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

/// S06 live conversation: turn-taking through the session state machine,
/// prompts from PromptComposer + ConversationPolicy, on-device voice, and
/// every turn saved as it happens so a closed app can be resumed.
class ConversationController extends Notifier<ConversationState> {
  static const _log = AppLogger('conversation');
  static const _composer = PromptComposer();

  /// Stand in for a learner message so the AI can take the first turn;
  /// never shown or stored.
  static const _kickoff = '[The learner has joined the session.]';
  static const _back = '[The learner is back.]';
  static const _openingNote =
      'The session is starting: greet the learner in a few words and ask '
      'your first question.';
  static const _resumeNote =
      'The learner is back after a break: in one short sentence, pick up '
      'where you left off with a question.';

  late ProviderAccount _account;
  late LlmProvider _llm;
  late Future<String> Function() _selectModel;
  late SpeechInput _mic;
  late SpeechOutput _voice;
  late SettingsStore _settings;
  late SessionRepository _sessions;
  late DateTime Function() _now;

  final _machine = ConversationSessionController();
  late ConversationPolicy _policy;
  String? _model;
  bool _speakReplies = true;

  DateTime? _sessionStartedAt;
  Duration _activeBefore = Duration.zero;
  DateTime? _activeSince;
  DateTime? _listeningSince;
  Timer? _ticker;
  Future<void>? _replying;
  List<String> _retryNotes = const [];

  /// Notes of the reply being streamed, and of one cut off by a pause
  /// (asked again on resume so the learner's turn still gets an answer).
  List<String>? _streamingNotes;
  List<String>? _pendingNotes;

  @override
  ConversationState build() {
    _account = ref.watch(chatGptAccountProvider);
    _llm = ref.watch(chatGptLlmProvider);
    _selectModel = ref.watch(chatGptModelSelectorProvider);
    _mic = ref.watch(speechInputProvider);
    _voice = ref.watch(speechOutputProvider);
    _settings = ref.watch(settingsStoreProvider);
    _sessions = ref.watch(sessionRepositoryProvider);
    _now = ref.watch(clockProvider);
    ref.onDispose(() {
      _ticker?.cancel();
      unawaited(_mic.stop());
      unawaited(_voice.stop());
    });
    final request = ref.read(conversationRequestProvider);
    final setup = switch (request) {
      NewSession(:final setup) => setup,
      ResumeSession() => const SessionSetup(),
    };
    _policy = ConversationPolicy(length: setup.length);
    unawaited(_open(request));
    return ConversationState(setup: setup);
  }

  Future<void> _open(ConversationRequest request) async {
    final signedIn = await _account.isSignedIn();
    _speakReplies = await _settings.read(SettingKeys.speakReplies) != 'false';
    if (!ref.mounted) return;
    state = state.copyWith(signedIn: signedIn);
    if (!signedIn) return;

    _dispatch(const StartRequested());
    try {
      _model = await _selectModel();
    } on ProviderException catch (e) {
      _onFailure(e, notes: const []);
      return;
    }
    if (!ref.mounted) return;

    final String note;
    switch (request) {
      case NewSession(:final setup):
        _sessionStartedAt = _now();
        final id = await _sessions.start(setup, _sessionStartedAt!);
        if (!ref.mounted) return;
        state = state.copyWith(sessionId: id);
        note = _openingNote;
      case ResumeSession(:final sessionId):
        final detail = await _sessions.load(sessionId);
        if (!ref.mounted) return;
        if (detail == null) {
          _dispatch(const EndRequested());
          return;
        }
        final last = detail.turns.isEmpty
            ? detail.summary.startedAt
            : detail.turns.last.startedAt;
        _sessionStartedAt = detail.summary.startedAt;
        _activeBefore = last.difference(detail.summary.startedAt);
        _policy = ConversationPolicy(length: detail.summary.setup.length);
        state = state.copyWith(
          sessionId: sessionId,
          setup: detail.summary.setup,
          elapsed: _activeBefore,
          turns: [
            for (final t in detail.turns)
              ConversationTurn(
                t.speaker,
                t.text,
                isRequest: t.isRequest,
                id: t.id,
              ),
          ],
        );
        note = _resumeNote;
    }

    _dispatch(const Connected());
    _activeSince = _now();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => tick());
    _dispatch(const AssistantTurnRequested());
    await _startReply(notes: [note]);
  }

  /// Learner's own answer, typed.
  Future<void> send(String text) async {
    final message = text.trim();
    if (message.isEmpty || !state.learnerCanAct) return;
    await _takeFloor();
    if (!_dispatch(const TextSubmitted())) return;
    await _learnerTurn(message);
  }

  /// Quick action (hint, repeat, slower, correct, change topic).
  Future<void> act(CoachAction action) async {
    if (!state.learnerCanAct) return;
    await _takeFloor();
    if (!_dispatch(const AssistantTurnRequested())) return;
    final request = _policy.act(action);
    await _saveTurn(
      ConversationTurn(Speaker.user, request.userText, isRequest: true),
    );
    await _startReply(notes: request.notes);
  }

  /// Listens for one utterance with the on-device recognizer and sends it.
  /// While the AI speaks this is barge-in: its voice stops at once.
  Future<void> talk() async {
    if (!state.learnerCanAct) return;
    if (!await _mic.ensureAvailable()) {
      if (ref.mounted) state = state.copyWith(speechUnavailable: true);
      return;
    }
    if (!ref.mounted || !_dispatch(const SpeechStarted())) return;
    state = state.copyWith(
      partial: '',
      speechUnavailable: false,
      hintSuggested: false,
      failure: null,
    );
    DateTime? first;
    DateTime? last;
    final heard = await _mic.listenOnce(
      hints: _hints(),
      onPartial: (p) {
        first ??= _now();
        last = _now();
        if (ref.mounted) state = state.copyWith(partial: p);
      },
    );
    if (!ref.mounted) return;
    state = state.copyWith(partial: '');
    final text = heard.trim();
    if (text.isEmpty || state.phase != SessionPhase.userSpeaking) {
      _dispatch(const SpeechDiscarded());
      return;
    }
    _dispatch(const SpeechEnded());
    // Recognizer timing approximates speaking time (an estimate, B2).
    final speechMs = first != null && last != null && last!.isAfter(first!)
        ? last!.difference(first!).inMilliseconds
        : null;
    await _learnerTurn(text, speechMs: speechMs);
  }

  Future<void> stopListening() => _mic.stop();

  /// The setup and the coach's latest lines, which answers tend to echo.
  List<String> _hints() {
    final setup = state.setup;
    final coach = [
      for (final t in state.turns.reversed)
        if (t.speaker == Speaker.assistant) t.text,
    ];
    return recognitionHints(
      phrases: [?setup.topic, ?setup.role, ?setup.goal],
      texts: coach.take(3),
    );
  }

  void toggleSubtitles() => state = state.copyWith(subtitles: !state.subtitles);

  Future<void> pause() => _pause(const PauseRequested());

  /// The app went to the background or the screen locked: stop listening
  /// and speaking (spec §3.3). The learner resumes when back.
  Future<void> appHidden() => _pause(const PauseRequested(inBackground: true));

  Future<void> _pause(PauseRequested event) async {
    if (!state.active) return;
    _pendingNotes = _streamingNotes;
    _dispatch(event);
    await _mic.stop();
    await _voice.stop();
  }

  /// Resume after a user pause, or reconnect after a lost connection and
  /// retry the request that failed.
  Future<void> resume() async {
    if (!state.paused) return;
    final reconnecting = state.connectionLost;
    if (!_dispatch(const ResumeRequested())) return;
    if (!reconnecting) {
      final pending = _pendingNotes;
      _pendingNotes = null;
      if (pending != null && _dispatch(const AssistantTurnRequested())) {
        await _startReply(notes: pending);
      }
      return;
    }
    _dispatch(const Connected());
    if (_dispatch(const AssistantTurnRequested())) {
      await _startReply(notes: _retryNotes);
    }
  }

  /// "Continue with text": replies stop being read aloud, then reconnect.
  Future<void> continueAsText() async {
    _speakReplies = false;
    await resume();
  }

  /// Updates the timer and the silence-based hint suggestion.
  void tick() {
    if (!ref.mounted || _sessionStartedAt == null) return;
    final now = _now();
    final since = _listeningSince;
    state = state.copyWith(
      elapsed: _activeElapsed(now),
      hintSuggested:
          state.phase == SessionPhase.listening &&
          since != null &&
          _policy.suggestHint(now.difference(since)),
    );
  }

  /// Ends and saves the session. The screen then opens the result (A7).
  Future<void> end() async {
    if (state.ended) return;
    final elapsed = _activeElapsed(_now());
    _ticker?.cancel();
    _dispatch(const EndRequested());
    await _mic.stop();
    await _voice.stop();
    await _replying;
    final id = state.sessionId;
    if (id != null) {
      await _sessions.finish(
        id,
        status: state.learnerAnswers > 0
            ? SessionStatus.completed
            : SessionStatus.abandoned,
        // Active time, so a resumed session doesn't count the break.
        endedAt: (_sessionStartedAt ?? _now()).add(elapsed),
        stats: _stats(),
      );
    }
    if (ref.mounted) {
      state = state.copyWith(elapsed: elapsed, hintSuggested: false);
    }
  }

  SpeechStats _stats() {
    var userMs = 0;
    var assistantMs = 0;
    var userMeasured = false;
    var assistantMeasured = false;
    for (final ms in _speechMs.entries) {
      final turn = state.turns.where((t) => t.id == ms.key).firstOrNull;
      if (turn == null) continue;
      if (turn.speaker == Speaker.user) {
        userMs += ms.value;
        userMeasured = true;
      } else {
        assistantMs += ms.value;
        assistantMeasured = true;
      }
    }
    return SpeechStats(
      userMs: userMs,
      assistantMs: assistantMs,
      turnCount: state.learnerAnswers,
      // The ratio needs both sides; user time is a recognizer-timing estimate.
      confidence: userMeasured && assistantMeasured ? 0.5 : null,
    );
  }

  final _speechMs = <int, int>{};

  Duration _activeElapsed(DateTime now) {
    final since = _activeSince;
    return since == null || !state.active
        ? _activeBefore
        : _activeBefore + now.difference(since);
  }

  /// Lets the learner take the turn while the AI is speaking.
  Future<void> _takeFloor() async {
    if (state.phase != SessionPhase.aiSpeaking) return;
    await _voice.stop();
    await _replying;
  }

  Future<void> _learnerTurn(String text, {int? speechMs}) async {
    _policy.learnerSpoke();
    await _saveTurn(ConversationTurn(Speaker.user, text), speechMs: speechMs);
    await _startReply();
  }

  /// Shows the turn (in place of [replacing], if given), stores it and
  /// returns its id.
  Future<int?> _saveTurn(
    ConversationTurn turn, {
    int? speechMs,
    ConversationTurn? replacing,
  }) async {
    final at = _now();
    final shown = replacing != null && state.turns.contains(replacing);
    state = state.copyWith(
      turns: shown
          ? [for (final t in state.turns) identical(t, replacing) ? turn : t]
          : [...state.turns, turn],
      hintSuggested: false,
      failure: null,
    );
    final id = state.sessionId;
    if (id == null) return null;
    final saved = await _sessions.addTurn(
      id,
      TurnRecord(
        speaker: turn.speaker,
        text: turn.text,
        startedAt: at,
        isRequest: turn.isRequest,
        speechMs: speechMs,
      ),
    );
    if (speechMs != null) _speechMs[saved] = speechMs;
    if (!ref.mounted) return saved;
    state = state.copyWith(
      turns: [
        for (final t in state.turns)
          identical(t, turn)
              ? ConversationTurn(
                  t.speaker,
                  t.text,
                  isRequest: t.isRequest,
                  id: saved,
                )
              : t,
      ],
    );
    return saved;
  }

  Future<void> _startReply({List<String> notes = const []}) {
    final reply = _reply(notes: notes);
    _replying = reply;
    return reply;
  }

  Future<void> _reply({required List<String> notes}) async {
    final model = _model;
    final turn = _machine.state.turn;
    if (model == null) return;
    final history = [
      for (final t in state.turns)
        ChatMessage(
          t.speaker == Speaker.user ? ChatRole.user : ChatRole.assistant,
          t.text,
        ),
    ];
    final elapsed = _activeElapsed(_now());
    final setup = state.setup;
    final messages = _composer.compose(
      PromptContext(
        mode: setup.mode,
        level: setup.level,
        topic: setup.topic,
        goal: setup.goal,
        role: setup.role,
      ),
      [
        ...history,
        if (history.isEmpty)
          const ChatMessage(ChatRole.user, _kickoff)
        else if (history.last.role == ChatRole.assistant)
          const ChatMessage(ChatRole.user, _back),
      ],
      policyNotes: [..._policy.standingNotes(elapsed), ...notes],
    );

    final text = StringBuffer();
    ConversationTurn? streaming;
    var started = false;
    var cut = false;
    bool current() =>
        ref.mounted &&
        _machine.state.turn == turn &&
        (state.phase == SessionPhase.processing ||
            state.phase == SessionPhase.aiSpeaking);
    _streamingNotes = notes;
    try {
      await for (final chunk in _llm.streamChat(
        model: model,
        messages: messages,
      )) {
        if (!current()) {
          cut = true;
          break;
        }
        if (chunk case TextDelta(text: final delta)) {
          if (!started) {
            started = true;
            _dispatch(ResponseStarted(turn: turn));
          }
          text.write(delta);
          final line = ConversationTurn(Speaker.assistant, text.toString());
          state = state.copyWith(
            turns: [
              for (final t in state.turns)
                if (!identical(t, streaming)) t,
              line,
            ],
          );
          streaming = line;
        }
      }
      _streamingNotes = null;
      if (!ref.mounted) return;
      if (cut) {
        // Paused or talked over before the reply was complete: drop the
        // fragment (a pause asks again on resume).
        state = state.copyWith(
          turns: [
            for (final t in state.turns)
              if (!identical(t, streaming)) t,
          ],
        );
        return;
      }
      _pendingNotes = null;
      final reply = text.toString().trim();
      if (!started) _dispatch(ResponseStarted(turn: turn));
      if (reply.isNotEmpty) {
        int? spokenMs;
        if (_speakReplies && current()) {
          final spokenAt = _now();
          await _voice.speak(reply, slow: _policy.slower);
          spokenMs = _now().difference(spokenAt).inMilliseconds;
        }
        // Saved after speaking so the measured time goes with it.
        await _saveTurn(
          ConversationTurn(Speaker.assistant, reply),
          speechMs: spokenMs,
          replacing: streaming,
        );
      }
      if (_policy.correctionDue(elapsed)) _policy.correctionGiven(elapsed);
      _dispatch(ResponseEnded(turn: turn));
    } on ProviderException catch (e) {
      _streamingNotes = null;
      if (ref.mounted) {
        state = state.copyWith(
          turns: [
            for (final t in state.turns)
              if (!identical(t, streaming)) t,
          ],
        );
      }
      _onFailure(e, notes: notes, turn: turn);
    }
  }

  void _onFailure(
    ProviderException e, {
    required List<String> notes,
    int? turn,
  }) {
    _log.warning('request failed: $e');
    if (!ref.mounted) return;
    switch (e.failure) {
      case ProviderFailure.network:
        _retryNotes = notes;
        _dispatch(const ConnectionLost());
        state = state.copyWith(failure: e.failure);
      case ProviderFailure.signInRequired:
        _dispatch(const EndRequested());
        state = state.copyWith(signedIn: false, failure: e.failure);
      default:
        if (turn != null) _dispatch(ResponseFailed(turn: turn));
        state = state.copyWith(failure: e.failure);
    }
  }

  /// Feeds the state machine and mirrors its phase. Returns false when the
  /// event was rejected (stale or not valid now).
  bool _dispatch(SessionEvent event) {
    final result = _machine.dispatch(event);
    switch (result) {
      case Rejected():
        _log.info('ignored: $result');
        return false;
      case Accepted(:final to, :final interruptsAssistant):
        if (interruptsAssistant) unawaited(_voice.stop());
        if (to.phase == SessionPhase.listening) _listeningSince = _now();
        if (state.active && to.phase == SessionPhase.paused) {
          _activeBefore = _activeElapsed(_now());
          _activeSince = null;
        }
        if (to.phase != SessionPhase.paused &&
            _activeSince == null &&
            state.paused) {
          _activeSince = _now();
        }
        if (ref.mounted) {
          state = state.copyWith(
            phase: to.phase,
            pauseReason: to.pauseReason,
            hintSuggested: false,
          );
        }
        return true;
    }
  }
}
