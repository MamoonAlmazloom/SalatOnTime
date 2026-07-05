import 'arrival_target.dart';
import 'prayer.dart';

/// The computed schedule for one prayer: adhan, iqama, and when to leave home.
class PrayerTiming {
  final Prayer prayer;
  final DateTime adhanTime;
  final DateTime iqamaTime;
  final ArrivalTarget target;
  final DateTime leaveTime;

  const PrayerTiming({
    required this.prayer,
    required this.adhanTime,
    required this.iqamaTime,
    required this.target,
    required this.leaveTime,
  });

  /// The time the user wants to be at the mosque.
  DateTime get arrivalTime =>
      target == ArrivalTarget.adhan ? adhanTime : iqamaTime;

  @override
  String toString() =>
      'PrayerTiming(${prayer.name}: adhan $adhanTime, iqama $iqamaTime, '
      'leave $leaveTime)';
}
