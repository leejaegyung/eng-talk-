import 'dart:math';

/// The "put the words in order" review exercise (user request 2026-10-18).

/// Words of [sentence] as tiles, punctuation dropped ("I'm" stays whole).
List<String> wordTiles(String sentence) => [
  for (final w in sentence.split(RegExp(r'\s+')))
    if (w.replaceAll(RegExp(r"^[^\w']+|[^\w']+$"), '') case final t
        when t.isNotEmpty)
      t,
];

/// [tiles] in a random order that differs from the answer whenever the
/// words allow it.
List<String> shuffledTiles(List<String> tiles, Random random) {
  final shuffled = [...tiles];
  if (tiles.toSet().length < 2) return shuffled;
  for (var i = 0; i < 20; i++) {
    shuffled.shuffle(random);
    if (!_same(shuffled, tiles)) break;
  }
  return shuffled;
}

/// Whether [answer] tiles spell [sentence], ignoring case and punctuation.
bool wordOrderCorrect(List<String> answer, String sentence) =>
    _same(answer, wordTiles(sentence));

/// How much of [b]'s vocabulary [a] reuses (0..1): a word-order fix keeps
/// the words, a rewrite doesn't.
double sharedWords(String a, String b) {
  final wa = wordTiles(a).map((w) => w.toLowerCase()).toList();
  final wb = wordTiles(b).map((w) => w.toLowerCase()).toSet();
  if (wa.isEmpty) return 0;
  return wa.where(wb.contains).length / wa.length;
}

bool _same(List<String> a, List<String> b) =>
    a.length == b.length &&
    [
      for (var i = 0; i < a.length; i++)
        a[i].toLowerCase() == b[i].toLowerCase(),
    ].every((x) => x);
