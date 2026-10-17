import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:speaking_coach/app/providers.dart';
import 'package:speaking_coach/domain/credentials/provider_account.dart';
import 'package:speaking_coach/domain/providers/ai_provider.dart';
import 'package:speaking_coach/domain/providers/provider_failure.dart';
import 'package:speaking_coach/features/chatgpt_lab/chatgpt_lab_controller.dart';

import '../../helpers/fakes.dart';

class FakeAccount implements ProviderAccount {
  bool signedIn = false;
  Object? signInError;
  int signOuts = 0;

  @override
  Future<bool> isSignedIn() async => signedIn;

  @override
  Future<void> signIn() async {
    if (signInError != null) throw signInError!;
    signedIn = true;
  }

  @override
  Future<bool> signOut() async {
    signOuts++;
    signedIn = false;
    return true;
  }
}

void main() {
  late FakeAccount account;
  late FakeAi ai;
  late ProviderContainer container;

  ChatGptLabController ctrl() => container.read(chatGptLabProvider.notifier);
  ChatGptLabState state() => container.read(chatGptLabProvider);

  ProviderContainer make({Future<String> Function()? selectModel}) {
    final c = ProviderContainer(
      overrides: [
        chatGptAccountProvider.overrideWithValue(account),
        chatGptLlmProvider.overrideWithValue(ai),
        chatGptModelSelectorProvider.overrideWithValue(
          selectModel ?? () async => 'plan-model',
        ),
      ],
    )..listen(chatGptLabProvider, (_, _) {});
    addTearDown(c.dispose);
    return c;
  }

  setUp(() async {
    account = FakeAccount();
    ai = FakeAi();
    container = make();
    await pumpEventQueue();
  });

  test('starts signed out', () {
    expect(state().signedIn, isFalse);
    expect(state().model, isNull);
  });

  test('sign-in picks the plan model', () async {
    await ctrl().signIn();
    expect(state().signedIn, isTrue);
    expect(state().model, 'plan-model');
    expect(state().failure, isNull);
  });

  test('existing session is restored on open', () async {
    account.signedIn = true;
    container = make();
    await pumpEventQueue();
    expect(state().signedIn, isTrue);
    expect(state().model, 'plan-model');
  });

  test('ineligible account is reported', () async {
    account.signInError = const ProviderException(
      ProviderFailure.planNotEligible,
    );
    await ctrl().signIn();
    expect(state().signedIn, isFalse);
    expect(state().failure, ProviderFailure.planNotEligible);
  });

  test('send streams the reply and measures it', () async {
    await ctrl().signIn();
    await ctrl().send('  I like hiking.  ');

    final sent = ai.chats.single;
    expect(sent.first.role, ChatRole.system);
    expect(sent.last.content, 'I like hiking.');
    expect(state().turns.map((t) => t.role), [
      ChatRole.user,
      ChatRole.assistant,
    ]);
    expect(state().turns.last.content, 'Nice! Where do you hike?');
    expect(state().firstTokens, hasLength(1));
    expect(state().inputTokens, 40);
    expect(state().outputTokens, 6);
    expect(state().streaming, isFalse);
  });

  test('history is carried into the next request', () async {
    await ctrl().signIn();
    await ctrl().send('Hi');
    await ctrl().send('Mountains.');
    expect(ai.chats.last.skip(1).map((m) => m.role), [
      ChatRole.user,
      ChatRole.assistant,
      ChatRole.user,
    ]);
  });

  test('blank input is ignored', () async {
    await ctrl().signIn();
    await ctrl().send('   ');
    expect(ai.chats, isEmpty);
  });

  test('usage limit keeps the user message and shows the failure', () async {
    await ctrl().signIn();
    ai.chatError = const ProviderException(ProviderFailure.planUsageLimit);
    await ctrl().send('Hello');
    expect(state().failure, ProviderFailure.planUsageLimit);
    expect(state().turns.single.role, ChatRole.user);
    expect(state().streaming, isFalse);
  });

  test('expired sign-in returns to the signed-out state', () async {
    await ctrl().signIn();
    ai.chatError = const ProviderException(ProviderFailure.signInRequired);
    await ctrl().send('Hello');
    expect(state().signedIn, isFalse);
    expect(state().failure, ProviderFailure.signInRequired);
  });

  test('sign-out clears the conversation', () async {
    await ctrl().signIn();
    await ctrl().send('Hi');
    await ctrl().signOut();
    expect(account.signOuts, 1);
    expect(state().signedIn, isFalse);
    expect(state().turns, isEmpty);
  });
}
