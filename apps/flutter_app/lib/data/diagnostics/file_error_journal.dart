import 'dart:convert';
import 'dart:io';

import '../../core/logging/app_logger.dart';
import '../../domain/diagnostics/error_journal.dart';

/// [ErrorJournal] as JSON lines in a file in the app's support directory,
/// capped at [maxEntries]. Never leaves the device unless the learner
/// exports it.
class FileErrorJournal implements ErrorJournal {
  FileErrorJournal(this._file, {DateTime Function()? now})
    : _now = now ?? DateTime.now;

  static const maxEntries = 100;

  final File _file;
  final DateTime Function() _now;
  Future<void> _writing = Future.value();

  @override
  Future<void> record(
    Object error,
    StackTrace? stack, {
    required String source,
  }) {
    final entry = errorEntryFor(
      error,
      stack,
      source: source,
      at: _now(),
      redact: AppLogger.redact,
    );
    // Serialized so concurrent errors don't interleave lines.
    return _writing = _writing.then((_) async {
      try {
        final kept = await _read();
        final lines = [
          ...kept.reversed.take(maxEntries - 1).toList().reversed,
          entry,
        ].map((e) => jsonEncode(e.toJson()));
        await _file.parent.create(recursive: true);
        await _file.writeAsString('${lines.join('\n')}\n', flush: true);
      } on FileSystemException {
        // Reporting must never become a new error.
      }
    });
  }

  @override
  Future<List<ErrorEntry>> entries() async {
    await _writing;
    return (await _read()).reversed.toList();
  }

  @override
  Future<void> clear() async {
    await _writing;
    if (await _file.exists()) await _file.delete();
  }

  Future<List<ErrorEntry>> _read() async {
    if (!await _file.exists()) return const [];
    return [
      for (final line in await _file.readAsLines())
        if (line.trim().isNotEmpty) ?ErrorEntry.fromJson(_tryDecode(line)),
    ];
  }

  static Object? _tryDecode(String line) {
    try {
      return jsonDecode(line);
    } on FormatException {
      return null;
    }
  }
}
