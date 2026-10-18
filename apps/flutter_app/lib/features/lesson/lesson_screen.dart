import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/l10n/gen/app_localizations.dart';
import '../../domain/feedback/feedback.dart';
import '../common/failure_text.dart';
import '../common/practice_verdict.dart';
import '../common/repeat_boxes.dart';
import '../growth/growth_screen.dart' show categoryName;
import 'lesson_controller.dart';

/// Mini lesson for one weak area: the rule, examples, then the learner's
/// own corrected sentences to repeat.
class LessonScreen extends ConsumerWidget {
  const LessonScreen({super.key, required this.category});

  final ErrorCategory category;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final s = ref.watch(lessonProvider(category));
    final ctrl = ref.read(lessonProvider(category).notifier);
    final mistakes = s.mistakes;
    final lesson = s.lesson;
    Widget heading(String text) => Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 8),
      child: Text(text, style: theme.textTheme.titleMedium),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(categoryName(l10n, category)),
        actions: [
          if (lesson != null)
            TextButton(
              onPressed: s.writing ? null : ctrl.write,
              child: Text(l10n.lessonRewrite),
            ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: mistakes == null
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                  children: [
                    if (mistakes.isEmpty) Text(l10n.lessonNoMistakes),
                    if (s.writing)
                      Row(
                        spacing: 12,
                        children: [
                          const SizedBox.square(
                            dimension: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          Expanded(child: Text(l10n.lessonWriting)),
                        ],
                      ),
                    if (s.failure case final f?)
                      Card(
                        child: ListTile(
                          leading: const Icon(Icons.error_outline),
                          title: Text(failureText(l10n, f)),
                          trailing: TextButton(
                            onPressed: ctrl.write,
                            child: Text(l10n.resultRetry),
                          ),
                        ),
                      ),
                    if (lesson != null) ...[
                      Text(lesson.titleKo, style: theme.textTheme.titleLarge),
                      const SizedBox(height: 8),
                      Text(lesson.explanationKo),
                      const SizedBox(height: 4),
                      Text(l10n.lessonAiNote, style: theme.textTheme.bodySmall),
                      heading(l10n.lessonExamples),
                      for (final e in lesson.examples)
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(e.en),
                          subtitle: Text(e.ko),
                          trailing: IconButton(
                            tooltip: l10n.shadowingListen,
                            icon: const Icon(Icons.volume_up),
                            onPressed: () => ctrl.play(e.en),
                          ),
                        ),
                    ],
                    if (mistakes.isNotEmpty) ...[
                      heading(l10n.lessonPractice),
                      Text(
                        l10n.lessonPracticeNote,
                        style: theme.textTheme.bodySmall,
                      ),
                      for (final (i, m) in mistakes.indexed)
                        Card(
                          margin: const EdgeInsets.only(top: 10),
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              spacing: 8,
                              children: [
                                Text(
                                  m.original,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    decoration: TextDecoration.lineThrough,
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                Text(
                                  m.suggested,
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                                if (s.heard[i] case final h? when h.isNotEmpty)
                                  PracticeVerdict(
                                    heard: h,
                                    target: m.suggested,
                                  ),
                                RepeatBoxes(
                                  checks: s.checksOf(i),
                                  onToggle: (box) => ctrl.toggle(i, box),
                                ),
                                Wrap(
                                  spacing: 8,
                                  children: [
                                    OutlinedButton.icon(
                                      onPressed: () => ctrl.play(m.suggested),
                                      icon: const Icon(Icons.volume_up),
                                      label: Text(l10n.shadowingListen),
                                    ),
                                    FilledButton.icon(
                                      onPressed: s.listeningTo == null
                                          ? () => ctrl.practice(i)
                                          : null,
                                      icon: const Icon(Icons.mic),
                                      label: Text(
                                        s.listeningTo == i
                                            ? l10n.resultListening
                                            : l10n.resultSayAgain,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ],
                ),
        ),
      ),
    );
  }
}
