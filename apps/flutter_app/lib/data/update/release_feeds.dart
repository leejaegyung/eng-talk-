import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../domain/update/app_update.dart';
import 'web_page.dart' if (dart.library.js_interop) 'web_page_web.dart';

/// The project's GitHub releases (ADR-010): the newest one's version, page
/// and Android installer. Installers are only taken from this repository's
/// release downloads.
class GithubReleaseFeed implements ReleaseFeed {
  GithubReleaseFeed({required this._client, this.repo = defaultRepo});

  static const defaultRepo = 'leejaegyung/eng-talk-';
  static const _timeout = Duration(seconds: 15);

  final http.Client _client;
  final String repo;

  @override
  Future<AppRelease?> latest() async {
    try {
      final res = await _client
          .get(
            Uri.https('api.github.com', '/repos/$repo/releases/latest'),
            headers: const {'Accept': 'application/vnd.github+json'},
          )
          .timeout(_timeout);
      if (res.statusCode != 200) return null;
      return parse(jsonDecode(res.body));
    } on Exception {
      return null;
    }
  }

  /// Null unless [json] is a published, non-pre-release `vX.Y.Z` release.
  AppRelease? parse(Object? json) {
    if (json is! Map || json['draft'] == true || json['prerelease'] == true) {
      return null;
    }
    final version = AppVersion.tryParse(json['tag_name'] as String?);
    final page = Uri.tryParse(json['html_url'] as String? ?? '');
    if (version == null || page == null || !_ours(page, '/releases/')) {
      return null;
    }
    Uri? apk;
    for (final a in json['assets'] as List? ?? const []) {
      if (a is! Map) continue;
      final name = a['name'] as String? ?? '';
      final url = Uri.tryParse(a['browser_download_url'] as String? ?? '');
      if (name.endsWith('-android.apk') &&
          url != null &&
          _ours(url, '/releases/download/')) {
        apk = url;
      }
    }
    return AppRelease(version: version, page: page, apk: apk);
  }

  bool _ours(Uri url, String under) =>
      url.scheme == 'https' &&
      url.host == 'github.com' &&
      url.path.startsWith('/$repo$under');
}

/// The web app: the version deployed next to the page right now
/// (`version.json`, written by `flutter build web`). Reloading gets it.
class DeployedWebFeed implements ReleaseFeed {
  DeployedWebFeed({required this._client, Uri? base}) : _givenBase = base;

  final http.Client _client;
  final Uri? _givenBase;

  @override
  Future<AppRelease?> latest() async {
    final base = _givenBase ?? pageBase();
    try {
      final res = await _client
          .get(
            base
                .resolve('version.json')
                .replace(
                  queryParameters: {
                    't': '${DateTime.now().millisecondsSinceEpoch}',
                  },
                ),
          )
          .timeout(const Duration(seconds: 15));
      if (res.statusCode != 200) return null;
      final json = jsonDecode(res.body);
      final version = AppVersion.tryParse(
        json is Map ? json['version'] as String? : null,
      );
      return version == null ? null : AppRelease(version: version, page: base);
    } on Exception {
      return null;
    }
  }
}
