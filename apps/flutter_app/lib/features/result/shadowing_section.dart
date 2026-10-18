import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/l10n/gen/app_localizations.dart';
import '../common/practice_verdict.dart';
import '../common/repeat_boxes.dart';
import 'shadowing_controller.dart';

/// "Shadowing" on the result screen: each coach sentence with listen,
/// slow listen, say it back and the repeat boxes.
class ShadowingSection extends ConsumerWidget {
  const ShadowingSection({super.key, required this.sessionId});

  final int sessionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final s = ref.watch(shadowingProvider(sessionId));
    final ctrl = ref.read(shadowingProvider(sessionId).notifier);
    if (s.sentences.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 24, bottom: 4),
          child: Text(l10n.shadowingTitle, style: theme.textTheme.titleMedium),
        ),
        Text(l10n.shadowingNote, style: theme.textTheme.bodySmall),
        for (final (i, sentence) in s.sentences.indexed)
          Card(
            margin: const EdgeInsets.only(top: 10),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 8,
                children: [
                  Text(sentence, style: theme.textTheme.titleSmall),
                  if (s.heard[i] case final h? when h.isNotEmpty)
                    PracticeVerdict(heard: h, target: sentence),
                  RepeatBoxes(
                    checks: s.checksOf(i),
                    onToggle: (box) => ctrl.toggle(i, box),
                  ),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      OutlinedButton.icon(
                        onPressed: s.busy ? null : () => ctrl.play(i),
                        icon: Icon(
                          s.playing == i ? Icons.graphic_eq : Icons.volume_up,
                        ),
                        label: Text(l10n.shadowingListen),
                      ),
                      OutlinedButton.icon(
                        onPressed: s.busy
                            ? null
                            : () => ctrl.play(i, slow: true),
                        icon: const Icon(Icons.slow_motion_video),
                        label: Text(l10n.shadowingSlow),
                      ),
                      FilledButton.icon(
                        onPressed: s.busy ? null : () => ctrl.practice(i),
                        icon: const Icon(Icons.mic),
                        label: Text(
                          s.listeningTo == i
                              ? l10n.resultListening
                              : l10n.shadowingRepeat,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
