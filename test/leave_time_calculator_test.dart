import 'package:flutter_test/flutter_test.dart';
import 'package:salat_app/domain/models/alert_style.dart';
import 'package:salat_app/domain/models/arrival_target.dart';
import 'package:salat_app/domain/models/prayer.dart';
import 'package:salat_app/domain/models/timing_settings.dart';
import 'package:salat_app/domain/use_cases/leave_time_calculator.dart';

void main() {
  const calculator = LeaveTimeCalculator();
  // Dhuhr adhan at 12:00 sharp keeps the arithmetic easy to follow.
  final adhan = DateTime(2026, 7, 6, 12, 0);

  group('LeaveTimeCalculator', () {
    test('iqama target: leave = adhan + offset - travel - wudu', () {
      const settings = TimingSettings(
        travelMinutes: 10,
        wuduEnabled: true, // +1
        bathroomEnabled: false,
      );
      final t = calculator.compute(
          prayer: Prayer.dhuhr, adhanTime: adhan, settings: settings);

      expect(t.iqamaTime, DateTime(2026, 7, 6, 12, 20)); // dhuhr offset 20
      expect(t.arrivalTime, t.iqamaTime);
      // 12:20 - 10 travel - 1 wudu = 12:09
      expect(t.leaveTime, DateTime(2026, 7, 6, 12, 9));
    });

    test('adhan target ignores iqama offset for arrival', () {
      const settings = TimingSettings(
        travelMinutes: 10,
        wuduEnabled: false,
        arrivalTargets: {
          Prayer.fajr: ArrivalTarget.iqama,
          Prayer.dhuhr: ArrivalTarget.adhan,
          Prayer.asr: ArrivalTarget.iqama,
          Prayer.maghrib: ArrivalTarget.iqama,
          Prayer.isha: ArrivalTarget.iqama,
        },
      );
      final t = calculator.compute(
          prayer: Prayer.dhuhr, adhanTime: adhan, settings: settings);

      expect(t.arrivalTime, adhan);
      expect(t.leaveTime, DateTime(2026, 7, 6, 11, 50)); // 12:00 - 10
      // Iqama time is still reported for display purposes.
      expect(t.iqamaTime, DateTime(2026, 7, 6, 12, 20));
    });

    test('all buffers combined', () {
      const settings = TimingSettings(
        travelMinutes: 12,
        wuduEnabled: true,
        wuduMinutes: 2,
        bathroomEnabled: true,
        bathroomMinutes: 3,
        safetyMarginMinutes: 5,
      );
      final t = calculator.compute(
          prayer: Prayer.maghrib, adhanTime: adhan, settings: settings);

      // maghrib offset 15 → arrival 12:15; minus 12+2+3+5 = 22 → 11:53
      expect(t.leaveTime, DateTime(2026, 7, 6, 11, 53));
    });

    test('disabled buffers contribute nothing', () {
      const settings = TimingSettings(
        travelMinutes: 10,
        wuduEnabled: false,
        wuduMinutes: 99,
        bathroomEnabled: false,
        bathroomMinutes: 99,
      );
      final t = calculator.compute(
          prayer: Prayer.dhuhr, adhanTime: adhan, settings: settings);

      expect(t.leaveTime, DateTime(2026, 7, 6, 12, 10)); // 12:20 - 10
    });

    test('zero travel: leave exactly at arrival target', () {
      const settings = TimingSettings(travelMinutes: 0, wuduEnabled: false);
      final t = calculator.compute(
          prayer: Prayer.dhuhr, adhanTime: adhan, settings: settings);

      expect(t.leaveTime, t.iqamaTime);
    });

    test('computeDay produces all five prayers with per-prayer offsets', () {
      const settings = TimingSettings();
      final adhanTimes = {
        Prayer.fajr: DateTime(2026, 7, 6, 3, 39),
        Prayer.dhuhr: DateTime(2026, 7, 6, 11, 58),
        Prayer.asr: DateTime(2026, 7, 6, 15, 20),
        Prayer.maghrib: DateTime(2026, 7, 6, 18, 46),
        Prayer.isha: DateTime(2026, 7, 6, 20, 16),
      };
      final day =
          calculator.computeDay(adhanTimes: adhanTimes, settings: settings);

      expect(day, hasLength(5));
      expect(day.map((t) => t.prayer), Prayer.values);
      // Spot-check per-prayer iqama offsets: fajr 25, maghrib 15.
      expect(day.first.iqamaTime, DateTime(2026, 7, 6, 4, 4));
      expect(day[3].iqamaTime, DateTime(2026, 7, 6, 19, 1));
    });
  });

  group('TimingSettings JSON round-trip', () {
    test('all fields survive serialization', () {
      const original = TimingSettings(
        travelMinutes: 7,
        wuduEnabled: false,
        bathroomEnabled: true,
        bathroomMinutes: 4,
        safetyMarginMinutes: 2,
        alertStyle: AlertStyle.alarm,
        iqamaOffsets: {
          Prayer.fajr: 30,
          Prayer.dhuhr: 20,
          Prayer.asr: 20,
          Prayer.maghrib: 10,
          Prayer.isha: 20,
        },
        arrivalTargets: {
          Prayer.fajr: ArrivalTarget.adhan,
          Prayer.dhuhr: ArrivalTarget.iqama,
          Prayer.asr: ArrivalTarget.iqama,
          Prayer.maghrib: ArrivalTarget.iqama,
          Prayer.isha: ArrivalTarget.iqama,
        },
      );
      final restored = TimingSettings.fromJson(original.toJson());

      expect(restored.travelMinutes, 7);
      expect(restored.wuduEnabled, false);
      expect(restored.bathroomEnabled, true);
      expect(restored.bathroomMinutes, 4);
      expect(restored.safetyMarginMinutes, 2);
      expect(restored.iqamaOffsets[Prayer.fajr], 30);
      expect(restored.iqamaOffsets[Prayer.maghrib], 10);
      expect(restored.arrivalTargets[Prayer.fajr], ArrivalTarget.adhan);
      expect(restored.arrivalTargets[Prayer.isha], ArrivalTarget.iqama);
      expect(restored.alertStyle, AlertStyle.alarm);
    });
  });
}
