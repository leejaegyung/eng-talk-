import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/logging/app_logger.dart';
import '../../domain/conversation/session_enums.dart';
import '../../domain/feedback/feedback.dart';
import '../../domain/feedback/feedback_service.dart';
import '../../domain/providers/provider_failure.dart';
import '../../domain/sessions/session_records.dart';

final class ResultState {
  const ResultState({
    this.detail,
    this.generating = false,
    this.failure,
    this.heard = const {},
    this.listeningTo,
  });

  final SessionDetail? detail;
  final bool generating;
  final ProviderFailure? failure;

  /// What the learner said when practicing correction i (no scoring).
  final Map<int, String> heard;
  final int? listeningTo;

  FeedbackResult? get feedback => detail?.feedback;

  ResultState copyWith({
    SessionDetail? detail,
    bool? generating,
    ProviderFailure? failure,
    bool clearFailure = false,
    Map<int, String>? heard,
    int? listeningTo,
    bool clearListening = false,
  }) => ResultState(
    detail: detail ?? this.detail,
    generating: generating ?? this.generating,
    failure: clearFailure ? null : failure ?? this.failure,
    heard: heard ?? this.heard,
    listeningTo: clearListening ? null : listeningTo ?? this.listeningTo,
  );
}

final resultProvider = NotifierProvider.autoDispose
    .family<ResultController, ResultState, int>(ResultController.new);

/// S08 session result + S07 corrections. Feedback is generated once, when
/// the result is first opened, and stored with the session.
class ResultController extends Notifier<ResultState> {
  ResultController(this.sessionId);

  final int sessionId;
  static const _log = AppLogger('result');

  @override
  ResultState build() {
    final mic = ref.watch(speechInputProvider);
    ref.onDispose(() => unawaited(mic.stop()));
    unawaited(_load());
    return const ResultState();
  }

  Future<void> _load() async {
    final detail = await ref.read(sessionRepositoryProvider).load(sessionId);
    if (!ref.mounted || detail == null) return;
    state = state.copyWith(detail: detail);
    final hasAnswers = detail.turns.any(
      (t) => t.speaker == Speaker.user && !t.isRequest,
    );
    if (detail.feedback == null && hasAnswers) await generate();
  }

  Future<void> generate() async {
    final detail = state.detail;
    if (detail == null || state.generating) return;
    state = state.copyWith(generating: true, clearFailure: true);
    try {
      final model = await ref.read(chatGptModelSelectorProvider)();
      final feedback = await FeedbackService(ref.read(chatGptLlmProvider))
          .evaluate(
            model: model,
            setup: detail.summary.setup,
            turns: detail.turns,
          );
      final repo = ref.read(sessionRepositoryProvider);
      await repo.saveFeedback(sessionId, feedback, ref.read(clockProvider)());
      final reloaded = await repo.load(sessionId);
      if (ref.mounted) state = state.copyWith(detail: reloaded);
    } on ProviderException catch (e) {
      _log.warning('feedback failed: $e');
      if (ref.mounted) state = state.copyWith(failure: e.failure);
    } finally {
      if (ref.mounted) state = state.copyWith(generating: false);
    }
  }

  /// "Say it again" for correction [index]: shows what was recognized.
  Future<void> practice(int index) async {
    final mic = ref.read(speechInputProvider);
    if (state.listeningTo != null || !await mic.ensureAvailable()) return;
    if (!ref.mounted) return;
    state = state.copyWith(listeningTo: index);
    final heard = await mic.listenOnce();
    if (!ref.mounted) return;
    state = state.copyWith(
      heard: {...state.heard, index: heard.trim()},
      clearListening: true,
    );
  }
}
