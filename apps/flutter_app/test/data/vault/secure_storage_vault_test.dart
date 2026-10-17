import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:speaking_coach/data/vault/secure_storage_vault.dart';

const fakeKey = 'sk-FAKE-0123456789abcdefghij';

void main() {
  late SecureStorageVault vault;

  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
    vault = SecureStorageVault();
  });

  test('write then read returns the secret', () async {
    await vault.write('provider.openai', fakeKey);
    expect(await vault.read('provider.openai'), fakeKey);
  });

  test('unknown ref reads as null', () async {
    expect(await vault.read('provider.openai'), isNull);
  });

  test('delete removes the secret (S5)', () async {
    await vault.write('provider.openai', fakeKey);
    await vault.delete('provider.openai');
    expect(await vault.read('provider.openai'), isNull);
  });

  test('write replaces an existing secret', () async {
    await vault.write('provider.openai', fakeKey);
    await vault.write('provider.openai', '${fakeKey}2');
    expect(await vault.read('provider.openai'), '${fakeKey}2');
  });

  test('refs are isolated from each other', () async {
    await vault.write('provider.openai', fakeKey);
    await vault.write('provider.gemini', 'AIzaFAKE');
    await vault.delete('provider.openai');
    expect(await vault.read('provider.gemini'), 'AIzaFAKE');
  });

  test('entries are namespaced in OS storage', () async {
    await vault.write('provider.openai', fakeKey);
    final all = await const FlutterSecureStorage().readAll();
    expect(all.keys, ['byok.provider.openai']);
  });

  group('rejects misuse', () {
    test('empty secret', () {
      expect(() => vault.write('provider.openai', ''), throwsArgumentError);
    });

    for (final ref in ['', 'Provider', 'has space', fakeKey, 'a' * 65]) {
      test('invalid ref "$ref"', () {
        expect(() => vault.write(ref, fakeKey), throwsArgumentError);
        expect(() => vault.read(ref), throwsArgumentError);
        expect(() => vault.delete(ref), throwsArgumentError);
      });
    }

    test('error message never contains the secret', () async {
      try {
        await vault.write(fakeKey, fakeKey);
        fail('expected ArgumentError');
      } on ArgumentError catch (e) {
        expect(e.toString(), isNot(contains(fakeKey)));
      }
    });
  });
}
