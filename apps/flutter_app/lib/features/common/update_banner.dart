import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/l10n/gen/app_localizations.dart';
import '../../app/theme.dart';
import '../../domain/update/app_update.dart';
import 'update_controller.dart';

/// "A new version is out" with the platform's way to get it. Nothing when
/// there's no newer release, or (unless [ignoreDismiss]) after "Later".
class UpdateBanner extends ConsumerWidget {
  const UpdateBanner({super.key, this.ignoreDismiss = false});

  final bool ignoreDismiss;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final s = ref.watch(updateProvider);
    final release = s.release;
    if (release == null || (s.dismissed && !ignoreDismiss)) {
      return const SizedBox.shrink();
    }
    final ctrl = ref.read(updateProvider.notifier);
    final method = ctrl.method;

    return Card(
      color: theme.colorScheme.primaryContainer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(kRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 8,
          children: [
            Row(
              spacing: 8,
              children: [
                Icon(Icons.system_update, color: theme.colorScheme.primary),
                Expanded(
                  child: Text(
                    l10n.updateAvailable('${release.version}'),
                    style: theme.textTheme.titleMedium,
                  ),
                ),
              ],
            ),
            Text(switch ((s.failed, method)) {
              (true, _) => l10n.updateFailed,
              (_, UpdateMethod.install) => l10n.updateInstallNote,
              (_, UpdateMethod.reload) => l10n.updateReloadNote,
              (_, UpdateMethod.openPage) => l10n.updatePageNote,
            }),
            if (s.applying && s.percent != null)
              LinearProgressIndicator(value: s.percent! / 100),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (s.failed)
                  FilledButton.icon(
                    onPressed: ctrl.openPage,
                    icon: const Icon(Icons.open_in_new),
                    label: Text(l10n.updateOpenPage),
                  )
                else
                  FilledButton.icon(
                    onPressed: s.applying ? null : ctrl.apply,
                    icon: const Icon(Icons.download),
                    label: Text(switch (method) {
                      _ when s.applying => l10n.updateDownloading(
                        s.percent ?? 0,
                      ),
                      UpdateMethod.install => l10n.updateInstall,
                      UpdateMethod.reload => l10n.updateReload,
                      UpdateMethod.openPage => l10n.updateOpenPage,
                    }),
                  ),
                if (!ignoreDismiss && !s.applying)
                  TextButton(
                    onPressed: ctrl.dismiss,
                    child: Text(l10n.updateLater),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
