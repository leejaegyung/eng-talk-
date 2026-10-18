import 'dart:async';
import 'dart:typed_data';

import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:speaking_coach/data/db/app_database.dart' show AppDatabase;
import 'package:speaking_coach/data/sessions/drift_session_repository.dart';

import 'package:speaking_coach/domain/audio/audio_io.dart';
import 'package:speaking_coach/domain/audio/speech_io.dart';
import 'package:speaking_coach/domain/credentials/credential_vault.dart';
import 'package:speaking_coach/domain/credentials/provider_account.dart';
import 'package:speaking_coach/domain/providers/ai_provider.dart';
import 'package:speaking_coach/domain/sessions/export.dart';
import 'package:speaking_coach/domain/settings/settings_store.dart';

class MemoryVault implements CredentialVault {
  final values = <String, String>{};

  @override
  Future<void> write(String ref, String secret) async => values[ref] = secret;

  @override
  Future<String?> read(String ref) async => values[ref];

  @override
  Future<void> delete(String ref) async => values.remove(ref);
}

class FakeInput implements AudioInput {
  FakeInput({this.permitted = true});

  final bool permitted;
  StreamController<Uint8List> chunks = StreamController<Uint8List>();
  bool stopped = false;
  int starts = 0;

  @override
  int get sampleRate => 16000;

  @override
  Future<bool> ensurePermission() async => permitted;

  @override
  Future<Stream<Uint8List>> start() async {
    starts++;
    stopped = false;
    if (chunks.isClosed) chunks = StreamController<Uint8List>();
    return chunks.stream;
  }

  @override
  Future<void> stop() async {
    stopped = true;
    await chunks.close();
  }

  @override
  Future<void> dispose() async {}
}

class FakeOutput implements AudioOutput {
  final played = <(Uint8List, String)>[];

  @override
  Future<void> play(Uint8List bytes, {required String fileExtension}) async =>
      played.add((bytes, fileExtension));

  @override
  Future<void> stop() async {}

  @override
  Future<void> dispose() async {}
}

/// Scripted LLM + voice provider that records what it was asked.
class FakeAi implements LlmProvider, VoiceProvider {
  List<String> models = ['chat-m', 'stt-m', 'tts-m'];
  String transcript = 'I like hiking.';
  List<ChatChunk> reply = const [
    TextDelta('Nice! '),
    TextDelta('Where do you hike?'),
    ChatUsage(inputTokens: 40, outputTokens: 6),
  ];
  Object? chatError;

  /// When set, replies wait for it after the first chunk (a slow stream).
  Future<void>? gate;

  /// Per-request reply, e.g. feedback JSON for the feedback prompt.
  List<ChatChunk>? Function(List<ChatMessage> messages)? responder;

  final transcribed = <Uint8List>[];
  final chats = <List<ChatMessage>>[];
  final spoken = <String>[];

  @override
  Future<List<String>> listModels() async => models;

  @override
  Future<String> transcribe({
    required String model,
    required Uint8List wav,
    String language = 'en',
  }) async {
    transcribed.add(wav);
    return transcript;
  }

  @override
  Stream<ChatChunk> streamChat({
    required String model,
    required List<ChatMessage> messages,
    int maxOutputTokens = 200,
  }) async* {
    chats.add([...messages]);
    if (chatError != null) throw chatError!;
    final chunks = responder?.call(messages) ?? reply;
    for (final (i, chunk) in chunks.indexed) {
      if (i == 1 && gate != null) await gate;
      yield chunk;
    }
  }

  @override
  Stream<Uint8List> synthesize({
    required String model,
    required String text,
    String? voice,
  }) async* {
    spoken.add(text);
    yield Uint8List.fromList([1, 2]);
    yield Uint8List.fromList([3]);
  }

  @override
  String get speechFileExtension => 'mp3';
}

/// 50 ms of PCM16 at 16 kHz with a constant sample value.
Uint8List pcmChunk(int sample) {
  final data = ByteData(1600);
  for (var i = 0; i < 800; i++) {
    data.setInt16(i * 2, sample, Endian.little);
  }
  return data.buffer.asUint8List();
}

