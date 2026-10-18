import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ko.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ko'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In ko, this message translates to:
  /// **'AI 영어 스피킹 코치'**
  String get appTitle;

  /// No description provided for @homeHeadline.
  ///
  /// In ko, this message translates to:
  /// **'오늘도 영어로 말해볼까요?'**
  String get homeHeadline;

  /// No description provided for @homeStartButton.
  ///
  /// In ko, this message translates to:
  /// **'대화 시작'**
  String get homeStartButton;

  /// No description provided for @homeAudioLab.
  ///
  /// In ko, this message translates to:
  /// **'오디오 테스트 (개발용)'**
  String get homeAudioLab;

  /// No description provided for @audioLabTitle.
  ///
  /// In ko, this message translates to:
  /// **'오디오 테스트'**
  String get audioLabTitle;

  /// No description provided for @audioLabHint.
  ///
  /// In ko, this message translates to:
  /// **'녹음을 누르고 영어로 몇 마디 말한 뒤 정지 → 다시 듣기. 녹음은 메모리에만 있고 이 화면을 나가면 지워져요.'**
  String get audioLabHint;

  /// No description provided for @audioLabRecord.
  ///
  /// In ko, this message translates to:
  /// **'녹음'**
  String get audioLabRecord;

  /// No description provided for @audioLabStop.
  ///
  /// In ko, this message translates to:
  /// **'정지'**
  String get audioLabStop;

  /// No description provided for @audioLabPlay.
  ///
  /// In ko, this message translates to:
  /// **'다시 듣기'**
  String get audioLabPlay;

  /// No description provided for @audioLabLevel.
  ///
  /// In ko, this message translates to:
  /// **'입력 음량 {db} dBFS'**
  String audioLabLevel(String db);

  /// No description provided for @audioLabSpeaking.
  ///
  /// In ko, this message translates to:
  /// **'말하는 중'**
  String get audioLabSpeaking;

  /// No description provided for @audioLabSilent.
  ///
  /// In ko, this message translates to:
  /// **'조용함'**
  String get audioLabSilent;

  /// No description provided for @audioLabSpeechTotal.
  ///
  /// In ko, this message translates to:
  /// **'감지된 발화 시간 {seconds}초'**
  String audioLabSpeechTotal(String seconds);

  /// No description provided for @audioLabRecorded.
  ///
  /// In ko, this message translates to:
  /// **'녹음 길이 {seconds}초'**
  String audioLabRecorded(String seconds);

  /// No description provided for @audioLabMicDenied.
  ///
  /// In ko, this message translates to:
  /// **'마이크 권한이 없어 음성 모드를 쓸 수 없어요. 시스템 설정에서 마이크를 허용하거나, 텍스트로 대화할 수 있어요.'**
  String get audioLabMicDenied;

  /// No description provided for @audioLabFailed.
  ///
  /// In ko, this message translates to:
  /// **'오디오 장치를 열 수 없어요. 마이크 연결을 확인해 주세요.'**
  String get audioLabFailed;

  /// No description provided for @audioLabNoSignal.
  ///
  /// In ko, this message translates to:
  /// **'마이크 신호가 들어오지 않아요. 맥북 덮개가 닫혀 있거나, 입력 장치가 음소거되었는지 확인해 주세요.'**
  String get audioLabNoSignal;

  /// No description provided for @homeVoiceLab.
  ///
  /// In ko, this message translates to:
  /// **'음성 대화 테스트 (개발용)'**
  String get homeVoiceLab;

  /// No description provided for @voiceLabTitle.
  ///
  /// In ko, this message translates to:
  /// **'음성 대화 테스트'**
  String get voiceLabTitle;

  /// No description provided for @voiceLabKeyTitle.
  ///
  /// In ko, this message translates to:
  /// **'OpenAI API 키'**
  String get voiceLabKeyTitle;

  /// No description provided for @voiceLabKeyHint.
  ///
  /// In ko, this message translates to:
  /// **'키는 이 기기의 보안 저장소(키체인 등)에만 저장되고, OpenAI 외 다른 곳으로 보내지 않아요. 사용량만큼 본인 OpenAI 계정에 과금돼요.'**
  String get voiceLabKeyHint;

  /// No description provided for @voiceLabKeyField.
  ///
  /// In ko, this message translates to:
  /// **'sk-로 시작하는 키'**
  String get voiceLabKeyField;

  /// No description provided for @voiceLabKeySave.
  ///
  /// In ko, this message translates to:
  /// **'저장'**
  String get voiceLabKeySave;

  /// No description provided for @voiceLabKeyStored.
  ///
  /// In ko, this message translates to:
  /// **'키 저장됨'**
  String get voiceLabKeyStored;

  /// No description provided for @voiceLabKeyDelete.
  ///
  /// In ko, this message translates to:
  /// **'키 삭제'**
  String get voiceLabKeyDelete;

  /// No description provided for @voiceLabTest.
  ///
  /// In ko, this message translates to:
  /// **'연결 테스트'**
  String get voiceLabTest;

  /// No description provided for @voiceLabChecking.
  ///
  /// In ko, this message translates to:
  /// **'확인 중…'**
  String get voiceLabChecking;

  /// No description provided for @voiceLabModels.
  ///
  /// In ko, this message translates to:
  /// **'사용 모델 — 대화: {chat} · 음성 인식: {stt} · 음성 합성: {tts}'**
  String voiceLabModels(String chat, String stt, String tts);

  /// No description provided for @voiceLabTalk.
  ///
  /// In ko, this message translates to:
  /// **'말하기'**
  String get voiceLabTalk;

  /// No description provided for @voiceLabStopListening.
  ///
  /// In ko, this message translates to:
  /// **'말하기 끝'**
  String get voiceLabStopListening;

  /// No description provided for @voiceLabPhaseListening.
  ///
  /// In ko, this message translates to:
  /// **'듣는 중… 말을 멈추면 자동으로 보내요'**
  String get voiceLabPhaseListening;

  /// No description provided for @voiceLabPhaseTranscribing.
  ///
  /// In ko, this message translates to:
  /// **'음성 인식 중…'**
  String get voiceLabPhaseTranscribing;

  /// No description provided for @voiceLabPhaseThinking.
  ///
  /// In ko, this message translates to:
  /// **'답변 생성 중…'**
  String get voiceLabPhaseThinking;

  /// No description provided for @voiceLabPhaseSpeaking.
  ///
  /// In ko, this message translates to:
  /// **'말하는 중…'**
  String get voiceLabPhaseSpeaking;

  /// No description provided for @voiceLabHeard.
  ///
  /// In ko, this message translates to:
  /// **'내 말: {text}'**
  String voiceLabHeard(String text);

  /// No description provided for @voiceLabReply.
  ///
  /// In ko, this message translates to:
  /// **'AI: {text}'**
  String voiceLabReply(String text);

  /// No description provided for @voiceLabRunsTitle.
  ///
  /// In ko, this message translates to:
  /// **'측정 기록 ({count}회)'**
  String voiceLabRunsTitle(int count);

  /// No description provided for @voiceLabRunRow.
  ///
  /// In ko, this message translates to:
  /// **'#{n} 인식 {stt} · 첫 토큰 {token} · 음성 첫 바이트 {tts} · 전체 {total} (ms)'**
  String voiceLabRunRow(int n, int stt, int token, int tts, int total);

  /// No description provided for @voiceLabStats.
  ///
  /// In ko, this message translates to:
  /// **'p50 / p95 — 인식 {stt} · 첫 토큰 {token} · 음성 첫 바이트 {tts} · 전체 {total} (ms)'**
  String voiceLabStats(String stt, String token, String tts, String total);

  /// No description provided for @voiceLabUsage.
  ///
  /// In ko, this message translates to:
  /// **'측정된 사용량 — 입력 토큰 {input} · 출력 토큰 {output} · 업로드 음성 {seconds}초 · 합성 글자 {chars}자'**
  String voiceLabUsage(int input, int output, String seconds, int chars);

  /// No description provided for @failureInvalidKey.
  ///
  /// In ko, this message translates to:
  /// **'API 키가 올바르지 않아요. 키를 확인하고 다시 입력해 주세요.'**
  String get failureInvalidKey;

  /// No description provided for @failureInsufficientQuota.
  ///
  /// In ko, this message translates to:
  /// **'API 계정에 남은 크레딧이 없어요. 무료 사용량을 넘었는지 확인해 주세요.'**
  String get failureInsufficientQuota;

  /// No description provided for @failureRateLimited.
  ///
  /// In ko, this message translates to:
  /// **'요청이 너무 많아요. 잠시 후 다시 시도해 주세요.'**
  String get failureRateLimited;

  /// No description provided for @failureModelUnavailable.
  ///
  /// In ko, this message translates to:
  /// **'이 계정에서 필요한 모델을 사용할 수 없어요.'**
  String get failureModelUnavailable;

  /// No description provided for @failureNetwork.
  ///
  /// In ko, this message translates to:
  /// **'네트워크에 연결할 수 없어요. 인터넷 연결을 확인해 주세요.'**
  String get failureNetwork;

  /// No description provided for @failureUnknown.
  ///
  /// In ko, this message translates to:
  /// **'알 수 없는 오류가 발생했어요. 잠시 후 다시 시도해 주세요.'**
  String get failureUnknown;

  /// No description provided for @failureSignInRequired.
  ///
  /// In ko, this message translates to:
  /// **'ChatGPT 로그인이 필요해요. 다시 로그인해 주세요.'**
  String get failureSignInRequired;

  /// No description provided for @failurePlanUsageLimit.
  ///
  /// In ko, this message translates to:
  /// **'ChatGPT 구독의 사용 한도에 도달했어요. ChatGPT 설정 → 사용량에서 확인할 수 있어요.'**
  String get failurePlanUsageLimit;

  /// No description provided for @failurePlanNotEligible.
  ///
  /// In ko, this message translates to:
  /// **'이 ChatGPT 계정은 앱에서 구독을 사용할 수 없어요. (Plus 또는 Pro 구독 필요)'**
  String get failurePlanNotEligible;

  /// No description provided for @homeChatGptLab.
  ///
  /// In ko, this message translates to:
  /// **'ChatGPT 대화 테스트 (구독 사용)'**
  String get homeChatGptLab;

  /// No description provided for @chatGptLabTitle.
  ///
  /// In ko, this message translates to:
  /// **'ChatGPT 대화 테스트'**
  String get chatGptLabTitle;

  /// No description provided for @chatGptLabIntro.
  ///
  /// In ko, this message translates to:
  /// **'ChatGPT Plus/Pro 구독으로 GPT를 사용해요. API 키나 추가 요금이 필요 없고, 구독의 사용 한도 안에서 동작해요.'**
  String get chatGptLabIntro;

  /// No description provided for @chatGptLabSignIn.
  ///
  /// In ko, this message translates to:
  /// **'ChatGPT로 로그인'**
  String get chatGptLabSignIn;

  /// No description provided for @chatGptLabSigningIn.
  ///
  /// In ko, this message translates to:
  /// **'브라우저에서 로그인을 완료해 주세요…'**
  String get chatGptLabSigningIn;

  /// No description provided for @chatGptLabSignOut.
  ///
  /// In ko, this message translates to:
  /// **'로그아웃'**
  String get chatGptLabSignOut;

  /// No description provided for @chatGptLabSignedIn.
  ///
  /// In ko, this message translates to:
  /// **'ChatGPT 연결됨 · 모델 {model}'**
  String chatGptLabSignedIn(String model);

  /// No description provided for @chatGptLabInput.
  ///
  /// In ko, this message translates to:
  /// **'영어로 입력해 보세요'**
  String get chatGptLabInput;

  /// No description provided for @chatGptLabSend.
  ///
  /// In ko, this message translates to:
  /// **'보내기'**
  String get chatGptLabSend;

  /// No description provided for @chatGptLabStats.
  ///
  /// In ko, this message translates to:
  /// **'측정값 — 첫 토큰 p50 {p50}ms · p95 {p95}ms ({count}회) · 토큰 입력 {input} / 출력 {output}'**
  String chatGptLabStats(int p50, int p95, int count, int input, int output);

  /// No description provided for @chatGptLabSpeakReplies.
  ///
  /// In ko, this message translates to:
  /// **'답변 소리로 듣기'**
  String get chatGptLabSpeakReplies;

  /// No description provided for @chatGptLabTalk.
  ///
  /// In ko, this message translates to:
  /// **'말하기'**
  String get chatGptLabTalk;

  /// No description provided for @chatGptLabListening.
  ///
  /// In ko, this message translates to:
  /// **'듣는 중… 말을 멈추면 자동으로 보내요'**
  String get chatGptLabListening;

  /// No description provided for @chatGptLabSpeaking.
  ///
  /// In ko, this message translates to:
  /// **'읽어주는 중…'**
  String get chatGptLabSpeaking;

  /// No description provided for @chatGptLabSpeechUnavailable.
  ///
  /// In ko, this message translates to:
  /// **'이 기기에서 음성 인식을 쓸 수 없어요. 시스템 설정에서 음성 인식·마이크 권한을 허용하거나, 글자로 입력해 주세요.'**
  String get chatGptLabSpeechUnavailable;

  /// No description provided for @chatGptLabFreeVoiceNote.
  ///
  /// In ko, this message translates to:
  /// **'음성 인식과 읽어주기는 기기에 내장된 무료 기능을 써요.'**
  String get chatGptLabFreeVoiceNote;

  /// No description provided for @onboardingWelcomeTitle.
  ///
  /// In ko, this message translates to:
  /// **'말하면서 배우는 영어 코치'**
  String get onboardingWelcomeTitle;

  /// No description provided for @onboardingWelcomeBody.
  ///
  /// In ko, this message translates to:
  /// **'AI는 짧게 묻고, 여러분이 길게 말해요.\n대화 중에는 흐름을 끊지 않고, 끝난 뒤에 고칠 점을 모아서 알려드려요.'**
  String get onboardingWelcomeBody;

  /// No description provided for @onboardingNext.
  ///
  /// In ko, this message translates to:
  /// **'다음'**
  String get onboardingNext;

  /// No description provided for @onboardingBack.
  ///
  /// In ko, this message translates to:
  /// **'이전'**
  String get onboardingBack;

  /// No description provided for @onboardingPrivacyTitle.
  ///
  /// In ko, this message translates to:
  /// **'데이터는 이렇게 다뤄요'**
  String get onboardingPrivacyTitle;

  /// No description provided for @onboardingPrivacyText.
  ///
  /// In ko, this message translates to:
  /// **'대화 내용(글자)은 고른 AI로 보내져 답변을 만들어요. ChatGPT 구독은 OpenAI 정책을 따르고, Gemini 무료 키는 Google이 대화 내용을 서비스 개선에 쓸 수 있어요.'**
  String get onboardingPrivacyText;

  /// No description provided for @onboardingPrivacyVoice.
  ///
  /// In ko, this message translates to:
  /// **'음성 인식은 기본으로 기기에 내장된 기능을 써요(기기 설정에 따라 Apple·Google·Microsoft 서버에서 처리될 수 있어요). 설정에서 \'Gemini\'를 고르면 말한 녹음이 Google Gemini로 보내져 받아써져요. 녹음은 저장하지 않아요.'**
  String get onboardingPrivacyVoice;

  /// No description provided for @onboardingPrivacyNoRecording.
  ///
  /// In ko, this message translates to:
  /// **'녹음 원본은 저장하지 않아요.'**
  String get onboardingPrivacyNoRecording;

  /// No description provided for @onboardingPrivacyLocal.
  ///
  /// In ko, this message translates to:
  /// **'대화 기록은 이 기기에만 저장돼요.'**
  String get onboardingPrivacyLocal;

  /// No description provided for @onboardingPrivacyCredentials.
  ///
  /// In ko, this message translates to:
  /// **'로그인 정보와 API 키는 기기의 보안 저장소에만 보관해요.'**
  String get onboardingPrivacyCredentials;

  /// No description provided for @onboardingAgree.
  ///
  /// In ko, this message translates to:
  /// **'확인했어요'**
  String get onboardingAgree;

  /// No description provided for @onboardingConnectTitle.
  ///
  /// In ko, this message translates to:
  /// **'AI 연결'**
  String get onboardingConnectTitle;

  /// No description provided for @onboardingConnectBody.
  ///
  /// In ko, this message translates to:
  /// **'ChatGPT Plus/Pro 구독이 있으면 추가 요금 없이 쓸 수 있어요. 구독의 사용 한도 안에서 동작해요.'**
  String get onboardingConnectBody;

  /// No description provided for @onboardingConnected.
  ///
  /// In ko, this message translates to:
  /// **'연결됐어요'**
  String get onboardingConnected;

  /// No description provided for @onboardingSkip.
  ///
  /// In ko, this message translates to:
  /// **'나중에 할게요'**
  String get onboardingSkip;

  /// No description provided for @onboardingSkipNote.
  ///
  /// In ko, this message translates to:
  /// **'연결하기 전에는 화면만 둘러볼 수 있어요.'**
  String get onboardingSkipNote;

  /// No description provided for @onboardingStart.
  ///
  /// In ko, this message translates to:
  /// **'시작하기'**
  String get onboardingStart;

  /// No description provided for @settingsTitle.
  ///
  /// In ko, this message translates to:
  /// **'설정'**
  String get settingsTitle;

  /// No description provided for @settingsAiSection.
  ///
  /// In ko, this message translates to:
  /// **'AI 연결'**
  String get settingsAiSection;

  /// No description provided for @settingsChatGpt.
  ///
  /// In ko, this message translates to:
  /// **'ChatGPT 구독'**
  String get settingsChatGpt;

  /// No description provided for @settingsNotConnected.
  ///
  /// In ko, this message translates to:
  /// **'연결 안 됨 — 로그인하면 추가 요금 없이 대화할 수 있어요'**
  String get settingsNotConnected;

  /// No description provided for @settingsConnectedModel.
  ///
  /// In ko, this message translates to:
  /// **'연결됨 · 모델 {model} (자동 선택)'**
  String settingsConnectedModel(String model);

  /// No description provided for @settingsChecking.
  ///
  /// In ko, this message translates to:
  /// **'연결 확인 중…'**
  String get settingsChecking;

  /// No description provided for @settingsRetry.
  ///
  /// In ko, this message translates to:
  /// **'다시 확인'**
  String get settingsRetry;

  /// No description provided for @settingsSignOut.
  ///
  /// In ko, this message translates to:
  /// **'로그아웃'**
  String get settingsSignOut;

  /// No description provided for @settingsApiKeyNote.
  ///
  /// In ko, this message translates to:
  /// **'ChatGPT 구독은 추가 요금이 없어요. Gemini는 Google AI Studio의 무료 API 키로 쓸 수 있어요.'**
  String get settingsApiKeyNote;

  /// No description provided for @settingsVoiceSection.
  ///
  /// In ko, this message translates to:
  /// **'음성'**
  String get settingsVoiceSection;

  /// No description provided for @settingsInfoSection.
  ///
  /// In ko, this message translates to:
  /// **'정보'**
  String get settingsInfoSection;

  /// No description provided for @settingsPrivacy.
  ///
  /// In ko, this message translates to:
  /// **'데이터 처리 안내'**
  String get settingsPrivacy;

  /// No description provided for @settingsLicenses.
  ///
  /// In ko, this message translates to:
  /// **'오픈소스 라이선스'**
  String get settingsLicenses;

  /// No description provided for @settingsClose.
  ///
  /// In ko, this message translates to:
  /// **'닫기'**
  String get settingsClose;

  /// No description provided for @homeSettings.
  ///
  /// In ko, this message translates to:
  /// **'설정'**
  String get homeSettings;

  /// No description provided for @conversationModeDaily.
  ///
  /// In ko, this message translates to:
  /// **'일상 대화'**
  String get conversationModeDaily;

  /// No description provided for @conversationTitle.
  ///
  /// In ko, this message translates to:
  /// **'{mode} · {level}'**
  String conversationTitle(String mode, String level);

  /// No description provided for @conversationEnd.
  ///
  /// In ko, this message translates to:
  /// **'종료'**
  String get conversationEnd;

  /// No description provided for @conversationConnecting.
  ///
  /// In ko, this message translates to:
  /// **'연결 중…'**
  String get conversationConnecting;

  /// No description provided for @conversationListening.
  ///
  /// In ko, this message translates to:
  /// **'듣는 중… 말을 멈추면 보내요'**
  String get conversationListening;

  /// No description provided for @conversationThinking.
  ///
  /// In ko, this message translates to:
  /// **'생각 중…'**
  String get conversationThinking;

  /// No description provided for @conversationAiSpeaking.
  ///
  /// In ko, this message translates to:
  /// **'AI가 말하는 중 — 🎤를 누르면 끊고 말할 수 있어요'**
  String get conversationAiSpeaking;

  /// No description provided for @conversationYourTurn.
  ///
  /// In ko, this message translates to:
  /// **'내 차례예요. 🎤를 누르고 말해보세요'**
  String get conversationYourTurn;

  /// No description provided for @conversationHint.
  ///
  /// In ko, this message translates to:
  /// **'힌트'**
  String get conversationHint;

  /// No description provided for @conversationRepeat.
  ///
  /// In ko, this message translates to:
  /// **'다시 말해줘'**
  String get conversationRepeat;

  /// No description provided for @conversationSlower.
  ///
  /// In ko, this message translates to:
  /// **'천천히'**
  String get conversationSlower;

  /// No description provided for @conversationCorrect.
  ///
  /// In ko, this message translates to:
  /// **'이 문장 교정'**
  String get conversationCorrect;

  /// No description provided for @conversationChangeTopic.
  ///
  /// In ko, this message translates to:
  /// **'주제 변경'**
  String get conversationChangeTopic;

  /// No description provided for @conversationHintSuggestion.
  ///
  /// In ko, this message translates to:
  /// **'막히셨나요? 힌트를 눌러보세요.'**
  String get conversationHintSuggestion;

  /// No description provided for @conversationSubtitlesHidden.
  ///
  /// In ko, this message translates to:
  /// **'자막을 숨겼어요. 듣고 말하는 데 집중해 보세요.'**
  String get conversationSubtitlesHidden;

  /// No description provided for @conversationShowSubtitles.
  ///
  /// In ko, this message translates to:
  /// **'자막 보기'**
  String get conversationShowSubtitles;

  /// No description provided for @conversationHideSubtitles.
  ///
  /// In ko, this message translates to:
  /// **'자막 숨기기'**
  String get conversationHideSubtitles;

  /// No description provided for @conversationInput.
  ///
  /// In ko, this message translates to:
  /// **'영어로 입력해도 돼요'**
  String get conversationInput;

  /// No description provided for @conversationSend.
  ///
  /// In ko, this message translates to:
  /// **'보내기'**
  String get conversationSend;

  /// No description provided for @conversationNeedsConnection.
  ///
  /// In ko, this message translates to:
  /// **'대화하려면 AI 연결이 필요해요.'**
  String get conversationNeedsConnection;

  /// No description provided for @conversationOpenSettings.
  ///
  /// In ko, this message translates to:
  /// **'설정에서 연결하기'**
  String get conversationOpenSettings;

  /// No description provided for @conversationBackHome.
  ///
  /// In ko, this message translates to:
  /// **'홈으로'**
  String get conversationBackHome;

  /// No description provided for @modeTheme.
  ///
  /// In ko, this message translates to:
  /// **'테마 대화'**
  String get modeTheme;

  /// No description provided for @modeRoleplay.
  ///
  /// In ko, this message translates to:
  /// **'상황 역할극'**
  String get modeRoleplay;

  /// No description provided for @modeRandom.
  ///
  /// In ko, this message translates to:
  /// **'랜덤 스피킹'**
  String get modeRandom;

  /// No description provided for @modeStorytelling.
  ///
  /// In ko, this message translates to:
  /// **'경험·이야기'**
  String get modeStorytelling;

  /// No description provided for @modeOpinion.
  ///
  /// In ko, this message translates to:
  /// **'의견·토론'**
  String get modeOpinion;

  /// No description provided for @modeAssessment.
  ///
  /// In ko, this message translates to:
  /// **'레벨 진단'**
  String get modeAssessment;

  /// No description provided for @modeDailyDesc.
  ///
  /// In ko, this message translates to:
  /// **'하루·취미·경험을 친구처럼 이야기해요'**
  String get modeDailyDesc;

  /// No description provided for @modeThemeDesc.
  ///
  /// In ko, this message translates to:
  /// **'고른 주제 하나를 깊게 파고들어요'**
  String get modeThemeDesc;

  /// No description provided for @modeRoleplayDesc.
  ///
  /// In ko, this message translates to:
  /// **'호텔·식당·면접 같은 상황을 연기해요'**
  String get modeRoleplayDesc;

  /// No description provided for @modeRandomDesc.
  ///
  /// In ko, this message translates to:
  /// **'예상 못 한 질문에 바로 답해봐요'**
  String get modeRandomDesc;

  /// No description provided for @modeStorytellingDesc.
  ///
  /// In ko, this message translates to:
  /// **'경험을 처음부터 끝까지 길게 말해요'**
  String get modeStorytellingDesc;

  /// No description provided for @modeOpinionDesc.
  ///
  /// In ko, this message translates to:
  /// **'주장 → 이유 → 예시로 의견을 말해요'**
  String get modeOpinionDesc;

  /// No description provided for @conversationPaused.
  ///
  /// In ko, this message translates to:
  /// **'일시정지했어요'**
  String get conversationPaused;

  /// No description provided for @conversationPause.
  ///
  /// In ko, this message translates to:
  /// **'일시정지'**
  String get conversationPause;

  /// No description provided for @conversationResume.
  ///
  /// In ko, this message translates to:
  /// **'이어하기'**
  String get conversationResume;

  /// No description provided for @conversationConnectionLost.
  ///
  /// In ko, this message translates to:
  /// **'연결이 끊겼어요. 대화는 저장돼 있어요.'**
  String get conversationConnectionLost;

  /// No description provided for @conversationReconnect.
  ///
  /// In ko, this message translates to:
  /// **'다시 연결'**
  String get conversationReconnect;

  /// No description provided for @conversationContinueText.
  ///
  /// In ko, this message translates to:
  /// **'읽어주기 없이 계속'**
  String get conversationContinueText;

  /// No description provided for @conversationSaveAndEnd.
  ///
  /// In ko, this message translates to:
  /// **'저장하고 끝내기'**
  String get conversationSaveAndEnd;

  /// No description provided for @conversationSaving.
  ///
  /// In ko, this message translates to:
  /// **'저장 중…'**
  String get conversationSaving;

  /// No description provided for @resultTitle.
  ///
  /// In ko, this message translates to:
  /// **'대화 결과'**
  String get resultTitle;

  /// No description provided for @resultPracticeTime.
  ///
  /// In ko, this message translates to:
  /// **'연습 시간'**
  String get resultPracticeTime;

  /// No description provided for @resultAnswers.
  ///
  /// In ko, this message translates to:
  /// **'내 답변'**
  String get resultAnswers;

  /// No description provided for @resultAnswerCount.
  ///
  /// In ko, this message translates to:
  /// **'{count}회'**
  String resultAnswerCount(int count);

  /// No description provided for @resultMinSec.
  ///
  /// In ko, this message translates to:
  /// **'{minutes}분 {seconds}초'**
  String resultMinSec(int minutes, int seconds);

  /// No description provided for @resultUserSpeech.
  ///
  /// In ko, this message translates to:
  /// **'내 발화 (추정)'**
  String get resultUserSpeech;

  /// No description provided for @resultAiSpeech.
  ///
  /// In ko, this message translates to:
  /// **'AI 발화 (추정)'**
  String get resultAiSpeech;

  /// No description provided for @resultRatio.
  ///
  /// In ko, this message translates to:
  /// **'내 발화 비율'**
  String get resultRatio;

  /// No description provided for @resultRatioValue.
  ///
  /// In ko, this message translates to:
  /// **'{percent}% (발화 시간만 기준)'**
  String resultRatioValue(String percent);

  /// No description provided for @resultEstimateNote.
  ///
  /// In ko, this message translates to:
  /// **'음성 인식 타이밍으로 추정한 값이라 실제와 차이가 있을 수 있어요.'**
  String get resultEstimateNote;

  /// No description provided for @resultNotMeasured.
  ///
  /// In ko, this message translates to:
  /// **'발화 시간은 🎤로 말하고 \'답변 소리로 듣기\'를 켰을 때만 추정해요.'**
  String get resultNotMeasured;

  /// No description provided for @resultGenerating.
  ///
  /// In ko, this message translates to:
  /// **'대화 내용으로 피드백을 만드는 중…'**
  String get resultGenerating;

  /// No description provided for @resultRetry.
  ///
  /// In ko, this message translates to:
  /// **'다시 시도'**
  String get resultRetry;

  /// No description provided for @resultReduced.
  ///
  /// In ko, this message translates to:
  /// **'피드백을 일부만 만들 수 있었어요.'**
  String get resultReduced;

  /// No description provided for @resultNoAnswers.
  ///
  /// In ko, this message translates to:
  /// **'답변이 없어서 피드백을 만들지 않았어요.'**
  String get resultNoAnswers;

  /// No description provided for @resultStrengths.
  ///
  /// In ko, this message translates to:
  /// **'잘한 점'**
  String get resultStrengths;

  /// No description provided for @resultCorrections.
  ///
  /// In ko, this message translates to:
  /// **'고쳐 말해볼 문장'**
  String get resultCorrections;

  /// No description provided for @resultNoCorrections.
  ///
  /// In ko, this message translates to:
  /// **'이번 대화에서는 꼭 고칠 문장이 없었어요.'**
  String get resultNoCorrections;

  /// No description provided for @resultSayAgain.
  ///
  /// In ko, this message translates to:
  /// **'다시 말하기'**
  String get resultSayAgain;

  /// No description provided for @resultYouSaid.
  ///
  /// In ko, this message translates to:
  /// **'방금 말한 문장: {text}'**
  String resultYouSaid(String text);

  /// No description provided for @resultListening.
  ///
  /// In ko, this message translates to:
  /// **'듣는 중…'**
  String get resultListening;

  /// No description provided for @resultExpressions.
  ///
  /// In ko, this message translates to:
  /// **'써볼 만한 표현'**
  String get resultExpressions;

  /// No description provided for @resultNextTopic.
  ///
  /// In ko, this message translates to:
  /// **'다음 추천 주제'**
  String get resultNextTopic;

  /// No description provided for @resultTalkAboutIt.
  ///
  /// In ko, this message translates to:
  /// **'이 주제로 대화하기'**
  String get resultTalkAboutIt;

  /// No description provided for @resultReviewNote.
  ///
  /// In ko, this message translates to:
  /// **'고친 문장은 복습 목록에 추가됐어요.'**
  String get resultReviewNote;

  /// No description provided for @setupTitle.
  ///
  /// In ko, this message translates to:
  /// **'대화 준비'**
  String get setupTitle;

  /// No description provided for @setupMode.
  ///
  /// In ko, this message translates to:
  /// **'모드'**
  String get setupMode;

  /// No description provided for @setupLevel.
  ///
  /// In ko, this message translates to:
  /// **'레벨'**
  String get setupLevel;

  /// No description provided for @setupLevelNote.
  ///
  /// In ko, this message translates to:
  /// **'L1 기초 문장 · L2 친숙한 대화 · L3 상황 대응 · L4 의견 표현 · L5 프리토킹'**
  String get setupLevelNote;

  /// No description provided for @setupTopic.
  ///
  /// In ko, this message translates to:
  /// **'주제'**
  String get setupTopic;

  /// No description provided for @setupTopicOptional.
  ///
  /// In ko, this message translates to:
  /// **'주제 (선택)'**
  String get setupTopicOptional;

  /// No description provided for @setupTopicHint.
  ///
  /// In ko, this message translates to:
  /// **'직접 입력해도 돼요'**
  String get setupTopicHint;

  /// No description provided for @setupRandomNote.
  ///
  /// In ko, this message translates to:
  /// **'랜덤 모드는 AI가 매번 다른 주제로 즉흥 질문을 해요.'**
  String get setupRandomNote;

  /// No description provided for @setupScenario.
  ///
  /// In ko, this message translates to:
  /// **'상황'**
  String get setupScenario;

  /// No description provided for @setupRole.
  ///
  /// In ko, this message translates to:
  /// **'AI 역할'**
  String get setupRole;

  /// No description provided for @setupSituation.
  ///
  /// In ko, this message translates to:
  /// **'상황 설명'**
  String get setupSituation;

  /// No description provided for @setupGoal.
  ///
  /// In ko, this message translates to:
  /// **'내 목표'**
  String get setupGoal;

  /// No description provided for @setupLength.
  ///
  /// In ko, this message translates to:
  /// **'시간'**
  String get setupLength;

  /// No description provided for @setupMinutes.
  ///
  /// In ko, this message translates to:
  /// **'{minutes}분'**
  String setupMinutes(int minutes);

  /// No description provided for @setupStart.
  ///
  /// In ko, this message translates to:
  /// **'대화 시작'**
  String get setupStart;

  /// No description provided for @assessmentTitle.
  ///
  /// In ko, this message translates to:
  /// **'레벨 진단'**
  String get assessmentTitle;

  /// No description provided for @assessmentIntro.
  ///
  /// In ko, this message translates to:
  /// **'다섯 가지 질문에 영어로 답하면 시작 레벨을 추천해 드려요. 5분 정도 걸려요.'**
  String get assessmentIntro;

  /// No description provided for @assessmentLimit.
  ///
  /// In ko, this message translates to:
  /// **'짧은 진단이라 정확도에 한계가 있어요. 레벨은 언제든 바꿀 수 있어요.'**
  String get assessmentLimit;

  /// No description provided for @assessmentMicCheck.
  ///
  /// In ko, this message translates to:
  /// **'마이크 확인: 🎤를 누르고 \"Hello, nice to meet you\"라고 말해보세요.'**
  String get assessmentMicCheck;

  /// No description provided for @assessmentMicHeard.
  ///
  /// In ko, this message translates to:
  /// **'들린 말: {text}'**
  String assessmentMicHeard(String text);

  /// No description provided for @assessmentMicNothing.
  ///
  /// In ko, this message translates to:
  /// **'아무 말도 들리지 않았어요. 마이크·음성 인식 권한을 확인하거나, 글자로 답해도 돼요.'**
  String get assessmentMicNothing;

  /// No description provided for @assessmentQuestion.
  ///
  /// In ko, this message translates to:
  /// **'질문 {n} / {total}'**
  String assessmentQuestion(int n, int total);

  /// No description provided for @assessmentAnswerHint.
  ///
  /// In ko, this message translates to:
  /// **'🎤로 말하거나 영어로 입력하세요'**
  String get assessmentAnswerHint;

  /// No description provided for @assessmentNext.
  ///
  /// In ko, this message translates to:
  /// **'다음'**
  String get assessmentNext;

  /// No description provided for @assessmentFinish.
  ///
  /// In ko, this message translates to:
  /// **'결과 보기'**
  String get assessmentFinish;

  /// No description provided for @assessmentEvaluating.
  ///
  /// In ko, this message translates to:
  /// **'답변을 평가하는 중…'**
  String get assessmentEvaluating;

  /// No description provided for @assessmentSuggested.
  ///
  /// In ko, this message translates to:
  /// **'추천 레벨: {level}'**
  String assessmentSuggested(String level);

  /// No description provided for @assessmentRubricNote.
  ///
  /// In ko, this message translates to:
  /// **'AI가 답변 내용(글자)만 보고 평가했어요. 발음과 유창성은 평가하지 않았어요.'**
  String get assessmentRubricNote;

  /// No description provided for @assessmentRelevance.
  ///
  /// In ko, this message translates to:
  /// **'질문에 맞는 답변'**
  String get assessmentRelevance;

  /// No description provided for @assessmentSentences.
  ///
  /// In ko, this message translates to:
  /// **'문장 만들기'**
  String get assessmentSentences;

  /// No description provided for @assessmentVocabulary.
  ///
  /// In ko, this message translates to:
  /// **'어휘 다양성'**
  String get assessmentVocabulary;

  /// No description provided for @assessmentContinuity.
  ///
  /// In ko, this message translates to:
  /// **'이어 말하기'**
  String get assessmentContinuity;

  /// No description provided for @assessmentScore.
  ///
  /// In ko, this message translates to:
  /// **'{score} / 5'**
  String assessmentScore(int score);

  /// No description provided for @assessmentGradingFailed.
  ///
  /// In ko, this message translates to:
  /// **'평가 결과를 읽지 못했어요. 직접 레벨을 골라 주세요.'**
  String get assessmentGradingFailed;

  /// No description provided for @assessmentPick.
  ///
  /// In ko, this message translates to:
  /// **'다른 레벨로 하려면 고르세요'**
  String get assessmentPick;

  /// No description provided for @assessmentAccept.
  ///
  /// In ko, this message translates to:
  /// **'이 레벨로 시작'**
  String get assessmentAccept;

  /// No description provided for @assessmentDone.
  ///
  /// In ko, this message translates to:
  /// **'레벨을 저장했어요.'**
  String get assessmentDone;

  /// No description provided for @historyTitle.
  ///
  /// In ko, this message translates to:
  /// **'학습 기록'**
  String get historyTitle;

  /// No description provided for @historySearch.
  ///
  /// In ko, this message translates to:
  /// **'주제나 대화 내용으로 검색'**
  String get historySearch;

  /// No description provided for @historyEmpty.
  ///
  /// In ko, this message translates to:
  /// **'아직 기록이 없어요.'**
  String get historyEmpty;

  /// No description provided for @historyNoMatch.
  ///
  /// In ko, this message translates to:
  /// **'검색 결과가 없어요.'**
  String get historyNoMatch;

  /// No description provided for @historyAnswers.
  ///
  /// In ko, this message translates to:
  /// **'답변 {count}회'**
  String historyAnswers(int count);

  /// No description provided for @historyUnfinished.
  ///
  /// In ko, this message translates to:
  /// **'진행 중'**
  String get historyUnfinished;

  /// No description provided for @historyDelete.
  ///
  /// In ko, this message translates to:
  /// **'삭제'**
  String get historyDelete;

  /// No description provided for @historyDeleteConfirm.
  ///
  /// In ko, this message translates to:
  /// **'이 대화 기록을 삭제할까요? 교정·복습 항목도 함께 지워져요.'**
  String get historyDeleteConfirm;

  /// No description provided for @cancel.
  ///
  /// In ko, this message translates to:
  /// **'취소'**
  String get cancel;

  /// No description provided for @reviewTitle.
  ///
  /// In ko, this message translates to:
  /// **'복습'**
  String get reviewTitle;

  /// No description provided for @reviewEmpty.
  ///
  /// In ko, this message translates to:
  /// **'지금 복습할 문장이 없어요. 대화를 마치면 고친 문장이 여기에 쌓여요.'**
  String get reviewEmpty;

  /// No description provided for @reviewIntro.
  ///
  /// In ko, this message translates to:
  /// **'예전에 고친 문장을 소리 내어 다시 말해보세요.'**
  String get reviewIntro;

  /// No description provided for @reviewDone.
  ///
  /// In ko, this message translates to:
  /// **'말해봤어요'**
  String get reviewDone;

  /// No description provided for @reviewLater.
  ///
  /// In ko, this message translates to:
  /// **'나중에'**
  String get reviewLater;

  /// No description provided for @homeHistory.
  ///
  /// In ko, this message translates to:
  /// **'학습 기록'**
  String get homeHistory;

  /// No description provided for @homeUnfinished.
  ///
  /// In ko, this message translates to:
  /// **'끝나지 않은 대화가 있어요'**
  String get homeUnfinished;

  /// No description provided for @homeResume.
  ///
  /// In ko, this message translates to:
  /// **'이어서 하기'**
  String get homeResume;

  /// No description provided for @homeCloseAndSee.
  ///
  /// In ko, this message translates to:
  /// **'끝내고 결과 보기'**
  String get homeCloseAndSee;

  /// No description provided for @homePlacementTitle.
  ///
  /// In ko, this message translates to:
  /// **'레벨 진단부터 해볼까요?'**
  String get homePlacementTitle;

  /// No description provided for @homePlacementBody.
  ///
  /// In ko, this message translates to:
  /// **'5개 질문으로 시작 레벨을 추천해 드려요 (약 5분).'**
  String get homePlacementBody;

  /// No description provided for @homePlacementStart.
  ///
  /// In ko, this message translates to:
  /// **'진단 시작'**
  String get homePlacementStart;

  /// No description provided for @homeToday.
  ///
  /// In ko, this message translates to:
  /// **'오늘 말한 시간 (추정)'**
  String get homeToday;

  /// No description provided for @homeWeek.
  ///
  /// In ko, this message translates to:
  /// **'최근 7일 (추정)'**
  String get homeWeek;

  /// No description provided for @homeStreak.
  ///
  /// In ko, this message translates to:
  /// **'연속 학습'**
  String get homeStreak;

  /// No description provided for @homeStreakDays.
  ///
  /// In ko, this message translates to:
  /// **'{days}일'**
  String homeStreakDays(int days);

  /// No description provided for @homeCompleted.
  ///
  /// In ko, this message translates to:
  /// **'완료한 대화'**
  String get homeCompleted;

  /// No description provided for @homeCompletedValue.
  ///
  /// In ko, this message translates to:
  /// **'{count}회 · 완료율 {percent}%'**
  String homeCompletedValue(int count, int percent);

  /// No description provided for @homeAvgAnswer.
  ///
  /// In ko, this message translates to:
  /// **'평균 답변 길이'**
  String get homeAvgAnswer;

  /// No description provided for @homeAvgWords.
  ///
  /// In ko, this message translates to:
  /// **'{words}단어'**
  String homeAvgWords(String words);

  /// No description provided for @homeReviews.
  ///
  /// In ko, this message translates to:
  /// **'복습할 문장'**
  String get homeReviews;

  /// No description provided for @homeReviewCount.
  ///
  /// In ko, this message translates to:
  /// **'{count}개'**
  String homeReviewCount(int count);

  /// No description provided for @homeNoData.
  ///
  /// In ko, this message translates to:
  /// **'—'**
  String get homeNoData;

  /// No description provided for @homeSpeechNote.
  ///
  /// In ko, this message translates to:
  /// **'말한 시간은 🎤로 대화했을 때 음성 인식 타이밍으로 추정해요.'**
  String get homeSpeechNote;

  /// No description provided for @homeNextTopic.
  ///
  /// In ko, this message translates to:
  /// **'추천 주제: {topic}'**
  String homeNextTopic(String topic);

  /// No description provided for @homeDevTools.
  ///
  /// In ko, this message translates to:
  /// **'개발용 테스트'**
  String get homeDevTools;

  /// No description provided for @homePlacementAgain.
  ///
  /// In ko, this message translates to:
  /// **'레벨 다시 진단'**
  String get homePlacementAgain;

  /// No description provided for @settingsDataSection.
  ///
  /// In ko, this message translates to:
  /// **'데이터'**
  String get settingsDataSection;

  /// No description provided for @settingsExport.
  ///
  /// In ko, this message translates to:
  /// **'대화 기록 내보내기 (JSON·CSV)'**
  String get settingsExport;

  /// No description provided for @settingsExportNote.
  ///
  /// In ko, this message translates to:
  /// **'백업으로도 쓸 수 있어요(JSON). 로그인 정보와 API 키는 포함되지 않아요.'**
  String get settingsExportNote;

  /// No description provided for @settingsExportedTo.
  ///
  /// In ko, this message translates to:
  /// **'저장 위치: {path}'**
  String settingsExportedTo(String path);

  /// No description provided for @settingsDeleteAll.
  ///
  /// In ko, this message translates to:
  /// **'모든 대화 기록 삭제'**
  String get settingsDeleteAll;

  /// No description provided for @settingsDeleteAllConfirm.
  ///
  /// In ko, this message translates to:
  /// **'모든 대화, 교정, 복습, 진단 기록을 지울까요? 되돌릴 수 없어요. (로그인과 설정은 유지돼요)'**
  String get settingsDeleteAllConfirm;

  /// No description provided for @settingsDeleted.
  ///
  /// In ko, this message translates to:
  /// **'모든 기록을 삭제했어요.'**
  String get settingsDeleted;

  /// No description provided for @conversationPausedInBackground.
  ///
  /// In ko, this message translates to:
  /// **'앱을 벗어나서 일시정지했어요.\n준비되면 계속하기를 눌러주세요.'**
  String get conversationPausedInBackground;

  /// No description provided for @goalsTitle.
  ///
  /// In ko, this message translates to:
  /// **'학습 목표'**
  String get goalsTitle;

  /// No description provided for @goalsWhy.
  ///
  /// In ko, this message translates to:
  /// **'왜 영어 말하기를 연습하나요?'**
  String get goalsWhy;

  /// No description provided for @goalEveryday.
  ///
  /// In ko, this message translates to:
  /// **'일상 대화'**
  String get goalEveryday;

  /// No description provided for @goalTravel.
  ///
  /// In ko, this message translates to:
  /// **'여행'**
  String get goalTravel;

  /// No description provided for @goalWork.
  ///
  /// In ko, this message translates to:
  /// **'업무·회의'**
  String get goalWork;

  /// No description provided for @goalInterview.
  ///
  /// In ko, this message translates to:
  /// **'면접'**
  String get goalInterview;

  /// No description provided for @goalConfidence.
  ///
  /// In ko, this message translates to:
  /// **'자신감 키우기'**
  String get goalConfidence;

  /// No description provided for @goalsDaily.
  ///
  /// In ko, this message translates to:
  /// **'하루 목표 시간'**
  String get goalsDaily;

  /// No description provided for @goalsMinutes.
  ///
  /// In ko, this message translates to:
  /// **'{minutes}분'**
  String goalsMinutes(int minutes);

  /// No description provided for @goalsNote.
  ///
  /// In ko, this message translates to:
  /// **'목표에 맞는 대화 모드와 시간을 추천해 드려요. 설정에서 언제든 바꿀 수 있어요.'**
  String get goalsNote;

  /// No description provided for @homeGoalProgress.
  ///
  /// In ko, this message translates to:
  /// **'오늘 {done}분 / 목표 {goal}분'**
  String homeGoalProgress(int done, int goal);

  /// No description provided for @homeGoalDone.
  ///
  /// In ko, this message translates to:
  /// **'오늘 목표 달성!'**
  String get homeGoalDone;

  /// No description provided for @homeSuggestedMode.
  ///
  /// In ko, this message translates to:
  /// **'{goal} 목표 추천: {mode}'**
  String homeSuggestedMode(String goal, String mode);

  /// No description provided for @homeGrowth.
  ///
  /// In ko, this message translates to:
  /// **'성장 기록'**
  String get homeGrowth;

  /// No description provided for @growthPeriodWeek.
  ///
  /// In ko, this message translates to:
  /// **'7일'**
  String get growthPeriodWeek;

  /// No description provided for @growthPeriodMonth.
  ///
  /// In ko, this message translates to:
  /// **'30일'**
  String get growthPeriodMonth;

  /// No description provided for @growthPractice.
  ///
  /// In ko, this message translates to:
  /// **'연습 시간'**
  String get growthPractice;

  /// No description provided for @growthSpeech.
  ///
  /// In ko, this message translates to:
  /// **'말한 시간 (추정)'**
  String get growthSpeech;

  /// No description provided for @growthSessions.
  ///
  /// In ko, this message translates to:
  /// **'대화 수'**
  String get growthSessions;

  /// No description provided for @growthSessionCount.
  ///
  /// In ko, this message translates to:
  /// **'{count}회'**
  String growthSessionCount(int count);

  /// No description provided for @growthDaily.
  ///
  /// In ko, this message translates to:
  /// **'날짜별 연습 시간'**
  String get growthDaily;

  /// No description provided for @growthDayBar.
  ///
  /// In ko, this message translates to:
  /// **'{date} · {minutes}분'**
  String growthDayBar(String date, int minutes);

  /// No description provided for @growthEmpty.
  ///
  /// In ko, this message translates to:
  /// **'이 기간에 끝낸 대화가 없어요.'**
  String get growthEmpty;

  /// No description provided for @growthWeakAreas.
  ///
  /// In ko, this message translates to:
  /// **'자주 고친 부분'**
  String get growthWeakAreas;

  /// No description provided for @growthWeakNote.
  ///
  /// In ko, this message translates to:
  /// **'대화 후 AI 피드백이 분류한 교정 기준이에요. 발음은 평가하지 않아요.'**
  String get growthWeakNote;

  /// No description provided for @growthNoWeak.
  ///
  /// In ko, this message translates to:
  /// **'아직 분류된 교정이 없어요. 대화를 마치고 결과를 보면 쌓여요.'**
  String get growthNoWeak;

  /// No description provided for @growthLevels.
  ///
  /// In ko, this message translates to:
  /// **'레벨 변화'**
  String get growthLevels;

  /// No description provided for @growthNoLevels.
  ///
  /// In ko, this message translates to:
  /// **'레벨 진단 기록이 없어요.'**
  String get growthNoLevels;

  /// No description provided for @categoryGrammar.
  ///
  /// In ko, this message translates to:
  /// **'문법 (시제·관사·전치사)'**
  String get categoryGrammar;

  /// No description provided for @categoryWordChoice.
  ///
  /// In ko, this message translates to:
  /// **'단어 선택'**
  String get categoryWordChoice;

  /// No description provided for @categoryStructure.
  ///
  /// In ko, this message translates to:
  /// **'문장 구조·어순'**
  String get categoryStructure;

  /// No description provided for @categoryNaturalness.
  ///
  /// In ko, this message translates to:
  /// **'자연스러운 표현'**
  String get categoryNaturalness;

  /// No description provided for @handsFreeOn.
  ///
  /// In ko, this message translates to:
  /// **'자동 듣기 켜짐 (끄기)'**
  String get handsFreeOn;

  /// No description provided for @handsFreeOff.
  ///
  /// In ko, this message translates to:
  /// **'자동 듣기 꺼짐 (켜기)'**
  String get handsFreeOff;

  /// No description provided for @settingsHandsFree.
  ///
  /// In ko, this message translates to:
  /// **'자동 듣기 (핸즈프리)'**
  String get settingsHandsFree;

  /// No description provided for @settingsHandsFreeNote.
  ///
  /// In ko, this message translates to:
  /// **'AI가 말을 마치면 🎤를 누르지 않아도 바로 들어요. 말이 없으면 두 번 뒤에 멈춰요.'**
  String get settingsHandsFreeNote;

  /// No description provided for @conversationDraftHelp.
  ///
  /// In ko, this message translates to:
  /// **'들린 문장이에요. 고칠 곳이 있으면 고친 뒤 보내기를 누르세요.'**
  String get conversationDraftHelp;

  /// No description provided for @settingsConfirmSpeech.
  ///
  /// In ko, this message translates to:
  /// **'말한 뒤 확인하고 보내기'**
  String get settingsConfirmSpeech;

  /// No description provided for @settingsConfirmSpeechNote.
  ///
  /// In ko, this message translates to:
  /// **'인식된 문장을 입력칸에 먼저 띄워요. 잘못 들린 단어를 고칠 수 있지만 대화가 조금 느려져요.'**
  String get settingsConfirmSpeechNote;

  /// No description provided for @reviewExpressions.
  ///
  /// In ko, this message translates to:
  /// **'최근 배운 표현'**
  String get reviewExpressions;

  /// No description provided for @reviewExpressionsIntro.
  ///
  /// In ko, this message translates to:
  /// **'표현을 넣어 한 문장으로 말해보세요. 다음 대화에서도 코치가 써볼 기회를 만들어 줘요.'**
  String get reviewExpressionsIntro;

  /// No description provided for @reviewUseExpression.
  ///
  /// In ko, this message translates to:
  /// **'넣어서 말하기'**
  String get reviewUseExpression;

  /// No description provided for @reviewExpressionUsed.
  ///
  /// In ko, this message translates to:
  /// **'표현을 넣어 말했어요'**
  String get reviewExpressionUsed;

  /// No description provided for @reviewExpressionMissing.
  ///
  /// In ko, this message translates to:
  /// **'표현이 들리지 않았어요. 다시 해볼까요?'**
  String get reviewExpressionMissing;

  /// No description provided for @a11yYouSaid.
  ///
  /// In ko, this message translates to:
  /// **'나: {text}'**
  String a11yYouSaid(String text);

  /// No description provided for @a11yCoachSaid.
  ///
  /// In ko, this message translates to:
  /// **'코치: {text}'**
  String a11yCoachSaid(String text);

  /// No description provided for @a11yStopListening.
  ///
  /// In ko, this message translates to:
  /// **'듣기 멈추기'**
  String get a11yStopListening;

  /// No description provided for @speechUnavailableTitle.
  ///
  /// In ko, this message translates to:
  /// **'마이크나 음성 인식을 쓸 수 없어요'**
  String get speechUnavailableTitle;

  /// No description provided for @speechUnavailableBody.
  ///
  /// In ko, this message translates to:
  /// **'설정에서 이 앱의 마이크·음성 인식 권한을 켜 주세요. 그동안은 입력해서 대화할 수 있어요.'**
  String get speechUnavailableBody;

  /// No description provided for @speechOpenSettings.
  ///
  /// In ko, this message translates to:
  /// **'설정 열기'**
  String get speechOpenSettings;

  /// No description provided for @speechIssueNetwork.
  ///
  /// In ko, this message translates to:
  /// **'음성 인식 서버에 연결할 수 없어요. 인터넷을 확인하거나 입력해서 계속하세요.'**
  String get speechIssueNetwork;

  /// No description provided for @speechIssueAudio.
  ///
  /// In ko, this message translates to:
  /// **'마이크 소리를 받을 수 없어요. 이어폰·마이크 연결을 확인한 뒤 🎤를 눌러 주세요.'**
  String get speechIssueAudio;

  /// No description provided for @speechIssueBusy.
  ///
  /// In ko, this message translates to:
  /// **'다른 앱이 음성 인식을 쓰고 있어요. 잠시 뒤 🎤를 눌러 주세요.'**
  String get speechIssueBusy;

  /// No description provided for @speechIssueOther.
  ///
  /// In ko, this message translates to:
  /// **'음성 인식이 중간에 멈췄어요. 🎤를 다시 누르거나 입력해 주세요.'**
  String get speechIssueOther;

  /// No description provided for @aiChoiceChatGpt.
  ///
  /// In ko, this message translates to:
  /// **'ChatGPT'**
  String get aiChoiceChatGpt;

  /// No description provided for @aiChoiceLabel.
  ///
  /// In ko, this message translates to:
  /// **'대화에 쓸 AI'**
  String get aiChoiceLabel;

  /// No description provided for @aiChoiceGemini.
  ///
  /// In ko, this message translates to:
  /// **'Gemini (무료 키)'**
  String get aiChoiceGemini;

  /// No description provided for @geminiKeyLabel.
  ///
  /// In ko, this message translates to:
  /// **'Gemini API 키'**
  String get geminiKeyLabel;

  /// No description provided for @geminiKeySave.
  ///
  /// In ko, this message translates to:
  /// **'저장하고 확인'**
  String get geminiKeySave;

  /// No description provided for @geminiKeyRemove.
  ///
  /// In ko, this message translates to:
  /// **'키 삭제'**
  String get geminiKeyRemove;

  /// No description provided for @geminiNoKey.
  ///
  /// In ko, this message translates to:
  /// **'키가 없어요. aistudio.google.com에서 무료로 만든 API 키를 넣어 주세요(결제 등록 없이).'**
  String get geminiNoKey;

  /// No description provided for @geminiKeyStored.
  ///
  /// In ko, this message translates to:
  /// **'키는 기기의 보안 저장소에만 보관돼요. 연결 확인은 모델 목록만 조회해요.'**
  String get geminiKeyStored;

  /// No description provided for @geminiFreeTier.
  ///
  /// In ko, this message translates to:
  /// **'무료 사용량 안에서는 요금이 없어요. 대신 Google 무료 등급에서는 대화 내용이 Google 서비스 개선에 쓰이고 사람이 검토할 수 있어요. 개인정보는 말하지 마세요. 사용량이 많으면 잠시 막힐 수 있어요.'**
  String get geminiFreeTier;

  /// No description provided for @geminiChosenNoKey.
  ///
  /// In ko, this message translates to:
  /// **'Gemini를 고르셨지만 키가 없어요. 키를 넣기 전까지 대화를 시작할 수 없어요.'**
  String get geminiChosenNoKey;

  /// No description provided for @settingsAutoBargeIn.
  ///
  /// In ko, this message translates to:
  /// **'말하면 AI 말 끊기 (이어폰 사용 시)'**
  String get settingsAutoBargeIn;

  /// No description provided for @settingsAutoBargeInNote.
  ///
  /// In ko, this message translates to:
  /// **'자동 듣기가 켜져 있을 때 AI가 말하는 동안에도 들어요. 스피커로 들으면 AI 목소리를 내 말로 알아들을 수 있어서 이어폰을 쓸 때만 켜세요.'**
  String get settingsAutoBargeInNote;

  /// No description provided for @settingsDiagnostics.
  ///
  /// In ko, this message translates to:
  /// **'진단 정보 내보내기'**
  String get settingsDiagnostics;

  /// No description provided for @settingsDiagnosticsNote.
  ///
  /// In ko, this message translates to:
  /// **'앱 오류 기록(최근 {count}건)을 파일로 저장해요. 대화 내용과 키는 들어가지 않아요. 문제를 알릴 때 첨부해 주세요.'**
  String settingsDiagnosticsNote(int count);

  /// No description provided for @settingsDiagnosticsClear.
  ///
  /// In ko, this message translates to:
  /// **'오류 기록 지우기'**
  String get settingsDiagnosticsClear;

  /// No description provided for @languageLabel.
  ///
  /// In ko, this message translates to:
  /// **'언어'**
  String get languageLabel;

  /// No description provided for @languageSystem.
  ///
  /// In ko, this message translates to:
  /// **'기기 설정'**
  String get languageSystem;

  /// No description provided for @languageKo.
  ///
  /// In ko, this message translates to:
  /// **'한국어'**
  String get languageKo;

  /// No description provided for @languageEn.
  ///
  /// In ko, this message translates to:
  /// **'English'**
  String get languageEn;

  /// No description provided for @settingsRestore.
  ///
  /// In ko, this message translates to:
  /// **'백업 파일에서 복원'**
  String get settingsRestore;

  /// No description provided for @settingsRestoreNote.
  ///
  /// In ko, this message translates to:
  /// **'내보낸 speaking-coach.json을 고르면 기록·복습·목표를 불러와요. 이미 있는 대화는 건너뛰어요.'**
  String get settingsRestoreNote;

  /// No description provided for @settingsRestored.
  ///
  /// In ko, this message translates to:
  /// **'대화 {added}개를 복원했어요 (이미 있던 {skipped}개는 건너뜀)'**
  String settingsRestored(int added, int skipped);

  /// No description provided for @settingsRestoreFailed.
  ///
  /// In ko, this message translates to:
  /// **'Speaking Coach 백업 파일이 아니에요. 내보내기로 만든 speaking-coach.json을 골라 주세요.'**
  String get settingsRestoreFailed;

  /// No description provided for @speechAndroidTip.
  ///
  /// In ko, this message translates to:
  /// **'들린 말이 계속 이상하면: 휴대폰 설정 → 일반 → 키보드 목록 및 기본값(또는 \'음성 입력\') → 기본 음성 인식 서비스를 \'Google\'로 바꾸고, Google 음성 인식에 영어(미국)가 받아져 있는지 확인해 주세요.'**
  String get speechAndroidTip;

  /// No description provided for @assessmentKeepTalking.
  ///
  /// In ko, this message translates to:
  /// **'잠깐 쉬어도 계속 들어요. 다 말했으면 ■를 누르세요.'**
  String get assessmentKeepTalking;

  /// No description provided for @pasteTitle.
  ///
  /// In ko, this message translates to:
  /// **'ChatGPT 로그인 마무리'**
  String get pasteTitle;

  /// No description provided for @pasteSteps.
  ///
  /// In ko, this message translates to:
  /// **'1. 새로 열린 탭에서 ChatGPT에 로그인하세요.\n2. 로그인 후 \'사이트에 연결할 수 없음\' 페이지가 뜨면 정상이에요.\n3. 그 페이지 주소창의 주소 전체(http://127.0.0.1:1455/auth/callback?code=…)를 복사해서 아래에 붙여넣으세요.'**
  String get pasteSteps;

  /// No description provided for @pasteLabel.
  ///
  /// In ko, this message translates to:
  /// **'주소 붙여넣기'**
  String get pasteLabel;

  /// No description provided for @pasteInvalid.
  ///
  /// In ko, this message translates to:
  /// **'로그인 후 받은 주소가 아니에요. 127.0.0.1로 시작하는 주소 전체를 붙여넣어 주세요.'**
  String get pasteInvalid;

  /// No description provided for @pasteConfirm.
  ///
  /// In ko, this message translates to:
  /// **'확인'**
  String get pasteConfirm;

  /// No description provided for @speechUnavailableWeb.
  ///
  /// In ko, this message translates to:
  /// **'이 브라우저에서는 음성 인식을 쓸 수 없어요. 아이폰·아이패드는 Safari, 그 외에는 Chrome 최신 버전에서 열고 마이크를 허용해 주세요. 그동안은 입력해서 대화할 수 있어요.'**
  String get speechUnavailableWeb;

  /// No description provided for @setupAiTopic.
  ///
  /// In ko, this message translates to:
  /// **'🎲 랜덤 (AI가 정해요)'**
  String get setupAiTopic;

  /// No description provided for @setupAiScenario.
  ///
  /// In ko, this message translates to:
  /// **'🎲 랜덤 상황 (AI가 정해요)'**
  String get setupAiScenario;

  /// No description provided for @setupAiTopicNote.
  ///
  /// In ko, this message translates to:
  /// **'대화를 시작하면 AI가 매번 다른 주제를 골라 첫마디에 알려줘요.'**
  String get setupAiTopicNote;

  /// No description provided for @setupAiScenarioNote.
  ///
  /// In ko, this message translates to:
  /// **'AI가 상황과 자기 역할을 정해서 첫마디에 알려줘요.'**
  String get setupAiScenarioNote;

  /// No description provided for @resultWordOrder.
  ///
  /// In ko, this message translates to:
  /// **'어순 체크'**
  String get resultWordOrder;

  /// No description provided for @resultWordOrderSummary.
  ///
  /// In ko, this message translates to:
  /// **'{total}문장 중 {ok}문장 어순이 맞았어요'**
  String resultWordOrderSummary(int total, int ok);

  /// No description provided for @resultWordOrderOk.
  ///
  /// In ko, this message translates to:
  /// **'어순 맞음'**
  String get resultWordOrderOk;

  /// No description provided for @resultWordOrderWrong.
  ///
  /// In ko, this message translates to:
  /// **'어순 다시 보기'**
  String get resultWordOrderWrong;

  /// No description provided for @resultWordOrderNote.
  ///
  /// In ko, this message translates to:
  /// **'어순이 틀린 문장은 복습에서 바른 어순으로 다시 말해봐요. 발음·시제는 여기서 보지 않아요.'**
  String get resultWordOrderNote;

  /// No description provided for @reviewKindWordOrder.
  ///
  /// In ko, this message translates to:
  /// **'어순 교정'**
  String get reviewKindWordOrder;

  /// No description provided for @practiceMatched.
  ///
  /// In ko, this message translates to:
  /// **'교정된 문장대로 말했어요'**
  String get practiceMatched;

  /// No description provided for @practiceDiffers.
  ///
  /// In ko, this message translates to:
  /// **'조금 달라요. 교정된 문장을 보고 다시 말해볼까요?'**
  String get practiceDiffers;

  /// No description provided for @settingsReviewSection.
  ///
  /// In ko, this message translates to:
  /// **'복습'**
  String get settingsReviewSection;

  /// No description provided for @settingsReviewRepeats.
  ///
  /// In ko, this message translates to:
  /// **'문장마다 반복 횟수'**
  String get settingsReviewRepeats;

  /// No description provided for @settingsReviewRepeatsNote.
  ///
  /// In ko, this message translates to:
  /// **'교정된 문장을 말한 횟수만큼 체크 박스가 채워져요. 인식이 틀려도 직접 눌러 체크할 수 있어요.'**
  String get settingsReviewRepeatsNote;

  /// No description provided for @settingsRepeatTimes.
  ///
  /// In ko, this message translates to:
  /// **'{count}회'**
  String settingsRepeatTimes(int count);

  /// No description provided for @reviewRepeatProgress.
  ///
  /// In ko, this message translates to:
  /// **'반복 {done}/{total}'**
  String reviewRepeatProgress(int done, int total);

  /// No description provided for @reviewRepeatDone.
  ///
  /// In ko, this message translates to:
  /// **'반복 완료!'**
  String get reviewRepeatDone;

  /// No description provided for @reviewRepeatBox.
  ///
  /// In ko, this message translates to:
  /// **'{n}번째 반복'**
  String reviewRepeatBox(int n);

  /// No description provided for @speechEngineLabel.
  ///
  /// In ko, this message translates to:
  /// **'음성 인식'**
  String get speechEngineLabel;

  /// No description provided for @speechEngineDevice.
  ///
  /// In ko, this message translates to:
  /// **'기기 내장'**
  String get speechEngineDevice;

  /// No description provided for @speechEngineGemini.
  ///
  /// In ko, this message translates to:
  /// **'Gemini (정확)'**
  String get speechEngineGemini;

  /// No description provided for @speechEngineGeminiNote.
  ///
  /// In ko, this message translates to:
  /// **'말을 마치면 녹음을 Gemini가 받아써요. 이름·억양을 훨씬 잘 알아듣지만 받아쓰는 데 1~2초 걸려요. 녹음은 저장하지 않고, 무료 키에서는 Google이 서비스 개선에 쓸 수 있어요.'**
  String get speechEngineGeminiNote;

  /// No description provided for @speechEngineNeedsKey.
  ///
  /// In ko, this message translates to:
  /// **'Gemini 인식에는 무료 키가 필요해요. 키가 없으면 기기 내장 인식으로 들어요.'**
  String get speechEngineNeedsKey;

  /// No description provided for @shadowingTitle.
  ///
  /// In ko, this message translates to:
  /// **'따라 말하기'**
  String get shadowingTitle;

  /// No description provided for @shadowingNote.
  ///
  /// In ko, this message translates to:
  /// **'코치가 한 문장을 듣고 그대로 따라 말해요. 똑같이 말하면 칸이 채워져요.'**
  String get shadowingNote;

  /// No description provided for @shadowingListen.
  ///
  /// In ko, this message translates to:
  /// **'듣기'**
  String get shadowingListen;

  /// No description provided for @shadowingSlow.
  ///
  /// In ko, this message translates to:
  /// **'천천히'**
  String get shadowingSlow;

  /// No description provided for @shadowingRepeat.
  ///
  /// In ko, this message translates to:
  /// **'따라 말하기'**
  String get shadowingRepeat;

  /// No description provided for @lessonWriting.
  ///
  /// In ko, this message translates to:
  /// **'내 실수를 보고 설명을 만드는 중…'**
  String get lessonWriting;

  /// No description provided for @lessonExamples.
  ///
  /// In ko, this message translates to:
  /// **'예문'**
  String get lessonExamples;

  /// No description provided for @lessonPractice.
  ///
  /// In ko, this message translates to:
  /// **'내 문장으로 연습'**
  String get lessonPractice;

  /// No description provided for @lessonPracticeNote.
  ///
  /// In ko, this message translates to:
  /// **'실제로 말했던 문장의 교정본이에요. 그대로 말하면 칸이 채워져요.'**
  String get lessonPracticeNote;

  /// No description provided for @lessonRewrite.
  ///
  /// In ko, this message translates to:
  /// **'다시 만들기'**
  String get lessonRewrite;

  /// No description provided for @lessonNoMistakes.
  ///
  /// In ko, this message translates to:
  /// **'이 유형의 교정이 아직 없어요.'**
  String get lessonNoMistakes;

  /// No description provided for @lessonOpen.
  ///
  /// In ko, this message translates to:
  /// **'미니 설명 보기'**
  String get lessonOpen;

  /// No description provided for @lessonAiNote.
  ///
  /// In ko, this message translates to:
  /// **'AI가 내 실수를 바탕으로 만든 설명이에요.'**
  String get lessonAiNote;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ko'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ko':
      return AppLocalizationsKo();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
