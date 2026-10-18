import '../feedback/feedback.dart';
import '../sessions/growth_stats.dart';

/// Recent window and repeat count that make a kind of mistake a focus for
/// the next sessions (P2-4).
const focusWindow = Duration(days: 14);
const focusMinRepeats = 3;

/// The most frequent classified mistake in the last [focusWindow], if it
/// came up at least [focusMinRepeats] times; otherwise null.
ErrorCategory? focusArea(List<CorrectionStat> corrections, DateTime now) {
  final since = now.subtract(focusWindow);
  final counts = <ErrorCategory, int>{};
  for (final c in corrections) {
    final category = c.category;
    if (category == null || c.at.isBefore(since)) continue;
    counts[category] = (counts[category] ?? 0) + 1;
  }
  ErrorCategory? best;
  for (final category in ErrorCategory.values) {
    final n = counts[category] ?? 0;
    if (n >= focusMinRepeats && n > (counts[best] ?? 0)) best = category;
  }
  return best;
}

/// Whether [said] contains [phrase], ignoring case, punctuation and an
/// ellipsis or "~" placeholder in the phrase ("That reminds me of...").
bool usedExpression(String said, String phrase) {
  String norm(String s) => s
      .toLowerCase()
      .replaceAll(RegExp(r'(\.\.\.|…|~)'), ' ')
      .replaceAll(RegExp(r"[^a-z0-9' ]"), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
  final p = norm(phrase);
  return p.isNotEmpty && ' ${norm(said)} '.contains(' $p ');
}
