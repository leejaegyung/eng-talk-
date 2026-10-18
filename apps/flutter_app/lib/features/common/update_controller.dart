import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/logging/app_logger.dart';
import '../../domain/update/app_update.dart';

enum UpdateCheck { none, checking, upToDate, unknown, available }

final class UpdateState {
  const UpdateState({
    this.current,
    this.check = UpdateCheck.none,
    this.release,
    this.dismissed = false,
    this.applying = false,
    this.percent,
    this.failed = false,
  });

  /// Null for local builds, which never check.
  final AppVersion? current;
  final UpdateCheck check;

  /// Newer than [current].
  final AppRelease? release;

  /// "Later" on the home banner, for this launch.
  final bool dismissed;
  final bool applying;
  final int? percent;
  final bool failed;

  UpdateState copyWith({
    bool? dismissed,
    bool? applying,
    int? Function()? percent,
    bool? failed,
  }) => UpdateState(
    current: current,
    check: check,
    release: release,
    dismissed: dismissed ?? this.dismissed,
    applying: applying ?? this.applying,
    percent: percent == null ? this.percent : percent(),
    failed: failed ?? this.failed,
  );
}

/// Looks for a newer release once per launch (and on demand from settings),
/// and applies it the way the platform allows (ADR-018).
final updateProvider = NotifierProvider<UpdateController, UpdateState>(
  UpdateController.new,
);

class UpdateController extends Notifier<UpdateState> {
  static const _log = AppLogger('update');

  @override
  UpdateState build() {
    final current = ref.watch(currentVersionProvider);
    if (current == null) return const UpdateState();
    Future.microtask(check);
    return UpdateState(current: current, check: UpdateCheck.checking);
  }

  UpdateMethod get method => ref.read(appUpdaterProvider).method;

  Future<void> check() async {
    final current = state.current;
    if (current == null || state.applying) return;
    state = UpdateState(current: current, check: UpdateCheck.checking);
    final latest = await ref.read(releaseFeedProvider).latest();
    if (!ref.mounted) return;
    final newer = newerRelease(current, latest);
    state = UpdateState(
      current: current,
      check: newer != null
          ? UpdateCheck.available
          : latest == null
          ? UpdateCheck.unknown
          : UpdateCheck.upToDate,
      release: newer,
    );
  }

  void dismiss() => state = state.copyWith(dismissed: true);

  Future<void> apply() async {
    final release = state.release;
    if (release == null || state.applying) return;
    state = state.copyWith(applying: true, failed: false, percent: () => null);
    try {
      await ref
          .read(appUpdaterProvider)
          .apply(
            release,
            onProgress: (p) {
              final percent = (p * 100).floor().clamp(0, 100);
              if (ref.mounted && percent != state.percent) {
                state = state.copyWith(percent: () => percent);
              }
            },
          );
      if (ref.mounted) {
        state = state.copyWith(applying: false, percent: () => null);
      }
    } on Object catch (e) {
      _log.warning('update failed: ${e.runtimeType}');
      if (ref.mounted) {
        state = state.copyWith(
          applying: false,
          failed: true,
          percent: () => null,
        );
      }
    }
  }

  /// The release page, when [apply] didn't work.
  Future<void> openPage() async {
    final release = state.release;
    if (release == null) return;
    try {
      await ref.read(releasePageOpenerProvider).apply(release);
    } on Object catch (e) {
      _log.warning('release page failed: ${e.runtimeType}');
    }
  }
}
