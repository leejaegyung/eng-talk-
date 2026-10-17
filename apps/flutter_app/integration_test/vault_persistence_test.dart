// Real OS keychain check across app launches (P0-T4). Run three times:
//   flutter test integration_test/vault_persistence_test.dart -d macos --dart-define=PHASE=write
//   ... --dart-define=PHASE=read    (new launch: value survived restart, then deleted)
//   ... --dart-define=PHASE=gone    (new launch: deletion persisted)
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:speaking_coach/data/vault/secure_storage_vault.dart';

const phase = String.fromEnvironment('PHASE');
const ref = 'poc.persistence';
const secret = 'sk-FAKE-persistence-check-0001';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  test('vault persistence phase "$phase"', () async {
    final vault = SecureStorageVault();
    switch (phase) {
      case 'write':
        await vault.delete(ref);
        await vault.write(ref, secret);
        expect(await vault.read(ref), secret);
      case 'read':
        expect(await vault.read(ref), secret);
        await vault.delete(ref);
        expect(await vault.read(ref), isNull);
      case 'gone':
        expect(await vault.read(ref), isNull);
      default:
        fail('pass --dart-define=PHASE=write|read|gone');
    }
  });
}
