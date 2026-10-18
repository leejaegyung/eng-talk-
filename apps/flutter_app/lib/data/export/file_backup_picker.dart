import 'package:file_selector/file_selector.dart';

import '../../domain/sessions/export.dart';

/// The system file dialog, limited to the exported files: the JSON backup
/// and the turns CSV.
class FileBackupPicker implements BackupPicker {
  static const _backup = XTypeGroup(
    label: 'JSON / CSV',
    extensions: ['json', 'csv'],
    mimeTypes: [
      'application/json',
      'text/csv',
      'text/comma-separated-values',
      'text/plain',
      // Android often labels downloaded files only by this.
      'application/octet-stream',
    ],
    uniformTypeIdentifiers: [
      'public.json',
      'public.comma-separated-values-text',
    ],
  );

  @override
  Future<String?> pick() async {
    final file = await openFile(acceptedTypeGroups: const [_backup]);
    return file?.readAsString();
  }
}
