import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../app/l10n/gen/app_localizations.dart';
import '../../core/platform/platform_info.dart';
import '../../domain/audio/speech_io.dart';

/// Where the OS lets the learner turn the permission back on, if it has a
/// link for it (macOS privacy pane, iOS app settings).
Uri? _settingsUri() {
  if (PlatformInfo.isMacOS) {
    return Uri.parse(
      'x-apple.systempreferences:com.apple.preference.security'
      '?Privacy_SpeechRecognition',
    );
  }
  if (PlatformInfo.isIOS) return Uri.parse('app-settings:');
  return null;
}

/// Says what went wrong with the microphone or recognizer and what to do
/// (P2-5). [unavailable] is a missing permission; otherwise [issue].
class SpeechProblem extends StatelessWidget {
  const SpeechProblem({super.key, required this.unavailable, this.issue});

  final bool unavailable;
  final SpeechIssue? issue;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final settings = _settingsUri();
    if (unavailable) {
      return Card(
        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
        child: ListTile(
          leading: const Icon(Icons.mic_off),
          title: Text(l10n.speechUnavailableTitle),
          subtitle: Text(l10n.speechUnavailableBody),
          trailing: settings == null
              ? null
              : TextButton(
                  onPressed: () => launchUrl(settings),
                  child: Text(l10n.speechOpenSettings),
                ),
        ),
      );
    }
    final text = switch (issue) {
      SpeechIssue.network => l10n.speechIssueNetwork,
      SpeechIssue.audio => l10n.speechIssueAudio,
      SpeechIssue.busy => l10n.speechIssueBusy,
      SpeechIssue.other => l10n.speechIssueOther,
      SpeechIssue.permission => l10n.speechUnavailableBody,
      SpeechIssue.noSpeech || null => null,
    };
    if (text == null) return const SizedBox.shrink();
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      child: ListTile(
        leading: const Icon(Icons.hearing_disabled),
        title: Text(text),
      ),
    );
  }
}
