import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/logging/app_logger.dart';
import '../../domain/feedback/feedback.dart';
import '../../domain/learning/mini_lesson.dart';
import '../../domain/learning/word_order.dart';
import '../../domain/providers/provider_failure.dart';
import '../../domain/settings/settings_store.dart';

final class LessonState {
  const LessonState({
    this.mistakes,
    this.lesson,
    this.writing = false,
    this.failure,
    this.repeats = 5,
    this.heard = const {},
    this.checks = const {},
    this.listeningTo,
  });

  /// The learner's own corrections of this kind; null while loading.
  final List<CorrectionExample>? mistakes;
  final MiniLesson? lesson;
  final bool writing;
  final ProviderFailure? failure;
  final int repeats;

  /// Practice of mistake i: what was heard and the repeat boxes.
  final Map<int, String> heard;
  final Map<int, List<bool>> checks;
  final int? listeningTo;

  List<bool> checksOf(int i) => checks[i] ?? List.filled(repeats, false);

  LessonState copyWith({
    List<CorrectionExample>? mistakes,
    MiniLesson? lesson,
    bool? writing,
    ProviderFailure? failure,
    bool clearFailure = false,
    int? repeats,
    Map<int, String>? heard,
    Map<int, List<bool>>? checks,
    int? listeningTo,
    bool clearListening = false,
  }) => LessonState(
    mistakes: mistakes ?? this.mistakes,
    lesson: lesson ?? this.lesson,
    writing: writing ?? this.writing,
    failure: clearFailure ? null : failure ?? this.failure,
    repeats: repeats ?? this.repeats,
    heard: heard ?? this.heard,
    checks: checks ?? this.checks,
    listeningTo: clearListening ? null : listeningTo ?? this.listeningTo,
  );
}

final lessonProvider = NotifierProvider.autoDispose
    .family<LessonController, LessonState, ErrorCategory>(LessonController.new);

/// Mini lesson for a weak area (S10): the model explains the rule behind the
/// learner's own mistakes; the lesson is kept until those mistakes change.
class LessonController extends Notifier<LessonState> {
  LessonController(this.category);

  final ErrorCategory category;
  static const _log = AppLogger('lesson');

  String get _cacheKey => 'lesson.${category.wire}';

  @override
  LessonState build() {
    final mic = ref.watch(speechInputProvider);
    final voice = ref.watch(speechOutputProvider);
    ref.onDispose(() {
      unawaited(mic.stop());
      unawaited(voice.stop());
    });
    unawaited(_load());
    return const LessonState();
  }

  /// Which mistakes a stored lesson was written from.
  static String _basis(List<CorrectionExample> m) =>
      [for (final c in m) c.suggested].join('|');

  Future<void> _load() async {
    final mistakes = await ref
        .read(sessionRepositoryProvider)
        .recentCorrections(category);
    final settings = ref.read(settingsStoreProvider);
    final repeats = int.tryParse(
      await settings.read(SettingKeys.reviewRepeats) ?? '',
    );
    final cached = await settings.read(_cacheKey);
    if (!ref.mounted) return;
    state = state.copyWith(
      mistakes: mistakes,
      repeats: reviewRepeatOptions.contains(repeats)
          ? repeats
          : reviewRepeatOptions.first,
    );
    if (mistakes.isEmpty) return;
    if (cached != null) {
      final json = jsonDecode(cached);
      if (json is Map && json['basis'] == _basis(mistakes)) {
        final lesson = MiniLesson.fromJson(json['lesson']);
        if (lesson != null) {
          state = state.copyWith(lesson: lesson);
          return;
        }
      }
    }
    await write();
  }

  /// Writes (or rewrites) the lesson from the current mistakes.
  Future<void> write() async {
    final mistakes = state.mistakes;
    if (mistakes == null || mistakes.isEmpty || state.writing) return;
    state = state.copyWith(writing: true, clearFailure: true);
    try {
      final model = await ref.read(aiModelSelectorProvider)();
      final lesson = await MiniLessonService(ref.read(aiLlmProvider))
          .write(model: model, category: category, mistakes: mistakes);
      if (!ref.mounted) return;
      if (lesson == null) {
        state = state.copyWith(failure: ProviderFailure.unknown);
        return;
      }
      state = state.copyWith(lesson: lesson);
      await ref
          .read(settingsStoreProvider)
          .write(
            _cacheKey,
            jsonEncode({'basis': _basis(mistakes), 'lesson': lesson.toJson()}),
          );
    } on ProviderException catch (e) {
      _log.warning('lesson failed: $e');
      if (ref.mounted) state = state.copyWith(failure: e.failure);
    } finally {
      if (ref.mounted) state = state.copyWith(writing: false);
    }
  }

  Future<void> play(String sentence) async {
    final voice = ref.read(speechOutputProvider);
    await voice.stop();
    await voice.speak(sentence);
  }

  /// Say the corrected sentence of mistake [i]; a match fills a box.
  Future<void> practice(int i) async {
    final mistakes = state.mistakes;
    final mic = ref.read(speechInputProvider);
    if (mistakes == null || state.listeningTo != null) return;
    if (!await mic.ensureAvailable() || !ref.mounted) return;
    state = state.copyWith(listeningTo: i);
    final heard = (await mic.listenOnce()).trim();
    if (!ref.mounted) return;
    state = state.copyWith(
      heard: {...state.heard, i: heard},
      clearListening: true,
    );
    if (saidAsCorrected(heard, mistakes[i].suggested)) {
      final boxes = [...state.checksOf(i)];
      final next = boxes.indexOf(false);
      if (next >= 0) boxes[next] = true;
      state = state.copyWith(checks: {...state.checks, i: boxes});
    }
  }

  void toggle(int i, int box) {
    final boxes = [...state.checksOf(i)];
    boxes[box] = !boxes[box];
    state = state.copyWith(checks: {...state.checks, i: boxes});
  }
}
