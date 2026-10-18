import 'package:flutter_test/flutter_test.dart';
import 'package:speaking_coach/core/logging/app_logger.dart';

void main() {
  group('AppLogger.redact', () {
    test('masks OpenAI-style keys', () {
      const key = 'sk-FAKE-abcdefghijklmnop';
      expect(AppLogger.redact('key=$key'), 'key=[REDACTED]');
    });

    test('masks bearer tokens', () {
      expect(
        AppLogger.redact('Authorization: Bearer abc.def-123'),
        'Authorization: [REDACTED]',
      );
    });

    test('masks Google API keys', () {
      expect(AppLogger.redact('AIzaFAKEFAKEFAKEFAKEFAKEFAKE'), '[REDACTED]');
    });

    test('masks JWT sign-in tokens', () {
      expect(
        AppLogger.redact('token eyJFAKEhead123.eyJFAKEbody456.FAKEsig789 end'),
        'token [REDACTED] end',
      );
    });

    test('leaves ordinary text untouched', () {
      expect(
        AppLogger.redact('I went there yesterday.'),
        'I went there yesterday.',
      );
    });
  });
}
