// Can the ChatGPT plan transcribe audio (no extra charge)?
//   dart run tool/eval/audio_probe.dart speech.wav
// Prints only HTTP status, model ids and the transcript — never tokens.
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:speaking_coach/data/providers/chatgpt/chatgpt_plan_client.dart';

import 'backend.dart';

Future<void> main(List<String> args) async {
  final wav = await File(args.single).readAsBytes();
  final auth = evalAuth();
  final client = ChatGptPlanClient(accessToken: auth.accessToken);
  final models = await client.planModels();
  stdout.writeln('plan models: ${[for (final m in models) m.slug].join(', ')}');
  final base = Uri.parse('https://api.openai.com/v1/');
  final token = await auth.accessToken();
  for (final model in [for (final m in models) m.slug]) {
    // 1. Responses API with an audio input part.
    final r1 = await http.post(
      base.resolve('responses'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'model': model,
        'instructions': 'Transcribe the English speech exactly. Reply with the transcript only.',
        'input': [
          {
            'role': 'user',
            'content': [
              {
                'type': 'input_audio',
                'input_audio': {'data': base64Encode(wav), 'format': 'wav'},
              },
            ],
          },
        ],
        'store': false,
        'stream': true,
      }),
    );
    final deltas = [
      for (final line in const LineSplitter().convert(r1.body))
        if (line.startsWith('data:'))
          if (_json(line.substring(5)) case {
            'type': 'response.output_text.delta',
            'delta': final String d,
          })
            d,
    ];
    final errors = [
      for (final line in const LineSplitter().convert(r1.body))
        if (line.startsWith('data:') && line.contains('error'))
          line.substring(0, line.length.clamp(0, 240)),
    ];
    stdout.writeln(
      'responses+audio ($model): ${r1.statusCode} '
      '${deltas.isNotEmpty
          ? 'TEXT: ${deltas.join()}'
          : errors.isNotEmpty
          ? errors.first
          : _summary(r1.body)}',
    );
  }
  exit(0);
}

Object? _json(String s) {
  try {
    return jsonDecode(s.trim());
  } on FormatException {
    return null;
  }
}

/// Output text or the error code/message, cut short.
String _summary(String body) {
  try {
    final j = jsonDecode(body);
    if (j is Map) {
      if (j['text'] is String) return 'TEXT: ${j['text']}';
      final out = j['output'];
      if (out is List) {
        final texts = [
          for (final o in out)
            if (o is Map && o['content'] is List)
              for (final c in o['content'] as List)
                if (c is Map && c['text'] is String) c['text'],
        ];
        if (texts.isNotEmpty) return 'TEXT: ${texts.join(' ')}';
      }
      final e = j['error'];
      if (e is Map) {
        return 'ERROR ${e['code'] ?? e['type']}: ${'${e['message']}'.substring(0, '${e['message']}'.length.clamp(0, 160))}';
      }
    }
  } on FormatException {
    // fall through
  }
  return body.substring(0, body.length.clamp(0, 160));
}
