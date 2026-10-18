import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/providers/provider_failure.dart';

/// Web ChatGPT sign-in: the browser can't receive the loopback redirect, so
/// the learner pastes the address it ended on. The sign-in code waits on
/// [request]; [PastedCallbackPrompt] in the app shows the paste dialog
/// while [pending] is true.
class PastedCallback {
  final pending = ValueNotifier<bool>(false);
  Completer<Map<String, String>>? _waiting;

  Future<Map<String, String>> request() {
    _waiting?.completeError(
      const ProviderException(ProviderFailure.signInRequired),
    );
    final waiting = _waiting = Completer<Map<String, String>>();
    pending.value = true;
    return waiting.future;
  }

  /// Returns false when [query] is null (not a callback address).
  bool submit(Map<String, String>? query) {
    if (query == null) return false;
    _waiting?.complete(query);
    _waiting = null;
    pending.value = false;
    return true;
  }

  void cancel() {
    _waiting?.completeError(
      const ProviderException(ProviderFailure.signInRequired),
    );
    _waiting = null;
    pending.value = false;
  }
}

final pastedCallbackProvider = Provider<PastedCallback>(
  (ref) => PastedCallback(),
);
