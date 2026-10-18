/// Splits [text] into sentences for shadowing, keeping abbreviations
/// ("Mr.", "Dr.") inside their sentence.
List<String> splitSentences(String text) {
  const abbreviations = ['Mr.', 'Mrs.', 'Ms.', 'Dr.', 'St.', 'e.g.', 'i.e.'];
  var masked = text;
  for (final a in abbreviations) {
    masked = masked.replaceAll(a, a.replaceAll('.', '\u0000'));
  }
  return [
    for (final m in RegExp(r'[^.!?]+[.!?]*').allMatches(masked))
      if (m.group(0)!.replaceAll('\u0000', '.').trim() case final s
          when s.isNotEmpty)
        s,
  ];
}

/// Sentences of the coach's lines worth repeating: at least [minWords]
/// words, each once, at most [max].
List<String> shadowingSentences(
  Iterable<String> coachLines, {
  int minWords = 4,
  int max = 12,
}) {
  final seen = <String>{};
  final out = <String>[];
  for (final line in coachLines) {
    for (final s in splitSentences(line)) {
      if (s.split(RegExp(r'\s+')).length < minWords) continue;
      if (seen.add(s.toLowerCase()) && out.length < max) out.add(s);
    }
  }
  return out;
}
