import 'dart:convert';

import 'package:share_plus/share_plus.dart';

import '../../domain/sessions/export.dart';
import 'web_download.dart' if (dart.library.js_interop) 'web_download_web.dart';

/// Web: the share sheet where the browser has one (iPhone/iPad Safari →
/// "Save to Files"), otherwise ordinary downloads.
class WebExporter implements DataExporter {
  @override
  Future<String> export(Map<String, String> files) async {
    try {
      await SharePlus.instance.share(
        ShareParams(
          files: [
            for (final MapEntry(:key, :value) in files.entries)
              XFile.fromData(
                utf8.encode(value),
                name: key,
                mimeType: key.endsWith('.json')
                    ? 'application/json'
                    : 'text/plain',
              ),
          ],
          fileNameOverrides: files.keys.toList(),
        ),
      );
      return files.keys.join(', ');
    } on Object {
      for (final MapEntry(:key, :value) in files.entries) {
        downloadInBrowser(key, value);
      }
      return files.keys.join(', ');
    }
  }
}
