import '../../domain/settings/settings_store.dart';
import '../db/app_database.dart';

class DriftSettingsStore implements SettingsStore {
  DriftSettingsStore(this._db);

  final AppDatabase _db;

  @override
  Future<String?> read(String key) async {
    final row = await (_db.select(
      _db.appSettings,
    )..where((t) => t.name.equals(key))).getSingleOrNull();
    return row?.value;
  }

  @override
  Future<void> write(String key, String value) => _db
      .into(_db.appSettings)
      .insertOnConflictUpdate(AppSetting(name: key, value: value));
}
