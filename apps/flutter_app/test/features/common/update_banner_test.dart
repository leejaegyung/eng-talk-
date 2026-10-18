import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:speaking_coach/app/providers.dart';
import 'package:speaking_coach/domain/update/app_update.dart';

import '../../helpers/app_harness.dart';

final page = Uri.parse('https://github.com/x/y/releases/tag/v0.9.1');

class FakeFeed implements ReleaseFeed {
  FakeFeed(this.release);
  AppRelease? release;
  int calls = 0;

  @override
  Future<AppRelease?> latest() async {
    calls++;
    return release;
  }
}

class FakeUpdater implements AppUpdater {
  FakeUpdater(this.method);

  @override
  final UpdateMethod method;
  final applied = <AppVersion>[];
  Completer<void> done = Completer();

  @override
  Future<void> apply(
    AppRelease release, {
    void Function(double)? onProgress,
  }) async {
    applied.add(release.version);
    onProgress?.call(0.42);
    await done.future;
  }
}

AppRelease release(String v) =>
    AppRelease(version: AppVersion.tryParse(v)!, page: page);

void main() {
  Future<(Harness, FakeFeed, FakeUpdater, FakeUpdater)> boot(
    WidgetTester tester, {
    String? current = '0.9.0',
    AppRelease? latest,
    UpdateMethod method = UpdateMethod.install,
  }) async {
    final feed = FakeFeed(latest);
    final updater = FakeUpdater(method);
    final pageOpener = FakeUpdater(UpdateMethod.openPage)..done.complete();
    final h = Harness()
      ..extra = [
        currentVersionProvider.overrideWithValue(AppVersion.tryParse(current)),
        releaseFeedProvider.overrideWithValue(feed),
        appUpdaterProvider.overrideWithValue(updater),
        releasePageOpenerProvider.overrideWithValue(pageOpener),
      ];
    await h.boot(tester);
    return (h, feed, updater, pageOpener);
  }

  testWidgets('Android: newer release → banner → download → installer', (
    tester,
  ) async {
    final (_, feed, updater, _) = await boot(tester, latest: release('0.9.1'));

    expect(feed.calls, 1);
    expect(find.text('새 버전이 나왔어요 (v0.9.1)'), findsOneWidget);
    await tester.tap(find.text('업데이트'));
    await settle(tester);

    expect(updater.applied, [AppVersion.tryParse('0.9.1')]);
    expect(find.text('받는 중… 42%'), findsOneWidget);
    expect(find.text('나중에'), findsNothing);

    updater.done.complete();
    await settle(tester);
    expect(find.text('업데이트'), findsOneWidget);
  });

  testWidgets('a failed update points to the download page', (tester) async {
    final (_, _, updater, pageOpener) = await boot(
      tester,
      latest: release('0.9.1'),
    );
    await tester.tap(find.text('업데이트'));
    await settle(tester);
    updater.done.completeError(StateError('no installer'));
    await settle(tester);

    expect(find.textContaining('업데이트하지 못했어요'), findsOneWidget);
    await tester.tap(find.text('다운로드 페이지'));
    await settle(tester);
    expect(pageOpener.applied, [AppVersion.tryParse('0.9.1')]);
  });

  testWidgets('web says reload; "later" hides it on home but not settings', (
    tester,
  ) async {
    await boot(tester, latest: release('1.0.0'), method: UpdateMethod.reload);
    expect(find.text('새로고침'), findsOneWidget);

    await tester.tap(find.text('나중에'));
    await settle(tester);
    expect(find.textContaining('새 버전'), findsNothing);

    await tester.tap(find.byTooltip('설정'));
    await settle(tester);
    await tester.scrollUntilVisible(find.text('새로고침'), 300);
    expect(find.text('새 버전이 나왔어요 (v1.0.0)'), findsOneWidget);
  });

  testWidgets('no banner when up to date; settings can check again', (
    tester,
  ) async {
    final (_, feed, _, _) = await boot(tester, latest: release('0.9.0'));
    expect(find.textContaining('새 버전'), findsNothing);

    await tester.tap(find.byTooltip('설정'));
    await settle(tester);
    await tester.scrollUntilVisible(find.text('업데이트 확인'), 300);
    expect(find.text('0.9.0 · 최신 버전이에요'), findsOneWidget);

    feed.release = release('0.9.2');
    await tester.tap(find.text('업데이트 확인'));
    await settle(tester);
    expect(feed.calls, 2);
    expect(find.text('새 버전이 나왔어요 (v0.9.2)'), findsOneWidget);
  });

  testWidgets('local builds never look for updates', (tester) async {
    final (_, feed, _, _) = await boot(
      tester,
      current: null,
      latest: release('9.9.9'),
    );
    expect(feed.calls, 0);
    expect(find.textContaining('새 버전'), findsNothing);
  });
}
