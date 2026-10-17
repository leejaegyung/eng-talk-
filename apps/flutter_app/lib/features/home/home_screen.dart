import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/l10n/gen/app_localizations.dart';
import '../../app/router.dart';
import '../../domain/conversation/session_enums.dart';
import '../common/mode_text.dart';
import '../conversation/conversation_request.dart';
import '../setup/setup_controller.dart';
import 'home_controller.dart';

/// S03. Only recorded numbers are shown; speaking time is marked as an
/// estimate, and nothing is shown before there is data.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final data = ref.watch(homeProvider).value;

    String minSec(Duration d) =>
        l10n.resultMinSec(d.inMinutes, d.inSeconds % 60);

    final stats = data?.stats;
    final tiles = stats == null
        ? const <(String, String, IconData, String?)>[]
        : [
            (
              l10n.homeToday,
              stats.speechMeasured
                  ? minSec(stats.todaySpeech)
                  : l10n.homeNoData,
              Icons.record_voice_over_outlined,
              null,
            ),
            (
              l10n.homeWeek,
              stats.speechMeasured ? minSec(stats.weekSpeech) : l10n.homeNoData,
              Icons.calendar_view_week_outlined,
              null,
            ),
            (
              l10n.homeStreak,
              l10n.homeStreakDays(stats.streakDays),
              Icons.local_fire_department_outlined,
              null,
            ),
            (
              l10n.homeCompleted,
              stats.completionRate == null
                  ? l10n.homeNoData
                  : l10n.homeCompletedValue(
                      stats.completed,
                      (stats.completionRate! * 100).round(),
                    ),
              Icons.check_circle_outline,
              null,
            ),
            (
              l10n.homeAvgAnswer,
              stats.avgAnswerWords == null
                  ? l10n.homeNoData
                  : l10n.homeAvgWords(stats.avgAnswerWords!.toStringAsFixed(1)),
              Icons.short_text,
              null,
            ),
            (
              l10n.homeReviews,
              l10n.homeReviewCount(stats.reviewsDue),
              Icons.replay_circle_filled_outlined,
              AppRoutes.review,
            ),
          ];

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
        actions: [
          IconButton(
            tooltip: l10n.homeHistory,
            onPressed: () => context.push(AppRoutes.history),
            icon: const Icon(Icons.history),
          ),
          IconButton(
            tooltip: l10n.homeSettings,
            onPressed: () => context.push(AppRoutes.settings),
            icon: const Icon(Icons.settings_outlined),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              if (data?.unfinished case final u?)
                Card(
                  color: theme.colorScheme.tertiaryContainer,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 8,
                      children: [
                        Text(
                          l10n.homeUnfinished,
                          style: theme.textTheme.titleMedium,
                        ),
                        Text(
                          [
                            modeName(l10n, u.setup.mode),
                            ?u.setup.topic,
                            l10n.historyAnswers(u.userTurns),
                          ].join(' · '),
                        ),
                        Wrap(
                          spacing: 8,
                          children: [
                            FilledButton(
                              onPressed: () {
                                ref
                                    .read(conversationRequestProvider.notifier)
                                    .open(ResumeSession(u.id));
                                context.push(AppRoutes.conversation);
                              },
                              child: Text(l10n.homeResume),
                            ),
                            OutlinedButton(
                              onPressed: () async {
                                await closeUnfinished(ref, u);
                                if (context.mounted) {
                                  await context.push(AppRoutes.result(u.id));
                                }
                              },
                              child: Text(l10n.homeCloseAndSee),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              if (data != null && !data.placed)
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.assignment_outlined),
                    title: Text(l10n.homePlacementTitle),
                    subtitle: Text(l10n.homePlacementBody),
                    trailing: FilledButton(
                      onPressed: () => context.push(AppRoutes.assessment),
                      child: Text(l10n.homePlacementStart),
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              Text(
                l10n.homeHeadline,
                style: theme.textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Center(
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 20,
                    ),
                  ),
                  onPressed: () => context.push(AppRoutes.setup),
                  icon: const Icon(Icons.mic),
                  label: Text(l10n.homeStartButton),
                ),
              ),
              if (data?.nextTopic case final topic?)
                Center(
                  child: TextButton(
                    onPressed: () {
                      final setup = ref.read(setupProvider.notifier)
                        ..setMode(SessionMode.theme)
                        ..setTopic(topic);
                      setup.start();
                      context.push(AppRoutes.conversation);
                    },
                    child: Text(l10n.homeNextTopic(topic)),
                  ),
                ),
              const SizedBox(height: 24),
              LayoutBuilder(
                builder: (context, constraints) {
                  final columns = constraints.maxWidth > 520 ? 3 : 2;
                  final width =
                      (constraints.maxWidth - 12 * (columns - 1)) / columns;
                  return Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      for (final (label, value, icon, route) in tiles)
                        SizedBox(
                          width: width,
                          child: Card(
                            margin: EdgeInsets.zero,
                            child: InkWell(
                              onTap: route == null
                                  ? null
                                  : () => context.push(route),
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  spacing: 4,
                                  children: [
                                    Icon(icon, size: 20),
                                    Text(
                                      label,
                                      style: theme.textTheme.bodySmall,
                                    ),
                                    Text(
                                      value,
                                      style: theme.textTheme.titleMedium,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 8),
              Text(l10n.homeSpeechNote, style: theme.textTheme.bodySmall),
              const SizedBox(height: 16),
              if (data?.placed ?? false)
                TextButton.icon(
                  onPressed: () => context.push(AppRoutes.assessment),
                  icon: const Icon(Icons.assignment_outlined),
                  label: Text(l10n.homePlacementAgain),
                ),
              ExpansionTile(
                title: Text(l10n.homeDevTools),
                children: [
                  ListTile(
                    leading: const Icon(Icons.chat_bubble_outline),
                    title: Text(l10n.homeChatGptLab),
                    onTap: () => context.push(AppRoutes.chatGptLab),
                  ),
                  ListTile(
                    leading: const Icon(Icons.graphic_eq),
                    title: Text(l10n.homeAudioLab),
                    onTap: () => context.push(AppRoutes.audioLab),
                  ),
                  ListTile(
                    leading: const Icon(Icons.record_voice_over),
                    title: Text(l10n.homeVoiceLab),
                    onTap: () => context.push(AppRoutes.voiceLab),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
