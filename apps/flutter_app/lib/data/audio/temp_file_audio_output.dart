import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';

import '../../core/logging/app_logger.dart';
import '../../domain/audio/audio_io.dart';

/// Plays bytes through a short-lived temp file that is deleted as soon as
/// playback ends. audioplayers' own BytesSource leaves temp files behind on
/// macOS, which would violate S4.
class TempFileAudioOutput implements AudioOutput {
  TempFileAudioOutput({Future<Directory> Function()? tempDir})
    : _tempDir = tempDir ?? getTemporaryDirectory;

  /// Subdirectory of the temp dir that holds only this class's files.
  static const dirName = 'playback';
  static const _prefix = 'playback_';
  static const _log = AppLogger('audio.output');

  final Future<Directory> Function() _tempDir;
  final AudioPlayer _player = AudioPlayer();
  Completer<void>? _playing;
  bool _swept = false;

  @override
  Future<void> play(Uint8List bytes, {required String fileExtension}) async {
    await stop();
    final dir = await Directory('${(await _tempDir()).path}/$dirName')
        .create(recursive: true);
    if (!_swept) {
      _swept = true;
      await _sweep(dir);
    }

    final file = File(
      '${dir.path}/$_prefix${DateTime.now().microsecondsSinceEpoch}'
      '.$fileExtension',
    );
    await file.writeAsBytes(bytes, flush: true);
    final playing = _playing = Completer<void>();
    final done = _player.onPlayerComplete.listen((_) {
      if (!playing.isCompleted) playing.complete();
    });
    try {
      await _player.play(DeviceFileSource(file.path));
      await playing.future;
    } finally {
      await done.cancel();
      if (identical(_playing, playing)) _playing = null;
      await _player.release();
      await _delete(file);
    }
  }

  @override
  Future<void> stop() async {
    final playing = _playing;
    if (playing == null) return;
    await _player.stop();
    if (!playing.isCompleted) playing.complete();
  }

  @override
  Future<void> dispose() async {
    await stop();
    await _player.dispose();
  }

  /// Removes files left by a crash during an earlier playback.
  Future<void> _sweep(Directory dir) async {
    await for (final e in dir.list()) {
      if (e is File && e.uri.pathSegments.last.startsWith(_prefix)) {
        await _delete(e);
      }
    }
  }

  Future<void> _delete(File f) async {
    try {
      if (await f.exists()) await f.delete();
    } on FileSystemException catch (e) {
      _log.warning('temp audio not deleted: ${e.osError?.message}');
    }
  }
}
