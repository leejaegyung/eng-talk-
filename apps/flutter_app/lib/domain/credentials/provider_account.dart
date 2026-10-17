/// An AI account the user signs in to through the browser instead of
/// pasting a key (ADR-011). Failures are thrown as `ProviderException`.
abstract interface class ProviderAccount {
  Future<bool> isSignedIn();

  Future<void> signIn();

  /// Returns false when remote revocation couldn't be confirmed; local
  /// credentials are removed either way.
  Future<bool> signOut();
}
