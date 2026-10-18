// Export really lands in the user's Downloads on macOS (sandbox
// entitlement), not only in tests with a fake exporter:
//   flutter test integration_test/file_export_test.dart -d macos
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:speaking_coach/data/export/file_exporter.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('writes the files to Downloads', (tester) async {
    final path = await FileExporter().export({'probe.txt': 'ok'});
    final file = File('$path/probe.txt');
    expect(await file.readAsString(), 'ok');
    expect(path, contains('Downloads'));
    await Directory(path).delete(recursive: true);
  });
}
