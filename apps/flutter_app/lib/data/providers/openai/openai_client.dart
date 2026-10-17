import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import '../../../domain/credentials/credential_vault.dart';
import '../../../domain/providers/ai_provider.dart';
import '../../../domain/providers/provider_failure.dart';
import 'provider_catalog.dart';

/// OpenAI REST adapter (STT → chat → TTS). The key is read from the vault
/// per request and never kept in a field (docs/security.md S5).
class OpenAiClient implements LlmProvider, VoiceProvider {
  OpenAiClient({
    required this._vault,
    required this._keyRef,
    http.Client? client,
    Uri? baseUrl,
  }) : _client = client ?? http.Client(),
       _base = baseUrl ?? Uri.parse('https://api.openai.com/v1/');

  static const _timeout = Duration(seconds: 30);

  final CredentialVault _vault;
  final String _keyRef;
  final http.Client _client;
  final Uri _base;

  @override
  String get speechFileExtension => 'mp3';

  void close() => _client.close();

  @override
  Future<List<String>> listModels() async {
    final res = await _send(http.Request('GET', _base.resolve('models')));
    final json = await _json(res);
    final data = json['data'];
    return [
      if (data is List)
        for (final m in data)
          if (m is Map && m['id'] is String) m['id'] as String,
    ]..sort();
  }

  @override
  Future<String> transcribe({
    required String model,
    required Uint8List wav,
    String language = 'en',
  }) async {
    final req =
        http.MultipartRequest('POST', _base.resolve('audio/transcriptions'))
          ..fields.addAll({
            'model': model,
            'language': language,
            'response_format': 'json',
          })
          ..files.add(
            http.MultipartFile.fromBytes('file', wav, filename: 'speech.wav'),
          );
    final json = await _json(await _send(req));
    return (json['text'] as String? ?? '').trim();
  }

  @override
  Stream<ChatChunk> streamChat({
    required String model,
    required List<ChatMessage> messages,
    int maxOutputTokens = 200,
  }) async* {
    final req = _jsonRequest('chat/completions', {
      'model': model,
      'messages': [
        for (final m in messages) {'role': m.role.name, 'content': m.content},
      ],
      'stream': true,
      'stream_options': {'include_usage': true},
      'max_completion_tokens': maxOutputTokens,
    });
    final res = await _send(req);
    final lines = res.stream
        .transform(utf8.decoder)
        .transform(const LineSplitter());
    await for (final line in lines) {
      if (!line.startsWith('data:')) continue;
      final payload = line.substring(5).trim();
      if (payload == '[DONE]') break;
      final event = jsonDecode(payload);
      if (event is! Map) continue;
      final choices = event['choices'];
      if (choices is List && choices.isNotEmpty) {
        final delta = (choices.first as Map)['delta'];
        final content = delta is Map ? delta['content'] : null;
        if (content is String && content.isNotEmpty) yield TextDelta(content);
      }
      final usage = event['usage'];
      if (usage is Map) {
        yield ChatUsage(
          inputTokens: (usage['prompt_tokens'] as num?)?.toInt() ?? 0,
          outputTokens: (usage['completion_tokens'] as num?)?.toInt() ?? 0,
        );
      }
    }
  }

  @override
  Stream<Uint8List> synthesize({
    required String model,
    required String text,
    String? voice,
  }) async* {
    final res = await _send(
      _jsonRequest('audio/speech', {
        'model': model,
        'input': text,
        'voice': voice ?? openAiDefaultVoice,
        'response_format': speechFileExtension,
      }),
    );
    yield* res.stream.map(Uint8List.fromList);
  }

  http.Request _jsonRequest(String path, Map<String, Object> body) =>
      http.Request('POST', _base.resolve(path))
        ..headers['Content-Type'] = 'application/json'
        ..body = jsonEncode(body);

  Future<http.StreamedResponse> _send(http.BaseRequest req) async {
    final key = await _vault.read(_keyRef);
    if (key == null || key.isEmpty) {
      throw const ProviderException(ProviderFailure.invalidKey);
    }
    req.headers['Authorization'] = 'Bearer $key';
    try {
      final res = await _client.send(req).timeout(_timeout);
      if (res.statusCode >= 400) {
        throw failureFrom(
          res.statusCode,
          await res.stream.bytesToString(),
          res.headers,
        );
      }
      return res;
    } on TimeoutException {
      throw const ProviderException(ProviderFailure.network);
    } on SocketException {
      throw const ProviderException(ProviderFailure.network);
    } on http.ClientException {
      throw const ProviderException(ProviderFailure.network);
    }
  }

  static Future<Map<Object?, Object?>> _json(http.StreamedResponse res) async {
    final decoded = jsonDecode(await res.stream.bytesToString());
    if (decoded is Map) return decoded;
    throw const ProviderException(ProviderFailure.unknown);
  }

  /// Maps an error response to a [ProviderFailure]. The body is inspected
  /// for the error code only and is not kept (it may echo part of the key).
  static ProviderException failureFrom(
    int status,
    String body,
    Map<String, String> headers,
  ) {
    String? code;
    try {
      final json = jsonDecode(body);
      final error = json is Map ? json['error'] : null;
      if (error is Map) code = (error['code'] ?? error['type'])?.toString();
    } on FormatException {
      // Non-JSON error page: status code decides.
    }

    final failure = switch ((status, code)) {
      (_, 'model_not_found') || (404, _) => ProviderFailure.modelUnavailable,
      (401, _) => ProviderFailure.invalidKey,
      (429, 'insufficient_quota') => ProviderFailure.insufficientQuota,
      (429, _) => ProviderFailure.rateLimited,
      _ => ProviderFailure.unknown,
    };
    final retrySeconds = int.tryParse(headers['retry-after'] ?? '');
    return ProviderException(
      failure,
      statusCode: status,
      retryAfter: retrySeconds == null ? null : Duration(seconds: retrySeconds),
    );
  }
}
