import '../../../domain/providers/provider_failure.dart';

// The only place Gemini model IDs may appear (CLAUDE.md rule 4). Only
// models on the Gemini API free tier (ADR-015); matched against the key's
// live model list. Re-check https://ai.google.dev/gemini-api/docs/pricing
// on release.

/// Flash-Lite first: fastest first token, thinking minimal or off by
/// default, free of charge.
const geminiChatPreference = [
  'gemini-3.5-flash-lite',
  'gemini-3.1-flash-lite',
  'gemini-2.5-flash-lite',
];

String selectGeminiModel(Iterable<String> available) {
  final ids = available.toSet();
  return geminiChatPreference.firstWhere(
    ids.contains,
    orElse: () =>
        throw const ProviderException(ProviderFailure.modelUnavailable),
  );
}
