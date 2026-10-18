import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../../../core/net/http_client.dart';

import '../../../domain/credentials/credential_vault.dart';
import '../../../domain/providers/ai_provider.dart';
import '../../../domain/providers/provider_failure.dart';

/// Gemini through the Gemini Developer API with the user's own (free tier)
/// key (ADR-015). The key is read from the vault per request, sent only in
/// a header (never the URL) and never kept in a field (docs/security.md S5).
class GeminiClient implements LlmProvider {
  GeminiClient({
    required this._vault,
    required this._keyRef,
    http.Client? client,
    Uri? baseUrl,
  }) : _client = client ?? newHttpClient(),
       _base =
           baseUrl ??
           Uri.parse('https://generativelanguage.googleapis.com/v1beta/');

  static const _timeout = Duration(seconds: 30);

  /// Stands in for the learner when the history starts with the coach: the
  /// API wants the first turn from the user.
  static const _opening = '[The learner is here.]';

  final CredentialVault _vault;
  final String _keyRef;
  final http.Client _client;
  final Uri _base;

  void close() => _client.close();

  /// Model IDs (without the `models/` prefix) that can generate text.
  @override
  Future<List<String>> listModels() async {
    final res = await _send(
      http.Request('GET', _base.resolve('models?pageSize=1000')),
    );
    final json = jsonDecode(await res.stream.bytesToString());
    final models = json is Map ? json['models'] : null;
    return [
      if (models is List)
        for (final m in models)
          if (m is Map &&
              m['name'] is String &&
              (m['supportedGenerationMethods'] as List?)?.contains(
                    'generateContent',
                  ) ==
                  true)
            (m['name'] as String).replaceFirst('models/', ''),
    ]..sort();
  }

  @override
  Stream<ChatChunk> streamChat({
    required String model,
    required List<ChatMessage> messages,
    int maxOutputTokens = 200,
  }) async* {
    final system = [
      for (final m in messages)
        if (m.role == ChatRole.system) m.content,
    ].join('\n\n');
    final req =
        http.Request(
            'POST',
            _base.resolve('models/$model:streamGenerateContent?alt=sse'),
          )
          ..headers['content-type'] = 'application/json'
          ..body = jsonEncode({
            if (system.isNotEmpty)
              'systemInstruction': {
                'parts': [
                  {'text': system},
                ],
              },
            'contents': toContents(messages),
            'generationConfig': {'maxOutputTokens': maxOutputTokens},
          });
    final res = await _send(req);
    Map<Object?, Object?>? usage;
    final lines = res.stream
        .transform(utf8.decoder)
        .transform(const LineSplitter());
    await for (final line in lines) {
      if (!line.startsWith('data:')) continue;
      final event = jsonDecode(line.substring(5).trim());
      if (event is! Map) continue;
      if (event['error'] is Map) {
        throw ProviderException(
          _failureFor(null, (event['error'] as Map)['status']?.toString()),
        );
      }
      final candidates = event['candidates'];
      if (candidates is List && candidates.isNotEmpty) {
        final parts = ((candidates.first as Map)['content'] as Map?)?['parts'];
        if (parts is List) {
          for (final p in parts) {
            // Thought summaries are not part of the reply.
            if (p is Map && p['thought'] != true && p['text'] is String) {
              final text = p['text'] as String;
              if (text.isNotEmpty) yield TextDelta(text);
            }
          }
        }
      }
      if (event['usageMetadata'] case final Map<Object?, Object?> u) {
        usage = u;
      }
    }
    if (usage != null) {
      int count(String field) => (usage![field] as num?)?.toInt() ?? 0;
      yield ChatUsage(
        inputTokens: count('promptTokenCount'),
        // Thinking tokens are output tokens too.
        outputTokens:
            count('candidatesTokenCount') + count('thoughtsTokenCount'),
      );
    }
  }

  /// User/model turns as the API wants them: system messages left out,
  /// starting with the user, roles alternating (same-role runs joined).
  static List<Map<String, Object>> toContents(List<ChatMessage> messages) {
    final turns = <(String, String)>[];
    for (final m in messages) {
      if (m.role == ChatRole.system) continue;
      final role = m.role == ChatRole.user ? 'user' : 'model';
      if (turns.isEmpty && role == 'model') turns.add(('user', _opening));
      if (turns.isNotEmpty && turns.last.$1 == role) {
        turns.last = (role, '${turns.last.$2}\n\n${m.content}');
      } else {
        turns.add((role, m.content));
      }
    }
    return [
      for (final (role, text) in turns)
        {
          'role': role,
          'parts': [
            {'text': text},
          ],
        },
    ];
  }

  Future<http.StreamedResponse> _send(http.BaseRequest req) async {
    final key = await _vault.read(_keyRef);
    if (key == null || key.isEmpty) {
      throw const ProviderException(ProviderFailure.invalidKey);
    }
    req.headers['x-goog-api-key'] = key;
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

  /// Maps an error response to a [ProviderFailure]. Only the status and
  /// error reason are read from the body; nothing of it is kept.
  static ProviderException failureFrom(
    int status,
    String body,
    Map<String, String> headers,
  ) {
    String? reason;
    try {
      final json = jsonDecode(body);
      final error = json is Map ? json['error'] : null;
      if (error is Map) {
        reason = error['status']?.toString();
        final details = error['details'];
        if (details is List) {
          for (final d in details) {
            if (d is Map && d['reason'] == 'API_KEY_INVALID') {
              reason = 'API_KEY_INVALID';
            }
          }
        }
      }
    } on FormatException {
      // Non-JSON error page: status code decides.
    }
    final retrySeconds = int.tryParse(headers['retry-after'] ?? '');
    return ProviderException(
      _failureFor(status, reason),
      statusCode: status,
      retryAfter: retrySeconds == null ? null : Duration(seconds: retrySeconds),
    );
  }

  static ProviderFailure _failureFor(int? status, String? reason) =>
      switch ((status, reason)) {
        (_, 'API_KEY_INVALID') ||
        (_, 'PERMISSION_DENIED') ||
        (_, 'UNAUTHENTICATED') ||
        (401, _) ||
        (403, _) => ProviderFailure.invalidKey,
        (_, 'NOT_FOUND') || (404, _) => ProviderFailure.modelUnavailable,
        // Free-tier limits come back as RESOURCE_EXHAUSTED.
        (_, 'RESOURCE_EXHAUSTED') ||
        (429, _) ||
        (503, _) => ProviderFailure.rateLimited,
        _ => ProviderFailure.unknown,
      };
}
