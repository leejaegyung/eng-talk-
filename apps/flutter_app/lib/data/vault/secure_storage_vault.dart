import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../core/logging/app_logger.dart';
import '../../domain/credentials/credential_vault.dart';

/// [CredentialVault] backed by the OS secure store (Keychain, Credential
/// Manager, Android Keystore).
class SecureStorageVault implements CredentialVault {
  SecureStorageVault()
    : _storage = const FlutterSecureStorage(
        // Unsigned builds can't use the data protection keychain (ADR-010).
        mOptions: MacOsOptions(usesDataProtectionKeychain: false),
      );

  static const _namespace = 'byok.';
  static final _refPattern = RegExp(r'^[a-z][a-z0-9_.-]{0,63}$');

  final FlutterSecureStorage _storage;

  @override
  Future<void> write(String ref, String secret) {
    if (secret.isEmpty) throw ArgumentError('secret must not be empty');
    return _storage.write(key: _key(ref), value: secret);
  }

  @override
  Future<String?> read(String ref) => _storage.read(key: _key(ref));

  @override
  Future<void> delete(String ref) => _storage.delete(key: _key(ref));

  /// Rejects malformed refs and refs that look like a secret, so a swapped
  /// argument can't put a key into a storage key name or error message.
  static String _key(String ref) {
    if (!_refPattern.hasMatch(ref) || AppLogger.redact(ref) != ref) {
      throw ArgumentError('invalid vault ref');
    }
    return '$_namespace$ref';
  }
}
