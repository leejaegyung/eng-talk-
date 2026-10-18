import 'dart:io';

import 'package:speaking_coach/data/providers/chatgpt/chatgpt_auth.dart';
import 'package:speaking_coach/data/providers/chatgpt/chatgpt_plan_client.dart';
import 'package:speaking_coach/data/providers/chatgpt/provider_catalog.dart';
import 'package:speaking_coach/data/providers/gemini/gemini_client.dart';
import 'package:speaking_coach/data/providers/gemini/provider_catalog.dart';
import 'package:speaking_coach/domain/credentials/credential_vault.dart';
import 'package:speaking_coach/domain/providers/ai_provider.dart';

import 'file_vault.dart';

/// The ChatGPT sign-in used by the evaluation (no Xcode, no app needed):
/// browser consent once, tokens in [FileVault].
ChatGptAuth evalAuth() => ChatGptAuth(
  vault: FileVault(),
  // Time to finish signing in in the browser.
  callbackTimeout: const Duration(minutes: 15),
  openBrowser: (url) async {
    final opener = Platform.isMacOS
        ? 'open'
        : Platform.isWindows
        ? 'explorer'
        : 'xdg-open';
    await Process.run(opener, [url.toString()]);
  },
);

/// The AI under test: the ChatGPT plan by default, or Gemini when
/// GEMINI_API_KEY is set and AI=gemini (the key stays in the environment).
Future<(LlmProvider, String)> evalBackend() async {
  if (Platform.environment['AI'] == 'gemini') {
    final key = Platform.environment['GEMINI_API_KEY'];
    if (key == null || key.isEmpty) {
      throw StateError('AI=gemini needs GEMINI_API_KEY in the environment');
    }
    final vault = _EnvVault(key);
    final gemini = GeminiClient(vault: vault, keyRef: 'gemini');
    return (gemini, selectGeminiModel(await gemini.listModels()));
  }
  final auth = evalAuth();
  if (!await auth.isSignedIn()) {
    throw StateError('Sign in first: dart run tool/eval/sign_in.dart');
  }
  final client = ChatGptPlanClient(accessToken: auth.accessToken);
  return (client, selectChatGptPlanModel(await client.planModels()));
}

/// The Gemini key from the environment; nothing is written anywhere.
class _EnvVault implements CredentialVault {
  _EnvVault(this._key);

  final String _key;

  @override
  Future<String?> read(String ref) async => _key;

  @override
  Future<void> write(String ref, String secret) async {}

  @override
  Future<void> delete(String ref) async {}
}
