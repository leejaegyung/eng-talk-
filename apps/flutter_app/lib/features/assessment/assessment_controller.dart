import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/logging/app_logger.dart';
import '../../domain/audio/recognition_hints.dart';
import '../../domain/conversation/session_enums.dart';
import '../../domain/learning/learner_level.dart';
import '../../domain/learning/placement.dart';
import '../../domain/providers/provider_failure.dart';
import '../../domain/sessions/session_records.dart';
import '../../domain/settings/settings_store.dart';
import '../setup/setup_controller.dart';

/// Step 0 is the intro and mic check, 1..5 the questions.
final class AssessmentState {
  const AssessmentState({
    this.step = 0,
    this.answers = const ['', '', '', '', ''],
    this.micCheck,
    this.listening = false,
    this.partial = '',
    this.evaluating = false,
    this.rubric,
    this.suggested,
    this.chosen,
    this.gradingFailed = false,
    this.failure,
    this.saved = false,
  });

  final int step;
  final List<String> answers;

  /// What the recognizer heard in the mic check; '' = heard nothing.
  final String? micCheck;
  final bool listening;
  final String partial;
  final bool evaluating;
  final Rubric? rubric;
  final LearnerLevel? suggested;
  final LearnerLevel? chosen;

  /// The model's grading couldn't be read; the learner picks a level.
  final bool gradingFailed;
  final ProviderFailure? failure;
  final bool saved;

  static const questionCount = 5;
  bool get onQuestion => step >= 1 && step <= questionCount;
  bool get finished => suggested != null || gradingFailed;
  String get currentAnswer => onQuestion ? answers[step - 1] : '';

  AssessmentState copyWith({
    int? step,
    List<String>? answers,
    String? micCheck,
    bool? listening,
    String? partial,
    bool? evaluating,
    Rubric? rubric,
    LearnerLevel? suggested,
    LearnerLevel? chosen,
    bool? gradingFailed,
    ProviderFailure? failure,
    bool clearFailure = false,
    bool? saved,
  }) => AssessmentState(
    step: step ?? this.step,
    answers: answers ?? this.answers,
    micCheck: micCheck ?? this.micCheck,
    listening: listening ?? this.listening,
    partial: partial ?? this.partial,
    evaluating: evaluating ?? this.evaluating,
    rubric: rubric ?? this.rubric,
    suggested: suggested ?? this.suggested,
    chosen: chosen ?? this.chosen,
    gradingFailed: gradingFailed ?? this.gradingFailed,
    failure: clearFailure ? null : failure ?? this.failure,
    saved: saved ?? this.saved,
  );
}

final assessmentProvider =
    NotifierProvider.autoDispose<AssessmentController, AssessmentState>(
      AssessmentController.new,
    );

/// First placement (spec §2.5): mic check → five questions → text-only
/// rubric → suggested level the learner accepts or changes.
class AssessmentController extends Notifier<AssessmentState> {
  static const _log = AppLogger('assessment');

  @override
  AssessmentState build() {
    final mic = ref.watch(speechInputProvider);
    final voice = ref.watch(speechOutputProvider);
    ref.onDispose(() {
      unawaited(mic.stop());
      unawaited(voice.stop());
    });
    return const AssessmentState();
  }

  Future<void> next() async {
    await ref.read(speechOutputProvider).stop();
    if (state.step < AssessmentState.questionCount) {
      state = state.copyWith(step: state.step + 1, partial: '');
      await _readQuestion();
    } else {
      await evaluate();
    }
  }

  Future<void> _readQuestion() async {
    final speak =
        await ref.read(settingsStoreProvider).read(SettingKeys.speakReplies) !=
        'false';
    if (!speak || !ref.mounted || !state.onQuestion) return;
    await ref
        .read(speechOutputProvider)
        .speak(placementQuestions[state.step - 1]);
  }

  void setAnswer(String text) {
    if (!state.onQuestion) return;
    final answers = [...state.answers]..[state.step - 1] = text;
    state = state.copyWith(answers: answers);
  }

  /// Longest a placement answer keeps listening.
  static const _maxAnswer = Duration(seconds: 90);
  bool _stopRequested = false;

