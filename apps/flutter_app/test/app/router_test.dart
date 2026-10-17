import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:speaking_coach/app/router.dart';

void main() {
  const done = AsyncData(true);
  const fresh = AsyncData(false);
  const loading = AsyncLoading<bool>();

  test('waits on the splash while the flag loads', () {
    expect(onboardingRedirect(loading, AppRoutes.home), AppRoutes.splash);
    expect(onboardingRedirect(loading, AppRoutes.splash), isNull);
  });

  test('fresh install goes to onboarding from anywhere', () {
    for (final at in [AppRoutes.splash, AppRoutes.home, AppRoutes.chatGptLab]) {
      expect(onboardingRedirect(fresh, at), AppRoutes.onboarding, reason: at);
    }
    expect(onboardingRedirect(fresh, AppRoutes.onboarding), isNull);
  });

  test('onboarded users skip splash and onboarding', () {
    expect(onboardingRedirect(done, AppRoutes.splash), AppRoutes.home);
    expect(onboardingRedirect(done, AppRoutes.onboarding), AppRoutes.home);
    expect(onboardingRedirect(done, AppRoutes.chatGptLab), isNull);
  });

  test('unreadable flag falls back to onboarding', () {
    final error = AsyncError<bool>(Exception('db'), StackTrace.empty);
    expect(onboardingRedirect(error, AppRoutes.home), AppRoutes.onboarding);
  });
}
