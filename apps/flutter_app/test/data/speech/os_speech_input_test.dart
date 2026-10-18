import 'package:flutter_test/flutter_test.dart';
import 'package:speaking_coach/data/speech/os_speech_input.dart';
import 'package:speaking_coach/domain/audio/speech_io.dart';

void main() {
  test('platform error codes map to what the learner can do', () {
    expect(OsSpeechInput.issueFor('error_no_match'), SpeechIssue.noSpeech);
    expect(
      OsSpeechInput.issueFor('error_speech_timeout'),
      SpeechIssue.noSpeech,
    );
    expect(OsSpeechInput.issueFor('error_permission'), SpeechIssue.permission);
    expect(OsSpeechInput.issueFor('error_network'), SpeechIssue.network);
    expect(
      OsSpeechInput.issueFor('error_server_disconnected'),
      SpeechIssue.network,
    );
    expect(OsSpeechInput.issueFor('error_audio_error'), SpeechIssue.audio);
    expect(OsSpeechInput.issueFor('error_busy'), SpeechIssue.busy);
    expect(OsSpeechInput.issueFor('error_something_new'), SpeechIssue.other);
  });
}
