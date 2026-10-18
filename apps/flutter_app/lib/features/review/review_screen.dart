import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/l10n/gen/app_localizations.dart';
import '../../app/theme.dart';
import '../../domain/learning/focus.dart';
import '../../domain/sessions/session_records.dart';
import '../common/practice_verdict.dart';
import 'review_controller.dart';

class ReviewScreen extends ConsumerWidget {
  const ReviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final s = ref.watch(reviewProvider);
    final ctrl = ref.read(reviewProvider.notifier);
    final theme = Theme.of(context);
    final items = s.items;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.reviewTitle)),
      body: items == null
          ? const Center(child: CircularProgressIndicator())
          : items.isEmpty && s.expressions.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(l10n.reviewEmpty, textAlign: TextAlign.center),
              ),
            )
          : Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: ListView(
                  padding: const EdgeInsets.all(24),
                  children: [
                    if (items.isNotEmpty) ...[
                      Text(l10n.reviewIntro),
                      const SizedBox(height: 12),
                    ] else
                      Text(l10n.reviewEmpty),
                    for (final item in items)
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            spacing: 8,
                            children: [
                              if (item.kind == ReviewKind.wordOrder)
                                Chip(
                                  avatar: const Icon(
                                    Icons.swap_horiz,
                                    size: 18,
                                  ),
                                  label: Text(l10n.reviewKindWordOrder),
                                  visualDensity: VisualDensity.compact,
                                ),
                              Text(
                                item.original,
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  decoration: TextDecoration.lineThrough,
                                  color: theme.colorScheme.outline,
                                ),
                              ),
                              Text(
                                item.suggested,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                              if (item.explanationKo case final e?) Text(e),
                              if (s.heard[item.id] case final h?
                                  when h.isNotEmpty)
                                PracticeVerdict(
                                  heard: h,
                                  target: item.suggested,
                                ),
                              _RepeatBoxes(
                                checks: s.checksOf(item.id),
                                onToggle: (i) => ctrl.toggleCheck(item.id, i),
                              ),
                              Wrap(
                                spacing: 8,
                                children: [
                                  OutlinedButton.icon(
                                    onPressed: !s.busy
                                        ? () => ctrl.practice(item.id)
                                        : null,
                                    icon: const Icon(Icons.mic),
                                    label: Text(
                                      s.listeningTo == item.id
                                          ? l10n.resultListening
                                          : l10n.resultSayAgain,
                                    ),
                                  ),
                                  FilledButton(
                                    onPressed: () => ctrl.done(item),
                                    child: Text(l10n.reviewDone),
                                  ),
                                  TextButton(
                                    onPressed: () => ctrl.later(item),
                                    child: Text(l10n.reviewLater),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    if (s.expressions.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      Text(
                        l10n.reviewExpressions,
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n.reviewExpressionsIntro,
                        style: theme.textTheme.bodySmall,
                      ),
                      const SizedBox(height: 8),
                      for (final (i, e) in s.expressions.indexed)
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              spacing: 8,
                              children: [
                                Text(
                                  e.phrase,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                                if (e.meaningKo case final m?) Text(m),
                                if (s.expressionHeard[i] case final h?
                                    when h.isNotEmpty) ...[
                                  Text(l10n.resultYouSaid(h)),
                                  Row(
                                    spacing: 6,
                                    children: [
                                      Icon(
                                        usedExpression(h, e.phrase)
                                            ? Icons.check_circle
                                            : Icons.info_outline,
                                        size: 18,
                                        color: usedExpression(h, e.phrase)
                                            ? theme.colorScheme.primary
                                            : theme.colorScheme.outline,
                                      ),
                                      Expanded(
                                        child: Text(
                                          usedExpression(h, e.phrase)
                                              ? l10n.reviewExpressionUsed
                                              : l10n.reviewExpressionMissing,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                                OutlinedButton.icon(
                                  onPressed: s.busy
                                      ? null
                                      : () => ctrl.useExpression(i),
                                  icon: const Icon(Icons.mic),
                                  label: Text(
                                    s.listeningToExpression == i
                                        ? l10n.resultListening
                                        : l10n.reviewUseExpression,
                                  ),
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

/// One box per repetition of the corrected sentence; ticked automatically
/// when it is said as corrected, or by hand.
class _RepeatBoxes extends StatelessWidget {
  const _RepeatBoxes({required this.checks, required this.onToggle});

  final List<bool> checks;
  final void Function(int index) onToggle;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final done = checks.where((c) => c).length;
    final complete = done == checks.length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 4,
      children: [
        Text(
          complete
              ? l10n.reviewRepeatDone
              : l10n.reviewRepeatProgress(done, checks.length),
          style: theme.textTheme.titleSmall?.copyWith(
            color: complete ? AppColors.green : null,
          ),
        ),
        Wrap(
          children: [
            for (final (i, checked) in checks.indexed)
              Checkbox(
                value: checked,
                semanticLabel: l10n.reviewRepeatBox(i + 1),
                onChanged: (_) => onToggle(i),
              ),
          ],
        ),
      ],
    );
  }
}
