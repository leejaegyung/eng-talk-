import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:speaking_coach/app/providers.dart';
import 'package:speaking_coach/features/home/home_controller.dart';

void main() {
  testWidgets('today turns over at local midnight while the app stays open', (
    tester,
  ) async {
    var now = DateTime(2026, 10, 17, 23, 59, 50);
    final container = ProviderContainer(
      overrides: [clockProvider.overrideWithValue(() => now)],
    );
    final sub = container.listen(todayProvider, (_, _) {});

    expect(sub.read(), DateTime(2026, 10, 17));

    now = DateTime(2026, 10, 17, 23, 59, 59);
    await tester.pump(const Duration(seconds: 9));
    expect(sub.read(), DateTime(2026, 10, 17));

    now = DateTime(2026, 10, 18, 0, 0, 2);
    await tester.pump(const Duration(seconds: 3));
    expect(sub.read(), DateTime(2026, 10, 18));

    // The midnight timer must go with the container.
    container.dispose();
  });
}
