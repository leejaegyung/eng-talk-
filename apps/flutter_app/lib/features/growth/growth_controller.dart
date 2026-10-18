import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/notifying_session_repository.dart';
import '../../app/providers.dart';
import '../../domain/sessions/growth_stats.dart';

/// Period shown on the dashboard, in days (7 or 30).
final growthPeriodProvider = NotifierProvider.autoDispose<GrowthPeriod, int>(
  GrowthPeriod.new,
);

class GrowthPeriod extends Notifier<int> {
  static const week = 7;
  static const month = 30;

  @override
  int build() => week;

  void set(int days) => state = days;
}

/// S10, reloaded whenever saved data changes.
final growthProvider = FutureProvider.autoDispose<GrowthStats>((ref) async {
  ref.watch(dataVersionProvider);
  final days = ref.watch(growthPeriodProvider);
  final repo = ref.watch(sessionRepositoryProvider);
  final now = ref.watch(clockProvider)();
  final local = now.toLocal();
  final since = DateTime(local.year, local.month, local.day - (days - 1));
  return GrowthStats.from(
    sessions: await repo.list(),
    corrections: await repo.correctionStats(since: since),
    levels: await repo.levelHistory(),
    now: now,
    days: days,
  );
});
