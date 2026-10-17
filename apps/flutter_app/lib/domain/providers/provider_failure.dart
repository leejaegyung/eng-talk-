/// Normalized provider errors; the UI branches only on these (spec §11).
enum ProviderFailure {
  invalidKey,
  insufficientQuota,
  rateLimited,
  modelUnavailable,
  network,
  unknown,
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
