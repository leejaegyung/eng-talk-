/// Which AI runs the coaching (ADR-011, ADR-015), persisted by name.
enum AiChoice {
  /// Sign in with ChatGPT; uses the plan, no extra charge (default).
  chatGpt,

  /// Gemini with the user's free-tier Google AI Studio key.
  gemini,
}
