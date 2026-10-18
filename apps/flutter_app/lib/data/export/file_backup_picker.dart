import 'package:file_selector/file_selector.dart';

import '../../domain/sessions/export.dart';

/// The system file dialog, limited to JSON.
class FileBackupPicker implements BackupPicker {
  static const _json = XTypeGroup(
    label: 'JSON',
    extensions: ['json'],
    mimeTypes: ['application/json'],
    uniformTypeIdentifiers: ['public.json'],
  );

  @override
  Future<String?> pick() async {
    final file = await openFile(acceptedTypeGroups: const [_json]);
    return file?.readAsString();
  }
}
