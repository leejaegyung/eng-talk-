import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../domain/sessions/export.dart';

/// Desktop: a folder in Downloads. Mobile: the system share sheet (files
/// are written to a temporary folder first).
class FileExporter implements DataExporter {
  @override
  Future<String> export(Map<String, String> files) async {
    final stamp = DateTime.now()
        .toIso8601String()
        .replaceAll(RegExp('[:.]'), '-')
        .substring(0, 19);
    final mobile = Platform.isAndroid || Platform.isIOS;
    final base = mobile
        ? await getTemporaryDirectory()
        : await getDownloadsDirectory() ??
              await getApplicationDocumentsDirectory();
    final dir = await Directory(
      '${base.path}${Platform.pathSeparator}speaking-coach-export-$stamp',
    ).create(recursive: true);
    final written = <String>[];
    for (final MapEntry(:key, :value) in files.entries) {
      final f = File('${dir.path}${Platform.pathSeparator}$key');
      await f.writeAsString(value);
      written.add(f.path);
    }
    if (mobile) {
      await SharePlus.instance.share(
        ShareParams(files: [for (final p in written) XFile(p)]),
      );
    }
    return dir.path;
  }
}
