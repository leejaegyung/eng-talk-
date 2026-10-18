// One-time ChatGPT sign-in for the real-model evaluation:
//   dart run tool/eval/sign_in.dart
// Opens the browser; tokens go to ~/.config/speaking-coach-eval (0600).
import 'dart:io';

import 'package:speaking_coach/domain/providers/provider_failure.dart';

import 'backend.dart';

Future<void> main(List<String> args) async {
  final auth = evalAuth();
  if (args.contains('--sign-out')) {
    await auth.signOut();
    stdout.writeln('Signed out.');
    return;
  }
  if (await auth.isSignedIn()) {
    stdout.writeln('Already signed in.');
    return;
  }
  stdout.writeln('Opening the browser for ChatGPT sign-in (15 min)…');
  try {
    await auth.signIn();
  } on ProviderException catch (e) {
    stderr.writeln('Sign-in failed: $e. Run this again.');
    exit(1);
  }
  stdout.writeln('Signed in. Run: flutter test tool/eval');
  exit(0);
}
