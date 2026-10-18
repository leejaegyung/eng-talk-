import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/notifying_session_repository.dart';
import '../../app/providers.dart';
import '../../domain/conversation/session_enums.dart';
import '../../domain/sessions/progress_stats.dart';
import '../../domain/sessions/session_records.dart';
import '../../domain/settings/settings_store.dart';
import '../common/goals_controller.dart';

final class HomeData {
  const HomeData({
    required this.stats,
    this.unfinished,
    this.placed = false,
    this.nextTopic,
    this.goals = const Goals(),
  });

  final ProgressStats stats;

  /// A session the app closed in the middle of (spec §15 recovery).
  final SessionSummary? unfinished;

  /// A level was set (by placement or by hand).
  final bool placed;

  /// Suggested by the latest feedback.
  final String? nextTopic;
  final Goals goals;
}

/// S03 home KPIs, reloaded whenever saved data changes.
final homeProvider = FutureProvider.autoDispose<HomeData>((ref) async {
  ref.watch(dataVersionProvider);
  final goals = await ref.watch(goalsProvider.future);
  final repo = ref.watch(sessionRepositoryProvider);
  final now = ref.watch(clockProvider)();
  final sessions = await repo.list();
  final level = await ref
      .watch(settingsStoreProvider)
      .read(SettingKeys.learnerLevel);
  return HomeData(
    stats: ProgressStats.from(
      sessions,
      now: now,
      reviewsDue: await repo.reviewCount(now),
    ),
    unfinished: await repo.unfinished(),
    placed: level != null,
    nextTopic: sessions
        .where((s) => s.setup.mode != SessionMode.assessment)
        .map((s) => s.nextTopic)
        .nonNulls
        .firstOrNull,
    goals: goals,
  );
});

/// Closes an unfinished session as it was left, so its result can be seen.
Future<void> closeUnfinished(WidgetRef ref, SessionSummary s) async {
  final repo = ref.read(sessionRepositoryProvider);
  final detail = await repo.load(s.id);
  final last = detail?.turns.lastOrNull?.startedAt ?? s.startedAt;
  await repo.finish(
    s.id,
    status: s.userTurns > 0 ? SessionStatus.completed : SessionStatus.abandoned,
    endedAt: last,
  );
}
