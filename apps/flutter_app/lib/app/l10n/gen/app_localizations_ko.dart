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
}
