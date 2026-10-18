import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../domain/conversation/session_enums.dart';
import '../../domain/learning/learner_level.dart';
import '../../domain/learning/learning_goal.dart';
import '../../domain/sessions/session_records.dart';
import '../../domain/settings/settings_store.dart';
import '../common/goals_controller.dart';
import '../conversation/conversation_request.dart';
import 'scenarios.dart';

/// S04/S05 choices. Kept while the app runs so the last setup is remembered;
/// the level is also saved.
final setupProvider = NotifierProvider<SetupController, SessionSetup>(
  SetupController.new,
);

class SetupController extends Notifier<SessionSetup> {
  @override
  SessionSetup build() {
    unawaited(_loadLevel());
    return const SessionSetup();
  }

  /// Saved level, and the mode and length that fit the learner's goals.
  Future<void> _loadLevel() async {
    final saved = await ref
        .read(settingsStoreProvider)
        .read(SettingKeys.learnerLevel);
    final goals = await ref.read(goalsProvider.future);
    if (!ref.mounted) return;
    final level = LearnerLevel.values.asNameMap()[saved];
    final minutes = goals.dailyMinutes;
    state = state.copyWith(
      level: level,
      mode: goals.goal?.mode,
      length: minutes == null ? null : sessionLengthFor(minutes),
    );
  }

  void setMode(SessionMode mode) {
    if (mode == state.mode) return;
    state = state.copyWith(mode: mode, aiTopic: false, clearScenario: true);
  }

  /// "Random": the AI picks the topic (roleplay: the whole scenario).
  void setAiTopic(bool on) =>
      state = state.copyWith(aiTopic: on, clearScenario: true);

  Future<void> setLevel(LearnerLevel level) async {
    state = state.copyWith(level: level);
    await ref
        .read(settingsStoreProvider)
        .write(SettingKeys.learnerLevel, level.name);
  }

  void setTopic(String? topic) => state = state.copyWith(
    topic: topic,
    aiTopic: false,
    goal: state.goal,
    role: state.role,
    clearScenario: true,
  );

  void setScenario(Scenario s) => state = state.copyWith(
    topic: s.situation,
    aiTopic: false,
    role: s.role,
    goal: s.goal,
    clearScenario: true,
  );

  void setRole(String? role) => state = state.copyWith(
    topic: state.topic,
    aiTopic: false,
    goal: state.goal,
    role: role,
    clearScenario: true,
  );

  void setGoal(String? goal) => state = state.copyWith(
    topic: state.topic,
    aiTopic: false,
    goal: goal,
    role: state.role,
    clearScenario: true,
  );

  void setLength(Duration length) => state = state.copyWith(length: length);

  /// Roleplay needs someone to play; other modes can start as they are.
  bool get ready =>
      state.mode != SessionMode.roleplay ||
      state.aiTopic ||
      (state.role?.trim().isNotEmpty ?? false);

  void start() => ref
      .read(conversationRequestProvider.notifier)
      .open(NewSession(_clean(state)));

  static SessionSetup _clean(SessionSetup s) {
    String? v(String? x) => x == null || x.trim().isEmpty ? null : x.trim();
    final random = s.mode == SessionMode.random;
    return s.copyWith(
      topic: random ? null : v(s.topic),
      goal: v(s.goal),
      role: s.mode == SessionMode.roleplay ? v(s.role) : null,
      clearScenario: true,
    );
  }
}
