import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:speaking_coach/app/providers.dart';
import 'package:speaking_coach/data/db/app_database.dart' show AppDatabase;
import 'package:speaking_coach/data/sessions/drift_session_repository.dart';
import 'package:speaking_coach/domain/conversation/conversation_policy.dart';
import 'package:speaking_coach/domain/conversation/session_enums.dart';
import 'package:speaking_coach/domain/conversation/session_types.dart';
import 'package:speaking_coach/domain/learning/learner_level.dart';
import 'package:speaking_coach/domain/providers/ai_provider.dart';
import 'package:speaking_coach/domain/providers/provider_failure.dart';
import 'package:speaking_coach/domain/sessions/session_records.dart';
import 'package:speaking_coach/domain/settings/settings_store.dart';
import 'package:speaking_coach/features/conversation/conversation_controller.dart';
import 'package:speaking_coach/features/conversation/conversation_request.dart';

import '../../helpers/fakes.dart';

void main() {
  late FakeAccount account;
  late FakeAi ai;
  late FakeSpeechInput mic;
  late FakeSpeechOutput voice;
  late MemorySettings settings;
  late AppDatabase db;
  late DriftSessionRepository repo;
  late DateTime now;
  late ProviderContainer container;
  late ConversationRequest request;

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
        sessionRepositoryProvider.overrideWithValue(repo),
        clockProvider.overrideWithValue(() => now),
      ],
    );
    c.read(conversationRequestProvider.notifier).open(request);
    c.listen(conversationProvider, (_, _) {});
    addTearDown(c.dispose);
    return c;
  }

  setUp(() async {
    account = FakeAccount()..signedIn = true;
    ai = FakeAi();
    mic = FakeSpeechInput();
    voice = FakeSpeechOutput();
    settings = MemorySettings({SettingKeys.handsFree: 'false'});
    (db, repo) = memoryRepository();
    addTearDown(db.close);
    now = DateTime.utc(2026, 10, 17, 9);
    request = const NewSession(SessionSetup());
    container = make();
    await pumpEventQueue();
  });

  test('opens: session stored, AI asks first, back to listening', () async {
    expect(state().sessionId, isNotNull);
    expect(state().phase, SessionPhase.listening);
    expect(state().turns.single.speaker, Speaker.assistant);
    expect(state().turns.single.id, isNotNull);
    expect(ai.chats.single.last.role, ChatRole.user);
    expect(voice.spoken, ['Nice! Where do you hike?']);
    final saved = (await repo.load(state().sessionId!))!;
    expect(saved.turns.single.text, 'Nice! Where do you hike?');
    expect(saved.turns.single.speechMs, isNotNull, reason: 'TTS timed');
  });

  test('prompt uses the setup: mode, level, topic, role', () async {
    request = const NewSession(
      SessionSetup(
        mode: SessionMode.roleplay,
        level: LearnerLevel.l4,
        topic: 'Late check-in',
        role: 'hotel clerk',
      ),
    );
    container = make();
    await pumpEventQueue();
    expect(lastSystem(), contains('mode: roleplay'));
    expect(lastSystem(), contains('level: L4'));
    expect(lastSystem(), contains('your_role: "hotel clerk"'));
    expect(lastSystem(), contains('topic: "Late check-in"'));
  });

  test('typed answer → reply; both saved in order', () async {
    await ctrl().send('I went hiking.');
    expect(state().turns.map((t) => t.speaker), [
      Speaker.assistant,
      Speaker.user,
      Speaker.assistant,
    ]);
    expect(ai.chats.last.last.content, 'I went hiking.');
    final saved = (await repo.load(state().sessionId!))!;
    expect(saved.turns.map((t) => t.text), [
      'Nice! Where do you hike?',
      'I went hiking.',
      'Nice! Where do you hike?',
    ]);
    expect(state().phase, SessionPhase.listening);
  });

  test('hint: visible request line saved as a quick action', () async {
    await ctrl().act(CoachAction.hint);
    expect(state().turns[1].isRequest, isTrue);
    expect(lastSystem(), contains('Hint level 1'));
    await ctrl().act(CoachAction.hint);
    expect(lastSystem(), contains('Hint level 2'));
    final saved = (await repo.load(state().sessionId!))!;
    expect(saved.turns[1].isRequest, isTrue);
  });

  test('slower makes the voice slow from then on', () async {
    await ctrl().act(CoachAction.slower);
    await ctrl().send('OK.');
    expect(voice.slow, [false, true, true]);
  });

  test('voice answer is sent with an estimated speaking time', () async {
    mic.queue.add('I like hiking a lot.');
    await ctrl().talk();
    expect(state().turns[1].text, 'I like hiking a lot.');
    expect(state().phase, SessionPhase.listening);
  });

  test('recognizer is biased toward the topic and the AI question', () async {
    request = const NewSession(
      SessionSetup(mode: SessionMode.roleplay, topic: 'Late check-in'),
    );
    container = make();
    await pumpEventQueue();
    mic.queue.add('Yes.');
    await ctrl().talk();
    expect(mic.hints.single, containsAll(['Late check-in', 'hike']));
  });

  test('nothing recognized: back to listening, nothing sent', () async {
    await ctrl().talk();
    expect(ai.chats, hasLength(1));
    expect(state().phase, SessionPhase.listening);
  });

  test('silence after the AI spoke suggests a hint', () async {
    ctrl().tick();
    expect(state().hintSuggested, isFalse);
    now = now.add(const Duration(seconds: 21));
    ctrl().tick();
    expect(state().hintSuggested, isTrue);
  });

  test('pause stops the clock; resume continues', () async {
    now = now.add(const Duration(minutes: 2));
    await ctrl().pause();
    expect(state().paused, isTrue);
    now = now.add(const Duration(minutes: 10));
    ctrl().tick();
    expect(state().elapsed, const Duration(minutes: 2));
    await ctrl().resume();
    now = now.add(const Duration(minutes: 1));
    ctrl().tick();
    expect(state().elapsed, const Duration(minutes: 3));
  });

  test(
    'app hidden: paused for the background, mic and voice stopped',
    () async {
      await ctrl().appHidden();
      expect(state().paused, isTrue);
      expect(state().pauseReason, PauseReason.background);
      expect(mic.stops, greaterThanOrEqualTo(1));
      expect(voice.stops, greaterThanOrEqualTo(1));
      await ctrl().resume();
      expect(state().phase, SessionPhase.listening);
    },
  );

  test('hidden when already paused or ended: nothing changes', () async {
    await ctrl().pause();
    await ctrl().appHidden();
    expect(state().pauseReason, PauseReason.user);
  });

  test('paused mid-reply: fragment dropped, asked again on resume', () async {
    final gate = Completer<void>();
    ai.gate = gate.future;
    final sending = ctrl().send('I went hiking.');
    await pumpEventQueue();
    expect(state().turns.last.text, 'Nice! ');
    await ctrl().appHidden();
    gate.complete();
    await sending;
    expect(state().turns.last.text, 'I went hiking.');

    ai.gate = null;
    await ctrl().resume();
    expect(ai.chats.last.last.content, 'I went hiking.');
    expect(state().turns.last.text, 'Nice! Where do you hike?');
    expect(state().phase, SessionPhase.listening);
    final saved = (await repo.load(state().sessionId!))!;
    expect(saved.turns.map((t) => t.text), [
      'Nice! Where do you hike?',
      'I went hiking.',
      'Nice! Where do you hike?',
    ]);
  });

  test(
    'quick resume before the stream notices still gets the answer',
    () async {
      final gate = Completer<void>();
      ai.gate = gate.future;
      final sending = ctrl().send('I went hiking.');
      await pumpEventQueue();
      await ctrl().pause();
      ai.gate = null;
      final resuming = ctrl().resume();
      gate.complete();
      await sending;
      await resuming;
      expect(state().turns.last.text, 'Nice! Where do you hike?');
      expect(
        state().turns.where((t) => t.text.startsWith('Nice')),
        hasLength(2),
      );
    },
  );

  group('hands-free (P2-1)', () {
    Future<void> open() async {
      settings.values[SettingKeys.handsFree] = 'true';
      container = make();
      await pumpEventQueue();
    }

    test('listens after the AI speaks and sends what was heard', () async {
      mic.queue.add('I like hiking.');
      await open();
      expect(state().handsFree, isTrue);
      expect(state().turns.map((t) => t.text), [
        'Nice! Where do you hike?',
        'I like hiking.',
        'Nice! Where do you hike?',
      ]);
      // Then two empty listens, and the mic is left to the learner.
      expect(mic.hints, hasLength(3));
      expect(state().phase, SessionPhase.listening);
    });

    test('nothing heard twice: stops listening', () async {
      await open();
      expect(mic.hints, hasLength(2));
      expect(state().turns, hasLength(1));
    });

    test(
      'typing while it listens drops the listen and sends the text',
      () async {
        mic.hold = Completer<void>();
        await open();
        expect(state().phase, SessionPhase.userSpeaking);
        expect(state().learnerCanAct, isTrue);
        await ctrl().send('Typed instead.');
        expect(state().turns[1].text, 'Typed instead.');
        expect(state().turns.last.speaker, Speaker.assistant);
      },
    );

    test('a quick action while it listens works too', () async {
      mic.hold = Completer<void>();
      await open();
      await ctrl().act(CoachAction.hint);
      expect(state().turns[1].isRequest, isTrue);
      expect(state().turns.last.speaker, Speaker.assistant);
    });

    test('stop with nothing said: no retry until the next AI turn', () async {
      mic.hold = Completer<void>();
      await open();
      await ctrl().stopListening();
      await pumpEventQueue();
      expect(mic.hints, hasLength(1));
      expect(state().phase, SessionPhase.listening);
    });

    test('pause stops it; resume listens again', () async {
      mic.hold = Completer<void>();
      await open();
      await ctrl().pause();
      await pumpEventQueue();
      expect(state().paused, isTrue);
      expect(mic.hints, hasLength(1));
      await ctrl().resume();
      await pumpEventQueue();
      expect(mic.hints, hasLength(3), reason: 'two empty listens again');
    });

    test('turned off: saved, and no listening on its own', () async {
      await open();
      await ctrl().setHandsFree(false);
      expect(settings.values[SettingKeys.handsFree], 'false');
      await ctrl().send('Hi');
      expect(mic.hints, hasLength(2), reason: 'only the opening attempts');
    });

    test('continue as text turns it off for the session', () async {
      await open();
      ai.chatError = const ProviderException(ProviderFailure.network);
      await ctrl().send('Hello');
      ai.chatError = null;
      final before = mic.hints.length;
      await ctrl().continueAsText();
      await pumpEventQueue();
      expect(mic.hints, hasLength(before));
    });
  });

  group('check speech before sending (P2-2)', () {
    setUp(() async {
      settings.values[SettingKeys.confirmSpeech] = 'true';
      container = make();
      await pumpEventQueue();
    });

    test('heard speech waits as a draft; nothing sent yet', () async {
      final chats = ai.chats.length;
      mic.queue.add('I like hiking a lot.');
      await ctrl().talk();
      expect(state().draft, 'I like hiking a lot.');
      expect(state().phase, SessionPhase.listening);
      expect(state().turns, hasLength(1));
      expect(ai.chats, hasLength(chats));
    });

    test('the fixed text is what gets sent and saved', () async {
      mic.queue.add('I like hike a lot.');
      await ctrl().talk();
      await ctrl().send('I like hiking a lot.');
      expect(state().draft, isNull);
      expect(state().turns[1].text, 'I like hiking a lot.');
      expect(ai.chats.last.last.content, 'I like hiking a lot.');
      final saved = (await repo.load(state().sessionId!))!;
      expect(saved.turns[1].text, 'I like hiking a lot.');
    });

    test('hands-free waits for the learner to send the draft', () async {
      settings.values[SettingKeys.handsFree] = 'true';
      mic.queue.add('Hello there.');
      container = make();
      await pumpEventQueue();
      expect(state().draft, 'Hello there.');
      expect(mic.hints, hasLength(1), reason: 'no listening over the draft');
    });
  });

  group('lost connection (B3)', () {
    setUp(() async {
      ai.chatError = const ProviderException(ProviderFailure.network);
      await ctrl().send('Hello');
    });

    test('pauses with the learner turn kept', () {
      expect(state().connectionLost, isTrue);
      expect(state().turns.last.text, 'Hello');
    });

    test('reconnect retries the request', () async {
      ai.chatError = null;
      await ctrl().resume();
      expect(state().phase, SessionPhase.listening);
      expect(state().turns.last.speaker, Speaker.assistant);
      expect(ai.chats.last.last.content, 'Hello');
    });

    test('continue as text stops reading aloud', () async {
      ai.chatError = null;
      await ctrl().continueAsText();
      expect(voice.spoken, hasLength(1));
      expect(state().turns.last.speaker, Speaker.assistant);
    });

    test('save and end keeps everything', () async {
      await ctrl().end();
      final saved = (await repo.load(state().sessionId!))!;
      expect(saved.summary.status, SessionStatus.completed);
      expect(saved.turns.last.text, 'Hello');
    });
  });

  test('other failures keep the turn with the learner', () async {
    ai.chatError = const ProviderException(ProviderFailure.planUsageLimit);
    await ctrl().send('Hello');
    expect(state().failure, ProviderFailure.planUsageLimit);
    expect(state().phase, SessionPhase.listening);
  });

  test('end saves status, time and speech stats', () async {
    mic.queue.add('I like hiking.');
    await ctrl().talk();
    now = now.add(const Duration(minutes: 3));
    await ctrl().end();
    expect(state().ended, isTrue);
    final saved = (await repo.load(state().sessionId!))!;
    expect(saved.summary.status, SessionStatus.completed);
    expect(saved.summary.duration, const Duration(minutes: 3));
    expect(saved.summary.stats!.turnCount, 1);
    await ctrl().send('more');
    expect(ai.chats, hasLength(2));
  });

  test('ending without answers is saved as abandoned', () async {
    await ctrl().end();
    final saved = (await repo.load(state().sessionId!))!;
    expect(saved.summary.status, SessionStatus.abandoned);
  });

  test('resume an unfinished session with its transcript', () async {
    await ctrl().send('I went hiking.');
    final id = state().sessionId!;
    container.dispose();

    request = ResumeSession(id);
    ai = FakeAi();
    container = make();
    await pumpEventQueue();
    expect(state().sessionId, id);
    expect(state().turns, hasLength(4));
    expect(lastSystem(), contains('back after a break'));
    expect(ai.chats.single.last.content, '[The learner is back.]');
  });

  test('not signed in: nothing stored or sent', () async {
    account.signedIn = false;
    ai = FakeAi();
    (db, repo) = memoryRepository();
    container = make();
    await pumpEventQueue();
    expect(state().signedIn, isFalse);
    expect(ai.chats, isEmpty);
    expect(await repo.list(), isEmpty);
  });

  test('read-aloud off in settings is respected', () async {
    settings.values[SettingKeys.speakReplies] = 'false';
    voice = FakeSpeechOutput();
    container = make();
    await pumpEventQueue();
    expect(voice.spoken, isEmpty);
  });
}
