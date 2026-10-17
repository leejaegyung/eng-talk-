import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:speaking_coach/app/providers.dart';
import 'package:speaking_coach/domain/conversation/session_enums.dart';
import 'package:speaking_coach/domain/learning/learner_level.dart';
import 'package:speaking_coach/domain/settings/settings_store.dart';
import 'package:speaking_coach/features/conversation/conversation_request.dart';
import 'package:speaking_coach/features/setup/scenarios.dart';
import 'package:speaking_coach/features/setup/setup_controller.dart';

import '../../helpers/fakes.dart';

void main() {
  late MemorySettings settings;
  late ProviderContainer c;

  SetupController ctrl() => c.read(setupProvider.notifier);
  NewSession started() => c.read(conversationRequestProvider) as NewSession;

  setUp(() async {
    settings = MemorySettings({SettingKeys.learnerLevel: 'l3'});
    c = ProviderContainer(
      overrides: [settingsStoreProvider.overrideWithValue(settings)],
    )..listen(setupProvider, (_, _) {});
    addTearDown(c.dispose);
    await pumpEventQueue();
  });

  test('starts from the saved level', () {
    expect(c.read(setupProvider).level, LearnerLevel.l3);
  });

  test('changing level is saved', () async {
    await ctrl().setLevel(LearnerLevel.l5);
    expect(settings.values[SettingKeys.learnerLevel], 'l5');
  });

  test('roleplay scenario fills role, situation and goal', () {
    ctrl()
      ..setMode(SessionMode.roleplay)
      ..setScenario(roleplayScenarios.first);
    ctrl().start();
    final s = started().setup;
    expect(s.mode, SessionMode.roleplay);
    expect(s.role, 'hotel front desk clerk');
    expect(s.topic, isNotNull);
    expect(s.goal, isNotNull);
  });

  test('roleplay needs a role', () {
    ctrl().setMode(SessionMode.roleplay);
    expect(ctrl().ready, isFalse);
    ctrl().setRole('taxi driver');
    expect(ctrl().ready, isTrue);
  });

  test('switching mode clears the previous scenario', () {
    ctrl()
      ..setMode(SessionMode.roleplay)
      ..setScenario(roleplayScenarios.first)
      ..setMode(SessionMode.theme);
    expect(c.read(setupProvider).role, isNull);
    expect(c.read(setupProvider).topic, isNull);
  });

  test('random ignores topics; blanks are dropped; length kept', () {
    ctrl()
      ..setMode(SessionMode.theme)
      ..setTopic('   ')
      ..setLength(const Duration(minutes: 45))
      ..start();
    expect(started().setup.topic, isNull);
    expect(started().setup.length, const Duration(minutes: 45));

    ctrl()
      ..setMode(SessionMode.random)
      ..setTopic('Food')
      ..start();
    expect(started().setup.topic, isNull);
  });
}
