import 'dart:typed_data';

enum ChatRole { system, user, assistant }

final class ChatMessage {
  const ChatMessage(this.role, this.content);

  final ChatRole role;
  final String content;
}

sealed class ChatChunk {
  const ChatChunk();
}

final class TextDelta extends ChatChunk {
  const TextDelta(this.text);

  final String text;
}

/// Token counts reported by the provider — measured, not estimated.
final class ChatUsage extends ChatChunk {
  const ChatUsage({required this.inputTokens, required this.outputTokens});

  final int inputTokens;
  final int outputTokens;
}

/// Models picked for one provider from its live model list.
final class ModelSelection {
  const ModelSelection({
    required this.chat,
    required this.transcription,
    required this.speech,
  });

  final String chat;
  final String transcription;
  final String speech;
}

/// Errors are thrown as `ProviderException`.
abstract interface class LlmProvider {
  Future<List<String>> listModels();

  Stream<ChatChunk> streamChat({
    required String model,
    required List<ChatMessage> messages,
    int maxOutputTokens = 200,
  });
}

abstract interface class VoiceProvider {
  Future<String> transcribe({
    required String model,
    required Uint8List wav,
    String language = 'en',
  });

  /// Encoded audio chunks as they arrive, in [speechFileExtension] format.
  Stream<Uint8List> synthesize({
    required String model,
    required String text,
    String? voice,
  });

  String get speechFileExtension;
}
