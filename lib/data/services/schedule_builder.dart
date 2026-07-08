import '../../domain/models/mosque.dart';
import '../../domain/models/prayer.dart';
import '../../domain/models/prayer_timing.dart';
import '../../domain/models/timing_settings.dart';
import '../../domain/models/work_profile.dart';
import '../../domain/use_cases/leave_time_calculator.dart';
import 'prayer_calculator_service.dart';

/// Builds one day's prayer schedule, choosing per prayer which place
/// governs it: the home mosque, the work/school mosque (schedule-based
/// profile), or the Jumu'ah mosque on Fridays (Jumu'ah wins over work).
/// Shared by the Home screen and the background rescheduler.
class ScheduleBuilder {
  const ScheduleBuilder();

  static const _calculator = PrayerCalculatorService();
  static const _leaveCalculator = LeaveTimeCalculator();

  List<PrayerTiming> dayFor({
    required DateTime day,
    required Mosque mosque,
    Mosque? jumuahMosque,
    WorkProfile workProfile = const WorkProfile(),
    required TimingSettings settings,
  }) {
    Map<Prayer, DateTime> timesAt(Mosque m) => _calculator.timesFor(
          latitude: m.latitude,
          longitude: m.longitude,
          // Noon avoids calendar-day ambiguity in the astronomical math.
          date: DateTime(day.year, day.month, day.day, 12),
          method: settings.calculationMethod,
        );

    final homeTimes = timesAt(mosque);
    // Lazily computed only when some prayer actually uses the work mosque.
    Map<Prayer, DateTime>? workTimes;
    Map<Prayer, DateTime>? jumuahTimes;

    final isFriday = day.weekday == DateTime.friday;
    final timings = <PrayerTiming>[];
    for (final prayer in Prayer.values) {
      final isJumuah =
          settings.jumuahEnabled && prayer == Prayer.dhuhr && isFriday;
      final isWork = !isJumuah &&
          workProfile.appliesTo(weekday: day.weekday, prayer: prayer);

      DateTime adhanTime;
      if (isJumuah && jumuahMosque != null) {
        jumuahTimes ??= timesAt(jumuahMosque);
        adhanTime = jumuahTimes[prayer]!;
      } else if (isWork) {
        workTimes ??= timesAt(workProfile.mosque!);
        adhanTime = workTimes[prayer]!;
      } else {
        adhanTime = homeTimes[prayer]!;
      }

      timings.add(_leaveCalculator.compute(
        prayer: prayer,
        adhanTime: adhanTime,
        settings: settings,
        workTravelMinutes: isWork ? workProfile.travelMinutes : null,
      ));
    }
    return timings;
  }
}
