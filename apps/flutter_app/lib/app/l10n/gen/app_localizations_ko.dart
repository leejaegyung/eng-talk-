// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get appTitle => 'AI 영어 스피킹 코치';

  @override
  String get homeHeadline => '오늘도 영어로 말해볼까요?';

  @override
  String get homeStartButton => '대화 시작';

  @override
  String get homeAudioLab => '오디오 테스트 (개발용)';

  @override
  String get audioLabTitle => '오디오 테스트';

  @override
  String get audioLabHint =>
      '녹음을 누르고 영어로 몇 마디 말한 뒤 정지 → 다시 듣기. 녹음은 메모리에만 있고 이 화면을 나가면 지워져요.';

  @override
  String get audioLabRecord => '녹음';

  @override
  String get audioLabStop => '정지';

  @override
  String get audioLabPlay => '다시 듣기';

  @override
  String audioLabLevel(String db) {
    return '입력 음량 $db dBFS';
  }

  @override
  String get audioLabSpeaking => '말하는 중';

  @override
  String get audioLabSilent => '조용함';

  @override
  String audioLabSpeechTotal(String seconds) {
    return '감지된 발화 시간 $seconds초';
  }

  @override
  String audioLabRecorded(String seconds) {
    return '녹음 길이 $seconds초';
  }

  @override
  String get audioLabMicDenied =>
      '마이크 권한이 없어 음성 모드를 쓸 수 없어요. 시스템 설정에서 마이크를 허용하거나, 텍스트로 대화할 수 있어요.';

  @override
  String get audioLabFailed => '오디오 장치를 열 수 없어요. 마이크 연결을 확인해 주세요.';

  @override
  String get audioLabNoSignal =>
      '마이크 신호가 들어오지 않아요. 맥북 덮개가 닫혀 있거나, 입력 장치가 음소거되었는지 확인해 주세요.';

  @override
  String get homeVoiceLab => '음성 대화 테스트 (개발용)';

  @override
  String get voiceLabTitle => '음성 대화 테스트';

  @override
  String get voiceLabKeyTitle => 'OpenAI API 키';

  @override
  String get voiceLabKeyHint =>
      '키는 이 기기의 보안 저장소(키체인 등)에만 저장되고, OpenAI 외 다른 곳으로 보내지 않아요. 사용량만큼 본인 OpenAI 계정에 과금돼요.';

  @override
  String get voiceLabKeyField => 'sk-로 시작하는 키';

  @override
  String get voiceLabKeySave => '저장';

  @override
  String get voiceLabKeyStored => '키 저장됨';

  @override
  String get voiceLabKeyDelete => '키 삭제';

  @override
  String get voiceLabTest => '연결 테스트';

  @override
  String get voiceLabChecking => '확인 중…';

  @override
  String voiceLabModels(String chat, String stt, String tts) {
    return '사용 모델 — 대화: $chat · 음성 인식: $stt · 음성 합성: $tts';
  }

  @override
  String get voiceLabTalk => '말하기';

  @override
  String get voiceLabStopListening => '말하기 끝';

  @override
  String get voiceLabPhaseListening => '듣는 중… 말을 멈추면 자동으로 보내요';

  @override
  String get voiceLabPhaseTranscribing => '음성 인식 중…';

  @override
  String get voiceLabPhaseThinking => '답변 생성 중…';

  @override
  String get voiceLabPhaseSpeaking => '말하는 중…';

  @override
  String voiceLabHeard(String text) {
    return '내 말: $text';
  }

  @override
  String voiceLabReply(String text) {
    return 'AI: $text';
  }

  @override
  String voiceLabRunsTitle(int count) {
    return '측정 기록 ($count회)';
  }

  @override
  String voiceLabRunRow(int n, int stt, int token, int tts, int total) {
    return '#$n 인식 $stt · 첫 토큰 $token · 음성 첫 바이트 $tts · 전체 $total (ms)';
  }

  @override
  String voiceLabStats(String stt, String token, String tts, String total) {
    return 'p50 / p95 — 인식 $stt · 첫 토큰 $token · 음성 첫 바이트 $tts · 전체 $total (ms)';
  }

  @override
  String voiceLabUsage(int input, int output, String seconds, int chars) {
    return '측정된 사용량 — 입력 토큰 $input · 출력 토큰 $output · 업로드 음성 $seconds초 · 합성 글자 $chars자';
  }

  @override
  String get failureInvalidKey => 'API 키가 올바르지 않아요. 키를 확인하고 다시 입력해 주세요.';

  @override
  String get failureInsufficientQuota =>
      'OpenAI 계정에 사용 가능한 크레딧이 없어요. platform.openai.com의 Billing에서 결제 수단이나 크레딧을 확인해 주세요.';

  @override
  String get failureRateLimited => '요청이 너무 많아요. 잠시 후 다시 시도해 주세요.';

  @override
  String get failureModelUnavailable => '이 계정에서 필요한 모델을 사용할 수 없어요.';

  @override
  String get failureNetwork => '네트워크에 연결할 수 없어요. 인터넷 연결을 확인해 주세요.';

  @override
  String get failureUnknown => '알 수 없는 오류가 발생했어요. 잠시 후 다시 시도해 주세요.';

  @override
  String get failureSignInRequired => 'ChatGPT 로그인이 필요해요. 다시 로그인해 주세요.';

  @override
  String get failurePlanUsageLimit =>
      'ChatGPT 구독의 사용 한도에 도달했어요. ChatGPT 설정 → 사용량에서 확인할 수 있어요.';

  @override
  String get failurePlanNotEligible =>
      '이 ChatGPT 계정은 앱에서 구독을 사용할 수 없어요. (Plus 또는 Pro 구독 필요)';

  @override
  String get homeChatGptLab => 'ChatGPT 대화 테스트 (구독 사용)';

  @override
  String get chatGptLabTitle => 'ChatGPT 대화 테스트';

  @override
  String get chatGptLabIntro =>
      'ChatGPT Plus/Pro 구독으로 GPT를 사용해요. API 키나 추가 요금이 필요 없고, 구독의 사용 한도 안에서 동작해요.';

  @override
  String get chatGptLabSignIn => 'ChatGPT로 로그인';

  @override
  String get chatGptLabSigningIn => '브라우저에서 로그인을 완료해 주세요…';

  @override
  String get chatGptLabSignOut => '로그아웃';

  @override
  String chatGptLabSignedIn(String model) {
    return 'ChatGPT 연결됨 · 모델 $model';
  }

  @override
  String get chatGptLabInput => '영어로 입력해 보세요';

  @override
  String get chatGptLabSend => '보내기';

  @override
  String chatGptLabStats(int p50, int p95, int count, int input, int output) {
    return '측정값 — 첫 토큰 p50 ${p50}ms · p95 ${p95}ms ($count회) · 토큰 입력 $input / 출력 $output';
  }

  @override
  String get chatGptLabSpeakReplies => '답변 소리로 듣기';

  @override
  String get chatGptLabTalk => '말하기';

  @override
  String get chatGptLabListening => '듣는 중… 말을 멈추면 자동으로 보내요';

  @override
  String get chatGptLabSpeaking => '읽어주는 중…';

  @override
  String get chatGptLabSpeechUnavailable =>
      '이 기기에서 음성 인식을 쓸 수 없어요. 시스템 설정에서 음성 인식·마이크 권한을 허용하거나, 글자로 입력해 주세요.';

  @override
  String get chatGptLabFreeVoiceNote => '음성 인식과 읽어주기는 기기에 내장된 무료 기능을 써요.';

  @override
  String get onboardingWelcomeTitle => '말하면서 배우는 영어 코치';

  @override
  String get onboardingWelcomeBody =>
      'AI는 짧게 묻고, 여러분이 길게 말해요.\n대화 중에는 흐름을 끊지 않고, 끝난 뒤에 고칠 점을 모아서 알려드려요.';

  @override
  String get onboardingNext => '다음';

  @override
  String get onboardingBack => '이전';

  @override
  String get onboardingPrivacyTitle => '데이터는 이렇게 다뤄요';

  @override
  String get onboardingPrivacyText =>
      '대화 내용(글자)은 연결한 AI(ChatGPT 등)로 보내져 답변을 만들어요.';

  @override
  String get onboardingPrivacyVoice =>
      '음성 인식은 기기에 내장된 기능을 써요. 기기 설정에 따라 Apple·Google·Microsoft 서버에서 처리될 수 있어요.';

  @override
  String get onboardingPrivacyNoRecording => '녹음 원본은 저장하지 않아요.';

  @override
  String get onboardingPrivacyLocal => '대화 기록은 이 기기에만 저장돼요.';

  @override
  String get onboardingPrivacyCredentials =>
      '로그인 정보와 API 키는 기기의 보안 저장소에만 보관해요.';

  @override
  String get onboardingAgree => '확인했어요';

  @override
  String get onboardingConnectTitle => 'AI 연결';

  @override
  String get onboardingConnectBody =>
      'ChatGPT Plus/Pro 구독이 있으면 추가 요금 없이 쓸 수 있어요. 구독의 사용 한도 안에서 동작해요.';

  @override
  String get onboardingConnected => '연결됐어요';

  @override
  String get onboardingSkip => '나중에 할게요';

  @override
  String get onboardingSkipNote => '연결하기 전에는 화면만 둘러볼 수 있어요.';

  @override
  String get onboardingStart => '시작하기';

  @override
  String get settingsTitle => '설정';

  @override
  String get settingsAiSection => 'AI 연결';

  @override
  String get settingsChatGpt => 'ChatGPT 구독';

  @override
  String get settingsNotConnected => '연결 안 됨 — 로그인하면 추가 요금 없이 대화할 수 있어요';

  @override
  String settingsConnectedModel(String model) {
    return '연결됨 · 모델 $model (자동 선택)';
  }

  @override
  String get settingsChecking => '연결 확인 중…';

  @override
  String get settingsRetry => '다시 확인';

  @override
  String get settingsSignOut => '로그아웃';

  @override
  String get settingsApiKeyNote =>
      'OpenAI API 키(사용량만큼 별도 과금)는 나중에 선택 항목으로 추가돼요.';

  @override
  String get settingsVoiceSection => '음성';

  @override
  String get settingsInfoSection => '정보';

  @override
  String get settingsPrivacy => '데이터 처리 안내';

  @override
  String get settingsLicenses => '오픈소스 라이선스';

  @override
  String get settingsClose => '닫기';

  @override
  String get homeSettings => '설정';

  @override
  String get conversationModeDaily => '일상 대화';

  @override
  String conversationTitle(String mode, String level) {
    return '$mode · $level';
  }

  @override
  String get conversationEnd => '종료';

  @override
  String get conversationConnecting => '연결 중…';

  @override
  String get conversationListening => '듣는 중… 말을 멈추면 보내요';

  @override
  String get conversationThinking => '생각 중…';

  @override
  String get conversationAiSpeaking => 'AI가 말하는 중 — 🎤를 누르면 끊고 말할 수 있어요';

  @override
  String get conversationYourTurn => '내 차례예요. 🎤를 누르고 말해보세요';

  @override
  String get conversationHint => '힌트';

  @override
  String get conversationRepeat => '다시 말해줘';

  @override
  String get conversationSlower => '천천히';

  @override
  String get conversationCorrect => '이 문장 교정';

  @override
  String get conversationChangeTopic => '주제 변경';

  @override
  String get conversationHintSuggestion => '막히셨나요? 힌트를 눌러보세요.';

  @override
  String get conversationSubtitlesHidden => '자막을 숨겼어요. 듣고 말하는 데 집중해 보세요.';

  @override
  String get conversationShowSubtitles => '자막 보기';

  @override
  String get conversationHideSubtitles => '자막 숨기기';

  @override
  String get conversationInput => '영어로 입력해도 돼요';

  @override
  String get conversationSend => '보내기';

  @override
  String get conversationNeedsConnection => '대화하려면 AI 연결이 필요해요.';

  @override
  String get conversationOpenSettings => '설정에서 연결하기';

  @override
  String get conversationBackHome => '홈으로';

  @override
  String get modeTheme => '테마 대화';

  @override
  String get modeRoleplay => '상황 역할극';

  @override
  String get modeRandom => '랜덤 스피킹';

  @override
  String get modeStorytelling => '경험·이야기';

  @override
  String get modeOpinion => '의견·토론';

  @override
  String get modeAssessment => '레벨 진단';

  @override
  String get modeDailyDesc => '하루·취미·경험을 친구처럼 이야기해요';

  @override
  String get modeThemeDesc => '고른 주제 하나를 깊게 파고들어요';

  @override
  String get modeRoleplayDesc => '호텔·식당·면접 같은 상황을 연기해요';

  @override
  String get modeRandomDesc => '예상 못 한 질문에 바로 답해봐요';

  @override
  String get modeStorytellingDesc => '경험을 처음부터 끝까지 길게 말해요';

  @override
  String get modeOpinionDesc => '주장 → 이유 → 예시로 의견을 말해요';

  @override
  String get conversationPaused => '일시정지했어요';

  @override
  String get conversationPause => '일시정지';

  @override
  String get conversationResume => '이어하기';

  @override
  String get conversationConnectionLost => '연결이 끊겼어요. 대화는 저장돼 있어요.';

  @override
  String get conversationReconnect => '다시 연결';

  @override
  String get conversationContinueText => '읽어주기 없이 계속';

  @override
  String get conversationSaveAndEnd => '저장하고 끝내기';

  @override
  String get conversationSaving => '저장 중…';

  @override
  String get resultTitle => '대화 결과';

  @override
  String get resultPracticeTime => '연습 시간';

  @override
  String get resultAnswers => '내 답변';

  @override
  String resultAnswerCount(int count) {
    return '$count회';
  }

  @override
  String resultMinSec(int minutes, int seconds) {
    return '$minutes분 $seconds초';
  }

  @override
  String get resultUserSpeech => '내 발화 (추정)';

  @override
  String get resultAiSpeech => 'AI 발화 (추정)';

  @override
  String get resultRatio => '내 발화 비율';

  @override
  String resultRatioValue(String percent) {
    return '$percent% (발화 시간만 기준)';
  }

  @override
  String get resultEstimateNote => '음성 인식 타이밍으로 추정한 값이라 실제와 차이가 있을 수 있어요.';

  @override
  String get resultNotMeasured => '발화 시간은 🎤로 말하고 \'답변 소리로 듣기\'를 켰을 때만 추정해요.';

  @override
  String get resultGenerating => '대화 내용으로 피드백을 만드는 중…';

  @override
  String get resultRetry => '다시 시도';

  @override
  String get resultReduced => '피드백을 일부만 만들 수 있었어요.';

  @override
  String get resultNoAnswers => '답변이 없어서 피드백을 만들지 않았어요.';

  @override
  String get resultStrengths => '잘한 점';

  @override
  String get resultCorrections => '고쳐 말해볼 문장';

  @override
  String get resultNoCorrections => '이번 대화에서는 꼭 고칠 문장이 없었어요.';

  @override
  String get resultSayAgain => '다시 말하기';

  @override
  String resultYouSaid(String text) {
    return '방금 말한 문장: $text';
  }

  @override
  String get resultListening => '듣는 중…';

  @override
  String get resultExpressions => '써볼 만한 표현';

  @override
  String get resultNextTopic => '다음 추천 주제';

  @override
  String get resultTalkAboutIt => '이 주제로 대화하기';

  @override
  String get resultReviewNote => '고친 문장은 복습 목록에 추가됐어요.';

  @override
  String get setupTitle => '대화 준비';

  @override
  String get setupMode => '모드';

  @override
  String get setupLevel => '레벨';

  @override
  String get setupLevelNote =>
      'L1 기초 문장 · L2 친숙한 대화 · L3 상황 대응 · L4 의견 표현 · L5 프리토킹';

  @override
  String get setupTopic => '주제';

  @override
  String get setupTopicOptional => '주제 (선택)';

  @override
  String get setupTopicHint => '직접 입력해도 돼요';

  @override
  String get setupRandomNote => '랜덤 모드는 AI가 매번 다른 주제로 즉흥 질문을 해요.';

  @override
  String get setupScenario => '상황';

  @override
  String get setupRole => 'AI 역할';

  @override
  String get setupSituation => '상황 설명';

  @override
  String get setupGoal => '내 목표';

  @override
  String get setupLength => '시간';

  @override
  String setupMinutes(int minutes) {
    return '$minutes분';
  }

  @override
  String get setupStart => '대화 시작';

  @override
  String get assessmentTitle => '레벨 진단';

  @override
  String get assessmentIntro => '다섯 가지 질문에 영어로 답하면 시작 레벨을 추천해 드려요. 5분 정도 걸려요.';

  @override
  String get assessmentLimit => '짧은 진단이라 정확도에 한계가 있어요. 레벨은 언제든 바꿀 수 있어요.';

  @override
  String get assessmentMicCheck =>
      '마이크 확인: 🎤를 누르고 \"Hello, nice to meet you\"라고 말해보세요.';

  @override
  String assessmentMicHeard(String text) {
    return '들린 말: $text';
  }

  @override
  String get assessmentMicNothing =>
      '아무 말도 들리지 않았어요. 마이크·음성 인식 권한을 확인하거나, 글자로 답해도 돼요.';

  @override
  String assessmentQuestion(int n, int total) {
    return '질문 $n / $total';
  }

  @override
  String get assessmentAnswerHint => '🎤로 말하거나 영어로 입력하세요';

  @override
  String get assessmentNext => '다음';

  @override
  String get assessmentFinish => '결과 보기';

  @override
  String get assessmentEvaluating => '답변을 평가하는 중…';

  @override
  String assessmentSuggested(String level) {
    return '추천 레벨: $level';
  }

  @override
  String get assessmentRubricNote =>
      'AI가 답변 내용(글자)만 보고 평가했어요. 발음과 유창성은 평가하지 않았어요.';

  @override
  String get assessmentRelevance => '질문에 맞는 답변';

  @override
  String get assessmentSentences => '문장 만들기';

  @override
  String get assessmentVocabulary => '어휘 다양성';

  @override
  String get assessmentContinuity => '이어 말하기';

  @override
  String assessmentScore(int score) {
    return '$score / 5';
  }

  @override
  String get assessmentGradingFailed => '평가 결과를 읽지 못했어요. 직접 레벨을 골라 주세요.';

  @override
  String get assessmentPick => '다른 레벨로 하려면 고르세요';

  @override
  String get assessmentAccept => '이 레벨로 시작';

  @override
  String get assessmentDone => '레벨을 저장했어요.';

  @override
  String get historyTitle => '학습 기록';

  @override
  String get historySearch => '주제나 대화 내용으로 검색';

  @override
  String get historyEmpty => '아직 기록이 없어요.';

  @override
  String get historyNoMatch => '검색 결과가 없어요.';

  @override
  String historyAnswers(int count) {
    return '답변 $count회';
  }

  @override
  String get historyUnfinished => '진행 중';

  @override
  String get historyDelete => '삭제';

  @override
  String get historyDeleteConfirm => '이 대화 기록을 삭제할까요? 교정·복습 항목도 함께 지워져요.';

  @override
  String get cancel => '취소';

  @override
  String get reviewTitle => '복습';

  @override
  String get reviewEmpty => '지금 복습할 문장이 없어요. 대화를 마치면 고친 문장이 여기에 쌓여요.';

  @override
  String get reviewIntro => '예전에 고친 문장을 소리 내어 다시 말해보세요.';

  @override
  String get reviewDone => '말해봤어요';

  @override
  String get reviewLater => '나중에';

  @override
  String get homeHistory => '학습 기록';

  @override
  String get homeUnfinished => '끝나지 않은 대화가 있어요';

  @override
  String get homeResume => '이어서 하기';

  @override
  String get homeCloseAndSee => '끝내고 결과 보기';

  @override
  String get homePlacementTitle => '레벨 진단부터 해볼까요?';

  @override
  String get homePlacementBody => '5개 질문으로 시작 레벨을 추천해 드려요 (약 5분).';

  @override
  String get homePlacementStart => '진단 시작';

  @override
  String get homeToday => '오늘 말한 시간 (추정)';

  @override
  String get homeWeek => '최근 7일 (추정)';

  @override
  String get homeStreak => '연속 학습';

  @override
  String homeStreakDays(int days) {
    return '$days일';
  }

  @override
  String get homeCompleted => '완료한 대화';

  @override
  String homeCompletedValue(int count, int percent) {
    return '$count회 · 완료율 $percent%';
  }

  @override
  String get homeAvgAnswer => '평균 답변 길이';

  @override
  String homeAvgWords(String words) {
    return '$words단어';
  }

  @override
  String get homeReviews => '복습할 문장';

  @override
  String homeReviewCount(int count) {
    return '$count개';
  }

  @override
  String get homeNoData => '—';

  @override
  String get homeSpeechNote => '말한 시간은 🎤로 대화했을 때 음성 인식 타이밍으로 추정해요.';

  @override
  String homeNextTopic(String topic) {
    return '추천 주제: $topic';
  }

  @override
  String get homeDevTools => '개발용 테스트';

  @override
  String get homePlacementAgain => '레벨 다시 진단';

  @override
  String get settingsDataSection => '데이터';

  @override
  String get settingsExport => '대화 기록 내보내기 (JSON·CSV)';

  @override
  String get settingsExportNote => '로그인 정보와 API 키는 포함되지 않아요.';

  @override
  String settingsExportedTo(String path) {
    return '저장 위치: $path';
  }

  @override
  String get settingsDeleteAll => '모든 대화 기록 삭제';

  @override
  String get settingsDeleteAllConfirm =>
      '모든 대화, 교정, 복습, 진단 기록을 지울까요? 되돌릴 수 없어요. (로그인과 설정은 유지돼요)';

  @override
  String get settingsDeleted => '모든 기록을 삭제했어요.';

  @override
  String get conversationPausedInBackground =>
      '앱을 벗어나서 일시정지했어요.\n준비되면 계속하기를 눌러주세요.';
}
