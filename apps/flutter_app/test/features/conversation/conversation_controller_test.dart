import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:speaking_coach/app/providers.dart';
import 'package:speaking_coach/domain/conversation/conversation_policy.dart';
import 'package:speaking_coach/domain/conversation/session_enums.dart';
import 'package:speaking_coach/domain/providers/ai_provider.dart';
import 'package:speaking_coach/domain/providers/provider_failure.dart';
import 'package:speaking_coach/domain/settings/settings_store.dart';
import 'package:speaking_coach/features/conversation/conversation_controller.dart';

import '../../helpers/fakes.dart';

void main() {
  late FakeAccount account;
  late FakeAi ai;
  late FakeSpeechInput mic;
  late FakeSpeechOutput voice;
  late MemorySettings settings;
  late DateTime now;
  late ProviderContainer container;

  ConversationController ctrl() =>
      container.read(conversationProvider.notifier);
  ConversationState state() => container.read(conversationProvider);
  String lastSystem() => ai.chats.last.first.content;

  ProviderContainer make() {
    final c = ProviderContainer(
      overrides: [
        chatGptAccountProvider.overrideWithValue(account),
        chatGptLlmProvider.overrideWithValue(ai),
        chatGptModelSelectorProvider.overrideWithValue(
          () async => 'plan-model',
        ),
        speechInputProvider.overrideWithValue(mic),
        speechOutputProvider.overrideWithValue(voice),
        settingsStoreProvider.overrideWithValue(settings),
        clockProvider.overrideWithValue(() => now),
      ],
    )..listen(conversationProvider, (_, _) {});
    addTearDown(c.dispose);
    return c;
  }

  setUp(() async {
    account = FakeAccount()..signedIn = true;
    ai = FakeAi();
    mic = FakeSpeechInput();
    voice = FakeSpeechOutput();
    settings = MemorySettings();
    now = DateTime.utc(2026, 10, 17, 9);
    container = make();
    await pumpEventQueue();
  });

  test('opens with the AI asking first; the kickoff is hidden', () {
    expect(state().active, isTrue);
    expect(state().turns.single.speaker, Speaker.assistant);
    expect(state().turns.single.text, 'Nice! Where do you hike?');
    expect(ai.chats.single.last.role, ChatRole.user);
    expect(voice.spoken, ['Nice! Where do you hike?']);
  });

  test('prompt is composed for daily mode at the default level', () {
    expect(lastSystem(), contains('mode: daily'));
    expect(lastSystem(), contains('level: L2'));
    expect(lastSystem(), contains('Warm-up'));
  });

  test('saved level is used', () async {
    settings.values[SettingKeys.learnerLevel] = 'l4';
    container = make();
    await pumpEventQueue();
    expect(lastSystem(), contains('level: L4'));
  });

  test('learner message → streamed reply, spoken', () async {
    await ctrl().send('I went hiking.');
    expect(state().turns.map((t) => t.speaker), [
      Speaker.assistant,
      Speaker.user,
      Speaker.assistant,
    ]);
    expect(ai.chats.last.last.content, 'I went hiking.');
    expect(voice.spoken, hasLength(2));
    expect(state().streaming, isFalse);
  });

  test('hint: visible request line, escalating notes', () async {
    await ctrl().act(CoachAction.hint);
    final request = state().turns[1];
    expect(request.speaker, Speaker.user);
    expect(request.isRequest, isTrue);
    expect(request.text, 'Could you give me a hint?');
    expect(lastSystem(), contains('Hint level 1'));

    await ctrl().act(CoachAction.hint);
    expect(lastSystem(), contains('Hint level 2'));

    await ctrl().send('I like mountains.');
    await ctrl().act(CoachAction.hint);
    expect(lastSystem(), contains('Hint level 1'));
  });

  test('slower makes the voice slow for the rest of the session', () async {
    await ctrl().act(CoachAction.slower);
    await ctrl().send('OK.');
    expect(voice.slow, [false, true, true]);
    expect(lastSystem(), contains('shorter, simpler'));
  });

  test('phase notes follow the elapsed time', () async {
    now = now.add(const Duration(minutes: 26));
    await ctrl().send('Hello');
    expect(lastSystem(), contains('wrap up'));
  });

  test('voice turn: recognized speech is sent', () async {
    mic.queue.add('I like hiking.');
    await ctrl().talk();
    expect(state().turns[1].text, 'I like hiking.');
    expect(state().turns[1].isRequest, isFalse);
  });

  test('silence after the AI spoke suggests a hint', () async {
    ctrl().tick();
    expect(state().hintSuggested, isFalse);
    now = now.add(const Duration(seconds: 21));
    ctrl().tick();
    expect(state().hintSuggested, isTrue);
    await ctrl().send('Sorry, thinking.');
    expect(state().hintSuggested, isFalse);
  });

  test('read-aloud off in settings is respected', () async {
    settings.values[SettingKeys.speakReplies] = 'false';
    voice = FakeSpeechOutput();
    container = make();
    await pumpEventQueue();
    expect(voice.spoken, isEmpty);
  });

  test('subtitles can be hidden', () {
    ctrl().toggleSubtitles();
    expect(state().subtitles, isFalse);
  });

  test('end stops voice and mic and freezes the session', () async {
    now = now.add(const Duration(minutes: 3));
    await ctrl().end();
    expect(state().active, isFalse);
    expect(state().ended, isTrue);
    expect(state().elapsed, const Duration(minutes: 3));
    expect(voice.stops, greaterThan(0));
    await ctrl().send('more');
    expect(ai.chats, hasLength(1));
  });

  test('not signed in: nothing is sent', () async {
    account.signedIn = false;
    ai = FakeAi();
    container = make();
    await pumpEventQueue();
    expect(state().signedIn, isFalse);
    expect(state().active, isFalse);
    expect(ai.chats, isEmpty);
  });

  test('failure keeps the conversation and shows the reason', () async {
    ai.chatError = const ProviderException(ProviderFailure.planUsageLimit);
    await ctrl().send('Hello');
    expect(state().failure, ProviderFailure.planUsageLimit);
    expect(state().turns.last.text, 'Hello');
    expect(state().active, isTrue);
  });
}
