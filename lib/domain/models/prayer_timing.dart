import 'arrival_target.dart';
import 'prayer.dart';

/// The computed schedule for one prayer: adhan, iqama, and when to leave home.
class PrayerTiming {
  final Prayer prayer;
  final DateTime adhanTime;
  final DateTime iqamaTime;
  final ArrivalTarget target;

  /// The time the user wants to be at the mosque: adhan or iqama for daily
  /// prayers, a while before the adhan for Jumu'ah.
  final DateTime arrivalTime;
  final DateTime leaveTime;

  /// Friday Dhuhr computed as Jumu'ah (arrive-before-adhan target,
  /// displayed and announced as Jumu'ah).
  final bool isJumuah;

  const PrayerTiming({
    required this.prayer,
    required this.adhanTime,
    required this.iqamaTime,
    required this.target,
    required this.arrivalTime,
    required this.leaveTime,
    this.isJumuah = false,
  });

  @override
  String toString() =>
      'PrayerTiming(${prayer.name}: adhan $adhanTime, iqama $iqamaTime, '
      'leave $leaveTime)';
}
