import '../../../domain/providers/ai_provider.dart';
import '../../../domain/providers/provider_failure.dart';

// The only place model IDs may appear (CLAUDE.md rule 4). Preferences are
// matched against the account's live model list, so retired models fall
// through to the next entry. Re-check against the provider docs on release.

/// Low-latency, non-reasoning chat models first: turn-taking needs a fast
/// first token more than deep reasoning.
const openAiChatPreference = ['gpt-4.1-mini', 'gpt-4o-mini', 'gpt-5-mini'];
const openAiTranscriptionPreference = [
  'gpt-4o-mini-transcribe',
  'gpt-4o-transcribe',
  'whisper-1',
];
const openAiSpeechPreference = ['gpt-4o-mini-tts', 'tts-1'];
const openAiDefaultVoice = 'alloy';

ModelSelection selectOpenAiModels(Iterable<String> available) {
  final ids = available.toSet();
  String pick(List<String> preference) => preference.firstWhere(
    ids.contains,
    orElse: () =>
        throw const ProviderException(ProviderFailure.modelUnavailable),
  );
  return ModelSelection(
    chat: pick(openAiChatPreference),
    transcription: pick(openAiTranscriptionPreference),
    speech: pick(openAiSpeechPreference),
  );
}
