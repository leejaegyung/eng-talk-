import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/l10n/gen/app_localizations.dart';
import '../common/failure_text.dart';
import '../common/goal_picker.dart';
import '../common/privacy_notice.dart';
import 'ai_choice_settings.dart';
import 'settings_controller.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final s = ref.watch(settingsProvider);
    final ctrl = ref.read(settingsProvider.notifier);
    final theme = Theme.of(context);

    Widget section(String title) => Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: theme.textTheme.titleSmall?.copyWith(
          color: theme.colorScheme.primary,
        ),
      ),
    );

    final accountSubtitle = switch (s) {
      SettingsState(signedIn: null) ||
      SettingsState(busy: true) => l10n.settingsChecking,
      SettingsState(model: final m?) => l10n.settingsConnectedModel(m),
      SettingsState(signedIn: false) => l10n.settingsNotConnected,
      _ => null,
    };

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: ListView(
            children: [
              section(l10n.settingsAiSection),
              ListTile(
                leading: const Icon(Icons.chat_bubble_outline),
                title: Text(l10n.settingsChatGpt),
                subtitle: accountSubtitle == null
                    ? null
                    : Text(accountSubtitle),
              ),
              if (s.failure case final f?)
                Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  child: ListTile(
                    leading: const Icon(Icons.error_outline),
                    title: Text(failureText(l10n, f)),
                    trailing: s.signedIn == true
                        ? TextButton(
                            onPressed: s.busy ? null : ctrl.checkConnection,
                            child: Text(l10n.settingsRetry),
                          )
                        : null,
                  ),
                ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: switch (s.signedIn) {
                    true => OutlinedButton(
                      onPressed: s.busy ? null : ctrl.signOut,
                      child: Text(l10n.settingsSignOut),
                    ),
                    false => FilledButton.icon(
                      onPressed: s.busy ? null : ctrl.signIn,
                      icon: const Icon(Icons.login),
                      label: Text(
                        s.busy
                            ? l10n.chatGptLabSigningIn
                            : l10n.chatGptLabSignIn,
                      ),
                    ),
                    null => const SizedBox.shrink(),
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Text(
                  l10n.settingsApiKeyNote,
                  style: theme.textTheme.bodySmall,
                ),
              ),
              const AiChoiceSettings(),
              section(l10n.goalsTitle),
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 4, 16, 8),
                child: GoalPicker(),
              ),
              section(l10n.settingsVoiceSection),
              SwitchListTile(
                secondary: const Icon(Icons.volume_up_outlined),
                title: Text(l10n.chatGptLabSpeakReplies),
                subtitle: Text(l10n.chatGptLabFreeVoiceNote),
                value: s.speakReplies,
                onChanged: ctrl.setSpeakReplies,
              ),
              SwitchListTile(
                secondary: const Icon(Icons.hearing),
                title: Text(l10n.settingsHandsFree),
                subtitle: Text(l10n.settingsHandsFreeNote),
                value: s.handsFree,
                onChanged: ctrl.setHandsFree,
              ),
              SwitchListTile(
                secondary: const Icon(Icons.headphones),
                title: Text(l10n.settingsAutoBargeIn),
                subtitle: Text(l10n.settingsAutoBargeInNote),
                value: s.autoBargeIn,
                onChanged: s.handsFree ? ctrl.setAutoBargeIn : null,
              ),
              SwitchListTile(
                secondary: const Icon(Icons.edit_note),
                title: Text(l10n.settingsConfirmSpeech),
                subtitle: Text(l10n.settingsConfirmSpeechNote),
                value: s.confirmSpeech,
                onChanged: ctrl.setConfirmSpeech,
              ),
              section(l10n.settingsDataSection),
              ListTile(
                leading: const Icon(Icons.download_outlined),
                title: Text(l10n.settingsExport),
                subtitle: Text(
                  s.exportedTo == null
                      ? l10n.settingsExportNote
                      : l10n.settingsExportedTo(s.exportedTo!),
                ),
                onTap: ctrl.exportData,
              ),
              ListTile(
                leading: Icon(
                  Icons.delete_forever_outlined,
                  color: theme.colorScheme.error,
                ),
                title: Text(l10n.settingsDeleteAll),
                subtitle: s.cleared ? Text(l10n.settingsDeleted) : null,
                onTap: () async {
                  final ok = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      content: Text(l10n.settingsDeleteAllConfirm),
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
                  if (ok ?? false) await ctrl.deleteAllData();
                },
              ),
              section(l10n.settingsInfoSection),
              ListTile(
                leading: const Icon(Icons.privacy_tip_outlined),
                title: Text(l10n.settingsPrivacy),
                onTap: () => showDialog<void>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text(l10n.settingsPrivacy),
                    content: const SingleChildScrollView(
                      child: PrivacyNotice(),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(l10n.settingsClose),
                      ),
                    ],
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.bug_report_outlined),
                title: Text(l10n.settingsDiagnostics),
                subtitle: Text(l10n.settingsDiagnosticsNote(s.errorCount)),
                onTap: ctrl.exportDiagnostics,
              ),
              if (s.errorCount > 0)
                Padding(
                  padding: const EdgeInsets.only(left: 56),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton(
                      onPressed: ctrl.clearErrors,
                      child: Text(l10n.settingsDiagnosticsClear),
                    ),
                  ),
                ),
              ListTile(
                leading: const Icon(Icons.description_outlined),
                title: Text(l10n.settingsLicenses),
                onTap: () => showLicensePage(
                  context: context,
                  applicationName: l10n.appTitle,
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
