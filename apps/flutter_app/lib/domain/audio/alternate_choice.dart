/// Picks among the recognizer's alternative transcripts using what the
/// learner is likely to say (P1-B1a hints: the coach's question, topic,
/// earlier words). Recognizers rank by sound alone, so with an accent the
/// right sentence is often second or third; a candidate that shares more
/// words with the context wins unless the top one is near certain.
///
/// [alternates] are (text, confidence) in the recognizer's order;
/// confidence is in 0..1, or negative when the platform doesn't give one.
String chooseAlternate(
  List<(String, double)> alternates,
  List<String> hints, {
  double sureEnough = 0.9,
}) {
  if (alternates.isEmpty) return '';
  final top = alternates.first;
  if (alternates.length == 1 || hints.isEmpty || top.$2 >= sureEnough) {
    return top.$1;
  }
  final context = {for (final h in hints) ..._words(h)};
  int matches(String text) => _words(text).where(context.contains).length;

  var best = top;
  var bestMatches = matches(top.$1);
  for (final alt in alternates.skip(1)) {
    final m = matches(alt.$1);
    // A clear gain in context words, not a coin flip on one word.
    if (m > bestMatches) {
      best = alt;
      bestMatches = m;
    }
  }
  return best.$1;
}

Set<String> _words(String text) => {
  for (final w in text.toLowerCase().split(RegExp(r"[^a-z0-9']+")))
    if (w.length >= 3) w,
};
