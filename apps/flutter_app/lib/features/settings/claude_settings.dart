import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/l10n/gen/app_localizations.dart';
import '../../domain/providers/ai_choice.dart';
import '../common/failure_text.dart';
import 'claude_settings_controller.dart';

/// Picks the coaching AI and manages the Claude key (ADR-014).
class ClaudeSettings extends ConsumerStatefulWidget {
  const ClaudeSettings({super.key});

  @override
  ConsumerState<ClaudeSettings> createState() => _ClaudeSettingsState();
}

class _ClaudeSettingsState extends ConsumerState<ClaudeSettings> {
  final _key = TextEditingController();

  @override
  void dispose() {
    _key.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final key = _key.text;
    // The field is cleared right away; the key lives only in the vault.
    _key.clear();
    await ref.read(claudeSettingsProvider.notifier).saveKey(key);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final s = ref.watch(claudeSettingsProvider);
    final ctrl = ref.read(claudeSettingsProvider.notifier);
    final small = theme.textTheme.bodySmall;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 12,
        children: [
          Text(l10n.aiChoiceLabel, style: theme.textTheme.titleSmall),
          SegmentedButton<AiChoice>(
            segments: [
              ButtonSegment(
                value: AiChoice.chatGpt,
                label: Text(l10n.aiChoiceChatGpt),
              ),
              ButtonSegment(
                value: AiChoice.claude,
                label: Text(l10n.aiChoiceClaude),
              ),
            ],
            selected: {s.choice},
            showSelectedIcon: false,
            onSelectionChanged: (v) => ctrl.choose(v.single),
          ),
          if (s.choice == AiChoice.claude) ...[
            Text(l10n.claudeBilling, style: small),
            if (s.hasKey == false) Text(l10n.claudeChosenNoKey, style: small),
          ],
          if (s.choice == AiChoice.claude || s.hasKey == true) ...[
            switch (s) {
              ClaudeSettingsState(busy: true) => Text(l10n.settingsChecking),
              ClaudeSettingsState(model: final m?) => Text(
                l10n.settingsConnectedModel(m),
              ),
              ClaudeSettingsState(hasKey: false) => Text(l10n.claudeNoKey),
              _ => const SizedBox.shrink(),
            },
            if (s.failure case final f?)
              Card(
                margin: EdgeInsets.zero,
                child: ListTile(
                  leading: const Icon(Icons.error_outline),
                  title: Text(failureText(l10n, f)),
                  trailing: TextButton(
                    onPressed: s.busy ? null : ctrl.check,
                    child: Text(l10n.settingsRetry),
                  ),
                ),
              ),
            Row(
              spacing: 8,
              children: [
                Expanded(
                  child: TextField(
                    controller: _key,
                    obscureText: true,
                    autocorrect: false,
                    enableSuggestions: false,
                    decoration: InputDecoration(labelText: l10n.claudeKeyLabel),
                    onSubmitted: (_) => _save(),
                  ),
                ),
                FilledButton(
                  onPressed: s.busy ? null : _save,
                  child: Text(l10n.claudeKeySave),
                ),
              ],
            ),
            Text(l10n.claudeKeyStored, style: small),
            if (s.hasKey == true)
              OutlinedButton(
                onPressed: s.busy ? null : ctrl.removeKey,
                child: Text(l10n.claudeKeyRemove),
              ),
          ],
        ],
      ),
    );
  }
}
