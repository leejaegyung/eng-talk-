import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/notifying_session_repository.dart';
import '../../app/providers.dart';
import '../../domain/sessions/session_records.dart';

final historyQueryProvider = NotifierProvider.autoDispose<HistoryQuery, String>(
  HistoryQuery.new,
);

class HistoryQuery extends Notifier<String> {
  @override
  String build() => '';

  // ignore: use_setters_to_change_properties
  void set(String q) => state = q;
}

/// S09: saved sessions, newest first, filtered by topic or transcript.
final historyProvider = FutureProvider.autoDispose<List<SessionSummary>>((ref) {
  ref.watch(dataVersionProvider);
  final query = ref.watch(historyQueryProvider);
  return ref.watch(sessionRepositoryProvider).list(query: query);
});
