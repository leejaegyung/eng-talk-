import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/audio/record_audio_input.dart';
import '../data/audio/temp_file_audio_output.dart';
import '../data/vault/secure_storage_vault.dart';
import '../domain/audio/audio_io.dart';
import '../domain/credentials/credential_vault.dart';

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
