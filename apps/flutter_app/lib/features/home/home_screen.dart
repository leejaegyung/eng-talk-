import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/l10n/gen/app_localizations.dart';
import '../../app/router.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.appTitle)),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.homeHeadline,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              // Wired to the conversation flow in P1-A5.
              onPressed: null,
              icon: const Icon(Icons.mic),
              label: Text(l10n.homeStartButton),
            ),
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: () => context.push(AppRoutes.audioLab),
              icon: const Icon(Icons.graphic_eq),
              label: Text(l10n.homeAudioLab),
            ),
            TextButton.icon(
              onPressed: () => context.push(AppRoutes.voiceLab),
              icon: const Icon(Icons.record_voice_over),
              label: Text(l10n.homeVoiceLab),
            ),
          ],
        ),
      ),
    );
  }
}
