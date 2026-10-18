import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../domain/learning/learning_goal.dart';
import '../../domain/settings/settings_store.dart';

final class Goals {
  const Goals({this.goal, this.dailyMinutes});

  final LearningGoal? goal;

  /// Null = no daily target.
  final int? dailyMinutes;
}

/// Learning goal and daily target (spec §3.1), shared by onboarding,
/// settings, home and setup.
final goalsProvider = AsyncNotifierProvider<GoalsController, Goals>(
  GoalsController.new,
);

class GoalsController extends AsyncNotifier<Goals> {
  @override
  Future<Goals> build() async {
    final store = ref.watch(settingsStoreProvider);
    final goal = await store.read(SettingKeys.learningGoal);
    final minutes = int.tryParse(
      await store.read(SettingKeys.dailyGoalMinutes) ?? '',
    );
    return Goals(
      goal: LearningGoal.values.asNameMap()[goal],
      dailyMinutes: dailyGoalOptions.contains(minutes) ? minutes : null,
    );
  }

  Future<void> setGoal(LearningGoal goal) async {
    final current = state.value ?? const Goals();
    state = AsyncData(Goals(goal: goal, dailyMinutes: current.dailyMinutes));
    await ref
        .read(settingsStoreProvider)
        .write(SettingKeys.learningGoal, goal.name);
  }

  Future<void> setDailyMinutes(int minutes) async {
    final current = state.value ?? const Goals();
    state = AsyncData(Goals(goal: current.goal, dailyMinutes: minutes));
    await ref
        .read(settingsStoreProvider)
        .write(SettingKeys.dailyGoalMinutes, '$minutes');
  }
}