  /// Mic check on step 0. On a question, keeps listening across the short
  /// pauses where phones end recognition (Android stops after ~1–2 s of
  /// silence), appending each part, until the learner taps stop, stays
  /// silent, or [_maxAnswer] passes.
  Future<void> talk() async {
    if (state.listening) return;
    // Reset before any await so a stop tapped right away still counts.
    _stopRequested = false;
    await ref.read(speechOutputProvider).stop();
    final mic = ref.read(speechInputProvider);
    if (!await mic.ensureAvailable()) {
      if (ref.mounted) state = state.copyWith(micCheck: '');
      return;
    }
    if (!ref.mounted) return;
    state = state.copyWith(listening: true, partial: '');
    final question = state.onQuestion;
    final until = DateTime.now().add(_maxAnswer);
    do {
      final before = state.currentAnswer.trim();
      final heard = (await mic.listenOnce(
        hints: question
            ? recognitionHints(
                texts: [placementQuestions[state.step - 1], before],
              )
            : const [],
        onPartial: (p) {
          if (ref.mounted) state = state.copyWith(partial: p);
        },
      )).trim();
      if (!ref.mounted) return;
      state = state.copyWith(partial: '');
      if (!question) {
        state = state.copyWith(micCheck: heard);
        break;
      }
      if (heard.isEmpty) break;
      setAnswer(before.isEmpty ? heard : '$before $heard');
    } while (!_stopRequested && DateTime.now().isBefore(until));
    if (ref.mounted) state = state.copyWith(listening: false);
  }

  Future<void> stopListening() {
    _stopRequested = true;
    return ref.read(speechInputProvider).stop();
  }

  Future<void> evaluate() async {
    state = state.copyWith(
      step: AssessmentState.questionCount + 1,
      evaluating: true,
      clearFailure: true,
    );
    try {
      final model = await ref.read(aiModelSelectorProvider)();
      final rubric = await PlacementService(ref.read(aiLlmProvider))
          .evaluate(model: model, answers: _pairs());
      if (!ref.mounted) return;
      if (rubric == null) {
        state = state.copyWith(gradingFailed: true);
        return;
      }
      final level = placementLevel(rubric, avgWords: _avgWords());
      state = state.copyWith(rubric: rubric, suggested: level, chosen: level);
    } on ProviderException catch (e) {
      _log.warning('placement failed: $e');
      if (ref.mounted) state = state.copyWith(failure: e.failure);
    } finally {
      if (ref.mounted) state = state.copyWith(evaluating: false);
    }
  }

  void choose(LearnerLevel level) => state = state.copyWith(chosen: level);

  /// Saves the placement conversation, the assessment and the level.
  Future<void> accept() async {
    final level = state.chosen;
    if (level == null || state.saved) return;
    final repo = ref.read(sessionRepositoryProvider);
    final now = ref.read(clockProvider);
    final at = now();
    final id = await repo.start(
      SessionSetup(mode: SessionMode.assessment, level: level),
      at,
    );
    for (final (q, a) in _pairs()) {
      await repo.addTurn(
        id,
        TurnRecord(speaker: Speaker.assistant, text: q, startedAt: at),
      );
      if (a.trim().isNotEmpty) {
        await repo.addTurn(
          id,
          TurnRecord(speaker: Speaker.user, text: a.trim(), startedAt: at),
        );
      }
    }
    await repo.finish(id, status: SessionStatus.completed, endedAt: now());
    await repo.saveAssessment(
      sessionId: id,
      rubricJson: jsonEncode({
        ...?state.rubric?.toJson(),
        'suggested': state.suggested?.name,
        'chosen': level.name,
      }),
      level: level,
      at: now(),
    );
    await ref.read(setupProvider.notifier).setLevel(level);
    if (ref.mounted) state = state.copyWith(saved: true);
  }

  List<(String, String)> _pairs() => [
    for (final (i, q) in placementQuestions.indexed) (q, state.answers[i]),
  ];

  double _avgWords() {
    final counts = [
      for (final a in state.answers)
        a.trim().isEmpty ? 0 : a.trim().split(RegExp(r'\s+')).length,
    ];
    return counts.reduce((a, b) => a + b) / counts.length;
  }
}
