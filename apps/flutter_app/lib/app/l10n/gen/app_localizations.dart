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
  /// **'OpenAI 계정에 사용 가능한 크레딧이 없어요. platform.openai.com의 Billing에서 결제 수단이나 크레딧을 확인해 주세요.'**
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
  /// **'대화 내용(글자)은 연결한 AI(ChatGPT 등)로 보내져 답변을 만들어요.'**
  String get onboardingPrivacyText;

  /// No description provided for @onboardingPrivacyVoice.
  ///
  /// In ko, this message translates to:
  /// **'음성 인식은 기기에 내장된 기능을 써요. 기기 설정에 따라 Apple·Google·Microsoft 서버에서 처리될 수 있어요.'**
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
  /// **'OpenAI API 키(사용량만큼 별도 과금)는 나중에 선택 항목으로 추가돼요.'**
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

  /// No description provided for @conversationEndedTitle.
  ///
  /// In ko, this message translates to:
  /// **'대화를 마쳤어요'**
  String get conversationEndedTitle;

  /// No description provided for @conversationEndedSummary.
  ///
  /// In ko, this message translates to:
  /// **'연습 시간 {minutes}분 {seconds}초 · 내 답변 {turns}회'**
  String conversationEndedSummary(int minutes, int seconds, int turns);

  /// No description provided for @conversationEndedNext.
  ///
  /// In ko, this message translates to:
  /// **'교정과 복습은 다음 업데이트에서 추가돼요.'**
  String get conversationEndedNext;

  /// No description provided for @conversationBackHome.
  ///
  /// In ko, this message translates to:
  /// **'홈으로'**
  String get conversationBackHome;
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
