// Real network call with a fake key: OpenAI answers 401 and nothing is
// billed. Proves the sandbox network entitlement and invalidKey mapping.
//   flutter test integration_test/openai_invalid_key_test.dart -d macos
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:speaking_coach/data/providers/openai/openai_client.dart';
import 'package:speaking_coach/domain/credentials/credential_vault.dart';
import 'package:speaking_coach/domain/providers/provider_failure.dart';

class _OneKeyVault implements CredentialVault {
  @override
  Future<String?> read(String ref) async => 'sk-FAKE-integration-invalid-key';

  @override
  Future<void> write(String ref, String secret) async {}

  @override
  Future<void> delete(String ref) async {}
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  test('fake key is rejected by OpenAI as invalidKey', () async {
    final client = OpenAiClient(vault: _OneKeyVault(), keyRef: 'poc.fake');
    addTearDown(client.close);
    await expectLater(
      client.listModels(),
      throwsA(
        isA<ProviderException>()
            .having((e) => e.failure, 'failure', ProviderFailure.invalidKey)
            .having((e) => e.statusCode, 'status', 401),
      ),
    );
  });
}
