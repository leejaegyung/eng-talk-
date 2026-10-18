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
      'API 계정에 남은 크레딧이 없어요. 무료 사용량을 넘었는지 확인해 주세요.';

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
      '대화 내용(글자)은 고른 AI로 보내져 답변을 만들어요. ChatGPT 구독은 OpenAI 정책을 따르고, Gemini 무료 키는 Google이 대화 내용을 서비스 개선에 쓸 수 있어요.';

  @override
  String get onboardingPrivacyVoice =>
      '음성 인식은 기본으로 기기에 내장된 기능을 써요(기기 설정에 따라 Apple·Google·Microsoft 서버에서 처리될 수 있어요). 설정에서 \'Gemini\'를 고르면 말한 녹음이 Google Gemini로 보내져 받아써져요. 녹음은 저장하지 않아요.';

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
      'ChatGPT 구독은 추가 요금이 없어요. Gemini는 Google AI Studio의 무료 API 키로 쓸 수 있어요.';

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
  String get settingsExportNote =>
      '백업으로도 쓸 수 있어요(JSON). 로그인 정보와 API 키는 포함되지 않아요.';

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

  @override
  String get goalsTitle => '학습 목표';

  @override
  String get goalsWhy => '왜 영어 말하기를 연습하나요?';

  @override
  String get goalEveryday => '일상 대화';

  @override
  String get goalTravel => '여행';

  @override
  String get goalWork => '업무·회의';

  @override
  String get goalInterview => '면접';

  @override
  String get goalConfidence => '자신감 키우기';

  @override
  String get goalsDaily => '하루 목표 시간';

  @override
  String goalsMinutes(int minutes) {
    return '$minutes분';
  }

  @override
  String get goalsNote => '목표에 맞는 대화 모드와 시간을 추천해 드려요. 설정에서 언제든 바꿀 수 있어요.';

  @override
  String homeGoalProgress(int done, int goal) {
    return '오늘 $done분 / 목표 $goal분';
  }

  @override
  String get homeGoalDone => '오늘 목표 달성!';

  @override
  String homeSuggestedMode(String goal, String mode) {
    return '$goal 목표 추천: $mode';
  }

  @override
  String get homeGrowth => '성장 기록';

  @override
  String get growthPeriodWeek => '7일';

  @override
  String get growthPeriodMonth => '30일';

  @override
  String get growthPractice => '연습 시간';

  @override
  String get growthSpeech => '말한 시간 (추정)';

  @override
  String get growthSessions => '대화 수';

  @override
  String growthSessionCount(int count) {
    return '$count회';
  }

  @override
  String get growthDaily => '날짜별 연습 시간';

  @override
  String growthDayBar(String date, int minutes) {
    return '$date · $minutes분';
  }

  @override
  String get growthEmpty => '이 기간에 끝낸 대화가 없어요.';

  @override
  String get growthWeakAreas => '자주 고친 부분';

  @override
  String get growthWeakNote => '대화 후 AI 피드백이 분류한 교정 기준이에요. 발음은 평가하지 않아요.';

  @override
  String get growthNoWeak => '아직 분류된 교정이 없어요. 대화를 마치고 결과를 보면 쌓여요.';

  @override
  String get growthLevels => '레벨 변화';

  @override
  String get growthNoLevels => '레벨 진단 기록이 없어요.';

  @override
  String get categoryGrammar => '문법 (시제·관사·전치사)';

  @override
  String get categoryWordChoice => '단어 선택';

  @override
  String get categoryStructure => '문장 구조·어순';

  @override
  String get categoryNaturalness => '자연스러운 표현';

  @override
  String get handsFreeOn => '자동 듣기 켜짐 (끄기)';

  @override
  String get handsFreeOff => '자동 듣기 꺼짐 (켜기)';

  @override
  String get settingsHandsFree => '자동 듣기 (핸즈프리)';

  @override
  String get settingsHandsFreeNote =>
      'AI가 말을 마치면 🎤를 누르지 않아도 바로 들어요. 말이 없으면 두 번 뒤에 멈춰요.';

  @override
  String get conversationDraftHelp => '들린 문장이에요. 고칠 곳이 있으면 고친 뒤 보내기를 누르세요.';

  @override
  String get settingsConfirmSpeech => '말한 뒤 확인하고 보내기';

  @override
  String get settingsConfirmSpeechNote =>
      '인식된 문장을 입력칸에 먼저 띄워요. 잘못 들린 단어를 고칠 수 있지만 대화가 조금 느려져요.';

  @override
  String get reviewExpressions => '최근 배운 표현';

  @override
  String get reviewExpressionsIntro =>
      '표현을 넣어 한 문장으로 말해보세요. 다음 대화에서도 코치가 써볼 기회를 만들어 줘요.';

  @override
  String get reviewUseExpression => '넣어서 말하기';

  @override
  String get reviewExpressionUsed => '표현을 넣어 말했어요';

  @override
  String get reviewExpressionMissing => '표현이 들리지 않았어요. 다시 해볼까요?';

  @override
  String a11yYouSaid(String text) {
    return '나: $text';
  }

  @override
  String a11yCoachSaid(String text) {
    return '코치: $text';
  }

  @override
  String get a11yStopListening => '듣기 멈추기';

  @override
  String get speechUnavailableTitle => '마이크나 음성 인식을 쓸 수 없어요';

  @override
  String get speechUnavailableBody =>
      '설정에서 이 앱의 마이크·음성 인식 권한을 켜 주세요. 그동안은 입력해서 대화할 수 있어요.';

  @override
  String get speechOpenSettings => '설정 열기';

  @override
  String get speechIssueNetwork =>
      '음성 인식 서버에 연결할 수 없어요. 인터넷을 확인하거나 입력해서 계속하세요.';

  @override
  String get speechIssueAudio =>
      '마이크 소리를 받을 수 없어요. 이어폰·마이크 연결을 확인한 뒤 🎤를 눌러 주세요.';

  @override
  String get speechIssueBusy => '다른 앱이 음성 인식을 쓰고 있어요. 잠시 뒤 🎤를 눌러 주세요.';

  @override
  String get speechIssueOther => '음성 인식이 중간에 멈췄어요. 🎤를 다시 누르거나 입력해 주세요.';

  @override
  String get aiChoiceChatGpt => 'ChatGPT';

  @override
  String get aiChoiceLabel => '대화에 쓸 AI';

  @override
  String get aiChoiceGemini => 'Gemini (무료 키)';

  @override
  String get geminiKeyLabel => 'Gemini API 키';

  @override
  String get geminiKeySave => '저장하고 확인';

  @override
  String get geminiKeyRemove => '키 삭제';

  @override
  String get geminiNoKey =>
      '키가 없어요. aistudio.google.com에서 무료로 만든 API 키를 넣어 주세요(결제 등록 없이).';

  @override
  String get geminiKeyStored => '키는 기기의 보안 저장소에만 보관돼요. 연결 확인은 모델 목록만 조회해요.';

  @override
  String get geminiFreeTier =>
      '무료 사용량 안에서는 요금이 없어요. 대신 Google 무료 등급에서는 대화 내용이 Google 서비스 개선에 쓰이고 사람이 검토할 수 있어요. 개인정보는 말하지 마세요. 사용량이 많으면 잠시 막힐 수 있어요.';

  @override
  String get geminiChosenNoKey =>
      'Gemini를 고르셨지만 키가 없어요. 키를 넣기 전까지 대화를 시작할 수 없어요.';

  @override
  String get settingsAutoBargeIn => '말하면 AI 말 끊기 (이어폰 사용 시)';

  @override
  String get settingsAutoBargeInNote =>
      '자동 듣기가 켜져 있을 때 AI가 말하는 동안에도 들어요. 스피커로 들으면 AI 목소리를 내 말로 알아들을 수 있어서 이어폰을 쓸 때만 켜세요.';

  @override
  String get settingsDiagnostics => '진단 정보 내보내기';

  @override
  String settingsDiagnosticsNote(int count) {
    return '앱 오류 기록(최근 $count건)을 파일로 저장해요. 대화 내용과 키는 들어가지 않아요. 문제를 알릴 때 첨부해 주세요.';
  }

  @override
  String get settingsDiagnosticsClear => '오류 기록 지우기';

  @override
  String get languageLabel => '언어';

  @override
  String get languageSystem => '기기 설정';

  @override
  String get languageKo => '한국어';

  @override
  String get languageEn => 'English';

  @override
  String get settingsRestore => '백업 파일에서 복원';

  @override
  String get settingsRestoreNote =>
      '내보낸 speaking-coach.json을 고르면 기록·복습·목표를 불러와요. 이미 있는 대화는 건너뛰어요.';

  @override
  String settingsRestored(int added, int skipped) {
    return '대화 $added개를 복원했어요 (이미 있던 $skipped개는 건너뜀)';
  }

  @override
  String get settingsRestoreFailed =>
      'Speaking Coach 백업 파일이 아니에요. 내보내기로 만든 speaking-coach.json을 골라 주세요.';

  @override
  String get speechAndroidTip =>
      '들린 말이 계속 이상하면: 휴대폰 설정 → 일반 → 키보드 목록 및 기본값(또는 \'음성 입력\') → 기본 음성 인식 서비스를 \'Google\'로 바꾸고, Google 음성 인식에 영어(미국)가 받아져 있는지 확인해 주세요.';

  @override
  String get assessmentKeepTalking => '잠깐 쉬어도 계속 들어요. 다 말했으면 ■를 누르세요.';

  @override
  String get pasteTitle => 'ChatGPT 로그인 마무리';

  @override
  String get pasteSteps =>
      '1. 새로 열린 탭에서 ChatGPT에 로그인하세요.\n2. 로그인 후 \'사이트에 연결할 수 없음\' 페이지가 뜨면 정상이에요.\n3. 그 페이지 주소창의 주소 전체(http://127.0.0.1:1455/auth/callback?code=…)를 복사해서 아래에 붙여넣으세요.';

  @override
  String get pasteLabel => '주소 붙여넣기';

  @override
  String get pasteInvalid =>
      '로그인 후 받은 주소가 아니에요. 127.0.0.1로 시작하는 주소 전체를 붙여넣어 주세요.';

  @override
  String get pasteConfirm => '확인';

  @override
  String get speechUnavailableWeb =>
      '이 브라우저에서는 음성 인식을 쓸 수 없어요. 아이폰·아이패드는 Safari, 그 외에는 Chrome 최신 버전에서 열고 마이크를 허용해 주세요. 그동안은 입력해서 대화할 수 있어요.';

  @override
  String get setupAiTopic => '🎲 랜덤 (AI가 정해요)';

  @override
  String get setupAiScenario => '🎲 랜덤 상황 (AI가 정해요)';

  @override
  String get setupAiTopicNote => '대화를 시작하면 AI가 매번 다른 주제를 골라 첫마디에 알려줘요.';

  @override
  String get setupAiScenarioNote => 'AI가 상황과 자기 역할을 정해서 첫마디에 알려줘요.';

  @override
  String get resultWordOrder => '어순 체크';

  @override
  String resultWordOrderSummary(int total, int ok) {
    return '$total문장 중 $ok문장 어순이 맞았어요';
  }

  @override
  String get resultWordOrderOk => '어순 맞음';

  @override
  String get resultWordOrderWrong => '어순 다시 보기';

  @override
  String get resultWordOrderNote =>
      '어순이 틀린 문장은 복습에서 바른 어순으로 다시 말해봐요. 발음·시제는 여기서 보지 않아요.';

  @override
  String get reviewKindWordOrder => '어순 교정';

  @override
  String get practiceMatched => '교정된 문장대로 말했어요';

  @override
  String get practiceDiffers => '조금 달라요. 교정된 문장을 보고 다시 말해볼까요?';

  @override
  String get settingsReviewSection => '복습';

  @override
  String get settingsReviewRepeats => '문장마다 반복 횟수';

  @override
  String get settingsReviewRepeatsNote =>
      '교정된 문장을 말한 횟수만큼 체크 박스가 채워져요. 인식이 틀려도 직접 눌러 체크할 수 있어요.';

  @override
  String settingsRepeatTimes(int count) {
    return '$count회';
  }

  @override
  String reviewRepeatProgress(int done, int total) {
    return '반복 $done/$total';
  }

  @override
  String get reviewRepeatDone => '반복 완료!';

  @override
  String reviewRepeatBox(int n) {
    return '$n번째 반복';
  }

  @override
  String get speechEngineLabel => '음성 인식';

  @override
  String get speechEngineDevice => '기기 내장';

  @override
  String get speechEngineGemini => 'Gemini (정확)';

  @override
  String get speechEngineGeminiNote =>
      '말을 마치면 녹음을 Gemini가 받아써요. 이름·억양을 훨씬 잘 알아듣지만 받아쓰는 데 1~2초 걸려요. 녹음은 저장하지 않고, 무료 키에서는 Google이 서비스 개선에 쓸 수 있어요.';

  @override
  String get speechEngineNeedsKey =>
      'Gemini 인식에는 무료 키가 필요해요. 키가 없으면 기기 내장 인식으로 들어요.';

  @override
  String get shadowingTitle => '따라 말하기';

  @override
  String get shadowingNote => '코치가 한 문장을 듣고 그대로 따라 말해요. 똑같이 말하면 칸이 채워져요.';

  @override
  String get shadowingListen => '듣기';

  @override
  String get shadowingSlow => '천천히';

  @override
  String get shadowingRepeat => '따라 말하기';

  @override
  String get lessonWriting => '내 실수를 보고 설명을 만드는 중…';

  @override
  String get lessonExamples => '예문';

  @override
  String get lessonPractice => '내 문장으로 연습';

  @override
  String get lessonPracticeNote => '실제로 말했던 문장의 교정본이에요. 그대로 말하면 칸이 채워져요.';

  @override
  String get lessonRewrite => '다시 만들기';

  @override
  String get lessonNoMistakes => '이 유형의 교정이 아직 없어요.';

  @override
  String get lessonOpen => '미니 설명 보기';

  @override
  String get lessonAiNote => 'AI가 내 실수를 바탕으로 만든 설명이에요.';

  @override
  String updateAvailable(String version) {
    return '새 버전이 나왔어요 (v$version)';
  }

  @override
  String get updateInstallNote => '받은 뒤 나오는 화면에서 \'설치\'를 누르세요. 기록은 그대로 남아요.';

  @override
  String get updateReloadNote => '새로고침하면 바로 새 버전이 열려요.';

  @override
  String get updatePageNote => '다운로드 페이지에서 새 설치 파일을 받아 덮어 설치하세요.';

  @override
  String get updateInstall => '업데이트';

  @override
  String get updateReload => '새로고침';

  @override
  String get updateOpenPage => '다운로드 페이지';

  @override
  String get updateLater => '나중에';

  @override
  String updateDownloading(int percent) {
    return '받는 중… $percent%';
  }

  @override
  String get updateFailed => '업데이트하지 못했어요. 다운로드 페이지에서 받아 주세요.';

  @override
  String get settingsVersion => '앱 버전';

  @override
  String get settingsVersionLocal => '개발용 빌드 (업데이트 확인 안 함)';

  @override
  String get settingsCheckUpdate => '업데이트 확인';

  @override
  String settingsUpToDate(String version) {
    return '$version · 최신 버전이에요';
  }

  @override
  String settingsUpdateUnknown(String version) {
    return '$version · 확인하지 못했어요. 인터넷 연결을 확인해 주세요.';
  }

  @override
  String get homePlacementPick => '레벨을 알고 있다면 직접 고르세요. 진단은 나중에도 할 수 있어요.';
}
