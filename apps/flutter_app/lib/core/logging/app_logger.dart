import 'dart:developer' as developer;

/// The only logging entry point in the app (`print` is banned by lint).
///
/// Every message passes through [redact] so API keys and bearer tokens never
/// reach logs or crash reports (docs/security.md S2).
class AppLogger {
  const AppLogger(this.name);

  final String name;

  static final List<RegExp> _secretPatterns = [
    RegExp(r'sk-[A-Za-z0-9_\-]{8,}'),
    RegExp(r'AIza[0-9A-Za-z_\-]{20,}'),
    RegExp(r'Bearer\s+[A-Za-z0-9._\-]+', caseSensitive: false),
  ];

  static String redact(String message) {
    var out = message;
    for (final pattern in _secretPatterns) {
      out = out.replaceAll(pattern, '[REDACTED]');
    }
    return out;
  }

  void info(String message) => _log(message, 800);

  void warning(String message) => _log(message, 900);

  void error(String message, [Object? error, StackTrace? stackTrace]) {
    _log(
      error == null ? message : '$message: ${redact(error.toString())}',
      1000,
      stackTrace,
    );
  }

  void _log(String message, int level, [StackTrace? stackTrace]) {
    developer.log(
      redact(message),
      name: name,
      level: level,
      stackTrace: stackTrace,
    );
  }
}
