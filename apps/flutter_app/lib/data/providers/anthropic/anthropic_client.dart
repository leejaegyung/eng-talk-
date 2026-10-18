import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../../../domain/credentials/credential_vault.dart';
import '../../../domain/providers/ai_provider.dart';
import '../../../domain/providers/provider_failure.dart';

/// Claude through the Anthropic Messages API with the user's own key
/// (ADR-014). The key is read from the vault per request and never kept in
/// a field (docs/security.md S5).
class AnthropicClient implements LlmProvider {
  AnthropicClient({
    required this._vault,
    required this._keyRef,
    http.Client? client,
    Uri? baseUrl,
  }) : _client = client ?? http.Client(),
       _base = baseUrl ?? Uri.parse('https://api.anthropic.com/v1/');

  static const _timeout = Duration(seconds: 30);
  static const _apiVersion = '2023-06-01';

  /// Stands in for the learner when the history starts with the coach: the
  /// API wants the first message from the user.
  static const _opening = '[The learner is here.]';

  final CredentialVault _vault;
  final String _keyRef;
  final http.Client _client;
  final Uri _base;

  void close() => _client.close();

  @override
  Future<List<String>> listModels() async {
    final res = await _send(
      http.Request('GET', _base.resolve('models?limit=1000')),
    );
    final json = jsonDecode(await res.stream.bytesToString());
    final data = json is Map ? json['data'] : null;
    return [
      if (data is List)
        for (final m in data)
          if (m is Map && m['id'] is String) m['id'] as String,
    ]..sort();
  }

  @override
  Stream<ChatChunk> streamChat({
    required String model,
    required List<ChatMessage> messages,
    int maxOutputTokens = 200,
  }) async* {
    final req = http.Request('POST', _base.resolve('messages'))
      ..headers['content-type'] = 'application/json'
      ..body = jsonEncode({
        'model': model,
        'max_tokens': maxOutputTokens,
        'stream': true,
        'system': [
          for (final m in messages)
            if (m.role == ChatRole.system) m.content,
        ].join('\n\n'),
        'messages': toTurns(messages),
      });
    final res = await _send(req);
    var input = 0;
    var output = 0;
    final lines = res.stream
        .transform(utf8.decoder)
        .transform(const LineSplitter());
    await for (final line in lines) {
      if (!line.startsWith('data:')) continue;
      final event = jsonDecode(line.substring(5).trim());
      if (event is! Map) continue;
      switch (event['type']) {
        case 'message_start':
          final usage = (event['message'] as Map?)?['usage'];
          if (usage is Map) {
            input = (usage['input_tokens'] as num?)?.toInt() ?? 0;
          }
        case 'content_block_delta':
          final delta = event['delta'];
          if (delta is Map &&
              delta['type'] == 'text_delta' &&
              delta['text'] is String &&
              (delta['text'] as String).isNotEmpty) {
            yield TextDelta(delta['text'] as String);
          }
        case 'message_delta':
          final usage = event['usage'];
          if (usage is Map) {
            output = (usage['output_tokens'] as num?)?.toInt() ?? output;
          }
        case 'error':
          throw ProviderException(
            _failureFor(null, (event['error'] as Map?)?['type']?.toString()),
          );
        case 'message_stop':
          yield ChatUsage(inputTokens: input, outputTokens: output);
      }
    }
  }

  /// User/assistant turns as the API wants them: system messages left out,
  /// starting with the user, roles alternating (same-role runs joined).
  static List<Map<String, String>> toTurns(List<ChatMessage> messages) {
    final turns = <Map<String, String>>[];
    for (final m in messages) {
      if (m.role == ChatRole.system) continue;
      final role = m.role == ChatRole.user ? 'user' : 'assistant';
      if (turns.isEmpty && role == 'assistant') {
        turns.add({'role': 'user', 'content': _opening});
      }
      if (turns.isNotEmpty && turns.last['role'] == role) {
        turns.last['content'] = '${turns.last['content']}\n\n${m.content}';
      } else {
        turns.add({'role': role, 'content': m.content});
      }
    }
    return turns;
  }

  Future<http.StreamedResponse> _send(http.BaseRequest req) async {
    final key = await _vault.read(_keyRef);
    if (key == null || key.isEmpty) {
      throw const ProviderException(ProviderFailure.invalidKey);
    }
    req.headers['x-api-key'] = key;
    req.headers['anthropic-version'] = _apiVersion;
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

  /// Maps an error response to a [ProviderFailure]. Only the error type and
  /// a low-credit hint are read from the body; nothing of it is kept.
  static ProviderException failureFrom(
    int status,
    String body,
    Map<String, String> headers,
  ) {
    String? type;
    var lowCredit = false;
    try {
      final json = jsonDecode(body);
      final error = json is Map ? json['error'] : null;
      if (error is Map) {
        type = error['type']?.toString();
        lowCredit = '${error['message']}'.toLowerCase().contains('credit');
      }
    } on FormatException {
      // Non-JSON error page: status code decides.
    }
    final retrySeconds = int.tryParse(headers['retry-after'] ?? '');
    return ProviderException(
      lowCredit ? ProviderFailure.insufficientQuota : _failureFor(status, type),
      statusCode: status,
      retryAfter: retrySeconds == null ? null : Duration(seconds: retrySeconds),
    );
  }

  static ProviderFailure _failureFor(int? status, String? type) =>
      switch ((status, type)) {
        (_, 'authentication_error') ||
        (_, 'permission_error') ||
        (401, _) ||
        (403, _) => ProviderFailure.invalidKey,
        (_, 'not_found_error') || (404, _) => ProviderFailure.modelUnavailable,
        (_, 'rate_limit_error') ||
        (_, 'overloaded_error') ||
        (429, _) ||
        (529, _) => ProviderFailure.rateLimited,
        _ => ProviderFailure.unknown,
      };
}
