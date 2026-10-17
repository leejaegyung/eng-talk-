import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/l10n/gen/app_localizations.dart';
import '../../domain/metrics/latency_stats.dart';
import '../../domain/providers/provider_failure.dart';
import 'voice_lab_controller.dart';

class VoiceLabScreen extends ConsumerStatefulWidget {
  const VoiceLabScreen({super.key});

  @override
  ConsumerState<VoiceLabScreen> createState() => _VoiceLabScreenState();
}

class _VoiceLabScreenState extends ConsumerState<VoiceLabScreen> {
  final _keyField = TextEditingController();

  @override
  void dispose() {
    _keyField.dispose();
    super.dispose();
  }

  Future<void> _saveKey() async {
    final key = _keyField.text;
    // Clear the field right away so the key isn't kept in widget state.
    _keyField.clear();
    await ref.read(voiceLabProvider.notifier).saveKey(key);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final s = ref.watch(voiceLabProvider);
    final ctrl = ref.read(voiceLabProvider.notifier);
    final busy = s.phase != VoicePhase.idle;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.voiceLabTitle)),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Text(
                l10n.voiceLabKeyTitle,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 4),
              Text(l10n.voiceLabKeyHint),
              const SizedBox(height: 12),
              if (s.keyStored == false)
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _keyField,
                        obscureText: true,
                        autocorrect: false,
                        enableSuggestions: false,
                        decoration: InputDecoration(
                          border: const OutlineInputBorder(),
                          labelText: l10n.voiceLabKeyField,
                        ),
                        onSubmitted: (_) => _saveKey(),
                      ),
                    ),
                    const SizedBox(width: 12),
                    FilledButton(
                      onPressed: _saveKey,
                      child: Text(l10n.voiceLabKeySave),
                    ),
                  ],
                ),
              if (s.keyStored == true)
                Wrap(
                  spacing: 12,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Chip(
                      avatar: const Icon(Icons.key),
                      label: Text(l10n.voiceLabKeyStored),
                    ),
                    OutlinedButton(
                      onPressed: s.checking || busy
                          ? null
                          : ctrl.testConnection,
                      child: Text(
                        s.checking ? l10n.voiceLabChecking : l10n.voiceLabTest,
                      ),
                    ),
                    TextButton(
                      onPressed: busy ? null : ctrl.deleteKey,
                      child: Text(l10n.voiceLabKeyDelete),
                    ),
                  ],
                ),
              if (s.models case final m?) ...[
                const SizedBox(height: 8),
                Text(
                  l10n.voiceLabModels(m.chat, m.transcription, m.speech),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
              if (s.failure case final f?)
                _Notice(_failureText(l10n, f), Icons.error_outline),
              if (s.micDenied) _Notice(l10n.audioLabMicDenied, Icons.mic_off),
              const Divider(height: 40),
              Center(
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 20,
                    ),
                  ),
                  onPressed: s.models == null
                      ? null
                      : s.phase == VoicePhase.listening
                      ? ctrl.stopListening
                      : busy
                      ? null
                      : ctrl.talk,
                  icon: Icon(
                    s.phase == VoicePhase.listening ? Icons.stop : Icons.mic,
                  ),
                  label: Text(
                    s.phase == VoicePhase.listening
                        ? l10n.voiceLabStopListening
                        : l10n.voiceLabTalk,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              if (_phaseText(l10n, s.phase) case final text?)
                Center(child: Text(text)),
              if (s.heard.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(l10n.voiceLabHeard(s.heard)),
              ],
              if (s.reply.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  l10n.voiceLabReply(s.reply),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
              if (s.runs.isNotEmpty) ...[
                const Divider(height: 40),
                _Measurements(runs: s.runs),
              ],
            ],
          ),
        ),
      ),
    );
  }

  static String? _phaseText(AppLocalizations l10n, VoicePhase p) => switch (p) {
    VoicePhase.idle => null,
    VoicePhase.listening => l10n.voiceLabPhaseListening,
    VoicePhase.transcribing => l10n.voiceLabPhaseTranscribing,
    VoicePhase.thinking => l10n.voiceLabPhaseThinking,
    VoicePhase.speaking => l10n.voiceLabPhaseSpeaking,
  };

  static String _failureText(AppLocalizations l10n, ProviderFailure f) =>
      switch (f) {
        ProviderFailure.invalidKey => l10n.failureInvalidKey,
        ProviderFailure.insufficientQuota => l10n.failureInsufficientQuota,
        ProviderFailure.rateLimited => l10n.failureRateLimited,
        ProviderFailure.modelUnavailable => l10n.failureModelUnavailable,
        ProviderFailure.network => l10n.failureNetwork,
        ProviderFailure.unknown => l10n.failureUnknown,
      };
}

class _Measurements extends StatelessWidget {
  const _Measurements({required this.runs});

  final List<RoundTrip> runs;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final small = Theme.of(context).textTheme.bodySmall;

    String stat(Duration Function(RoundTrip) pick) {
      final samples = runs.map(pick).toList();
      return '${percentile(samples, 50).inMilliseconds}'
          '/${percentile(samples, 95).inMilliseconds}';
    }

    final sentMs = runs.fold(0, (sum, r) => sum + r.audioSent.inMilliseconds);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.voiceLabRunsTitle(runs.length),
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Text(
          l10n.voiceLabStats(
            stat((r) => r.stt),
            stat((r) => r.firstToken),
            stat((r) => r.ttsFirstByte),
            stat((r) => r.total),
          ),
        ),
        Text(
          l10n.voiceLabUsage(
            runs.fold(0, (sum, r) => sum + r.inputTokens),
            runs.fold(0, (sum, r) => sum + r.outputTokens),
            (sentMs / 1000).toStringAsFixed(1),
            runs.fold(0, (sum, r) => sum + r.speechChars),
          ),
        ),
        const SizedBox(height: 8),
        for (final (i, r) in runs.indexed)
          Text(
            l10n.voiceLabRunRow(
              i + 1,
              r.stt.inMilliseconds,
              r.firstToken.inMilliseconds,
              r.ttsFirstByte.inMilliseconds,
              r.total.inMilliseconds,
            ),
            style: small,
          ),
      ],
    );
  }
}

class _Notice extends StatelessWidget {
  const _Notice(this.text, this.icon);

  final String text;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.only(top: 16),
    child: ListTile(leading: Icon(icon), title: Text(text)),
  );
}
