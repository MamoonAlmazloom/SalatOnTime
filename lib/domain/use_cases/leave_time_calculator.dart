import '../models/arrival_target.dart';
import '../models/prayer.dart';
import '../models/prayer_timing.dart';
import '../models/timing_settings.dart';

/// Pure arithmetic at the heart of the app: given an adhan time and the
/// user's settings, compute iqama time and the moment to leave home.
class LeaveTimeCalculator {
  const LeaveTimeCalculator();

  PrayerTiming compute({
    required Prayer prayer,
    required DateTime adhanTime,
    required TimingSettings settings,
  }) {
    final iqamaTime = adhanTime.add(
      Duration(minutes: settings.iqamaOffsets[prayer] ?? 0),
    );
    final target =
        settings.arrivalTargets[prayer] ?? ArrivalTarget.iqama;
    final arrivalTime =
        target == ArrivalTarget.adhan ? adhanTime : iqamaTime;
    final leaveTime = arrivalTime.subtract(
      Duration(
        minutes:
            settings.travelMinutes + settings.preparationMinutesFor(prayer),
      ),
    );
    return PrayerTiming(
      prayer: prayer,
      adhanTime: adhanTime,
      iqamaTime: iqamaTime,
      target: target,
      leaveTime: leaveTime,
    );
  }

  /// Computes the full day's schedule from a map of adhan times.
  List<PrayerTiming> computeDay({
    required Map<Prayer, DateTime> adhanTimes,
    required TimingSettings settings,
  }) {
    return [
      for (final prayer in Prayer.values)
        if (adhanTimes[prayer] != null)
          compute(
            prayer: prayer,
            adhanTime: adhanTimes[prayer]!,
            settings: settings,
          ),
    ];
  }
}
