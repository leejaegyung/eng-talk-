/// Five practice levels (spec §2.2). Persisted by name. Not CEFR
/// certification.
enum LearnerLevel {
  l1('L1'),
  l2('L2'),
  l3('L3'),
  l4('L4'),
  l5('L5');

  const LearnerLevel(this.label);

  final String label;
}
