import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:speaking_coach/app/providers.dart';
import 'package:speaking_coach/domain/providers/ai_provider.dart';
import 'package:speaking_coach/domain/providers/provider_failure.dart';
import 'package:speaking_coach/features/voice_lab/voice_lab_controller.dart';

import '../../helpers/fakes.dart';

const fakeKey = 'sk-FAKE-voice-lab-000000000000';

void main() {
  late MemoryVault vault;
  late FakeInput input;
  late FakeOutput output;
  late FakeAi ai;
  late ProviderContainer container;

  VoiceLabController ctrl() => container.read(voiceLabProvider.notifier);
  VoiceLabState state() => container.read(voiceLabProvider);

  ProviderContainer make({Future<ModelSelection> Function()? selectModels}) {
    final c = ProviderContainer(
      overrides: [
        credentialVaultProvider.overrideWithValue(vault),
        audioInputProvider.overrideWithValue(input),
        audioOutputProvider.overrideWithValue(output),
        llmProviderProvider.overrideWithValue(ai),
        voiceProviderProvider.overrideWithValue(ai),
        modelSelectorProvider.overrideWithValue(
          selectModels ??
              () async => const ModelSelection(
                chat: 'chat-m',
                transcription: 'stt-m',
                speech: 'tts-m',
              ),
        ),
      ],
    )..listen(voiceLabProvider, (_, _) {});
    addTearDown(c.dispose);
    return c;
  }

  /// Speaks for [loudFrames] × 50 ms, then stays silent until the VAD ends
  /// the utterance.
  Future<void> speak({int loudFrames = 10}) async {
    final talking = ctrl().talk();
    await pumpEventQueue();
    for (var i = 0; i < loudFrames; i++) {
      input.chunks.add(pcmChunk(8000));
    }
    for (var i = 0; i < 20 && !input.stopped; i++) {
      input.chunks.add(pcmChunk(0));
      await pumpEventQueue();
    }
    await talking;
  }

  setUp(() async {
    vault = MemoryVault();
    input = FakeInput();
    output = FakeOutput();
    ai = FakeAi();
    container = make();
    await pumpEventQueue();
  });

  group('key handling', () {
    test('reports no key on first launch', () {
      expect(state().keyStored, isFalse);
      expect(state().models, isNull);
    });

    test('saving a key stores it in the vault and selects models', () async {
      await ctrl().saveKey('  $fakeKey  ');
      expect(vault.values[openAiKeyRef], fakeKey);
      expect(state().keyStored, isTrue);
      expect(state().models?.chat, 'chat-m');
      expect(state().failure, isNull);
    });

    test('an existing key is picked up and verified on open', () async {
      vault.values[openAiKeyRef] = fakeKey;
      container = make();
      await pumpEventQueue();
      expect(state().keyStored, isTrue);
      expect(state().models, isNotNull);
    });

    test('failed connection test shows the normalized failure', () async {
      container = make(
        selectModels: () async =>
            throw const ProviderException(ProviderFailure.invalidKey),
      );
      await ctrl().saveKey(fakeKey);
      expect(state().failure, ProviderFailure.invalidKey);
      expect(state().models, isNull);
    });

    test('deleting the key removes it from the vault (S5)', () async {
      await ctrl().saveKey(fakeKey);
      await ctrl().deleteKey();
      expect(vault.values, isEmpty);
      expect(state().keyStored, isFalse);
      expect(state().models, isNull);
    });
  });

  group('round trip', () {
    setUp(() => ctrl().saveKey(fakeKey));

    test('speech → STT → chat → TTS → playback, with measurements', () async {
      await speak();

      expect(ai.transcribed.single.sublist(0, 4), 'RIFF'.codeUnits);
      expect(state().heard, 'I like hiking.');
      expect(state().reply, 'Nice! Where do you hike?');
      expect(ai.spoken.single, 'Nice! Where do you hike?');
      expect(output.played.single.$2, 'mp3');
      expect(output.played.single.$1, [1, 2, 3]);

      final run = state().runs.single;
      expect(run.inputTokens, 40);
      expect(run.outputTokens, 6);
      expect(run.speechChars, 'Nice! Where do you hike?'.length);
      expect(
        run.audioSent,
        greaterThanOrEqualTo(const Duration(milliseconds: 500)),
      );
      expect(run.total, greaterThanOrEqualTo(run.stt));
      expect(state().phase, VoicePhase.idle);
    });

    test('conversation history is sent with the system prompt', () async {
      await speak();
      await speak();
      final second = ai.chats.last;
      expect(second.first.role, ChatRole.system);
      expect(second.map((m) => m.role).skip(1), [
        ChatRole.user,
        ChatRole.assistant,
        ChatRole.user,
      ]);
      expect(state().runs, hasLength(2));
    });

    test('provider failure mid-turn is shown and the lab recovers', () async {
      ai.chatError = const ProviderException(ProviderFailure.insufficientQuota);
      await speak();
      expect(state().failure, ProviderFailure.insufficientQuota);
      expect(state().phase, VoicePhase.idle);
      expect(output.played, isEmpty);
      expect(state().runs, isEmpty);
    });

    test('stopping without speech sends nothing', () async {
      final talking = ctrl().talk();
      await pumpEventQueue();
      input.chunks.add(pcmChunk(0));
      await pumpEventQueue();
      await ctrl().stopListening();
      await talking;
      expect(ai.transcribed, isEmpty);
      expect(state().phase, VoicePhase.idle);
    });

    test('denied mic permission is reported', () async {
      input = FakeInput(permitted: false);
      container = make();
      await ctrl().saveKey(fakeKey);
      await ctrl().talk();
      expect(state().micDenied, isTrue);
    });
  });
}
