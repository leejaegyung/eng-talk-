import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/l10n/gen/app_localizations.dart';
import '../../app/router.dart';
import '../../app/theme.dart';
import '../../core/platform/platform_info.dart';
import '../../domain/conversation/session_enums.dart';
import '../common/goal_picker.dart';
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
        ? const <(String, String, IconData, Color, String?)>[]
        : [
            (
              l10n.homeToday,
              stats.speechMeasured
                  ? minSec(stats.todaySpeech)
                  : l10n.homeNoData,
              Icons.record_voice_over_outlined,
              AppColors.blue,
              null,
            ),
            (
              l10n.homeWeek,
              stats.speechMeasured ? minSec(stats.weekSpeech) : l10n.homeNoData,
              Icons.calendar_view_week_outlined,
              AppColors.green,
              null,
            ),
            (
              l10n.homeStreak,
              l10n.homeStreakDays(stats.streakDays),
              Icons.local_fire_department_outlined,
              AppColors.orange,
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
              AppColors.blue,
              null,
            ),
            (
              l10n.homeAvgAnswer,
              stats.avgAnswerWords == null
                  ? l10n.homeNoData
                  : l10n.homeAvgWords(stats.avgAnswerWords!.toStringAsFixed(1)),
              Icons.short_text,
              AppColors.yellow,
              null,
            ),
            (
              l10n.homeReviews,
              l10n.homeReviewCount(stats.reviewsDue),
              Icons.replay_circle_filled_outlined,
              AppColors.orange,
              AppRoutes.review,
            ),
          ];

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 72,
        title: Row(
          spacing: 12,
          children: [
            const _Logo(),
            Flexible(
              child: Text(l10n.appTitle, overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: l10n.homeGrowth,
            onPressed: () => context.push(AppRoutes.growth),
            icon: const Icon(Icons.insights_outlined),
          ),
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
          const SizedBox(width: 8),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            children: [
              if (data?.unfinished case final u?)
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(kRadius),
                    side: BorderSide(color: theme.colorScheme.secondary),
                  ),
                  color: theme.colorScheme.secondaryContainer,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 8,
                      children: [
                        Row(
                          spacing: 8,
                          children: [
                            Icon(
                              Icons.play_circle_fill,
                              color: theme.colorScheme.secondary,
                            ),
                            Expanded(
                              child: Text(
                                l10n.homeUnfinished,
                                style: theme.textTheme.titleMedium,
                              ),
                            ),
                          ],
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
                          runSpacing: 8,
                          children: [
                            FilledButton(
                              style: FilledButton.styleFrom(
                                backgroundColor: theme.colorScheme.secondary,
                                foregroundColor: theme.colorScheme.onSecondary,
                              ),
                              onPressed: () {
                                ref
                                    .read(conversationRequestProvider.notifier)
                                    .open(ResumeSession(u.id));
                                context.push(AppRoutes.conversation);
                              },
                              child: Text(l10n.homeResume),
                            ),
                            OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: theme.colorScheme.onSurface,
                                side: BorderSide(
                                  color: theme.colorScheme.outline,
                                ),
                              ),
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
                  color: theme.colorScheme.tertiaryContainer,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(kRadius),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    leading: const _Badge(
                      icon: Icons.assignment_outlined,
                      color: AppColors.yellow,
                    ),
                    title: Text(
                      l10n.homePlacementTitle,
                      style: theme.textTheme.titleMedium,
                    ),
                    subtitle: Text(l10n.homePlacementBody),
                    trailing: FilledButton(
                      onPressed: () => context.push(AppRoutes.assessment),
                      child: Text(l10n.homePlacementStart),
                    ),
                  ),
                ),
              const SizedBox(height: 8),
              _Hero(
                goalLine: switch ((
                  data?.goals.dailyMinutes,
                  data?.stats.todayPractice.inMinutes,
                )) {
                  (final goal?, final done?) when done >= goal =>
                    l10n.homeGoalDone,
                  (final goal?, final done?) => l10n.homeGoalProgress(
                    done,
                    goal,
                  ),
                  _ => null,
                },
                goalProgress: switch ((
                  data?.goals.dailyMinutes,
                  data?.stats.todayPractice,
                )) {
                  (final goal?, final done?) =>
                    (done.inSeconds / (goal * 60)).clamp(0.0, 1.0),
                  _ => null,
                },
                suggestion: switch (data?.goals.goal) {
                  final g? => l10n.homeSuggestedMode(
                    goalName(l10n, g),
                    modeName(l10n, g.mode),
                  ),
                  null => null,
                },
                headline: l10n.homeHeadline,
                button: l10n.homeStartButton,
                onStart: () => context.push(AppRoutes.setup),
                nextTopic: data?.nextTopic == null
                    ? null
                    : l10n.homeNextTopic(data!.nextTopic!),
                onNextTopic: () {
                  final setup = ref.read(setupProvider.notifier)
                    ..setMode(SessionMode.theme)
                    ..setTopic(data!.nextTopic!);
                  setup.start();
                  context.push(AppRoutes.conversation);
                },
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
                      for (final (label, value, icon, accent, route) in tiles)
                        SizedBox(
                          width: width,
                          child: Card(
                            margin: EdgeInsets.zero,
                            child: InkWell(
                              onTap: route == null
                                  ? null
                                  : () => context.push(route),
                              child: Padding(
                                padding: const EdgeInsets.all(14),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  spacing: 6,
                                  children: [
                                    _Badge(icon: icon, color: accent),
                                    const SizedBox(height: 2),
                                    Text(
                                      label,
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(
                                            color: theme
                                                .colorScheme
                                                .onSurfaceVariant,
                                          ),
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
              Text(
                l10n.homeSpeechNote,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: OutlinedButton.icon(
                  onPressed: () => context.push(AppRoutes.growth),
                  icon: const Icon(Icons.insights_outlined),
                  label: Text(l10n.homeGrowth),
                ),
              ),
              const SizedBox(height: 8),
              if (data?.placed ?? false)
                TextButton.icon(
                  onPressed: () => context.push(AppRoutes.assessment),
                  icon: const Icon(Icons.assignment_outlined),
                  label: Text(l10n.homePlacementAgain),
                ),
              // Recording/API-key labs need native audio and files.
              if (!PlatformInfo.isWeb)
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

/// Round app mark, after the kit's logo badge.
class _Logo extends StatelessWidget {
  const _Logo();

  @override
  Widget build(BuildContext context) => Container(
    width: 36,
    height: 36,
    decoration: const BoxDecoration(
      color: AppColors.blue,
      shape: BoxShape.circle,
    ),
    child: const Icon(Icons.graphic_eq, color: Colors.white, size: 20),
  );
}

/// Tinted rounded icon square used on stat tiles.
class _Badge extends StatelessWidget {
  const _Badge({required this.icon, required this.color});

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    width: 36,
    height: 36,
    decoration: BoxDecoration(
      color: color.withValues(alpha: .14),
      borderRadius: BorderRadius.circular(10),
    ),
    child: Icon(icon, size: 20, color: color),
  );
}

/// Blue call-to-action card (kit's "Let's start learning" header).
class _Hero extends StatelessWidget {
  const _Hero({
    required this.goalLine,
    required this.goalProgress,
    required this.suggestion,
    required this.headline,
    required this.button,
    required this.onStart,
    required this.nextTopic,
    required this.onNextTopic,
  });

  /// Today's practice against the daily target; null without a target.
  final String? goalLine;
  final double? goalProgress;

  /// Mode suggested by the learning goal.
  final String? suggestion;
  final String headline;
  final String button;
  final VoidCallback onStart;
  final String? nextTopic;
  final VoidCallback onNextTopic;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2F6DF2), AppColors.blue, Color(0xFF1D4FD0)],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -8,
            top: -8,
            child: Icon(
              Icons.graphic_eq,
              size: 96,
              color: Colors.white.withValues(alpha: .12),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 16,
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 64),
                child: Text(
                  headline,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                  ),
                ),
              ),
              if (goalProgress case final progress?)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 6,
                  children: [
                    Text(
                      goalLine ?? '',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white,
                      ),
                    ),
                    LinearProgressIndicator(
                      value: progress,
                      minHeight: 6,
                      color: AppColors.orange,
                      backgroundColor: Colors.white.withValues(alpha: .25),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ],
                )
              else
                Container(
                  height: 4,
                  width: 56,
                  decoration: BoxDecoration(
                    color: AppColors.orange,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              if (suggestion case final text?)
                Text(
                  text,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.white.withValues(alpha: .9),
                  ),
                ),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.blue,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                    ),
                    onPressed: onStart,
                    icon: const Icon(Icons.mic),
                    label: Text(button),
                  ),
                  if (nextTopic case final topic?)
                    TextButton(
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                      ),
                      onPressed: onNextTopic,
                      child: Text(topic),
                    ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
