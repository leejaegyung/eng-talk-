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
}
