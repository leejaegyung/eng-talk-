import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/sessions/session_records.dart';

/// What the conversation screen should open: a new session from the setup
/// screen, or an unfinished one to continue (spec §15 Phase 1 recovery).
sealed class ConversationRequest {
  const ConversationRequest();
}

final class NewSession extends ConversationRequest {
  const NewSession(this.setup);

  final SessionSetup setup;
}

final class ResumeSession extends ConversationRequest {
  const ResumeSession(this.sessionId);

  final int sessionId;
}

final conversationRequestProvider =
    NotifierProvider<ConversationRequestNotifier, ConversationRequest>(
      ConversationRequestNotifier.new,
    );

class ConversationRequestNotifier extends Notifier<ConversationRequest> {
  @override
  ConversationRequest build() => const NewSession(SessionSetup());

  // ignore: use_setters_to_change_properties
  void open(ConversationRequest request) => state = request;
}
