import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/l10n/gen/app_localizations.dart';
import '../../domain/learning/focus.dart';
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
                                Text(l10n.resultYouSaid(h)),
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
