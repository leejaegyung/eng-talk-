import '../../../domain/providers/provider_failure.dart';

/// One entry of the plan-usage model list (`GET /v1/models` returns
/// `{"models": [{"slug", "priority", "description", "visibility",
/// "supported_in_api", ...}]}` for ChatGPT plan tokens).
final class PlanModel {
  const PlanModel({
    required this.slug,
    this.priority = 1 << 30,
    this.description = '',
    this.listed = true,
    this.supportedInApi = true,
  });

  final String slug;
  final int priority;
  final String description;
  final bool listed;
  final bool supportedInApi;
}

/// Picks a model from the account's live list without naming models here
/// (CLAUDE.md rule 4): conversation turns need a quick reply, so the
/// highest-priority model OpenAI describes as fast wins, otherwise the
/// highest-priority one. A user override comes with P1-A2.
String selectChatGptPlanModel(List<PlanModel> available) {
  final usable = [
    for (final m in available)
      if (m.listed && m.supportedInApi) m,
  ]..sort((a, b) => a.priority.compareTo(b.priority));
  if (usable.isEmpty) {
    throw const ProviderException(ProviderFailure.modelUnavailable);
  }
  final fast = usable.where(
    (m) => m.description.toLowerCase().contains('fast'),
  );
  return (fast.isEmpty ? usable.first : fast.first).slug;
}
