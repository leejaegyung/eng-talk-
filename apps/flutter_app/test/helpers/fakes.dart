import 'dart:async';
import 'dart:typed_data';

import 'package:speaking_coach/domain/audio/audio_io.dart';
import 'package:speaking_coach/domain/audio/speech_io.dart';
import 'package:speaking_coach/domain/credentials/credential_vault.dart';
import 'package:speaking_coach/domain/credentials/provider_account.dart';
import 'package:speaking_coach/domain/providers/ai_provider.dart';
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
    yield* Stream.fromIterable(reply);
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
  int stops = 0;

  @override
  Future<void> speak(String text) async => spoken.add(text);

  @override
  Future<void> stop() async => stops++;
}

class FakeSpeechInput implements SpeechInput {
  FakeSpeechInput({this.available = true});

  final bool available;

  /// Transcripts returned by successive [listenOnce] calls.
  final queue = <String>[];
  int stops = 0;

  @override
  Future<bool> ensureAvailable() async => available;

  @override
  Future<String> listenOnce({void Function(String partial)? onPartial}) async {
    final text = queue.isEmpty ? '' : queue.removeAt(0);
    if (text.isNotEmpty) onPartial?.call(text.split(' ').first);
    return text;
  }

  @override
  Future<void> stop() async => stops++;
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
