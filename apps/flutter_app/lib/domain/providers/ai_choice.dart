/// Which AI runs the coaching (ADR-011, ADR-014), persisted by name.
enum AiChoice {
  /// Sign in with ChatGPT; uses the plan, no extra charge (default).
  chatGpt,

  /// Claude with the user's Anthropic API key; billed per use.
  claude,
}
