import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/l10n/gen/app_localizations.dart';
import '../../domain/metrics/latency_stats.dart';
import '../../domain/providers/ai_provider.dart';
import '../common/failure_text.dart';
import 'chatgpt_lab_controller.dart';

class ChatGptLabScreen extends ConsumerStatefulWidget {
  const ChatGptLabScreen({super.key});

  @override
  ConsumerState<ChatGptLabScreen> createState() => _ChatGptLabScreenState();
}

class _ChatGptLabScreenState extends ConsumerState<ChatGptLabScreen> {
  final _input = TextEditingController();

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _input.text;
    _input.clear();
    await ref.read(chatGptLabProvider.notifier).send(text);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final s = ref.watch(chatGptLabProvider);
    final ctrl = ref.read(chatGptLabProvider.notifier);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.chatGptLabTitle),
        actions: [
          if (s.signedIn == true)
            TextButton(
              onPressed: s.streaming ? null : ctrl.signOut,
              child: Text(l10n.chatGptLabSignOut),
            ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (s.signedIn == false) ...[
                      Text(l10n.chatGptLabIntro),
                      const SizedBox(height: 16),
                      Center(
                        child: FilledButton.icon(
                          onPressed: s.busy ? null : ctrl.signIn,
                          icon: const Icon(Icons.login),
                          label: Text(
                            s.busy
                                ? l10n.chatGptLabSigningIn
                                : l10n.chatGptLabSignIn,
                          ),
                        ),
                      ),
                    ],
                    if (s.signedIn == true && s.model != null) ...[
                      Text(
                        l10n.chatGptLabSignedIn(s.model!),
                        style: theme.textTheme.bodySmall,
                      ),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(l10n.chatGptLabSpeakReplies),
                        subtitle: Text(l10n.chatGptLabFreeVoiceNote),
                        value: s.speakReplies,
                        onChanged: ctrl.setSpeakReplies,
                      ),
                    ],
                    if (s.speechUnavailable)
                      Card(
                        margin: const EdgeInsets.only(top: 12),
                        child: ListTile(
                          leading: const Icon(Icons.mic_off),
                          title: Text(l10n.chatGptLabSpeechUnavailable),
                        ),
                      ),
                    if (s.failure case final f?)
                      Card(
                        margin: const EdgeInsets.only(top: 12),
                        child: ListTile(
                          leading: const Icon(Icons.error_outline),
                          title: Text(failureText(l10n, f)),
                        ),
                      ),
                    if (s.firstTokens.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          l10n.chatGptLabStats(
                            percentile(s.firstTokens, 50).inMilliseconds,
                            percentile(s.firstTokens, 95).inMilliseconds,
                            s.firstTokens.length,
                            s.inputTokens,
                            s.outputTokens,
                          ),
                          style: theme.textTheme.bodySmall,
                        ),
                      ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(24),
                  reverse: true,
                  children: [
                    for (final m in s.turns.reversed) _Bubble(message: m),
                  ],
                ),
              ),
              if (s.listening || s.speaking)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    s.listening
                        ? (s.partial.isEmpty
                              ? l10n.chatGptLabListening
                              : s.partial)
                        : l10n.chatGptLabSpeaking,
                    style: theme.textTheme.titleMedium,
                  ),
                ),
              if (s.model != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                  child: Row(
                    children: [
                      IconButton.filled(
                        iconSize: 28,
                        tooltip: l10n.chatGptLabTalk,
                        onPressed: s.streaming
                            ? null
                            : s.listening
                            ? ctrl.stopListening
                            : ctrl.talk,
                        icon: Icon(s.listening ? Icons.stop : Icons.mic),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _input,
                          enabled: !s.streaming && !s.listening,
                          decoration: InputDecoration(
                            border: const OutlineInputBorder(),
                            hintText: l10n.chatGptLabInput,
                          ),
                          onSubmitted: (_) => _send(),
                        ),
                      ),
                      const SizedBox(width: 12),
                      FilledButton(
                        onPressed: s.streaming || s.listening ? null : _send,
                        child: Text(l10n.chatGptLabSend),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.message});

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final mine = message.role == ChatRole.user;
    final colors = Theme.of(context).colorScheme;
    return Align(
      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: const BoxConstraints(maxWidth: 520),
        decoration: BoxDecoration(
          color: mine ? colors.primaryContainer : colors.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(16),
        ),
        child: SelectableText(message.content),
      ),
    );
  }
}
