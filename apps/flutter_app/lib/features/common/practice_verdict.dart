import 'package:flutter/material.dart';

import '../../app/l10n/gen/app_localizations.dart';
import '../../app/theme.dart';
import '../../domain/learning/word_order.dart';

/// What the learner just said for a corrected sentence, and whether it was
/// that sentence word for word (no score: same or not).
class PracticeVerdict extends StatelessWidget {
  const PracticeVerdict({super.key, required this.heard, required this.target});

  final String heard;
  final String target;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final matched = saidAsCorrected(heard, target);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 4,
      children: [
        Text(l10n.resultYouSaid(heard)),
        Row(
          spacing: 6,
          children: [
            Icon(
              matched ? Icons.check_circle : Icons.info_outline,
              size: 18,
              color: matched ? AppColors.green : AppColors.orange,
            ),
            Expanded(
              child: Text(
                matched ? l10n.practiceMatched : l10n.practiceDiffers,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
