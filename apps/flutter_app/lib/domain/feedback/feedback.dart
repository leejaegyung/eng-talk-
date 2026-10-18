/// Post-session feedback (spec §8.4), validated against the transcript.
library;

enum Severity { low, medium, high }

/// Kind of mistake, as classified by the model, for the growth dashboard's
/// weak areas (spec §3.2 S10). [wire] is the JSON value.
enum ErrorCategory {
  grammar('grammar'),
  wordChoice('word_choice'),
  structure('structure'),
  naturalness('naturalness');

  const ErrorCategory(this.wire);

  final String wire;

  static ErrorCategory? fromWire(Object? value) =>
      values.where((c) => c.wire == value).firstOrNull;
}

final class Correction {
  const Correction({
    required this.turnId,
    required this.original,
    required this.suggested,
    this.explanationKo,
    this.severity = Severity.medium,
    this.practicePrompt,
    this.category,
  });

  /// The learner turn the [original] text was taken from.
  final int turnId;
  final String original;
  final String suggested;
  final String? explanationKo;
  final Severity severity;
  final String? practicePrompt;

  /// Null for older feedback or an unknown value.
  final ErrorCategory? category;
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
