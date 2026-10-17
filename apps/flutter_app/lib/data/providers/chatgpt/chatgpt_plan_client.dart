import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../../../domain/providers/ai_provider.dart';
import '../../../domain/providers/provider_failure.dart';

/// GPT through the user's ChatGPT plan (ADR-011): `POST /v1/responses` with
/// the Sign in with ChatGPT access token. Plan usage requires `stream: true`
/// and `store: false`, rejects system message items (use `instructions`) and
/// output-token limits.
class ChatGptPlanClient implements LlmProvider {
  ChatGptPlanClient({required this._accessToken, http.Client? client})
    : _client = client ?? http.Client();

  static final _base = Uri.parse('https://api.openai.com/v1/');
  static const _timeout = Duration(seconds: 30);

  final Future<String> Function() _accessToken;
  final http.Client _client;

  void close() => _client.close();

  @override
  Future<List<String>> listModels() async {
    final res = await _send(http.Request('GET', _base.resolve('models')));
    final json = jsonDecode(await res.stream.bytesToString());
    final data = json is Map ? json['data'] : null;
    return [
      if (data is List)
        for (final m in data)
          if (m is Map &&
              m['id'] is String &&
              (m['visibility'] == null || m['visibility'] == 'list'))
            m['id'] as String,
    ];
  }

  /// [maxOutputTokens] is ignored: plan usage rejects `max_output_tokens`;
  /// reply length is steered by the instructions instead.
  @override
  Stream<ChatChunk> streamChat({
    required String model,
    required List<ChatMessage> messages,
    int maxOutputTokens = 200,
  }) async* {
    final instructions = [
      for (final m in messages)
        if (m.role == ChatRole.system) m.content,
    ].join('\n\n');
    final req = http.Request('POST', _base.resolve('responses'))
      ..headers['Content-Type'] = 'application/json'
      ..body = jsonEncode({
        'model': model,
        'instructions': instructions,
        'input': [
          for (final m in messages)
            if (m.role != ChatRole.system)
              {'role': m.role.name, 'content': m.content},
        ],
        'stream': true,
        'store': false,
      });

    final res = await _send(req);
    final lines = res.stream
        .transform(utf8.decoder)
        .transform(const LineSplitter());
    await for (final line in lines) {
      if (!line.startsWith('data:')) continue;
      final event = jsonDecode(line.substring(5).trim());
      if (event is! Map) continue;
      switch (event['type']) {
        case 'response.output_text.delta':
          final delta = event['delta'];
          if (delta is String && delta.isNotEmpty) yield TextDelta(delta);
        case 'response.completed':
          final response = event['response'];
          final usage = response is Map ? response['usage'] : null;
          if (usage is Map) {
            yield ChatUsage(
              inputTokens: (usage['input_tokens'] as num?)?.toInt() ?? 0,
              outputTokens: (usage['output_tokens'] as num?)?.toInt() ?? 0,
            );
          }
          return;
        case 'response.incomplete':
          return;
        case 'response.failed':
          final response = event['response'];
          final error = response is Map ? response['error'] : null;
          throw _failure(error is Map ? error['code']?.toString() : null, null);
        case 'error':
          throw _failure(event['code']?.toString(), null);
      }
    }
  }

  Future<http.StreamedResponse> _send(http.BaseRequest req) async {
    req.headers['Authorization'] = 'Bearer ${await _accessToken()}';
    try {
      final res = await _client.send(req).timeout(_timeout);
      if (res.statusCode >= 400) {
        final body = await res.stream.bytesToString();
        String? code;
        try {
          final json = jsonDecode(body);
          final error = json is Map ? json['error'] : null;
          if (error is Map) code = error['code']?.toString();
        } on FormatException {
          // `{"detail": ...}` or plain text: the status decides.
        }
        throw _failure(code, res.statusCode);
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

  /// Codes from developers.openai.com/siwc/.../errors-and-recovery.
  static ProviderException _failure(String? code, int? status) {
    final failure = switch ((code, status)) {
      ('subscription_sharing_usage_limit_exceeded', _) =>
        ProviderFailure.planUsageLimit,
      ('subscription_sharing_user_not_eligible', _) =>
        ProviderFailure.planNotEligible,
      ('subscription_sharing_invalid_user', _) =>
        ProviderFailure.signInRequired,
      ('model_not_found', _) => ProviderFailure.modelUnavailable,
      // Usage/user unavailable (503) and anything else: retry later.
      (String(), _) => ProviderFailure.unknown,
      (null, 401) => ProviderFailure.signInRequired,
      (null, 403) => ProviderFailure.planNotEligible,
      (null, 429) => ProviderFailure.planUsageLimit,
      _ => ProviderFailure.unknown,
    };
    return ProviderException(failure, statusCode: status);
  }
}
