import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../app/l10n/gen/app_localizations.dart';
import '../../app/providers.dart';
import '../../app/router.dart';
import '../../domain/conversation/session_enums.dart';
import '../../domain/sessions/session_records.dart';
import '../common/mode_text.dart';
import 'history_controller.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  Future<void> _delete(
    BuildContext context,
    WidgetRef ref,
    SessionSummary s,
  ) async {
    final l10n = AppLocalizations.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        content: Text(l10n.historyDeleteConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.historyDelete),
          ),
        ],
      ),
    );
    if (ok ?? false) await ref.read(sessionRepositoryProvider).delete(s.id);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final sessions = ref.watch(historyProvider);
    final query = ref.watch(historyQueryProvider);
    final date = DateFormat.yMMMd(Localizations.localeOf(context).toString())
        .add_Hm();

    return Scaffold(
      appBar: AppBar(title: Text(l10n.historyTitle)),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search),
                    hintText: l10n.historySearch,
                    border: const OutlineInputBorder(),
                  ),
                  onChanged: ref.read(historyQueryProvider.notifier).set,
                ),
              ),
              Expanded(
                child: switch (sessions) {
                  AsyncData(value: final list) when list.isEmpty => Center(
                    child: Text(
                      query.isEmpty ? l10n.historyEmpty : l10n.historyNoMatch,
                    ),
                  ),
                  AsyncData(value: final list) => ListView(
                    children: [
                      for (final s in list)
                        ListTile(
                          leading: Icon(modeIcon(s.setup.mode)),
                          title: Text(
                            [
                              modeName(l10n, s.setup.mode),
                              s.setup.level.label,
                              ?s.setup.topic,
                            ].join(' · '),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(
                            [
                              date.format(s.startedAt.toLocal()),
                              l10n.resultMinSec(
                                s.duration.inMinutes,
                                s.duration.inSeconds % 60,
                              ),
                              l10n.historyAnswers(s.userTurns),
                              if (s.status == SessionStatus.active ||
                                  s.status == SessionStatus.paused)
                                l10n.historyUnfinished,
                            ].join(' · '),
                          ),
                          onTap: () => context.push(AppRoutes.result(s.id)),
                          trailing: IconButton(
                            tooltip: l10n.historyDelete,
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () => _delete(context, ref, s),
                          ),
                        ),
                    ],
                  ),
                  _ => const Center(child: CircularProgressIndicator()),
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
