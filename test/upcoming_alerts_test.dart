import 'package:flutter_test/flutter_test.dart';
import 'package:salat_app/domain/models/prayer.dart';
import 'package:salat_app/domain/models/timing_settings.dart';
import 'package:salat_app/domain/use_cases/leave_time_calculator.dart';
import 'package:salat_app/domain/use_cases/upcoming_alerts.dart';

void main() {
  const calculator = LeaveTimeCalculator();
  const settings = TimingSettings(travelMinutes: 10);

  Map<Prayer, DateTime> adhansFor(DateTime day) => {
        Prayer.fajr: DateTime(day.year, day.month, day.day, 3, 39),
        Prayer.dhuhr: DateTime(day.year, day.month, day.day, 11, 58),
        Prayer.asr: DateTime(day.year, day.month, day.day, 15, 20),
        Prayer.maghrib: DateTime(day.year, day.month, day.day, 18, 46),
        Prayer.isha: DateTime(day.year, day.month, day.day, 20, 16),
      };

  final day0 = DateTime(2026, 7, 6);
  final days = [
    calculator.computeDay(adhanTimes: adhansFor(day0), settings: settings),
    calculator.computeDay(
        adhanTimes: adhansFor(day0.add(const Duration(days: 1))),
        settings: settings),
    calculator.computeDay(
        adhanTimes: adhansFor(day0.add(const Duration(days: 2))),
        settings: settings),
  ];

  group('upcomingLeaveAlerts', () {
    test('early morning: all 15 alerts are in the future', () {
      final alerts =
          upcomingLeaveAlerts(now: DateTime(2026, 7, 6, 2, 0), days: days);
      expect(alerts, hasLength(15));
    });

    test('mid-day: passed leave times are excluded', () {
      // Dhuhr leave time is 12:07 (11:58 + 20 iqama - 11 buffers).
      final alerts =
          upcomingLeaveAlerts(now: DateTime(2026, 7, 6, 12, 30), days: days);
      // Today only asr/maghrib/isha remain (3) + 5 + 5.
      expect(alerts, hasLength(13));
      expect(alerts.first.timing.prayer, Prayer.asr);
    });

    test('ids are deterministic and unique across days', () {
      final alerts =
          upcomingLeaveAlerts(now: DateTime(2026, 7, 6, 2, 0), days: days);
      final ids = alerts.map((a) => a.id).toSet();
      expect(ids, hasLength(15));
      // Same prayer on consecutive days differs by 10.
      final fajrIds = alerts
          .where((a) => a.timing.prayer == Prayer.fajr)
          .map((a) => a.id)
          .toList();
      expect(fajrIds, [0, 10, 20]);
    });
  });
}
