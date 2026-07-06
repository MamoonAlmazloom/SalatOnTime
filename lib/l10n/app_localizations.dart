import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
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

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
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
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'SalatApp'**
  String get appTitle;

  /// No description provided for @welcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Reach your mosque on time'**
  String get welcomeTitle;

  /// No description provided for @welcomeBody.
  ///
  /// In en, this message translates to:
  /// **'SalatApp tells you the exact moment to leave home so you arrive at your mosque right on time for the adhan or iqama.\n\nTo calculate accurate prayer times for your area, the app needs your location.'**
  String get welcomeBody;

  /// No description provided for @allowLocation.
  ///
  /// In en, this message translates to:
  /// **'Allow location'**
  String get allowLocation;

  /// No description provided for @locationGranted.
  ///
  /// In en, this message translates to:
  /// **'Location found'**
  String get locationGranted;

  /// No description provided for @locationDeniedNote.
  ///
  /// In en, this message translates to:
  /// **'Location unavailable — you can still continue. The map will start in Riyadh; drag it to your area.'**
  String get locationDeniedNote;

  /// No description provided for @stepNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get stepNext;

  /// No description provided for @stepBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get stepBack;

  /// No description provided for @stepFinish.
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get stepFinish;

  /// No description provided for @mosqueStepTitle.
  ///
  /// In en, this message translates to:
  /// **'Pick your mosque'**
  String get mosqueStepTitle;

  /// No description provided for @mosqueStepHint.
  ///
  /// In en, this message translates to:
  /// **'Move the map until the pin sits on your mosque'**
  String get mosqueStepHint;

  /// No description provided for @mosqueNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Mosque name'**
  String get mosqueNameLabel;

  /// No description provided for @mosqueNameDefault.
  ///
  /// In en, this message translates to:
  /// **'My mosque'**
  String get mosqueNameDefault;

  /// No description provided for @travelStepTitle.
  ///
  /// In en, this message translates to:
  /// **'Getting there'**
  String get travelStepTitle;

  /// No description provided for @travelMinutesLabel.
  ///
  /// In en, this message translates to:
  /// **'Time from home to mosque (minutes)'**
  String get travelMinutesLabel;

  /// No description provided for @calculateForMe.
  ///
  /// In en, this message translates to:
  /// **'Calculate for me'**
  String get calculateForMe;

  /// No description provided for @walking.
  ///
  /// In en, this message translates to:
  /// **'Walking'**
  String get walking;

  /// No description provided for @driving.
  ///
  /// In en, this message translates to:
  /// **'Driving'**
  String get driving;

  /// No description provided for @travelCalcFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t calculate the route — please enter the minutes manually.'**
  String get travelCalcFailed;

  /// No description provided for @travelCalcNeedsLocation.
  ///
  /// In en, this message translates to:
  /// **'Allow location in the first step to use automatic calculation.'**
  String get travelCalcNeedsLocation;

  /// No description provided for @wuduToggle.
  ///
  /// In en, this message translates to:
  /// **'I make wudu before leaving (+{minutes} min)'**
  String wuduToggle(int minutes);

  /// No description provided for @bathroomToggle.
  ///
  /// In en, this message translates to:
  /// **'I need the bathroom before prayer'**
  String get bathroomToggle;

  /// No description provided for @bathroomMinutesLabel.
  ///
  /// In en, this message translates to:
  /// **'Minutes for the bathroom'**
  String get bathroomMinutesLabel;

  /// No description provided for @offsetsStepTitle.
  ///
  /// In en, this message translates to:
  /// **'Iqama at your mosque'**
  String get offsetsStepTitle;

  /// No description provided for @offsetsStepHint.
  ///
  /// In en, this message translates to:
  /// **'How many minutes after the adhan is the iqama held? Choose also whether you want to arrive by the adhan or the iqama.'**
  String get offsetsStepHint;

  /// No description provided for @arriveBy.
  ///
  /// In en, this message translates to:
  /// **'Arrive by'**
  String get arriveBy;

  /// No description provided for @targetAdhan.
  ///
  /// In en, this message translates to:
  /// **'Adhan'**
  String get targetAdhan;

  /// No description provided for @targetIqama.
  ///
  /// In en, this message translates to:
  /// **'Iqama'**
  String get targetIqama;

  /// No description provided for @prayerFajr.
  ///
  /// In en, this message translates to:
  /// **'Fajr'**
  String get prayerFajr;

  /// No description provided for @prayerDhuhr.
  ///
  /// In en, this message translates to:
  /// **'Dhuhr'**
  String get prayerDhuhr;

  /// No description provided for @prayerAsr.
  ///
  /// In en, this message translates to:
  /// **'Asr'**
  String get prayerAsr;

  /// No description provided for @prayerMaghrib.
  ///
  /// In en, this message translates to:
  /// **'Maghrib'**
  String get prayerMaghrib;

  /// No description provided for @prayerIsha.
  ///
  /// In en, this message translates to:
  /// **'Isha'**
  String get prayerIsha;

  /// No description provided for @minutesShort.
  ///
  /// In en, this message translates to:
  /// **'min'**
  String get minutesShort;

  /// No description provided for @homeSetupComplete.
  ///
  /// In en, this message translates to:
  /// **'Setup complete!'**
  String get homeSetupComplete;

  /// No description provided for @homeComingSoon.
  ///
  /// In en, this message translates to:
  /// **'The Home screen with live countdowns is coming next.'**
  String get homeComingSoon;

  /// No description provided for @homeMosqueLine.
  ///
  /// In en, this message translates to:
  /// **'Mosque: {name}'**
  String homeMosqueLine(String name);

  /// No description provided for @homeTravelLine.
  ///
  /// In en, this message translates to:
  /// **'Travel time: {minutes} min'**
  String homeTravelLine(int minutes);

  /// No description provided for @adhanIn.
  ///
  /// In en, this message translates to:
  /// **'Adhan in'**
  String get adhanIn;

  /// No description provided for @iqamaIn.
  ///
  /// In en, this message translates to:
  /// **'Iqama in'**
  String get iqamaIn;

  /// No description provided for @leaveIn.
  ///
  /// In en, this message translates to:
  /// **'Leave home in'**
  String get leaveIn;

  /// No description provided for @leaveNow.
  ///
  /// In en, this message translates to:
  /// **'Leave now!'**
  String get leaveNow;

  /// No description provided for @adhanPassed.
  ///
  /// In en, this message translates to:
  /// **'Adhan called'**
  String get adhanPassed;

  /// No description provided for @todaysPrayers.
  ///
  /// In en, this message translates to:
  /// **'Today\'s prayers'**
  String get todaysPrayers;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @notifTitle.
  ///
  /// In en, this message translates to:
  /// **'Time to leave for {prayer} 🕌'**
  String notifTitle(String prayer);

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'Auto'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @sectionMosque.
  ///
  /// In en, this message translates to:
  /// **'Mosque & location'**
  String get sectionMosque;

  /// No description provided for @changeMosque.
  ///
  /// In en, this message translates to:
  /// **'Change mosque'**
  String get changeMosque;

  /// No description provided for @updateHomeLocation.
  ///
  /// In en, this message translates to:
  /// **'Update home location'**
  String get updateHomeLocation;

  /// No description provided for @homeLocationUpdated.
  ///
  /// In en, this message translates to:
  /// **'Home location updated'**
  String get homeLocationUpdated;

  /// No description provided for @homeLocationFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t get your location'**
  String get homeLocationFailed;

  /// No description provided for @sectionTiming.
  ///
  /// In en, this message translates to:
  /// **'Timing'**
  String get sectionTiming;

  /// No description provided for @safetyMarginLabel.
  ///
  /// In en, this message translates to:
  /// **'Safety margin (minutes)'**
  String get safetyMarginLabel;

  /// No description provided for @sectionPerPrayer.
  ///
  /// In en, this message translates to:
  /// **'Per-prayer settings'**
  String get sectionPerPrayer;

  /// No description provided for @alertStyleTitle.
  ///
  /// In en, this message translates to:
  /// **'Alert style'**
  String get alertStyleTitle;

  /// No description provided for @alertStandard.
  ///
  /// In en, this message translates to:
  /// **'Standard notification'**
  String get alertStandard;

  /// No description provided for @alertStandardDesc.
  ///
  /// In en, this message translates to:
  /// **'A normal notification with the default sound.'**
  String get alertStandardDesc;

  /// No description provided for @alertAlarm.
  ///
  /// In en, this message translates to:
  /// **'Alarm style (loud)'**
  String get alertAlarm;

  /// No description provided for @alertAlarmDesc.
  ///
  /// In en, this message translates to:
  /// **'Rings on the alarm volume — sounds even in silent mode on most phones — and shows on the lock screen.'**
  String get alertAlarmDesc;

  /// No description provided for @notifBody.
  ///
  /// In en, this message translates to:
  /// **'Leave now to reach {mosque} for {prayer} on time.'**
  String notifBody(String mosque, String prayer);
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
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
