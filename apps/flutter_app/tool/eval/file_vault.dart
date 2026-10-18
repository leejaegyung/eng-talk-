import 'dart:convert';
import 'dart:io';

import 'package:speaking_coach/domain/credentials/credential_vault.dart';

/// Credentials for the command-line evaluation, kept the way OpenAI's
/// Sign in with ChatGPT docs ask of command-line tools: one owner-only file
/// under ~/.config, outside the repository. The app itself never uses this.
class FileVault implements CredentialVault {
  FileVault([File? file]) : _file = file ?? defaultFile;

  static File get defaultFile => File(
    '${Platform.environment['HOME']}/.config/speaking-coach-eval/credentials.json',
  );

  final File _file;

  Future<Map<String, String>> _all() async {
    if (!await _file.exists()) return {};
    final json = jsonDecode(await _file.readAsString());
    return json is Map ? json.cast<String, String>() : {};
  }

  Future<void> _save(Map<String, String> all) async {
    await _file.parent.create(recursive: true);
    await _file.writeAsString(jsonEncode(all), flush: true);
    if (!Platform.isWindows) {
      await Process.run('chmod', ['600', _file.path]);
      await Process.run('chmod', ['700', _file.parent.path]);
    }
  }

  @override
  Future<String?> read(String ref) async => (await _all())[ref];

  @override
  Future<void> write(String ref, String secret) async =>
      _save({...await _all(), ref: secret});

  @override
  Future<void> delete(String ref) async =>
      _save({...await _all()}..remove(ref));
}
