/// One recorded error, kept on the device only (Phase 3 error reporting
/// without a server). Holds no conversation text: just the kind of error,
/// a short redacted message and the app's own code locations.
final class ErrorEntry {
  const ErrorEntry({
    required this.at,
    required this.source,
    required this.type,
    required this.message,
    this.frames = const [],
  });

  final DateTime at;

  /// Where it was caught: 'flutter', 'platform' or 'app'.
  final String source;
  final String type;
  final String message;

  /// `file.dart:line` of this app's own frames, innermost first.
  final List<String> frames;

  Map<String, Object> toJson() => {
    'at': at.toUtc().toIso8601String(),
    'source': source,
    'type': type,
    'message': message,
    'frames': frames,
  };

  static ErrorEntry? fromJson(Object? json) {
    if (json is! Map) return null;
    final at = DateTime.tryParse('${json['at']}');
    if (at == null) return null;
    return ErrorEntry(
      at: at,
      source: '${json['source']}',
      type: '${json['type']}',
      message: '${json['message']}',
      frames: [...?(json['frames'] as List?)?.map((f) => '$f')],
    );
  }
}

abstract interface class ErrorJournal {
  Future<void> record(
    Object error,
    StackTrace? stack, {
    required String source,
  });

  /// Newest first.
  Future<List<ErrorEntry>> entries();

  Future<void> clear();
}

/// Builds an entry that is safe to keep: the message is redacted by
/// [redact], flattened to one line and cut short; only frames from
/// [package] are kept.
ErrorEntry errorEntryFor(
  Object error,
  StackTrace? stack, {
  required String source,
  required DateTime at,
  required String Function(String) redact,
  String package = 'speaking_coach',
  int maxMessage = 200,
  int maxFrames = 8,
}) {
  var message = redact('$error').replaceAll(RegExp(r'\s+'), ' ').trim();
  if (message.length > maxMessage) {
    message = '${message.substring(0, maxMessage)}…';
  }
  final frames = <String>[];
  final frame = RegExp('package:$package/([^ )]+?\\.dart):(\\d+)');
  for (final line in '${stack ?? ''}'.split('\n')) {
    final m = frame.firstMatch(line);
    if (m != null) frames.add('${m[1]}:${m[2]}');
    if (frames.length == maxFrames) break;
  }
  return ErrorEntry(
    at: at,
    source: source,
    type: '${error.runtimeType}',
    message: message,
    frames: frames,
  );
}

/// In memory, for tests and until the file journal is open.
class MemoryErrorJournal implements ErrorJournal {
  MemoryErrorJournal({DateTime Function()? now}) : _now = now ?? DateTime.now;

  final DateTime Function() _now;
  final _entries = <ErrorEntry>[];

  @override
  Future<void> record(
    Object error,
    StackTrace? stack, {
    required String source,
  }) async => _entries.add(
    errorEntryFor(error, stack, source: source, at: _now(), redact: (s) => s),
  );

  @override
  Future<List<ErrorEntry>> entries() async => _entries.reversed.toList();

  @override
  Future<void> clear() async => _entries.clear();
}
