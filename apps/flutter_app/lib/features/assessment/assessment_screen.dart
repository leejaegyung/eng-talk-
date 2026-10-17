import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/l10n/gen/app_localizations.dart';
import '../../app/router.dart';
import '../../domain/learning/learner_level.dart';
import '../../domain/learning/placement.dart';
import '../common/failure_text.dart';
import 'assessment_controller.dart';

class AssessmentScreen extends ConsumerStatefulWidget {
  const AssessmentScreen({super.key});

  @override
  ConsumerState<AssessmentScreen> createState() => _AssessmentScreenState();
}

class _AssessmentScreenState extends ConsumerState<AssessmentScreen> {
  final _answer = TextEditingController();

  @override
  void dispose() {
    _answer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final s = ref.watch(assessmentProvider);
    final ctrl = ref.read(assessmentProvider.notifier);
    final theme = Theme.of(context);

    // Keep the field in sync when speech is appended or the step changes.
    ref.listen(assessmentProvider, (prev, next) {
      if (_answer.text != next.currentAnswer) {
        _answer.text = next.currentAnswer;
      }
      if (prev?.saved == false && next.saved) context.go(AppRoutes.home);
    });

    final mic = IconButton.filled(
      iconSize: 32,
      tooltip: l10n.chatGptLabTalk,
      onPressed: s.listening ? ctrl.stopListening : ctrl.talk,
      icon: Icon(s.listening ? Icons.stop : Icons.mic),
    );

    final List<Widget> body;
    if (s.step == 0) {
      body = [
        Text(l10n.assessmentIntro, style: theme.textTheme.titleMedium),
        Text(l10n.assessmentLimit, style: theme.textTheme.bodySmall),
        const SizedBox(height: 8),
        Text(l10n.assessmentMicCheck),
        Center(child: mic),
        if (s.listening && s.partial.isNotEmpty) Center(child: Text(s.partial)),
        if (s.micCheck case final heard?)
          Text(
            heard.isEmpty
                ? l10n.assessmentMicNothing
                : l10n.assessmentMicHeard(heard),
          ),
        FilledButton(onPressed: ctrl.next, child: Text(l10n.assessmentNext)),
      ];
    } else if (s.onQuestion) {
      final last = s.step == AssessmentState.questionCount;
      body = [
        LinearProgressIndicator(value: s.step / AssessmentState.questionCount),
        Text(
          l10n.assessmentQuestion(s.step, AssessmentState.questionCount),
          style: theme.textTheme.labelLarge,
        ),
        Text(
          placementQuestions[s.step - 1],
          style: theme.textTheme.headlineSmall,
        ),
        Row(
          children: [
            mic,
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _answer,
                minLines: 2,
                maxLines: 5,
                enabled: !s.listening,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  hintText: s.listening && s.partial.isNotEmpty
                      ? s.partial
                      : l10n.assessmentAnswerHint,
                ),
                onChanged: ctrl.setAnswer,
              ),
            ),
          ],
        ),
        FilledButton(
          onPressed: s.listening ? null : ctrl.next,
          child: Text(last ? l10n.assessmentFinish : l10n.assessmentNext),
        ),
      ];
    } else if (s.evaluating) {
      body = [
        const Center(child: CircularProgressIndicator()),
        Center(child: Text(l10n.assessmentEvaluating)),
      ];
    } else if (s.failure case final f?) {
      body = [
        Text(failureText(l10n, f)),
        FilledButton(onPressed: ctrl.evaluate, child: Text(l10n.resultRetry)),
      ];
    } else {
      final r = s.rubric;
      body = [
        if (s.suggested case final level?)
          Text(
            l10n.assessmentSuggested(level.label),
            style: theme.textTheme.headlineSmall,
          )
        else
          Text(l10n.assessmentGradingFailed),
        if (r != null) ...[
          for (final (label, score) in [
            (l10n.assessmentRelevance, r.relevance),
            (l10n.assessmentSentences, r.sentenceFormation),
            (l10n.assessmentVocabulary, r.vocabulary),
            (l10n.assessmentContinuity, r.continuity),
          ])
            Row(
              children: [
                Expanded(child: Text(label)),
                Text(l10n.assessmentScore(score)),
              ],
            ),
          if (r.commentKo case final c?) Text(c),
          Text(l10n.assessmentRubricNote, style: theme.textTheme.bodySmall),
        ],
        Text(l10n.assessmentLimit, style: theme.textTheme.bodySmall),
        Text(l10n.assessmentPick),
        SegmentedButton<LearnerLevel>(
          segments: [
            for (final l in LearnerLevel.values)
              ButtonSegment(value: l, label: Text(l.label)),
          ],
          selected: {?s.chosen},
          emptySelectionAllowed: true,
          showSelectedIcon: false,
          onSelectionChanged: (v) {
            if (v.isNotEmpty) ctrl.choose(v.single);
          },
        ),
        Text(l10n.setupLevelNote, style: theme.textTheme.bodySmall),
        FilledButton(
          onPressed: s.chosen == null ? null : ctrl.accept,
          child: Text(l10n.assessmentAccept),
        ),
      ];
    }

    return Scaffold(
      appBar: AppBar(title: Text(l10n.assessmentTitle)),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              for (final w in body)
                Padding(padding: const EdgeInsets.only(bottom: 16), child: w),
            ],
          ),
        ),
      ),
    );
  }
}
