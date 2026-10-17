import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/l10n/gen/app_localizations.dart';
import '../../app/router.dart';
import '../../domain/conversation/session_enums.dart';
import '../common/failure_text.dart';
import '../common/mode_text.dart';
import '../conversation/conversation_request.dart';
import 'result_controller.dart';

class ResultScreen extends ConsumerWidget {
  const ResultScreen({required this.sessionId, super.key});

  final int sessionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final s = ref.watch(resultProvider(sessionId));
    final ctrl = ref.read(resultProvider(sessionId).notifier);
    final theme = Theme.of(context);
    final detail = s.detail;

    String minSec(Duration d) =>
        l10n.resultMinSec(d.inMinutes, d.inSeconds % 60);

    Widget heading(String text) => Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 8),
      child: Text(text, style: theme.textTheme.titleMedium),
    );

    final children = <Widget>[];
    if (detail != null) {
      final summary = detail.summary;
      final stats = summary.stats;
      final answers = detail.turns
          .where((t) => t.speaker == Speaker.user && !t.isRequest)
          .length;
      children.addAll([
        Text(
          [
            modeName(l10n, summary.setup.mode),
            summary.setup.level.label,
            ?summary.setup.topic,
          ].join(' · '),
          style: theme.textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        _Stat(l10n.resultPracticeTime, minSec(summary.duration)),
        _Stat(l10n.resultAnswers, l10n.resultAnswerCount(answers)),
        if (stats != null && stats.confidence != null) ...[
          _Stat(
            l10n.resultUserSpeech,
            minSec(Duration(milliseconds: stats.userMs)),
          ),
          _Stat(
            l10n.resultAiSpeech,
            minSec(Duration(milliseconds: stats.assistantMs)),
          ),
          if (stats.speakingRatio case final r?)
            _Stat(
              l10n.resultRatio,
              l10n.resultRatioValue((r * 100).toStringAsFixed(1)),
            ),
          Text(l10n.resultEstimateNote, style: theme.textTheme.bodySmall),
        ] else
          Text(l10n.resultNotMeasured, style: theme.textTheme.bodySmall),
      ]);

      final f = s.feedback;
      if (answers == 0) {
        children.add(heading(l10n.resultNoAnswers));
      } else if (s.generating) {
        children.addAll([
          const SizedBox(height: 32),
          const Center(child: CircularProgressIndicator()),
          const SizedBox(height: 12),
          Center(child: Text(l10n.resultGenerating)),
        ]);
      } else if (s.failure case final failure?) {
        children.add(
          Card(
            margin: const EdgeInsets.only(top: 24),
            child: ListTile(
              leading: const Icon(Icons.error_outline),
              title: Text(failureText(l10n, failure)),
              trailing: TextButton(
                onPressed: ctrl.generate,
                child: Text(l10n.resultRetry),
              ),
            ),
          ),
        );
      } else if (f != null) {
        children.addAll([
          if (f.reduced)
            Card(
              margin: const EdgeInsets.only(top: 24),
              child: ListTile(
                leading: const Icon(Icons.info_outline),
                title: Text(l10n.resultReduced),
                trailing: TextButton(
                  onPressed: ctrl.generate,
                  child: Text(l10n.resultRetry),
                ),
              ),
            ),
          if (f.strengths.isNotEmpty) heading(l10n.resultStrengths),
          for (final strength in f.strengths)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.thumb_up_alt_outlined),
              title: Text(strength),
            ),
          heading(l10n.resultCorrections),
          if (f.corrections.isEmpty && !f.reduced)
            Text(l10n.resultNoCorrections),
          for (final (i, c) in f.corrections.indexed)
            _CorrectionCard(
              original: c.original,
              suggested: c.suggested,
              explanation: c.explanationKo,
              prompt: c.practicePrompt,
              listening: s.listeningTo == i,
              canPractice: s.listeningTo == null,
              heard: s.heard[i],
              onPractice: () => ctrl.practice(i),
            ),
          if (f.corrections.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                l10n.resultReviewNote,
                style: theme.textTheme.bodySmall,
              ),
            ),
          if (f.expressions.isNotEmpty) ...[
            heading(l10n.resultExpressions),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final e in f.expressions)
                  Chip(
                    label: Text(
                      e.meaningKo == null
                          ? e.phrase
                          : '${e.phrase} — ${e.meaningKo}',
                    ),
                  ),
              ],
            ),
          ],
          if (f.nextTopic case final topic?) ...[
            heading(l10n.resultNextTopic),
            Text(topic),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: OutlinedButton(
                onPressed: () {
                  ref
                      .read(conversationRequestProvider.notifier)
                      .open(
                        NewSession(
                          summary.setup.copyWith(
                            mode: SessionMode.theme,
                            topic: topic,
                            clearScenario: true,
                          ),
                        ),
                      );
                  context.pushReplacement(AppRoutes.conversation);
                },
                child: Text(l10n.resultTalkAboutIt),
              ),
            ),
          ],
        ]);
      }
    }

    return Scaffold(
      appBar: AppBar(title: Text(l10n.resultTitle)),
      body: detail == null
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: ListView(
                  padding: const EdgeInsets.all(24),
                  children: [
                    ...children,
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: () => context.go(AppRoutes.home),
                      child: Text(l10n.conversationBackHome),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      children: [
        Expanded(child: Text(label)),
        Text(value, style: Theme.of(context).textTheme.titleMedium),
      ],
    ),
  );
}

/// S07: my sentence → natural sentence → say it again. No scoring.
class _CorrectionCard extends StatelessWidget {
  const _CorrectionCard({
    required this.original,
    required this.suggested,
    required this.explanation,
    required this.prompt,
    required this.listening,
    required this.canPractice,
    required this.heard,
    required this.onPractice,
  });

  final String original;
  final String suggested;
  final String? explanation;
  final String? prompt;
  final bool listening;
  final bool canPractice;
  final String? heard;
  final VoidCallback onPractice;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 8,
          children: [
            Text(
              original,
              style: theme.textTheme.bodyLarge?.copyWith(
                decoration: TextDecoration.lineThrough,
                color: theme.colorScheme.outline,
              ),
            ),
            Text(
              suggested,
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
            if (explanation case final e?) Text(e),
            if (prompt case final p?)
              Text(
                p,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontStyle: FontStyle.italic,
                ),
              ),
            Row(
              children: [
                OutlinedButton.icon(
                  onPressed: canPractice ? onPractice : null,
                  icon: const Icon(Icons.mic),
                  label: Text(l10n.resultSayAgain),
                ),
                const SizedBox(width: 12),
                if (listening) Text(l10n.resultListening),
              ],
            ),
            if (heard case final h? when h.isNotEmpty)
              Text(l10n.resultYouSaid(h)),
          ],
        ),
      ),
    );
  }
}
