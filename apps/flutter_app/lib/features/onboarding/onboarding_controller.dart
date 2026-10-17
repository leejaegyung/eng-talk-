import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/onboarding_gate.dart';
import '../../app/providers.dart';
import '../../core/logging/app_logger.dart';
import '../../domain/credentials/provider_account.dart';
import '../../domain/providers/provider_failure.dart';

/// S01, minimal (slice A): what the app does → how data is handled →
/// connect an AI. Mic test and the placement assessment join in slice D.
enum OnboardingStep { welcome, privacy, connect }

final class OnboardingState {
  const OnboardingState({
    this.step = OnboardingStep.welcome,
    this.signedIn = false,
    this.busy = false,
    this.failure,
  });

  final OnboardingStep step;
  final bool signedIn;
  final bool busy;
  final ProviderFailure? failure;

  OnboardingState copyWith({
    OnboardingStep? step,
    bool? signedIn,
    bool? busy,
    ProviderFailure? failure,
  }) => OnboardingState(
    step: step ?? this.step,
    signedIn: signedIn ?? this.signedIn,
    busy: busy ?? this.busy,
    failure: failure,
  );
}

final onboardingProvider =
    NotifierProvider.autoDispose<OnboardingController, OnboardingState>(
      OnboardingController.new,
    );

class OnboardingController extends Notifier<OnboardingState> {
  static const _log = AppLogger('onboarding');

  late ProviderAccount _account;

  @override
  OnboardingState build() {
    _account = ref.watch(chatGptAccountProvider);
    unawaited(_checkAccount());
    return const OnboardingState();
  }

  Future<void> _checkAccount() async {
    final signedIn = await _account.isSignedIn();
    if (ref.mounted && signedIn) state = state.copyWith(signedIn: true);
  }

  void next() {
    final i = state.step.index;
    if (i < OnboardingStep.values.length - 1) {
      state = state.copyWith(step: OnboardingStep.values[i + 1]);
    }
  }

  void back() {
    final i = state.step.index;
    if (i > 0) state = state.copyWith(step: OnboardingStep.values[i - 1]);
  }

  Future<void> signIn() async {
    if (state.busy) return;
    state = state.copyWith(busy: true);
    try {
      await _account.signIn();
      if (ref.mounted) state = state.copyWith(signedIn: true, busy: false);
    } on ProviderException catch (e) {
      _log.warning('sign-in failed: $e');
      if (ref.mounted) state = state.copyWith(busy: false, failure: e.failure);
    }
  }

  /// Used for both "start" and "later": AI can be connected in settings.
  Future<void> finish() => ref.read(onboardingDoneProvider.notifier).complete();
}
