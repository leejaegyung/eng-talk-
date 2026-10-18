// Gemini transcription of a real recording (the "Oasis music" case the
// device recognizer got wrong). Needs the free key in the environment:
//   GEMINI_API_KEY=… flutter test tool/eval/gemini_speech_test.dart
// tool/eval/audio/oasis.wav: macOS `say` voice, "I really like Oasis music.
// My favorite song is Wonderwall."
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:speaking_coach/data/providers/gemini/gemini_client.dart';
import 'package:speaking_coach/data/providers/gemini/provider_catalog.dart';
import 'package:speaking_coach/domain/credentials/credential_vault.dart';

class _EnvKey implements CredentialVault {
  @override
  Future<String?> read(String ref) async =>
      Platform.environment['GEMINI_API_KEY'];

  @override
  Future<void> write(String ref, String secret) async {}

  @override
  Future<void> delete(String ref) async {}
}

void main() {
  final hasKey = Platform.environment['GEMINI_API_KEY']?.isNotEmpty ?? false;

  test('Gemini hears "Oasis" and "Wonderwall"', () async {
    final gemini = GeminiClient(vault: _EnvKey(), keyRef: 'gemini');
    final model = selectGeminiModel(await gemini.listModels());
    final text = await gemini.transcribe(
      model: model,
      wav: await File('tool/eval/audio/oasis.wav').readAsBytes(),
      context: const ['What kind of music do you like?'],
    );
    // ignore: avoid_print
    print('GEMINI ($model): $text');
    expect(text.toLowerCase(), contains('oasis'));
    expect(text.toLowerCase(), contains('wonderwall'));
  }, skip: hasKey ? false : 'set GEMINI_API_KEY to run');
}
