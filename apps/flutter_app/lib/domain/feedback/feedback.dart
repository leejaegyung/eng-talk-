/// Post-session feedback (spec §8.4), validated against the transcript.
library;

enum Severity { low, medium, high }

final class Correction {
  const Correction({
    required this.turnId,
    required this.original,
    required this.suggested,
    this.explanationKo,
    this.severity = Severity.medium,
    this.practicePrompt,
  });

  /// The learner turn the [original] text was taken from.
  final int turnId;
  final String original;
  final String suggested;
  final String? explanationKo;
  final Severity severity;
  final String? practicePrompt;
}

final class Expression {
  const Expression(this.phrase, {this.meaningKo});

  final String phrase;
  final String? meaningKo;
}

final class FeedbackResult {
  const FeedbackResult({
    this.strengths = const [],
    this.corrections = const [],
    this.expressions = const [],
    this.nextTopic,
    this.reduced = false,
  });

  static const empty = FeedbackResult(reduced: true);

  final List<String> strengths;
  final List<Correction> corrections;
  final List<Expression> expressions;
  final String? nextTopic;

  /// True when the model's output couldn't be fully used and a safe,
  /// shortened result is shown instead (spec §11).
  final bool reduced;

  bool get isEmpty =>
      strengths.isEmpty && corrections.isEmpty && expressions.isEmpty;
}
