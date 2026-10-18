import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/l10n/gen/app_localizations.dart';
import '../common/failure_text.dart';
import '../common/goal_picker.dart';
import '../common/privacy_notice.dart';
import 'onboarding_controller.dart';

class OnboardingScreen extends ConsumerWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final s = ref.watch(onboardingProvider);
    final ctrl = ref.read(onboardingProvider.notifier);
    final theme = Theme.of(context);
    final steps = OnboardingStep.values.length;

    final (title, body, actions) = switch (s.step) {
      OnboardingStep.welcome => (
        l10n.onboardingWelcomeTitle,
        <Widget>[Text(l10n.onboardingWelcomeBody)],
        <Widget>[
          FilledButton(onPressed: ctrl.next, child: Text(l10n.onboardingNext)),
        ],
      ),
      OnboardingStep.privacy => (
        l10n.onboardingPrivacyTitle,
        <Widget>[const PrivacyNotice()],
        <Widget>[
          TextButton(onPressed: ctrl.back, child: Text(l10n.onboardingBack)),
          FilledButton(onPressed: ctrl.next, child: Text(l10n.onboardingAgree)),
        ],
      ),
      OnboardingStep.goals => (
        l10n.goalsTitle,
        <Widget>[
          const GoalPicker(),
          const SizedBox(height: 16),
          Text(l10n.goalsNote, style: theme.textTheme.bodySmall),
        ],
        <Widget>[
          TextButton(onPressed: ctrl.back, child: Text(l10n.onboardingBack)),
          FilledButton(onPressed: ctrl.next, child: Text(l10n.onboardingNext)),
        ],
      ),
      OnboardingStep.connect => (
        l10n.onboardingConnectTitle,
        <Widget>[
          Text(l10n.onboardingConnectBody),
          const SizedBox(height: 24),
          Center(
            child: s.signedIn
                ? Chip(
                    avatar: const Icon(Icons.check_circle),
                    label: Text(l10n.onboardingConnected),
                  )
                : FilledButton.icon(
                    onPressed: s.busy ? null : ctrl.signIn,
                    icon: const Icon(Icons.login),
                    label: Text(
                      s.busy ? l10n.chatGptLabSigningIn : l10n.chatGptLabSignIn,
                    ),
                  ),
          ),
          if (s.failure case final f?)
            Card(
              margin: const EdgeInsets.only(top: 16),
              child: ListTile(
                leading: const Icon(Icons.error_outline),
                title: Text(failureText(l10n, f)),
              ),
            ),
          if (!s.signedIn)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Text(
                l10n.onboardingSkipNote,
                style: theme.textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ),
        ],
        <Widget>[
          TextButton(onPressed: ctrl.back, child: Text(l10n.onboardingBack)),
          if (s.signedIn)
            FilledButton(
              onPressed: ctrl.finish,
              child: Text(l10n.onboardingStart),
            )
          else
            OutlinedButton(
              onPressed: s.busy ? null : ctrl.finish,
              child: Text(l10n.onboardingSkip),
            ),
        ],
      ),
    };

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  LinearProgressIndicator(value: (s.step.index + 1) / steps),
                  const SizedBox(height: 32),
                  Text(title, style: theme.textTheme.headlineSmall),
                  const SizedBox(height: 16),
                  Expanded(child: ListView(children: body)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    spacing: 12,
                    children: actions,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
