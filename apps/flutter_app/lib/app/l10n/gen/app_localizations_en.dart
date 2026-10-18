// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'AI English Speaking Coach';

  @override
  String get homeHeadline => 'Ready to speak English today?';

  @override
  String get homeStartButton => 'Start conversation';

  @override
  String get homeAudioLab => 'Audio test (dev)';

  @override
  String get audioLabTitle => 'Audio test';

  @override
  String get audioLabHint =>
      'Press Record, say a few words in English, then Stop and Play. The recording stays in memory and is discarded when you leave this screen.';

  @override
  String get audioLabRecord => 'Record';

  @override
  String get audioLabStop => 'Stop';

  @override
  String get audioLabPlay => 'Play back';

  @override
  String audioLabLevel(String db) {
    return 'Input level $db dBFS';
  }

  @override
  String get audioLabSpeaking => 'Speaking';

  @override
  String get audioLabSilent => 'Silent';

  @override
  String audioLabSpeechTotal(String seconds) {
    return 'Detected speech ${seconds}s';
  }

  @override
  String audioLabRecorded(String seconds) {
    return 'Recorded ${seconds}s';
  }

  @override
  String get audioLabMicDenied =>
      'Microphone access is off, so voice mode is unavailable. Allow the microphone in system settings, or continue by text.';

  @override
  String get audioLabFailed =>
      'Couldn\'t open the audio device. Check that a microphone is connected.';

  @override
  String get audioLabNoSignal =>
      'No microphone signal. Check that the laptop lid is open and the input device isn\'t muted.';

  @override
  String get homeVoiceLab => 'Voice chat test (dev)';

  @override
  String get voiceLabTitle => 'Voice chat test';

  @override
  String get voiceLabKeyTitle => 'OpenAI API key';

  @override
  String get voiceLabKeyHint =>
      'The key is kept only in this device\'s secure storage (e.g. Keychain) and is sent only to OpenAI. Usage is billed to your own OpenAI account.';

  @override
  String get voiceLabKeyField => 'Key starting with sk-';

  @override
  String get voiceLabKeySave => 'Save';

  @override
  String get voiceLabKeyStored => 'Key saved';

  @override
  String get voiceLabKeyDelete => 'Delete key';

  @override
  String get voiceLabTest => 'Test connection';

  @override
  String get voiceLabChecking => 'Checking…';

  @override
  String voiceLabModels(String chat, String stt, String tts) {
    return 'Models — chat: $chat · speech-to-text: $stt · text-to-speech: $tts';
  }

  @override
  String get voiceLabTalk => 'Speak';

  @override
  String get voiceLabStopListening => 'Done';

  @override
  String get voiceLabPhaseListening =>
      'Listening… it sends when you stop talking';

  @override
  String get voiceLabPhaseTranscribing => 'Transcribing…';

  @override
  String get voiceLabPhaseThinking => 'Thinking…';

  @override
  String get voiceLabPhaseSpeaking => 'Speaking…';

  @override
  String voiceLabHeard(String text) {
    return 'You: $text';
  }

  @override
  String voiceLabReply(String text) {
    return 'AI: $text';
  }

  @override
  String voiceLabRunsTitle(int count) {
    return 'Measurements ($count)';
  }

  @override
  String voiceLabRunRow(int n, int stt, int token, int tts, int total) {
    return '#$n STT $stt · first token $token · TTS first byte $tts · total $total (ms)';
  }

  @override
  String voiceLabStats(String stt, String token, String tts, String total) {
    return 'p50 / p95 — STT $stt · first token $token · TTS first byte $tts · total $total (ms)';
  }

  @override
  String voiceLabUsage(int input, int output, String seconds, int chars) {
    return 'Measured usage — input tokens $input · output tokens $output · audio uploaded ${seconds}s · characters synthesized $chars';
  }

  @override
  String get failureInvalidKey =>
      'The API key is not valid. Check it and enter it again.';

  @override
  String get failureInsufficientQuota =>
      'Your API account is out of credit. Check whether you went over the free usage.';

  @override
  String get failureRateLimited =>
      'Too many requests. Please try again shortly.';

  @override
  String get failureModelUnavailable =>
      'A required model isn\'t available on this account.';

  @override
  String get failureNetwork =>
      'Can\'t reach the network. Check your internet connection.';

  @override
  String get failureUnknown =>
      'Something went wrong. Please try again shortly.';

  @override
  String get failureSignInRequired => 'Please sign in with ChatGPT again.';

  @override
  String get failurePlanUsageLimit =>
      'You\'ve reached your ChatGPT plan\'s usage limit. Check ChatGPT Settings → Usage.';

  @override
  String get failurePlanNotEligible =>
      'This ChatGPT account can\'t use its plan in apps (Plus or Pro required).';

  @override
  String get homeChatGptLab => 'ChatGPT chat test (uses your plan)';

  @override
  String get chatGptLabTitle => 'ChatGPT chat test';

  @override
  String get chatGptLabIntro =>
      'Uses GPT through your ChatGPT Plus/Pro plan. No API key or extra charges — it runs within your plan\'s usage limits.';

  @override
  String get chatGptLabSignIn => 'Sign in with ChatGPT';

  @override
  String get chatGptLabSigningIn => 'Finish signing in in your browser…';

  @override
  String get chatGptLabSignOut => 'Sign out';

  @override
  String chatGptLabSignedIn(String model) {
    return 'Connected to ChatGPT · model $model';
  }

  @override
  String get chatGptLabInput => 'Type something in English';

  @override
  String get chatGptLabSend => 'Send';

  @override
  String chatGptLabStats(int p50, int p95, int count, int input, int output) {
    return 'Measured — first token p50 ${p50}ms · p95 ${p95}ms ($count) · tokens in $input / out $output';
  }

  @override
  String get chatGptLabSpeakReplies => 'Read replies aloud';

  @override
  String get chatGptLabTalk => 'Speak';

  @override
  String get chatGptLabListening => 'Listening… it sends when you stop talking';

  @override
  String get chatGptLabSpeaking => 'Speaking…';

  @override
  String get chatGptLabSpeechUnavailable =>
      'Speech recognition isn\'t available on this device. Allow speech recognition and microphone access in system settings, or type instead.';

  @override
  String get chatGptLabFreeVoiceNote =>
      'Speech recognition and read-aloud use your device\'s free built-in features.';

  @override
  String get onboardingWelcomeTitle =>
      'An English coach you learn with by talking';

  @override
  String get onboardingWelcomeBody =>
      'The AI asks short questions and you do most of the talking.\nIt won\'t interrupt you for mistakes — you get corrections after the conversation.';

  @override
  String get onboardingNext => 'Next';

  @override
  String get onboardingBack => 'Back';

  @override
  String get onboardingPrivacyTitle => 'How your data is handled';

  @override
  String get onboardingPrivacyText =>
      'What you say (as text) is sent to the AI you choose to generate replies. The ChatGPT plan follows OpenAI\'s policies; with a free Gemini key, Google may use conversations to improve its products.';

  @override
  String get onboardingPrivacyVoice =>
      'Speech is recognized by your device by default (it may be processed on Apple, Google or Microsoft servers). If you pick \'Gemini\' in settings, your recording is sent to Google Gemini for transcription. Recordings are never kept.';

  @override
  String get onboardingPrivacyNoRecording => 'Raw recordings are never saved.';

  @override
  String get onboardingPrivacyLocal =>
      'Conversation history stays on this device.';

  @override
  String get onboardingPrivacyCredentials =>
      'Sign-in tokens and API keys are kept only in your device\'s secure storage.';

  @override
  String get onboardingAgree => 'Got it';

  @override
  String get onboardingConnectTitle => 'Connect an AI';

  @override
  String get onboardingConnectBody =>
      'With a ChatGPT Plus/Pro plan there\'s no extra charge — usage counts toward your plan\'s limits.';

  @override
  String get onboardingConnected => 'Connected';

  @override
  String get onboardingSkip => 'Later';

  @override
  String get onboardingSkipNote =>
      'Until you connect, you can only look around.';

  @override
  String get onboardingStart => 'Get started';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsAiSection => 'AI connection';

  @override
  String get settingsChatGpt => 'ChatGPT plan';

  @override
  String get settingsNotConnected =>
      'Not connected — sign in to talk at no extra charge';

  @override
  String settingsConnectedModel(String model) {
    return 'Connected · model $model (picked automatically)';
  }

  @override
  String get settingsChecking => 'Checking connection…';

  @override
  String get settingsRetry => 'Check again';

  @override
  String get settingsSignOut => 'Sign out';

  @override
  String get settingsApiKeyNote =>
      'The ChatGPT plan has no extra charge. Gemini works with a free API key from Google AI Studio.';

  @override
  String get settingsVoiceSection => 'Voice';

  @override
  String get settingsInfoSection => 'About';

  @override
  String get settingsPrivacy => 'How your data is handled';

  @override
  String get settingsLicenses => 'Open-source licenses';

  @override
  String get settingsClose => 'Close';

  @override
  String get homeSettings => 'Settings';

  @override
  String get conversationModeDaily => 'Daily talk';

  @override
  String conversationTitle(String mode, String level) {
    return '$mode · $level';
  }

  @override
  String get conversationEnd => 'End';

  @override
  String get conversationConnecting => 'Connecting…';

  @override
  String get conversationListening => 'Listening… sends when you pause';

  @override
  String get conversationThinking => 'Thinking…';

  @override
  String get conversationAiSpeaking => 'AI is speaking — tap 🎤 to cut in';

  @override
  String get conversationYourTurn => 'Your turn — tap 🎤 and speak';

  @override
  String get conversationHint => 'Hint';

  @override
  String get conversationRepeat => 'Say again';

  @override
  String get conversationSlower => 'Slower';

  @override
  String get conversationCorrect => 'Correct this';

  @override
  String get conversationChangeTopic => 'New topic';

  @override
  String get conversationHintSuggestion => 'Stuck? Try a hint.';

  @override
  String get conversationSubtitlesHidden =>
      'Subtitles hidden — focus on listening and speaking.';

  @override
  String get conversationShowSubtitles => 'Show subtitles';

  @override
  String get conversationHideSubtitles => 'Hide subtitles';

  @override
  String get conversationInput => 'You can also type in English';

  @override
  String get conversationSend => 'Send';

  @override
  String get conversationNeedsConnection => 'Connect an AI to start talking.';

  @override
  String get conversationOpenSettings => 'Connect in Settings';

  @override
  String get conversationBackHome => 'Home';

  @override
  String get modeTheme => 'Theme talk';

  @override
  String get modeRoleplay => 'Role-play';

  @override
  String get modeRandom => 'Random speaking';

  @override
  String get modeStorytelling => 'Storytelling';

  @override
  String get modeOpinion => 'Opinions';

  @override
  String get modeAssessment => 'Placement';

  @override
  String get modeDailyDesc => 'Chat about your day, hobbies and experiences';

  @override
  String get modeThemeDesc => 'Go deep on one topic you pick';

  @override
  String get modeRoleplayDesc =>
      'Act out situations like hotels, restaurants, interviews';

  @override
  String get modeRandomDesc => 'Answer unexpected questions on the spot';

  @override
  String get modeStorytellingDesc => 'Tell a story from start to finish';

  @override
  String get modeOpinionDesc => 'Give opinions with reasons and examples';

  @override
  String get conversationPaused => 'Paused';

  @override
  String get conversationPause => 'Pause';

  @override
  String get conversationResume => 'Resume';

  @override
  String get conversationConnectionLost =>
      'Connection lost. Your conversation is saved.';

  @override
  String get conversationReconnect => 'Reconnect';

  @override
  String get conversationContinueText => 'Continue without voice';

  @override
  String get conversationSaveAndEnd => 'Save and end';

  @override
  String get conversationSaving => 'Saving…';

  @override
  String get resultTitle => 'Session result';

  @override
  String get resultPracticeTime => 'Practice time';

  @override
  String get resultAnswers => 'Your answers';

  @override
  String resultAnswerCount(int count) {
    return '$count';
  }

  @override
  String resultMinSec(int minutes, int seconds) {
    return '${minutes}m ${seconds}s';
  }

  @override
  String get resultUserSpeech => 'Your speaking (est.)';

  @override
  String get resultAiSpeech => 'AI speaking (est.)';

  @override
  String get resultRatio => 'Your share of speaking';

  @override
  String resultRatioValue(String percent) {
    return '$percent% (speaking time only)';
  }

  @override
  String get resultEstimateNote =>
      'Estimated from speech-recognition timing; may differ from reality.';

  @override
  String get resultNotMeasured =>
      'Speaking time is estimated only when you talk with 🎤 and replies are read aloud.';

  @override
  String get resultGenerating => 'Making feedback from your conversation…';

  @override
  String get resultRetry => 'Try again';

  @override
  String get resultReduced => 'Feedback could only be partly generated.';

  @override
  String get resultNoAnswers => 'No answers, so no feedback was made.';

  @override
  String get resultStrengths => 'Strengths';

  @override
  String get resultCorrections => 'Sentences to fix';

  @override
  String get resultNoCorrections => 'Nothing important to fix this time.';

  @override
  String get resultSayAgain => 'Say it again';

  @override
  String resultYouSaid(String text) {
    return 'You said: $text';
  }

  @override
  String get resultListening => 'Listening…';

  @override
  String get resultExpressions => 'Expressions to try';

  @override
  String get resultNextTopic => 'Next topic';

  @override
  String get resultTalkAboutIt => 'Talk about this';

  @override
  String get resultReviewNote => 'Corrections were added to your review list.';

  @override
  String get setupTitle => 'Set up a conversation';

  @override
  String get setupMode => 'Mode';

  @override
  String get setupLevel => 'Level';

  @override
  String get setupLevelNote =>
      'L1 basics · L2 familiar talk · L3 situations · L4 opinions · L5 free talk';

  @override
  String get setupTopic => 'Topic';

  @override
  String get setupTopicOptional => 'Topic (optional)';

  @override
  String get setupTopicHint => 'Or type your own';

  @override
  String get setupRandomNote =>
      'In random mode the AI asks impromptu questions on varied topics.';

  @override
  String get setupScenario => 'Situation';

  @override
  String get setupRole => 'AI\'s role';

  @override
  String get setupSituation => 'Situation';

  @override
  String get setupGoal => 'Your goal';

  @override
  String get setupLength => 'Length';

  @override
  String setupMinutes(int minutes) {
    return '$minutes min';
  }

  @override
  String get setupStart => 'Start';

  @override
  String get assessmentTitle => 'Placement';

  @override
  String get assessmentIntro =>
      'Answer five questions in English and we\'ll suggest a starting level. About 5 minutes.';

  @override
  String get assessmentLimit =>
      'A short test has limited accuracy. You can change your level any time.';

  @override
  String get assessmentMicCheck =>
      'Mic check: tap 🎤 and say \"Hello, nice to meet you\".';

  @override
  String assessmentMicHeard(String text) {
    return 'Heard: $text';
  }

  @override
  String get assessmentMicNothing =>
      'Nothing was heard. Check mic and speech permissions, or type your answers.';

  @override
  String assessmentQuestion(int n, int total) {
    return 'Question $n of $total';
  }

  @override
  String get assessmentAnswerHint => 'Speak with 🎤 or type in English';

  @override
  String get assessmentNext => 'Next';

  @override
  String get assessmentFinish => 'See result';

  @override
  String get assessmentEvaluating => 'Evaluating your answers…';

  @override
  String assessmentSuggested(String level) {
    return 'Suggested level: $level';
  }

  @override
  String get assessmentRubricNote =>
      'The AI judged only the text of your answers — not pronunciation or fluency.';

  @override
  String get assessmentRelevance => 'Relevance';

  @override
  String get assessmentSentences => 'Sentence formation';

  @override
  String get assessmentVocabulary => 'Vocabulary';

  @override
  String get assessmentContinuity => 'Continuity';

  @override
  String assessmentScore(int score) {
    return '$score / 5';
  }

  @override
  String get assessmentGradingFailed =>
      'Couldn\'t read the evaluation. Please choose a level yourself.';

  @override
  String get assessmentPick => 'Or pick another level';

  @override
  String get assessmentAccept => 'Start with this level';

  @override
  String get assessmentDone => 'Level saved.';

  @override
  String get historyTitle => 'History';

  @override
  String get historySearch => 'Search topics or conversations';

  @override
  String get historyEmpty => 'No sessions yet.';

  @override
  String get historyNoMatch => 'No matches.';

  @override
  String historyAnswers(int count) {
    return '$count answers';
  }

  @override
  String get historyUnfinished => 'In progress';

  @override
  String get historyDelete => 'Delete';

  @override
  String get historyDeleteConfirm =>
      'Delete this session? Its corrections and review items are deleted too.';

  @override
  String get cancel => 'Cancel';

  @override
  String get reviewTitle => 'Review';

  @override
  String get reviewEmpty =>
      'Nothing to review now. Corrections from your sessions show up here.';

  @override
  String get reviewIntro => 'Say your corrected sentences out loud again.';

  @override
  String get reviewDone => 'I said it';

  @override
  String get reviewLater => 'Later';

  @override
  String get homeHistory => 'History';

  @override
  String get homeUnfinished => 'You have an unfinished conversation';

  @override
  String get homeResume => 'Continue';

  @override
  String get homeCloseAndSee => 'End and see result';

  @override
  String get homePlacementTitle => 'Start with a placement?';

  @override
  String get homePlacementBody =>
      'Five questions to suggest your starting level (about 5 min).';

  @override
  String get homePlacementStart => 'Start placement';

  @override
  String get homeToday => 'Spoken today (est.)';

  @override
  String get homeWeek => 'Last 7 days (est.)';

  @override
  String get homeStreak => 'Streak';

  @override
  String homeStreakDays(int days) {
    return '$days days';
  }

  @override
  String get homeCompleted => 'Completed';

  @override
  String homeCompletedValue(int count, int percent) {
    return '$count · $percent% done';
  }

  @override
  String get homeAvgAnswer => 'Average answer';

  @override
  String homeAvgWords(String words) {
    return '$words words';
  }

  @override
  String get homeReviews => 'To review';

  @override
  String homeReviewCount(int count) {
    return '$count';
  }

  @override
  String get homeNoData => '—';

  @override
  String get homeSpeechNote =>
      'Speaking time is estimated from speech-recognition timing when you talk with 🎤.';

  @override
  String homeNextTopic(String topic) {
    return 'Suggested topic: $topic';
  }

  @override
  String get homeDevTools => 'Developer tests';

  @override
  String get homePlacementAgain => 'Retake placement';

  @override
  String get settingsDataSection => 'Data';

  @override
  String get settingsExport => 'Export history (JSON, CSV)';

  @override
  String get settingsExportNote =>
      'Also works as a backup (JSON). Sign-in details and API keys are not included.';

  @override
  String settingsExportedTo(String path) {
    return 'Saved to: $path';
  }

  @override
  String get settingsDeleteAll => 'Delete all history';

  @override
  String get settingsDeleteAllConfirm =>
      'Delete all conversations, corrections, reviews and placements? This can\'t be undone. (Sign-in and settings are kept.)';

  @override
  String get settingsDeleted => 'All history deleted.';

  @override
  String get conversationPausedInBackground =>
      'Paused while you were away.\nTap resume when you\'re ready.';

  @override
  String get goalsTitle => 'Your goals';

  @override
  String get goalsWhy => 'Why do you practice speaking?';

  @override
  String get goalEveryday => 'Everyday talk';

  @override
  String get goalTravel => 'Travel';

  @override
  String get goalWork => 'Work & meetings';

  @override
  String get goalInterview => 'Interviews';

  @override
  String get goalConfidence => 'Confidence';

  @override
  String get goalsDaily => 'Daily target';

  @override
  String goalsMinutes(int minutes) {
    return '$minutes min';
  }

  @override
  String get goalsNote =>
      'We suggest a mode and session length that fit. You can change these in settings anytime.';

  @override
  String homeGoalProgress(int done, int goal) {
    return 'Today $done / $goal min';
  }

  @override
  String get homeGoalDone => 'Today\'s goal reached!';

  @override
  String homeSuggestedMode(String goal, String mode) {
    return 'For $goal: $mode';
  }

  @override
  String get homeGrowth => 'Progress';

  @override
  String get growthPeriodWeek => '7 days';

  @override
  String get growthPeriodMonth => '30 days';

  @override
  String get growthPractice => 'Practice time';

  @override
  String get growthSpeech => 'Speaking time (est.)';

  @override
  String get growthSessions => 'Sessions';

  @override
  String growthSessionCount(int count) {
    return '$count';
  }

  @override
  String get growthDaily => 'Practice by day';

  @override
  String growthDayBar(String date, int minutes) {
    return '$date · $minutes min';
  }

  @override
  String get growthEmpty => 'No finished sessions in this period.';

  @override
  String get growthWeakAreas => 'Most corrected';

  @override
  String get growthWeakNote =>
      'Based on how post-session feedback classified corrections. Pronunciation is not assessed.';

  @override
  String get growthNoWeak =>
      'No classified corrections yet. They build up as you finish sessions and open the results.';

  @override
  String get growthLevels => 'Level history';

  @override
  String get growthNoLevels => 'No placement results yet.';

  @override
  String get categoryGrammar => 'Grammar (tense, articles, prepositions)';

  @override
  String get categoryWordChoice => 'Word choice';

  @override
  String get categoryStructure => 'Sentence structure';

  @override
  String get categoryNaturalness => 'Natural phrasing';

  @override
  String get handsFreeOn => 'Auto-listen on (turn off)';

  @override
  String get handsFreeOff => 'Auto-listen off (turn on)';

  @override
  String get settingsHandsFree => 'Auto-listen (hands-free)';

  @override
  String get settingsHandsFreeNote =>
      'Listens as soon as the AI finishes, without tapping 🎤. Stops after two silent tries.';

  @override
  String get conversationDraftHelp =>
      'This is what was heard. Fix it if needed, then tap send.';

  @override
  String get settingsConfirmSpeech => 'Check speech before sending';

  @override
  String get settingsConfirmSpeechNote =>
      'Recognized speech goes to the input box first so you can fix misheard words. Conversation gets a little slower.';

  @override
  String get reviewExpressions => 'Recent expressions';

  @override
  String get reviewExpressionsIntro =>
      'Say a sentence using each one. Your coach will also give you chances to use them in your next conversation.';

  @override
  String get reviewUseExpression => 'Use it';

  @override
  String get reviewExpressionUsed => 'You used it';

  @override
  String get reviewExpressionMissing =>
      'Didn\'t hear the expression. Try again?';

  @override
  String a11yYouSaid(String text) {
    return 'You: $text';
  }

  @override
  String a11yCoachSaid(String text) {
    return 'Coach: $text';
  }

  @override
  String get a11yStopListening => 'Stop listening';

  @override
  String get speechUnavailableTitle =>
      'Microphone or speech recognition isn\'t available';

  @override
  String get speechUnavailableBody =>
      'Turn on microphone and speech recognition for this app in settings. Meanwhile you can type.';

  @override
  String get speechOpenSettings => 'Open settings';

  @override
  String get speechIssueNetwork =>
      'Can\'t reach the speech recognition service. Check the internet or keep going by typing.';

  @override
  String get speechIssueAudio =>
      'No sound from the microphone. Check your earphones or mic, then tap 🎤.';

  @override
  String get speechIssueBusy =>
      'Another app is using speech recognition. Tap 🎤 again in a moment.';

  @override
  String get speechIssueOther =>
      'Speech recognition stopped. Tap 🎤 again or type.';

  @override
  String get aiChoiceChatGpt => 'ChatGPT';

  @override
  String get aiChoiceLabel => 'AI for coaching';

  @override
  String get aiChoiceGemini => 'Gemini (free key)';

  @override
  String get geminiKeyLabel => 'Gemini API key';

  @override
  String get geminiKeySave => 'Save and check';

  @override
  String get geminiKeyRemove => 'Remove key';

  @override
  String get geminiNoKey =>
      'No key yet. Paste a free API key from aistudio.google.com (no billing needed).';

  @override
  String get geminiKeyStored =>
      'The key stays in this device\'s secure storage. Checking only lists models.';

  @override
  String get geminiFreeTier =>
      'No charge within the free usage. On Google\'s free tier, conversations are used to improve Google\'s products and may be read by people, so don\'t share personal information. Heavy use can be paused for a while.';

  @override
  String get geminiChosenNoKey =>
      'Gemini is selected but there\'s no key. Add one to start conversations.';

  @override
  String get settingsAutoBargeIn => 'Talk over the AI to interrupt (earphones)';

  @override
  String get settingsAutoBargeInNote =>
      'With auto-listen on, it also listens while the AI speaks. On speakers the AI\'s own voice can be heard as yours, so turn this on only with earphones.';

  @override
  String get settingsDiagnostics => 'Export diagnostics';

  @override
  String settingsDiagnosticsNote(int count) {
    return 'Saves the app\'s error log ($count recent) to a file, without conversations or keys. Attach it when reporting a problem.';
  }

  @override
  String get settingsDiagnosticsClear => 'Clear error log';

  @override
  String get languageLabel => 'Language';

  @override
  String get languageSystem => 'Device';

  @override
  String get languageKo => '한국어';

  @override
  String get languageEn => 'English';

  @override
  String get settingsRestore => 'Restore from a backup';

  @override
  String get settingsRestoreNote =>
      'Pick an exported speaking-coach.json to bring back history, reviews and goals. Conversations already here are skipped.';

  @override
  String settingsRestored(int added, int skipped) {
    return 'Restored $added conversations ($skipped already here were skipped)';
  }

  @override
  String get settingsRestoreFailed =>
      'That isn\'t a Speaking Coach backup. Pick the speaking-coach.json made by export.';

  @override
  String get speechAndroidTip =>
      'If what\'s heard keeps coming out wrong: phone Settings → General → Keyboard list and default (or \'Voice input\') → set the default speech recognition service to \'Google\', and make sure English (US) is downloaded for it.';

  @override
  String get assessmentKeepTalking =>
      'It keeps listening through short pauses. Tap ■ when you\'re done.';

  @override
  String get pasteTitle => 'Finish ChatGPT sign-in';

  @override
  String get pasteSteps =>
      '1. Sign in to ChatGPT in the new tab.\n2. When it ends on a \'can\'t connect\' page, that\'s expected.\n3. Copy that page\'s full address (http://127.0.0.1:1455/auth/callback?code=…) and paste it below.';

  @override
  String get pasteLabel => 'Paste the address';

  @override
  String get pasteInvalid =>
      'That\'s not the sign-in address. Paste the full address starting with 127.0.0.1.';

  @override
  String get pasteConfirm => 'Continue';

  @override
  String get speechUnavailableWeb =>
      'Speech recognition isn\'t available in this browser. Open it in Safari on iPhone/iPad or the latest Chrome elsewhere, and allow the microphone. Meanwhile you can type.';

  @override
  String get setupAiTopic => '🎲 Random (AI picks)';

  @override
  String get setupAiScenario => '🎲 Random scenario (AI picks)';

  @override
  String get setupAiTopicNote =>
      'When you start, the AI picks a different topic each time and tells you in its first line.';

  @override
  String get setupAiScenarioNote =>
      'The AI makes up the situation and its role and tells you in its first line.';

  @override
  String get resultWordOrder => 'Word order';

  @override
  String resultWordOrderSummary(int total, int ok) {
    return '$ok of $total sentences had natural word order';
  }

  @override
  String get resultWordOrderOk => 'Natural order';

  @override
  String get resultWordOrderWrong => 'Order needs work';

  @override
  String get resultWordOrderNote =>
      'Sentences with the wrong order come back in review to say in the right order. Tense and pronunciation aren\'t judged here.';

  @override
  String get reviewKindWordOrder => 'Word order';

  @override
  String get practiceMatched => 'You said it as corrected';

  @override
  String get practiceDiffers =>
      'A little different. Look at the corrected sentence and try again?';

  @override
  String get settingsReviewSection => 'Review';

  @override
  String get settingsReviewRepeats => 'Repetitions per sentence';

  @override
  String get settingsReviewRepeatsNote =>
      'A box fills each time you say the corrected sentence. You can also tick boxes yourself if recognition gets it wrong.';

  @override
  String settingsRepeatTimes(int count) {
    return '$count×';
  }

  @override
  String reviewRepeatProgress(int done, int total) {
    return 'Repeated $done/$total';
  }

  @override
  String get reviewRepeatDone => 'All repetitions done!';

  @override
  String reviewRepeatBox(int n) {
    return 'Repetition $n';
  }

  @override
  String get speechEngineLabel => 'Speech recognition';

  @override
  String get speechEngineDevice => 'On device';

  @override
  String get speechEngineGemini => 'Gemini (accurate)';

  @override
  String get speechEngineGeminiNote =>
      'When you finish, Gemini transcribes the recording. Much better with names and accents, but takes 1–2 seconds. The recording isn\'t kept; on a free key Google may use it to improve its products.';

  @override
  String get speechEngineNeedsKey =>
      'Gemini recognition needs the free key. Without it, the device recognizer is used.';

  @override
  String get shadowingTitle => 'Shadowing';

  @override
  String get shadowingNote =>
      'Listen to the coach\'s sentences and say them back. A box fills each time you say it word for word.';

  @override
  String get shadowingListen => 'Listen';

  @override
  String get shadowingSlow => 'Slowly';

  @override
  String get shadowingRepeat => 'Say it';

  @override
  String get lessonWriting => 'Writing a lesson from your mistakes…';

  @override
  String get lessonExamples => 'Examples';

  @override
  String get lessonPractice => 'Practice with your sentences';

  @override
  String get lessonPracticeNote =>
      'These are corrections of what you actually said. A box fills when you say one word for word.';

  @override
  String get lessonRewrite => 'Rewrite';

  @override
  String get lessonNoMistakes => 'No corrections of this kind yet.';

  @override
  String get lessonOpen => 'Mini lesson';

  @override
  String get lessonAiNote => 'Written by the AI from your mistakes.';

  @override
  String updateAvailable(String version) {
    return 'A new version is out (v$version)';
  }

  @override
  String get updateInstallNote =>
      'Tap Install on the screen that follows. Your records stay.';

  @override
  String get updateReloadNote => 'Reload to open the new version.';

  @override
  String get updatePageNote =>
      'Get the new installer from the download page and install it over this one.';

  @override
  String get updateInstall => 'Update';

  @override
  String get updateReload => 'Reload';

  @override
  String get updateOpenPage => 'Download page';

  @override
  String get updateLater => 'Later';

  @override
  String updateDownloading(int percent) {
    return 'Downloading… $percent%';
  }

  @override
  String get updateFailed =>
      'Couldn\'t update. Please get it from the download page.';

  @override
  String get settingsVersion => 'App version';

  @override
  String get settingsVersionLocal => 'Development build (no update check)';

  @override
  String get settingsCheckUpdate => 'Check for updates';

  @override
  String settingsUpToDate(String version) {
    return '$version · Up to date';
  }

  @override
  String settingsUpdateUnknown(String version) {
    return '$version · Couldn\'t check. Check your internet connection.';
  }
}