class FakeSpeechOutput implements SpeechOutput {
  final spoken = <String>[];
  final slow = <bool>[];
  int stops = 0;

  @override
  Future<void> speak(String text, {bool slow = false}) async {
    spoken.add(text);
    this.slow.add(slow);
  }

  @override
  Future<void> stop() async => stops++;
}

class FakeSpeechInput implements SpeechInput {
  FakeSpeechInput({this.available = true});

  final bool available;

  /// Transcripts returned by successive [listenOnce] calls.
  final queue = <String>[];

  /// Recognition hints passed to each [listenOnce] call.
  final hints = <List<String>>[];
  int stops = 0;

  /// When set, listening lasts until [stop] (a learner still talking).
  Completer<void>? hold;

  /// Reported after an empty listen, as the platform would.
  SpeechIssue? issue;

  @override
  SpeechIssue? lastIssue;

  @override
  Future<bool> ensureAvailable() async => available;

  @override
  Future<String> listenOnce({
    void Function(String partial)? onPartial,
    List<String> hints = const [],
  }) async {
    this.hints.add(hints);
    if (hold case final h? when !h.isCompleted) await h.future;
    final text = queue.isEmpty ? '' : queue.removeAt(0);
    lastIssue = text.isEmpty ? issue : null;
    if (text.isNotEmpty) onPartial?.call(text.split(' ').first);
    return text;
  }

  @override
  Future<void> stop() async {
    stops++;
    if (hold case final h? when !h.isCompleted) h.complete();
  }
}

class MemorySettings implements SettingsStore {
  MemorySettings([Map<String, String>? initial]) : values = {...?initial};

  final Map<String, String> values;

  @override
  Future<String?> read(String key) async => values[key];

  @override
  Future<void> write(String key, String value) async => values[key] = value;
}

class FakeAccount implements ProviderAccount {
  bool signedIn = false;
  Object? signInError;
  int signOuts = 0;

  @override
  Future<bool> isSignedIn() async => signedIn;

  @override
  Future<void> signIn() async {
    if (signInError != null) throw signInError!;
    signedIn = true;
  }

  @override
  Future<bool> signOut() async {
    signOuts++;
    signedIn = false;
    return true;
  }
}

/// Real repository on an in-memory database.
(AppDatabase, DriftSessionRepository) memoryRepository() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  final db = AppDatabase(NativeDatabase.memory());
  return (db, DriftSessionRepository(db));
}

/// Replies like the model would for the app's structured prompts: feedback
/// JSON quoting the first learner line, a placement rubric, otherwise the
/// default conversation reply.
List<ChatChunk>? smartReplies(List<ChatMessage> messages) {
  final system = messages.first.content;
  if (system.contains('You review an English speaking practice')) {
    final line = RegExp(r'\[t(\d+)\] learner: (.+)')
        .firstMatch(messages[1].content);
    if (line == null) return null;
    return [
      TextDelta(
        '{"strengths": ["Kept the conversation going"], "corrections": '
        '[{"turn_id": ${line.group(1)}, "original": "${line.group(2)}", '
        '"suggested": "Fixed sentence.", "explanation_ko": "설명", '
        '"severity": "high", "category": "grammar", '
        '"practice_prompt": "Say it again?"}], '
        '"expressions": [{"phrase": "That reminds me of", "meaning_ko": "그러고 보니"}], '
        '"next_topic": "Weekend plans"}',
      ),
    ];
  }
  if (system.contains('placement conversation')) {
    return const [
      TextDelta(
        '{"relevance": 3, "sentence_formation": 3, "vocabulary": 3, '
        '"continuity": 3, "comment_ko": "무난해요"}',
      ),
    ];
  }
  return null;
}

class CapturingExporter implements DataExporter {
  final exports = <Map<String, String>>[];

  @override
  Future<String> export(Map<String, String> files) async {
    exports.add(files);
    return '/tmp/export';
  }
}
