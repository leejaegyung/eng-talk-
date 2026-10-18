import 'package:flutter/material.dart';

import '../../app/l10n/gen/app_localizations.dart';
import '../../app/theme.dart';

/// One box per repetition of a sentence; ticked automatically
/// when it is said as corrected, or by hand.
class RepeatBoxes extends StatelessWidget {
  const RepeatBoxes({super.key, required this.checks, required this.onToggle});

  final List<bool> checks;
  final void Function(int index) onToggle;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final done = checks.where((c) => c).length;
    final complete = done == checks.length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 4,
      children: [
        Text(
          complete
              ? l10n.reviewRepeatDone
              : l10n.reviewRepeatProgress(done, checks.length),
          style: theme.textTheme.titleSmall?.copyWith(
            color: complete ? AppColors.green : null,
          ),
        ),
        Wrap(
          children: [
            for (final (i, checked) in checks.indexed)
              Checkbox(
                value: checked,
                semanticLabel: l10n.reviewRepeatBox(i + 1),
                onChanged: (_) => onToggle(i),
              ),
          ],
        ),
      ],
    );
  }
}
