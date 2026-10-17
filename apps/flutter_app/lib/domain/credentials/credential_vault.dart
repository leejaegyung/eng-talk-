/// The only path for storing BYOK API keys (docs/security.md S1).
///
/// A `ref` (e.g. `provider.openai`) is what the database stores as
/// `vault_key_ref`; the secret itself never leaves the vault except to the
/// provider client that needs it.
abstract interface class CredentialVault {
  Future<void> write(String ref, String secret);

  /// Returns null when nothing is stored under [ref].
  Future<String?> read(String ref);

  Future<void> delete(String ref);
}
