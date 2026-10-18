import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'app/providers.dart';
import 'domain/diagnostics/error_journal.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // The web has no app folder: errors are kept for the session only.
  final journal = kIsWeb ? MemoryErrorJournal() : await openErrorJournal();
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
