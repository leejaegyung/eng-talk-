import 'dart:convert';
import 'dart:js_interop';

import 'package:web/web.dart' as web;

/// Saves [content] as a file through the browser's download.
void downloadInBrowser(String name, String content) {
  final bytes = utf8.encode(content).toJS;
  final blob = web.Blob(
    [bytes].toJS,
    web.BlobPropertyBag(type: 'text/plain;charset=utf-8'),
  );
  final url = web.URL.createObjectURL(blob);
  web.HTMLAnchorElement()
    ..href = url
    ..download = name
    ..click();
  web.URL.revokeObjectURL(url);
}
