import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/audio_lab/audio_lab_screen.dart';
import '../features/home/home_screen.dart';
import '../features/voice_lab/voice_lab_screen.dart';

abstract final class AppRoutes {
  static const home = '/';
  static const audioLab = '/lab/audio';
  static const voiceLab = '/lab/voice';
}

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.home,
    routes: [
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.audioLab,
        builder: (context, state) => const AudioLabScreen(),
      ),
      GoRoute(
        path: AppRoutes.voiceLab,
        builder: (context, state) => const VoiceLabScreen(),
      ),
    ],
  );
});
