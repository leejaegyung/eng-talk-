import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:speaking_coach/data/db/app_database.dart';
import 'package:speaking_coach/data/settings/drift_settings_store.dart';

/// Real on-disk database: a value survives closing and reopening.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('settings persist across database reopen', (tester) async {
    const key = 'itest.persist';
    final stamp = DateTime.now().toIso8601String();

    final first = AppDatabase.open();
    await DriftSettingsStore(first).write(key, stamp);
    await first.close();

    final second = AppDatabase.open();
    addTearDown(second.close);
    expect(await DriftSettingsStore(second).read(key), stamp);
    expect(await second.select(second.appSettings).get(), isNotEmpty);
  });
}
