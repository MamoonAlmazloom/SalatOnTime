import 'package:flutter_test/flutter_test.dart';
import 'package:salat_app/domain/models/prayer.dart';
import 'package:salat_app/domain/models/timing_settings.dart';
import 'package:salat_app/domain/use_cases/leave_time_calculator.dart';
import 'package:salat_app/domain/use_cases/next_prayer_resolver.dart';

void main() {
  const resolver = NextPrayerResolver();
  const calculator = LeaveTimeCalculator();
  const settings = TimingSettings(travelMinutes: 10); // wudu on → 11 min total

  // Riyadh-like day (2026-07-06) and the following day.
  final todayAdhans = {
    Prayer.fajr: DateTime(2026, 7, 6, 3, 39),
    Prayer.dhuhr: DateTime(2026, 7, 6, 11, 58),
    Prayer.asr: DateTime(2026, 7, 6, 15, 20),
    Prayer.maghrib: DateTime(2026, 7, 6, 18, 46),
    Prayer.isha: DateTime(2026, 7, 6, 20, 16),
  };
  final tomorrowAdhans = {
    for (final e in todayAdhans.entries)
      e.key: e.value.add(const Duration(days: 1)),
  };
  final today = calculator.computeDay(adhanTimes: todayAdhans, settings: settings);
  final tomorrow =
      calculator.computeDay(adhanTimes: tomorrowAdhans, settings: settings);

  NextPrayerStatus at(DateTime now) =>
      resolver.resolve(now: now, today: today, tomorrow: tomorrow);

  group('NextPrayerResolver', () {
    test('mid-morning → dhuhr is next with correct countdowns', () {
      final status = at(DateTime(2026, 7, 6, 9, 0));

      expect(status.timing.prayer, Prayer.dhuhr);
      expect(status.untilAdhan, const Duration(hours: 2, minutes: 58));
      // iqama 12:18 → 3h18m; leave 12:07 (iqama - 11) → 3h07m
      expect(status.untilIqama, const Duration(hours: 3, minutes: 18));
      expect(status.untilLeave, const Duration(hours: 3, minutes: 7));
    });

    test('between adhan and iqama, that prayer is still next', () {
      final status = at(DateTime(2026, 7, 6, 12, 5)); // after 11:58 adhan

      expect(status.timing.prayer, Prayer.dhuhr);
      expect(status.untilAdhan.isNegative, isTrue);
      expect(status.untilIqama, const Duration(minutes: 13));
    });

    test('past leave time → negative leave countdown ("leave now")', () {
      // Dhuhr leave time is 12:07; at 12:10 it is 3 minutes overdue.
      final status = at(DateTime(2026, 7, 6, 12, 10));

      expect(status.timing.prayer, Prayer.dhuhr);
      expect(status.untilLeave, const Duration(minutes: -3));
    });

    test('exactly at iqama rolls to the following prayer', () {
      final status = at(DateTime(2026, 7, 6, 12, 18)); // dhuhr iqama moment

      expect(status.timing.prayer, Prayer.asr);
    });

    test('after isha iqama → tomorrow fajr', () {
      // Isha iqama today is 20:36.
      final status = at(DateTime(2026, 7, 6, 22, 0));

      expect(status.timing.prayer, Prayer.fajr);
      expect(status.timing.adhanTime, DateTime(2026, 7, 7, 3, 39));
      expect(status.untilAdhan, const Duration(hours: 5, minutes: 39));
    });

    test('just after midnight still targets that morning fajr via tomorrow list',
        () {
      // 00:30 on the 6th: today's fajr (03:39) has not passed → still today.
      final status = at(DateTime(2026, 7, 6, 0, 30));

      expect(status.timing.prayer, Prayer.fajr);
      expect(status.timing.adhanTime, DateTime(2026, 7, 6, 3, 39));
    });
  });
}
