/// Words and short phrases the learner is likely to say next, passed to the
/// speech recognizer to bias it toward them (contextual strings). Learners
/// tend to reuse the coach's words and the session topic, which are exactly
/// what generic recognizers miss with an accent.
///
/// [phrases] (topic, role, goal) are kept whole when short; [texts] (recent
/// coach lines, most important first) contribute their content words.
List<String> recognitionHints({
  Iterable<String> phrases = const [],
  Iterable<String> texts = const [],
  int max = 40,
}) {
  final seen = <String>{};
  final hints = <String>[];
  void add(String hint) {
    if (hints.length < max && seen.add(hint.toLowerCase())) hints.add(hint);
  }

  for (final p in phrases) {
    final phrase = p.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (phrase.isEmpty) continue;
    if (phrase.split(' ').length <= _maxPhraseWords) add(phrase);
  }
  for (final text in [...phrases, ...texts]) {
    for (final m in _word.allMatches(text)) {
      final word = m.group(0)!;
      if (word.length >= _minWordLength &&
          !_common.contains(word.toLowerCase())) {
        add(word);
      }
    }
  }
  return hints;
}

const _maxPhraseWords = 4;
const _minWordLength = 4;
final _word = RegExp(r"[A-Za-z][A-Za-z'-]*[A-Za-z]");

/// Frequent words the recognizer already gets right; biasing toward them
/// only crowds out the useful hints.
const _common = {
  'about',
  'after',
  'again',
  'also',
  'because',
  'been',
  'before',
  'being',
  'could',
  'does',
  'doing',
  'don\'t',
  'each',
  'even',
  'every',
  'from',
  'have',
  'having',
  'here',
  'it\'s',
  'just',
  'know',
  'like',
  'make',
  'many',
  'more',
  'most',
  'much',
  'only',
  'other',
  'really',
  'same',
  'should',
  'some',
  'such',
  'tell',
  'than',
  'that',
  'that\'s',
  'their',
  'them',
  'then',
  'there',
  'these',
  'they',
  'thing',
  'things',
  'think',
  'this',
  'those',
  'very',
  'want',
  'were',
  'what',
  'what\'s',
  'when',
  'where',
  'which',
  'while',
  'will',
  'with',
  'would',
  'your',
  'you\'re',
  'yours',
};
