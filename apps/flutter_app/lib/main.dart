import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'app/providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final journal = await openErrorJournal();
  // Uncaught errors go to the local journal (never sent anywhere); the
  // learner can export it from settings.
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    unawaited(
      journal.record(details.exception, details.stack, source: 'flutter'),
    );
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    unawaited(journal.record(error, stack, source: 'platform'));
    return false;
  };
  runApp(
    ProviderScope(
      overrides: [errorJournalProvider.overrideWithValue(journal)],
      child: const SpeakingCoachApp(),
    ),
  );
}
