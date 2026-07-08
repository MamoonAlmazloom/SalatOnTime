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
    int? workTravelMinutes,
  }) {
    // Praying near work/school: that place's travel time replaces the
    // home-to-mosque one (the caller decides when the profile applies).
    final isWork = workTravelMinutes != null;
    // Friday Dhuhr is Jumu'ah: the goal is to be seated before the adhan
    // and khutbah, so the arrival target sits ahead of the adhan itself.
    final isJumuah = settings.jumuahEnabled &&
        prayer == Prayer.dhuhr &&
        adhanTime.weekday == DateTime.friday;

    final iqamaTime = adhanTime.add(
      Duration(minutes: settings.iqamaOffsets[prayer] ?? 0),
    );
    final target =
        settings.arrivalTargets[prayer] ?? ArrivalTarget.iqama;
    final arrivalTime = isJumuah
        ? adhanTime
            .subtract(Duration(minutes: settings.jumuahArriveEarlyMinutes))
        : (target == ArrivalTarget.adhan ? adhanTime : iqamaTime);
    // The Jumu'ah or work mosque may be a different (farther) one.
    final travelMinutes = isJumuah
        ? (settings.jumuahTravelMinutes ?? settings.travelMinutes)
        : (workTravelMinutes ?? settings.travelMinutes);
    final leaveTime = arrivalTime.subtract(
      Duration(
        minutes: travelMinutes + settings.preparationMinutesFor(prayer),
      ),
    );
    return PrayerTiming(
      prayer: prayer,
      adhanTime: adhanTime,
      iqamaTime: iqamaTime,
      target: target,
      arrivalTime: arrivalTime,
      leaveTime: leaveTime,
      isJumuah: isJumuah,
      isWork: isWork && !isJumuah,
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
