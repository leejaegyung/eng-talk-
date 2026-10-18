import '../domain/credentials/credential_vault.dart';
import '../domain/credentials/provider_account.dart';
import '../domain/providers/ai_choice.dart';
import '../domain/providers/ai_provider.dart';
import '../domain/providers/provider_failure.dart';

/// "Signed in" for a key-based provider: a key is stored. Keys are entered
/// in settings, not through a browser sign-in.
class ApiKeyAccount implements ProviderAccount {
  ApiKeyAccount(this._vault, this._keyRef);

  final CredentialVault _vault;
  final String _keyRef;

  @override
  Future<bool> isSignedIn() async =>
      (await _vault.read(_keyRef))?.isNotEmpty ?? false;

  @override
  Future<void> signIn() async {
    if (!await isSignedIn()) {
      throw const ProviderException(ProviderFailure.invalidKey);
    }
  }

  @override
  Future<bool> signOut() async {
    await _vault.delete(_keyRef);
    return true;
  }
}

/// The AI the learner picked, resolved on every call so a change in
/// settings applies to the next request without rebuilding anything.
final class ActiveAi {
  ActiveAi({required this.choice, required this.chatGpt, required this.gemini});

  final Future<AiChoice> Function() choice;
  final AiBackend chatGpt;
  final AiBackend gemini;

  Future<AiBackend> current() async =>
      await choice() == AiChoice.gemini ? gemini : chatGpt;

  late final ProviderAccount account = _ActiveAccount(this);
  late final LlmProvider llm = _ActiveLlm(this);
  Future<String> selectModel() async => (await current()).selectModel();
}

final class AiBackend {
  const AiBackend({
    required this.account,
    required this.llm,
    required this.selectModel,
  });

  final ProviderAccount account;
  final LlmProvider llm;
  final Future<String> Function() selectModel;
}

class _ActiveAccount implements ProviderAccount {
  _ActiveAccount(this._ai);

  final ActiveAi _ai;

  @override
  Future<bool> isSignedIn() async => (await _ai.current()).account.isSignedIn();

  @override
  Future<void> signIn() async => (await _ai.current()).account.signIn();

  @override
  Future<bool> signOut() async => (await _ai.current()).account.signOut();
}

class _ActiveLlm implements LlmProvider {
  _ActiveLlm(this._ai);

  final ActiveAi _ai;

  @override
  Future<List<String>> listModels() async =>
      (await _ai.current()).llm.listModels();

  @override
  Stream<ChatChunk> streamChat({
    required String model,
    required List<ChatMessage> messages,
    int maxOutputTokens = 200,
  }) async* {
    final backend = await _ai.current();
    yield* backend.llm.streamChat(
      model: model,
      messages: messages,
      maxOutputTokens: maxOutputTokens,
    );
  }
}
