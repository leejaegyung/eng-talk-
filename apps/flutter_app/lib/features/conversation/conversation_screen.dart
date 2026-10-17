import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/l10n/gen/app_localizations.dart';
import '../../app/router.dart';
import '../../domain/conversation/conversation_policy.dart';
import '../../domain/conversation/session_enums.dart';
import '../common/failure_text.dart';
import 'conversation_controller.dart';

/// S06. No scores or mistake counters here (spec §3.3).
class ConversationScreen extends ConsumerStatefulWidget {
  const ConversationScreen({super.key});

  @override
  ConsumerState<ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends ConsumerState<ConversationScreen> {
  final _input = TextEditingController();

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _input.text;
    _input.clear();
    await ref.read(conversationProvider.notifier).send(text);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final s = ref.watch(conversationProvider);
    final ctrl = ref.read(conversationProvider.notifier);
    final theme = Theme.of(context);

    final modeName = switch (s.mode) {
      SessionMode.daily => l10n.conversationModeDaily,
      _ => s.mode.name,
    };

    Widget body;
    if (s.signedIn == false && !s.ended) {
      body = _Centered(
        children: [
          Text(l10n.conversationNeedsConnection),
          if (s.failure case final f?) Text(failureText(l10n, f)),
          FilledButton(
            onPressed: () => context.push(AppRoutes.settings),
            child: Text(l10n.conversationOpenSettings),
          ),
        ],
      );
    } else if (s.ended) {
      final userTurns = s.turns
          .where((t) => t.speaker == Speaker.user && !t.isRequest)
          .length;
      body = _Centered(
        children: [
          Text(
            l10n.conversationEndedTitle,
            style: theme.textTheme.headlineSmall,
          ),
          Text(
            l10n.conversationEndedSummary(
              s.elapsed.inMinutes,
              s.elapsed.inSeconds % 60,
              userTurns,
            ),
          ),
          Text(l10n.conversationEndedNext, style: theme.textTheme.bodySmall),
          FilledButton(
            onPressed: () => context.go(AppRoutes.home),
            child: Text(l10n.conversationBackHome),
          ),
        ],
      );
    } else {
      final status = switch (s) {
        ConversationState(active: false) => l10n.conversationConnecting,
        ConversationState(listening: true) =>
          s.partial.isEmpty ? l10n.conversationListening : s.partial,
        ConversationState(streaming: true) => l10n.conversationThinking,
        ConversationState(speaking: true) => l10n.conversationAiSpeaking,
        _ => l10n.conversationYourTurn,
      };
      final canAct = s.active && !s.busy;
      body = Column(
        children: [
          Expanded(
            child: s.subtitles
                ? ListView(
                    padding: const EdgeInsets.all(24),
                    reverse: true,
                    children: [
                      for (final t in s.turns.reversed) _Line(turn: t),
                    ],
                  )
                : _Centered(
                    children: [
                      Icon(
                        Icons.closed_caption_disabled_outlined,
                        size: 48,
                        color: theme.colorScheme.outline,
                      ),
                      Text(l10n.conversationSubtitlesHidden),
                    ],
                  ),
          ),
          if (s.failure case final f?)
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              child: ListTile(
                leading: const Icon(Icons.error_outline),
                title: Text(failureText(l10n, f)),
              ),
            ),
          if (s.hintSuggested)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                l10n.conversationHintSuggestion,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 4),
            child: Text(
              status,
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Row(
              spacing: 8,
              children: [
                for (final (action, label, icon) in [
                  (
                    CoachAction.hint,
                    l10n.conversationHint,
                    Icons.lightbulb_outline,
                  ),
                  (CoachAction.repeat, l10n.conversationRepeat, Icons.replay),
                  (
                    CoachAction.slower,
                    l10n.conversationSlower,
                    Icons.slow_motion_video,
                  ),
                  (
                    CoachAction.correctLast,
                    l10n.conversationCorrect,
                    Icons.spellcheck,
                  ),
                  (
                    CoachAction.changeTopic,
                    l10n.conversationChangeTopic,
                    Icons.shuffle,
                  ),
                ])
                  ActionChip(
                    avatar: Icon(icon, size: 18),
                    label: Text(label),
                    onPressed: canAct ? () => ctrl.act(action) : null,
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 4, 24, 24),
            child: Row(
              children: [
                IconButton.filled(
                  iconSize: 32,
                  tooltip: l10n.chatGptLabTalk,
                  onPressed: !s.active || s.streaming
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
                    enabled: canAct,
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      hintText: l10n.conversationInput,
                    ),
                    onSubmitted: (_) => _send(),
                  ),
                ),
                const SizedBox(width: 12),
                FilledButton(
                  onPressed: canAct ? _send : null,
                  child: Text(l10n.conversationSend),
                ),
              ],
            ),
          ),
        ],
      );
    }

    final remaining = s.length - s.elapsed;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.conversationTitle(modeName, s.level.label)),
        actions: [
          if (s.active) ...[
            Center(
              child: Text(
                _clock(s.elapsed),
                style: theme.textTheme.titleMedium?.copyWith(
                  color: remaining.isNegative ? theme.colorScheme.error : null,
                ),
              ),
            ),
            IconButton(
              tooltip: s.subtitles
                  ? l10n.conversationHideSubtitles
                  : l10n.conversationShowSubtitles,
              onPressed: ctrl.toggleSubtitles,
              icon: Icon(
                s.subtitles
                    ? Icons.closed_caption_outlined
                    : Icons.closed_caption_disabled_outlined,
              ),
            ),
            TextButton(onPressed: ctrl.end, child: Text(l10n.conversationEnd)),
          ],
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: body,
        ),
      ),
    );
  }

  static String _clock(Duration d) =>
      '${d.inMinutes.toString().padLeft(2, '0')}:'
      '${(d.inSeconds % 60).toString().padLeft(2, '0')}';
}

class _Centered extends StatelessWidget {
  const _Centered({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 16,
        children: children,
      ),
    ),
  );
}

/// Large subtitles (spec §3.3). Quick-action lines are shown smaller.
class _Line extends StatelessWidget {
  const _Line({required this.turn});

  final ConversationTurn turn;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final mine = turn.speaker == Speaker.user;
    if (turn.isRequest) {
      return Align(
        alignment: Alignment.centerRight,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Text(
            turn.text,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontStyle: FontStyle.italic,
              color: colors.outline,
            ),
          ),
        ),
      );
    }
    return Align(
      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: const BoxConstraints(maxWidth: 560),
        decoration: BoxDecoration(
          color: mine ? colors.primaryContainer : colors.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(18),
        ),
        child: SelectableText(turn.text, style: theme.textTheme.titleMedium),
      ),
    );
  }
}
