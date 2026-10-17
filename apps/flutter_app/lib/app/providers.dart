import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/audio/record_audio_input.dart';
import '../data/audio/temp_file_audio_output.dart';
import '../data/providers/openai/openai_client.dart';
import '../data/providers/openai/provider_catalog.dart';
import '../data/vault/secure_storage_vault.dart';
import '../domain/audio/audio_io.dart';
import '../domain/credentials/credential_vault.dart';
import '../domain/providers/ai_provider.dart';

// The only place where data implementations are bound to domain interfaces.
// Tests override these.

final credentialVaultProvider = Provider<CredentialVault>(
  (ref) => SecureStorageVault(),
);

final audioInputProvider = Provider<AudioInput>((ref) {
  final input = RecordAudioInput();
  ref.onDispose(input.dispose);
  return input;
});

final audioOutputProvider = Provider<AudioOutput>((ref) {
  final output = TempFileAudioOutput();
  ref.onDispose(output.dispose);
  return output;
});

/// Vault entry holding the user's OpenAI key (stored in DB as vault_key_ref).
const openAiKeyRef = 'provider.openai';

final openAiClientProvider = Provider<OpenAiClient>((ref) {
  final client = OpenAiClient(
    vault: ref.watch(credentialVaultProvider),
    keyRef: openAiKeyRef,
  );
  ref.onDispose(client.close);
  return client;
});

final llmProviderProvider = Provider<LlmProvider>(
  (ref) => ref.watch(openAiClientProvider),
);

final voiceProviderProvider = Provider<VoiceProvider>(
  (ref) => ref.watch(openAiClientProvider),
);

/// Lists the account's models and picks one per capability.
final modelSelectorProvider = Provider<Future<ModelSelection> Function()>((
  ref,
) {
  final llm = ref.watch(llmProviderProvider);
  return () async => selectOpenAiModels(await llm.listModels());
});
