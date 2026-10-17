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
}
