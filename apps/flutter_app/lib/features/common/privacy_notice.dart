import 'package:flutter/material.dart';

import '../../app/l10n/gen/app_localizations.dart';

/// What leaves the device and what's kept (spec §13-1). Shown in onboarding
/// and settings.
class PrivacyNotice extends StatelessWidget {
  const PrivacyNotice({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final (icon, text) in [
          (Icons.chat_outlined, l10n.onboardingPrivacyText),
          (Icons.mic_none, l10n.onboardingPrivacyVoice),
          (Icons.voice_over_off, l10n.onboardingPrivacyNoRecording),
          (Icons.phone_android, l10n.onboardingPrivacyLocal),
          (Icons.lock_outline, l10n.onboardingPrivacyCredentials),
        ])
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(icon),
            title: Text(text),
          ),
      ],
    );
  }
}
