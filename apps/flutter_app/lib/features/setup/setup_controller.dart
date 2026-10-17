import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../domain/conversation/session_enums.dart';
import '../../domain/learning/learner_level.dart';
import '../../domain/sessions/session_records.dart';
import '../../domain/settings/settings_store.dart';
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

  Future<void> _loadLevel() async {
    final saved = await ref
        .read(settingsStoreProvider)
        .read(SettingKeys.learnerLevel);
    final level = LearnerLevel.values.asNameMap()[saved];
    if (ref.mounted && level != null) state = state.copyWith(level: level);
  }

  void setMode(SessionMode mode) {
    if (mode == state.mode) return;
    state = state.copyWith(mode: mode, clearScenario: true);
  }

  Future<void> setLevel(LearnerLevel level) async {
    state = state.copyWith(level: level);
    await ref
        .read(settingsStoreProvider)
        .write(SettingKeys.learnerLevel, level.name);
  }

  void setTopic(String? topic) => state = state.copyWith(
    topic: topic,
    goal: state.goal,
    role: state.role,
    clearScenario: true,
  );

  void setScenario(Scenario s) => state = state.copyWith(
    topic: s.situation,
    role: s.role,
    goal: s.goal,
    clearScenario: true,
  );

  void setRole(String? role) => state = state.copyWith(
    topic: state.topic,
    goal: state.goal,
    role: role,
    clearScenario: true,
  );

  void setGoal(String? goal) => state = state.copyWith(
    topic: state.topic,
    goal: goal,
    role: state.role,
    clearScenario: true,
  );

  void setLength(Duration length) => state = state.copyWith(length: length);

  /// Roleplay needs someone to play; other modes can start as they are.
  bool get ready =>
      state.mode != SessionMode.roleplay ||
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
