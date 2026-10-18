import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/providers/chatgpt/chatgpt_auth.dart' show ChatGptAuth;
import 'l10n/gen/app_localizations.dart';
import 'pasted_callback.dart';

/// Over the whole app while a web ChatGPT sign-in waits for the pasted
/// callback address (see [PastedCallback]).
class PastedCallbackPrompt extends ConsumerWidget {
  const PastedCallbackPrompt({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paste = ref.watch(pastedCallbackProvider);
    return ValueListenableBuilder<bool>(
      valueListenable: paste.pending,
      builder: (context, pending, _) => Stack(
        children: [
          child,
          if (pending) ...[
            const ModalBarrier(dismissible: false, color: Colors.black54),
            // Own overlay: text fields need one, and this sits above the
            // navigator's.
            Overlay(
              initialEntries: [
                OverlayEntry(builder: (_) => _PastePanel(paste: paste)),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _PastePanel extends StatefulWidget {
  const _PastePanel({required this.paste});

  final PastedCallback paste;

  @override
  State<_PastePanel> createState() => _PastePanelState();
}

class _PastePanelState extends State<_PastePanel> {
  final _text = TextEditingController();
  bool _invalid = false;

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  void _submit() {
    final ok = widget.paste.submit(ChatGptAuth.parseCallback(_text.text));
    setState(() => _invalid = !ok);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Card(
          margin: const EdgeInsets.all(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 12,
              children: [
                Text(l10n.pasteTitle, style: theme.textTheme.titleLarge),
                Text(l10n.pasteSteps),
                TextField(
                  controller: _text,
                  autocorrect: false,
                  enableSuggestions: false,
                  decoration: InputDecoration(
                    labelText: l10n.pasteLabel,
                    errorText: _invalid ? l10n.pasteInvalid : null,
                    errorMaxLines: 3,
                  ),
                  onSubmitted: (_) => _submit(),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  spacing: 8,
                  children: [
                    TextButton(
                      onPressed: widget.paste.cancel,
                      child: Text(l10n.cancel),
                    ),
                    FilledButton(
                      onPressed: _submit,
                      child: Text(l10n.pasteConfirm),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
