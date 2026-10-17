/// Normalized provider errors; the UI branches only on these (spec §11).
enum ProviderFailure {
  invalidKey,
  insufficientQuota,
  rateLimited,
  modelUnavailable,
  network,
  unknown,

  /// ChatGPT sign-in missing, expired or revoked (ADR-011).
  signInRequired,

  /// The ChatGPT plan's usage limit for this app was reached.
  planUsageLimit,

  /// The ChatGPT account or workspace can't use its plan in apps.
  planNotEligible,
}

/// Never carries the response body or request headers, so it is safe to log.
final class ProviderException implements Exception {
  const ProviderException(this.failure, {this.statusCode, this.retryAfter});

  final ProviderFailure failure;
  final int? statusCode;
  final Duration? retryAfter;

  @override
  String toString() =>
      'ProviderException($failure'
      '${statusCode == null ? '' : ', status: $statusCode'})';
}
