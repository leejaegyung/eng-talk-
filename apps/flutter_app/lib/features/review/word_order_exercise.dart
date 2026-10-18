import 'dart:math';

import 'package:flutter/material.dart';

import '../../app/l10n/gen/app_localizations.dart';
import '../../app/theme.dart';
import '../../domain/learning/word_order.dart';
import '../../domain/sessions/session_records.dart';

/// Review card for a word-order mistake: tap the shuffled words in order.
class WordOrderExercise extends StatefulWidget {
  const WordOrderExercise({
    super.key,
    required this.item,
    required this.onDone,
    required this.onLater,
  });

  final ReviewItem item;
  final VoidCallback onDone;
  final VoidCallback onLater;

  @override
  State<WordOrderExercise> createState() => _WordOrderExerciseState();
}

class _WordOrderExerciseState extends State<WordOrderExercise> {
  late final List<String> _tiles = shuffledTiles(
    wordTiles(widget.item.suggested),
    // Same order each time the card is shown.
    Random(widget.item.id),
  );

  /// Indexes into [_tiles], in the order tapped.
  final _placed = <int>[];
  bool? _result;
  bool _revealed = false;

  void _tap(int i) => setState(() {
    _placed.add(i);
    _result = null;
  });

  void _untap(int position) => setState(() {
    _placed.removeAt(position);
    _result = null;
  });

  void _check() => setState(
    () => _result = wordOrderCorrect([
      for (final i in _placed) _tiles[i],
    ], widget.item.suggested),
  );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final done = _result == true;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 10,
          children: [
            Row(
              spacing: 8,
              children: [
                const Icon(Icons.swap_horiz, color: AppColors.orange),
                Text(
                  l10n.reviewWordOrderTitle,
                  style: theme.textTheme.titleMedium,
                ),
              ],
            ),
            Text(
              l10n.reviewYouSaidBefore(widget.item.original),
              style: theme.textTheme.bodySmall,
            ),
            if (widget.item.explanationKo case final e?) Text(e),
            Text(l10n.reviewWordOrderHelp, style: theme.textTheme.bodySmall),
            // The sentence being built.
            Container(
              width: double.infinity,
              constraints: const BoxConstraints(minHeight: 52),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: switch (_result) {
                    true => AppColors.green,
                    false => AppColors.orange,
                    null => theme.colorScheme.outlineVariant,
                  },
                  width: 2,
                ),
              ),
              child: Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final (position, i) in _placed.indexed)
                    ActionChip(
                      label: Text(_tiles[i]),
                      onPressed: done ? null : () => _untap(position),
                    ),
                ],
              ),
            ),
            // Words still to place.
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final (i, word) in _tiles.indexed)
                  if (!_placed.contains(i))
                    ActionChip(
                      label: Text(word),
                      onPressed: done ? null : () => _tap(i),
                    ),
              ],
            ),
            if (_result != null)
              Text(
                done
                    ? l10n.reviewWordOrderCorrect
                    : l10n.reviewWordOrderTryAgain,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: done ? AppColors.green : AppColors.orange,
                ),
              ),
            if (_revealed)
              Text(
                widget.item.suggested,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (!done) ...[
                  FilledButton(
                    onPressed: _placed.length == _tiles.length ? _check : null,
                    child: Text(l10n.reviewWordOrderCheck),
                  ),
                  TextButton(
                    onPressed: _placed.isEmpty
                        ? null
                        : () => setState(() {
                            _placed.clear();
                            _result = null;
                          }),
                    child: Text(l10n.reviewWordOrderReset),
                  ),
                  TextButton(
                    onPressed: () => setState(() => _revealed = true),
                    child: Text(l10n.reviewWordOrderShow),
                  ),
                ] else
                  FilledButton(
                    onPressed: widget.onDone,
                    child: Text(l10n.reviewDone),
                  ),
                TextButton(
                  onPressed: widget.onLater,
                  child: Text(l10n.reviewLater),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
