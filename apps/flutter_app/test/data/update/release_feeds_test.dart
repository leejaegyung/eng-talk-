import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:speaking_coach/data/update/release_feeds.dart';

const repo = GithubReleaseFeed.defaultRepo;

Map<String, Object> release({
  String tag = 'v0.9.1',
  bool prerelease = false,
  List<Map<String, String>>? assets,
}) => {
  'tag_name': tag,
  'html_url': 'https://github.com/$repo/releases/tag/$tag',
  'draft': false,
  'prerelease': prerelease,
  'assets':
      assets ??
      [
        {
          'name': 'SpeakingCoach-0.9.1-windows-x64.zip',
          'browser_download_url':
              'https://github.com/$repo/releases/download/$tag/SpeakingCoach-0.9.1-windows-x64.zip',
        },
        {
          'name': 'SpeakingCoach-0.9.1-android.apk',
          'browser_download_url':
              'https://github.com/$repo/releases/download/$tag/SpeakingCoach-0.9.1-android.apk',
        },
      ],
};

void main() {
  test('reads the latest release with its APK', () async {
    late http.Request sent;
    final feed = GithubReleaseFeed(
      client: MockClient((req) async {
        sent = req;
        return http.Response(jsonEncode(release()), 200);
      }),
    );

    final r = await feed.latest();

    expect(
      sent.url.toString(),
      'https://api.github.com/repos/$repo/releases/latest',
    );
    expect(r!.version.toString(), '0.9.1');
    expect(r.page.path, '/$repo/releases/tag/v0.9.1');
    expect(r.apk!.pathSegments.last, 'SpeakingCoach-0.9.1-android.apk');
  });

  test('never takes an installer from outside this repository', () {
    final feed = GithubReleaseFeed(client: MockClient((_) async => throw 0));
    for (final url in [
      'https://evil.test/$repo/releases/download/v0.9.1/x-android.apk',
      'https://github.com/someone/else/releases/download/v0.9.1/x-android.apk',
      'http://github.com/$repo/releases/download/v0.9.1/x-android.apk',
    ]) {
      final r = feed.parse(
        release(
          assets: [
            {'name': 'x-android.apk', 'browser_download_url': url},
          ],
        ),
      );
      expect(r!.apk, isNull, reason: url);
    }
  });

  test('nothing for pre-releases, odd tags, errors or offline', () async {
    final feed = GithubReleaseFeed(client: MockClient((_) async => throw 0));
    expect(feed.parse(release(prerelease: true)), isNull);
    expect(feed.parse(release(tag: 'nightly')), isNull);
    expect(feed.parse('nope'), isNull);

    Future<Object?> latest(http.Response Function() reply) =>
        GithubReleaseFeed(client: MockClient((_) async => reply())).latest();
    expect(await latest(() => http.Response('{}', 404)), isNull);
    expect(await latest(() => http.Response('<html>', 200)), isNull);
    expect(
      await GithubReleaseFeed(
        client: MockClient((_) async => throw http.ClientException('offline')),
      ).latest(),
      isNull,
    );
  });

  test('web: reads the deployed version.json past the browser cache', () async {
    late Uri asked;
    final base = Uri.parse('https://example.test/eng-talk-/');
    final feed = DeployedWebFeed(
      base: base,
      client: MockClient((req) async {
        asked = req.url;
        return http.Response(
          jsonEncode({'app_name': 'speaking_coach', 'version': '0.9.1'}),
          200,
        );
      }),
    );

    final r = await feed.latest();

    expect(asked.path, '/eng-talk-/version.json');
    expect(asked.queryParameters, contains('t'));
    expect(r!.version.toString(), '0.9.1');
    expect(r.page, base);
    expect(r.apk, isNull);
  });
}
