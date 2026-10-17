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
