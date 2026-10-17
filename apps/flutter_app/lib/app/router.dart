import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/audio_lab/audio_lab_screen.dart';
import '../features/chatgpt_lab/chatgpt_lab_screen.dart';
import '../features/conversation/conversation_screen.dart';
import '../features/home/home_screen.dart';
import '../features/onboarding/onboarding_screen.dart';
import '../features/settings/settings_screen.dart';
import '../features/voice_lab/voice_lab_screen.dart';
import 'onboarding_gate.dart';

abstract final class AppRoutes {
  static const splash = '/splash';
  static const onboarding = '/onboarding';
  static const home = '/';
  static const settings = '/settings';
  static const conversation = '/conversation';
  static const audioLab = '/lab/audio';
  static const voiceLab = '/lab/voice';
  static const chatGptLab = '/lab/chatgpt';
}

/// Where to go given the onboarding flag; null stays. An unreadable flag
/// shows onboarding again rather than blocking the app.
String? onboardingRedirect(AsyncValue<bool> done, String location) =>
    switch (done) {
      AsyncData(value: true) =>
        location == AppRoutes.splash || location == AppRoutes.onboarding
            ? AppRoutes.home
            : null,
      AsyncData() || AsyncError() =>
        location == AppRoutes.onboarding ? null : AppRoutes.onboarding,
      _ => location == AppRoutes.splash ? null : AppRoutes.splash,
    };

final routerProvider = Provider<GoRouter>((ref) {
  final onboarding = ValueNotifier(ref.read(onboardingDoneProvider));
  ref
    ..listen(onboardingDoneProvider, (_, next) => onboarding.value = next)
    ..onDispose(onboarding.dispose);

  final router = GoRouter(
    initialLocation: AppRoutes.splash,
    refreshListenable: onboarding,
    redirect: (context, state) =>
        onboardingRedirect(onboarding.value, state.matchedLocation),
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) =>
            const Scaffold(body: Center(child: CircularProgressIndicator())),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.conversation,
        builder: (context, state) => const ConversationScreen(),
      ),
      GoRoute(
        path: AppRoutes.settings,
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: AppRoutes.audioLab,
        builder: (context, state) => const AudioLabScreen(),
      ),
      GoRoute(
        path: AppRoutes.voiceLab,
        builder: (context, state) => const VoiceLabScreen(),
      ),
      GoRoute(
        path: AppRoutes.chatGptLab,
        builder: (context, state) => const ChatGptLabScreen(),
      ),
    ],
  );
  ref.onDispose(router.dispose);
  return router;
});
