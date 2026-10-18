import 'dart:io';

import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

import '../../domain/update/app_update.dart';
import 'web_page.dart' if (dart.library.js_interop) 'web_page_web.dart';

/// Android: downloads the APK into the app's cache and opens the system
/// installer; the user confirms there. The same signing key (ADR-006) lets
/// it install over the current app and keep its data.
class ApkUpdater implements AppUpdater {
  ApkUpdater({required this._client, required this._cacheDir});

  static const _channel = MethodChannel('speaking_coach/update');

  final http.Client _client;
  final Future<Directory> Function() _cacheDir;

  @override
  UpdateMethod get method => UpdateMethod.install;

  @override
  Future<void> apply(
    AppRelease release, {
    void Function(double)? onProgress,
  }) async {
    final url = release.apk;
    if (url == null) throw StateError('release has no APK');
    final dir = Directory('${(await _cacheDir()).path}/updates');
    if (dir.existsSync()) dir.deleteSync(recursive: true);
    dir.createSync(recursive: true);
    final file = File('${dir.path}/speaking-coach-${release.version}.apk');

    final res = await _client.send(http.Request('GET', url));
    if (res.statusCode != 200) {
      throw HttpException('APK download ${res.statusCode}', uri: url);
    }
    final total = res.contentLength;
    var received = 0;
    final sink = file.openWrite();
    try {
      await for (final chunk in res.stream) {
        sink.add(chunk);
        received += chunk.length;
        if (total != null && total > 0) onProgress?.call(received / total);
      }
    } finally {
      await sink.close();
    }
    await _channel.invokeMethod<void>('installApk', {'path': file.path});
  }
}

/// Web: the new version is already deployed; loading the page again gets it.
class ReloadUpdater implements AppUpdater {
  @override
  UpdateMethod get method => UpdateMethod.reload;

  @override
  Future<void> apply(
    AppRelease release, {
    void Function(double)? onProgress,
  }) async => reloadPage();
}

/// Desktop: opens the release page to download the new installer.
class PageUpdater implements AppUpdater {
  @override
  UpdateMethod get method => UpdateMethod.openPage;

  @override
  Future<void> apply(
    AppRelease release, {
    void Function(double)? onProgress,
  }) async {
    if (!await launchUrl(release.page, mode: LaunchMode.externalApplication)) {
      throw StateError('could not open the release page');
    }
  }
}
