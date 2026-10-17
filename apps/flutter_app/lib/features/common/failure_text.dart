import '../../app/l10n/gen/app_localizations.dart';
import '../../domain/providers/provider_failure.dart';

/// User-facing message for each normalized provider failure (spec §11).
String failureText(AppLocalizations l10n, ProviderFailure f) => switch (f) {
  ProviderFailure.invalidKey => l10n.failureInvalidKey,
  ProviderFailure.insufficientQuota => l10n.failureInsufficientQuota,
  ProviderFailure.rateLimited => l10n.failureRateLimited,
  ProviderFailure.modelUnavailable => l10n.failureModelUnavailable,
  ProviderFailure.network => l10n.failureNetwork,
  ProviderFailure.unknown => l10n.failureUnknown,
  ProviderFailure.signInRequired => l10n.failureSignInRequired,
  ProviderFailure.planUsageLimit => l10n.failurePlanUsageLimit,
  ProviderFailure.planNotEligible => l10n.failurePlanNotEligible,
};
