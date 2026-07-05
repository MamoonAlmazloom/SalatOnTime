import '../models/prayer_timing.dart';

/// One notification to schedule: a stable id plus the prayer timing it alerts for.
class AlertOccurrence {
  final int id;
  final PrayerTiming timing;

  const AlertOccurrence({required this.id, required this.timing});
}

/// Selects which leave-time alerts to schedule: every timing across the
/// given days whose leave time is still in the future.
///
/// Ids are deterministic (dayIndex * 10 + position in day) so rescheduling
/// overwrites the same notifications instead of piling up duplicates.
List<AlertOccurrence> upcomingLeaveAlerts({
  required DateTime now,
  required List<List<PrayerTiming>> days,
}) {
  final alerts = <AlertOccurrence>[];
  for (var dayIndex = 0; dayIndex < days.length; dayIndex++) {
    final day = days[dayIndex];
    for (var i = 0; i < day.length; i++) {
      final timing = day[i];
      if (timing.leaveTime.isAfter(now)) {
        alerts.add(AlertOccurrence(id: dayIndex * 10 + i, timing: timing));
      }
    }
  }
  return alerts;
}
