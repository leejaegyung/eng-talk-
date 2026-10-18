import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/l10n/gen/app_localizations.dart';
import '../../domain/learning/learning_goal.dart';
import 'goals_controller.dart';

String goalName(AppLocalizations l10n, LearningGoal g) => switch (g) {
  LearningGoal.everyday => l10n.goalEveryday,
  LearningGoal.travel => l10n.goalTravel,
  LearningGoal.work => l10n.goalWork,
  LearningGoal.interview => l10n.goalInterview,
  LearningGoal.confidence => l10n.goalConfidence,
};

/// Goal and daily target chips, saved as they are tapped.
class GoalPicker extends ConsumerWidget {
  const GoalPicker({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final goals = ref.watch(goalsProvider).value ?? const Goals();
    final ctrl = ref.read(goalsProvider.notifier);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 12,
      children: [
        Text(l10n.goalsWhy, style: theme.textTheme.titleSmall),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final g in LearningGoal.values)
              ChoiceChip(
                label: Text(goalName(l10n, g)),
                selected: goals.goal == g,
                onSelected: (_) => ctrl.setGoal(g),
              ),
          ],
        ),
        const SizedBox(height: 4),
        Text(l10n.goalsDaily, style: theme.textTheme.titleSmall),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final m in dailyGoalOptions)
              ChoiceChip(
                label: Text(l10n.goalsMinutes(m)),
                selected: goals.dailyMinutes == m,
                onSelected: (_) => ctrl.setDailyMinutes(m),
              ),
          ],
        ),
      ],
    );
  }
}
