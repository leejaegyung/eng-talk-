import 'package:flutter_test/flutter_test.dart';
import 'package:speaking_coach/domain/update/app_update.dart';

void main() {
  test('parses release versions, not local or pre-release ones', () {
    expect(AppVersion.tryParse('0.9.0'), const AppVersion(0, 9, 0));
    expect(AppVersion.tryParse('v1.10.2'), const AppVersion(1, 10, 2));
    for (final bad in [null, '', '1.0', '1.0.0-beta', 'abc', '1.0.0+3']) {
      expect(AppVersion.tryParse(bad), isNull, reason: '$bad');
    }
  });

  test('compares numerically', () {
    expect(
      AppVersion.tryParse('0.10.0')! > AppVersion.tryParse('0.9.9')!,
      true,
    );
    expect(
      AppVersion.tryParse('1.0.0')! > AppVersion.tryParse('0.99.99')!,
      true,
    );
    expect(
      AppVersion.tryParse('0.9.1')! > AppVersion.tryParse('0.9.1')!,
      false,
    );
  });

  test('offers only a newer release, and never to local builds', () {
    final page = Uri.parse('https://example.test/r');
    AppRelease r(String v) =>
        AppRelease(version: AppVersion.tryParse(v)!, page: page);
    final current = AppVersion.tryParse('0.9.0');

    expect(newerRelease(current, r('0.9.1'))?.version.toString(), '0.9.1');
    expect(newerRelease(current, r('0.9.0')), isNull);
    expect(newerRelease(current, r('0.8.2')), isNull);
    expect(newerRelease(current, null), isNull);
    expect(newerRelease(null, r('9.9.9')), isNull);
  });
}
