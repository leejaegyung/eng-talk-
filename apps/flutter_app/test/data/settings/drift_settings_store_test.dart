import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:speaking_coach/data/db/app_database.dart';
import 'package:speaking_coach/data/settings/drift_settings_store.dart';

void main() {
  late AppDatabase db;
  late DriftSettingsStore store;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    store = DriftSettingsStore(db);
  });
  tearDown(() => db.close());

  test('missing key reads null', () async {
    expect(await store.read('nope'), isNull);
  });

  test('write then overwrite', () async {
    await store.write('k', 'a');
    await store.write('k', 'b');
    expect(await store.read('k'), 'b');
    expect(await db.select(db.appSettings).get(), hasLength(1));
  });
}
