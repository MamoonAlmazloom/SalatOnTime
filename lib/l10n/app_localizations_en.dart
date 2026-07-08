// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Salat On Time';

  @override
  String get welcomeTitle => 'Reach your mosque on time';

  @override
  String get welcomeBody =>
      'Salat On Time tells you the exact moment to leave home so you arrive at your mosque right on time for the adhan or iqama.\n\nTo calculate accurate prayer times for your area, the app needs your location.';

  @override
  String get allowLocation => 'Allow location';

  @override
  String get locationGranted => 'Location found';

  @override
  String get locationDeniedNote =>
      'Location unavailable — you can still continue. The map will start in Riyadh; drag it to your area.';

  @override
  String get stepNext => 'Next';

  @override
  String get stepBack => 'Back';

  @override
  String get stepFinish => 'Finish';

  @override
  String get mosqueStepTitle => 'Pick your mosque';

  @override
  String get mosqueStepHint => 'Move the map until the pin sits on your mosque';

  @override
  String get mosqueNameLabel => 'Mosque name';

  @override
  String get mosqueNameDefault => 'My mosque';

  @override
  String get travelStepTitle => 'Getting there';

  @override
  String get travelMinutesLabel => 'Time from home to mosque (minutes)';

  @override
  String get calculateForMe => 'Calculate for me';

  @override
  String get walking => 'Walking';

  @override
  String get driving => 'Driving';

  @override
  String get travelCalcFailed =>
      'Couldn\'t calculate the route — please enter the minutes manually.';

  @override
  String get travelCalcNeedsLocation =>
      'Allow location in the first step to use automatic calculation.';

  @override
  String wuduToggle(int minutes) {
    return 'I make wudu before leaving (+$minutes min)';
  }

  @override
  String get bathroomToggle => 'I need the bathroom before prayer';

  @override
  String get bathroomMinutesLabel => 'Minutes for the bathroom';

  @override
  String get offsetsStepTitle => 'Iqama at your mosque';

  @override
  String get offsetsStepHint =>
      'How many minutes after the adhan is the iqama held? Choose also whether you want to arrive by the adhan or the iqama.';

  @override
  String get arriveBy => 'Arrive by';

  @override
  String get targetAdhan => 'Adhan';

  @override
  String get targetIqama => 'Iqama';

  @override
  String get prayerFajr => 'Fajr';

  @override
  String get prayerDhuhr => 'Dhuhr';

  @override
  String get prayerAsr => 'Asr';

  @override
  String get prayerMaghrib => 'Maghrib';

  @override
  String get prayerIsha => 'Isha';

  @override
  String get prayerJumuah => 'Jumu\'ah';

  @override
  String get sectionJumuah => 'Jumu\'ah';

  @override
  String get jumuahToggle => 'I attend Jumu\'ah prayer';

  @override
  String get jumuahArriveEarlyLabel => 'Arrive before the adhan (minutes)';

  @override
  String get jumuahHint =>
      'On Fridays, Dhuhr becomes Jumu\'ah: the leave time is calculated so you arrive at the mosque this many minutes before the adhan.';

  @override
  String get prayerSettingsHint =>
      'Iqama offset and arrival target for each prayer';

  @override
  String get minutesShort => 'min';

  @override
  String get homeSetupComplete => 'Setup complete!';

  @override
  String get homeComingSoon =>
      'The Home screen with live countdowns is coming next.';

  @override
  String homeMosqueLine(String name) {
    return 'Mosque: $name';
  }

  @override
  String homeTravelLine(int minutes) {
    return 'Travel time: $minutes min';
  }

  @override
  String get adhanIn => 'Adhan in';

  @override
  String get iqamaIn => 'Iqama in';

  @override
  String get leaveIn => 'Leave home in';

  @override
  String get leaveNow => 'Leave now!';

  @override
  String get adhanPassed => 'Adhan called';

  @override
  String get todaysPrayers => 'Today\'s prayers';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String notifTitle(String prayer) {
    return 'Time to leave for $prayer 🕌';
  }

  @override
  String get settingsTitle => 'Settings';

  @override
  String get appearance => 'Appearance';

  @override
  String get language => 'Language';

  @override
  String get themeSystem => 'Auto';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get sectionMosque => 'Mosque & location';

  @override
  String get changeMosque => 'Change mosque';

  @override
  String get updateHomeLocation => 'Update home location';

  @override
  String get homeLocationUpdated => 'Home location updated';

  @override
  String get homeLocationFailed => 'Couldn\'t get your location';

  @override
  String get sectionTiming => 'Timing';

  @override
  String get safetyMarginLabel => 'Safety margin (minutes)';

  @override
  String get sectionPerPrayer => 'Per-prayer settings';

  @override
  String get about => 'About';

  @override
  String get privacyPolicy => 'Privacy policy';

  @override
  String get calcMethodNote => 'Prayer time calculation method';

  @override
  String get calcMethodExplanation =>
      'Prayer times are calculated entirely on your device using the Umm al-Qura method (the official method of Saudi Arabia), based on your mosque\'s location — no internet connection is used.\n\nThe iqama time is the adhan time plus the offset you set for each prayer, and the leave-home time works backwards from your arrival target: travel time, wudu, bathroom, and safety margin.';

  @override
  String get okLabel => 'OK';

  @override
  String get notifOffTitle => 'Notifications are off';

  @override
  String get notifOffBody =>
      'Leave-time alerts are the heart of this app — with notifications off it cannot tell you when to leave for prayer. Please turn them on.';

  @override
  String get notifOffButton => 'Enable notifications';

  @override
  String get alertStyleTitle => 'Alert style';

  @override
  String get alertStandard => 'Standard notification';

  @override
  String get alertStandardDesc =>
      'A normal notification with the default sound.';

  @override
  String get alertAlarm => 'Alarm style (loud)';

  @override
  String get alertAlarmDesc =>
      'Rings on the alarm volume — sounds even in silent mode on most phones — and shows on the lock screen.';

  @override
  String notifBody(String mosque, String prayer) {
    return 'Leave now to reach $mosque for $prayer on time.';
  }
}
