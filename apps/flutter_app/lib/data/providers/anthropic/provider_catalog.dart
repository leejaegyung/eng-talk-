import '../../../domain/providers/provider_failure.dart';

// The only place Claude model IDs may appear (CLAUDE.md rule 4). Matched
// against the account's live model list; re-check the Anthropic docs on
// release.

/// Fast first token matters more than depth for turn-taking (ADR-014).
const claudeChatPreference = ['claude-haiku-5-5', 'claude-sonnet-5-5'];

/// Families tried, in order, when none of the preferred IDs is offered.
const _families = ['claude-haiku', 'claude-sonnet'];

String selectClaudeModel(Iterable<String> available) {
  final ids = available.toList()..sort();
  for (final id in claudeChatPreference) {
    if (ids.contains(id)) return id;
  }
  for (final family in _families) {
    // Newest by name within the family (IDs carry the version).
    final match = ids.lastWhere(
      (id) => id.startsWith(family),
      orElse: () => '',
    );
    if (match.isNotEmpty) return match;
  }
  throw const ProviderException(ProviderFailure.modelUnavailable);
}
