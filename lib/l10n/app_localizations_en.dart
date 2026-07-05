// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'SalatApp';

  @override
  String get welcomeTitle => 'Reach your mosque on time';

  @override
  String get welcomeBody =>
      'SalatApp tells you the exact moment to leave home so you arrive at your mosque right on time for the adhan or iqama.\n\nTo calculate accurate prayer times for your area, the app needs your location.';

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
}
