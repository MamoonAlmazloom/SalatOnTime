import '../models/prayer_timing.dart';

/// The next relevant prayer and live countdowns toward it.
class NextPrayerStatus {
  final PrayerTiming timing;

  /// Time until adhan; negative once the adhan has passed.
  final Duration untilAdhan;

  /// Time until iqama.
  final Duration untilIqama;

  /// Time until the user must leave home; negative means "leave now!".
  final Duration untilLeave;

  const NextPrayerStatus({
    required this.timing,
    required this.untilAdhan,
    required this.untilIqama,
    required this.untilLeave,
  });
}

/// Decides which prayer is "next" and computes countdowns toward it.
///
/// A prayer counts as next until its iqama has passed — between adhan and
/// iqama the user can still make it to that prayer.
class NextPrayerResolver {
  const NextPrayerResolver();

  NextPrayerStatus resolve({
    required DateTime now,
    required List<PrayerTiming> today,
    required List<PrayerTiming> tomorrow,
  }) {
    final sortedToday = [...today]
      ..sort((a, b) => a.adhanTime.compareTo(b.adhanTime));
    for (final timing in sortedToday) {
      if (now.isBefore(timing.iqamaTime)) {
        return _status(timing, now);
      }
    }
    // All of today's iqamas have passed: next is tomorrow's first prayer.
    final sortedTomorrow = [...tomorrow]
      ..sort((a, b) => a.adhanTime.compareTo(b.adhanTime));
    return _status(sortedTomorrow.first, now);
  }

  NextPrayerStatus _status(PrayerTiming timing, DateTime now) {
    return NextPrayerStatus(
      timing: timing,
      untilAdhan: timing.adhanTime.difference(now),
      untilIqama: timing.iqamaTime.difference(now),
      untilLeave: timing.leaveTime.difference(now),
    );
  }
}
