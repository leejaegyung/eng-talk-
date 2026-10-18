import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/l10n/gen/app_localizations.dart';
import '../../app/theme.dart';
import '../../domain/feedback/feedback.dart';
import '../../domain/sessions/growth_stats.dart';
import 'growth_controller.dart';

String categoryName(AppLocalizations l10n, ErrorCategory c) => switch (c) {
  ErrorCategory.grammar => l10n.categoryGrammar,
  ErrorCategory.wordChoice => l10n.categoryWordChoice,
  ErrorCategory.structure => l10n.categoryStructure,
  ErrorCategory.naturalness => l10n.categoryNaturalness,
};

/// S10 growth dashboard. Practice time is measured; speaking time is an
/// estimate and marked so; weak areas come from classified corrections.
class GrowthScreen extends ConsumerWidget {
  const GrowthScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final days = ref.watch(growthPeriodProvider);
    final g = ref.watch(growthProvider).value;

    String minutes(Duration d) => l10n.goalsMinutes(d.inMinutes);
    Widget heading(String text) => Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 8),
      child: Text(text, style: theme.textTheme.titleMedium),
    );
    final muted = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );

    return Scaffold(
      appBar: AppBar(title: Text(l10n.homeGrowth)),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            children: [
              SegmentedButton<int>(
                segments: [
                  ButtonSegment(
                    value: GrowthPeriod.week,
                    label: Text(l10n.growthPeriodWeek),
                  ),
                  ButtonSegment(
                    value: GrowthPeriod.month,
                    label: Text(l10n.growthPeriodMonth),
                  ),
                ],
                selected: {days},
                showSelectedIcon: false,
                onSelectionChanged: (v) =>
                    ref.read(growthPeriodProvider.notifier).set(v.single),
              ),
              if (g != null) ...[
                const SizedBox(height: 16),
                Row(
                  spacing: 12,
                  children: [
                    _Stat(
                      label: l10n.growthPractice,
                      value: minutes(g.practice),
                      color: AppColors.blue,
                    ),
                    _Stat(
                      label: l10n.growthSpeech,
                      value: g.speech == null
                          ? l10n.homeNoData
                          : minutes(g.speech!),
                      color: AppColors.green,
                    ),
                    _Stat(
                      label: l10n.growthSessions,
                      value: l10n.growthSessionCount(g.sessions),
                      color: AppColors.orange,
                    ),
                  ],
                ),
                if (g.avgAnswerWords case final w?)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(
                      '${l10n.homeAvgAnswer}: '
                      '${l10n.homeAvgWords(w.toStringAsFixed(1))}',
                    ),
                  ),
                heading(l10n.growthDaily),
                if (g.sessions == 0)
                  Text(l10n.growthEmpty, style: muted)
                else
                  _DayBars(days: g.days),
                heading(l10n.growthWeakAreas),
                if (g.weakAreas.isEmpty)
                  Text(l10n.growthNoWeak, style: muted)
                else
                  for (final (category, count) in g.weakAreas)
                    _WeakArea(
                      label: categoryName(l10n, category),
                      count: count,
                      share: count / g.weakAreas.first.$2,
                    ),
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(l10n.growthWeakNote, style: muted),
                ),
                heading(l10n.growthLevels),
                if (g.levels.isEmpty)
                  Text(l10n.growthNoLevels, style: muted)
                else
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      for (final (i, p) in g.levels.indexed) ...[
                        if (i > 0)
                          Icon(
                            Icons.arrow_forward,
                            size: 16,
                            color: theme.colorScheme.outline,
                          ),
                        Chip(
                          label: Text(
                            '${_date(p.at.toLocal())} ${p.level.label}',
                          ),
                        ),
                      ],
                    ],
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

String _date(DateTime d) => '${d.month}/${d.day}';

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value, required this.color});

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 6,
            children: [
              Container(
                width: 24,
                height: 4,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              Text(value, style: theme.textTheme.titleMedium),
            ],
          ),
        ),
      ),
    );
  }
}

/// Practice minutes per day as bars, oldest on the left.
class _DayBars extends StatelessWidget {
  const _DayBars({required this.days});

  final List<DayTotal> days;

  static const _height = 120.0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final most = days.map((d) => d.practice.inSeconds).reduce(math.max);
    final label = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );
    return Column(
      children: [
        SizedBox(
          height: _height,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            spacing: days.length > 7 ? 2 : 8,
            children: [
              for (final d in days)
                Expanded(
                  child: Tooltip(
                    message: l10n.growthDayBar(
                      _date(d.day),
                      d.practice.inMinutes,
                    ),
                    child: Semantics(
                      label: l10n.growthDayBar(
                        _date(d.day),
                        d.practice.inMinutes,
                      ),
                      child: Container(
                        height: most == 0
                            ? 2
                            : math.max(
                                2,
                                _height * d.practice.inSeconds / most,
                              ),
                        decoration: BoxDecoration(
                          color: d.practice == Duration.zero
                              ? theme.colorScheme.outlineVariant
                              : AppColors.blue,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(_date(days.first.day), style: label),
            Text(_date(days.last.day), style: label),
          ],
        ),
      ],
    );
  }
}

class _WeakArea extends StatelessWidget {
  const _WeakArea({
    required this.label,
    required this.count,
    required this.share,
  });

  final String label;
  final int count;

  /// Relative to the most frequent category (0..1).
  final double share;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 4,
        children: [
          Row(
            children: [
              Expanded(child: Text(label)),
              Text(l10n.growthSessionCount(count)),
            ],
          ),
          LinearProgressIndicator(
            value: share,
            color: AppColors.orange,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    );
  }
}
