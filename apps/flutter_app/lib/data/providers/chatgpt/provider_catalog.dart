import '../../../domain/providers/provider_failure.dart';

/// The plan-usage model list is already filtered to models the signed-in
/// account may use, so take the first one OpenAI offers instead of naming
/// models here (CLAUDE.md rule 4). A user override comes with P1-A2.
String selectChatGptPlanModel(List<String> available) {
  if (available.isEmpty) {
    throw const ProviderException(ProviderFailure.modelUnavailable);
  }
  return available.first;
}
