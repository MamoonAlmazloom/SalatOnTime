import 'package:flutter_test/flutter_test.dart';
import 'package:salat_app/data/services/schedule_builder.dart';
import 'package:salat_app/domain/models/mosque.dart';
import 'package:salat_app/domain/models/prayer.dart';
import 'package:salat_app/domain/models/timing_settings.dart';
import 'package:salat_app/domain/models/work_profile.dart';

void main() {
  const builder = ScheduleBuilder();
  const home =
      Mosque(name: 'Home Mosque', latitude: 24.7136, longitude: 46.6753);
  const work =
      Mosque(name: 'Work Mosque', latitude: 24.7743, longitude: 46.7386);
  const settings = TimingSettings(travelMinutes: 10, wuduEnabled: false);
  const profile = WorkProfile(
    enabled: true,
    mosque: work,
    travelMinutes: 25,
  );

  group('ScheduleBuilder work profile', () {
    test('workday Dhuhr/Asr use the work travel time and are flagged', () {
      // 2026-07-06 is a Monday (inside the default Sun–Thu week).
      final day = builder.dayFor(
        day: DateTime(2026, 7, 6),
        mosque: home,
        workProfile: profile,
        settings: settings,
      );
      final fajr = day[0];
      final dhuhr = day[1];
      final asr = day[2];

      expect(dhuhr.isWork, isTrue);
      expect(asr.isWork, isTrue);
      expect(fajr.isWork, isFalse);
      // Work prayers: leave = arrival - 25 travel; home prayers: -10.
      expect(dhuhr.arrivalTime.difference(dhuhr.leaveTime).inMinutes, 25);
      expect(fajr.arrivalTime.difference(fajr.leaveTime).inMinutes, 10);
    });

    test('off days are untouched', () {
      // 2026-07-11 is a Saturday (outside the default week).
      final day = builder.dayFor(
        day: DateTime(2026, 7, 11),
        mosque: home,
        workProfile: profile,
        settings: settings,
      );
      expect(day.every((t) => !t.isWork), isTrue);
      for (final t in day) {
        expect(t.arrivalTime.difference(t.leaveTime).inMinutes, 10);
      }
    });

    test("Friday Jumu'ah wins over the work profile", () {
      final fridayProfile = profile.copyWith(weekdays: {DateTime.friday});
      // 2026-07-10 is a Friday.
      final day = builder.dayFor(
        day: DateTime(2026, 7, 10),
        mosque: home,
        workProfile: fridayProfile,
        settings: settings,
      );
      final dhuhr = day[1];
      final asr = day[2];

      expect(dhuhr.isJumuah, isTrue);
      expect(dhuhr.isWork, isFalse);
      // Asr on that Friday still follows the work profile.
      expect(asr.isWork, isTrue);
    });

    test('disabled profile leaves everything on the home mosque', () {
      final day = builder.dayFor(
        day: DateTime(2026, 7, 6),
        mosque: home,
        workProfile: profile.copyWith(enabled: false),
        settings: settings,
      );
      expect(day.every((t) => !t.isWork), isTrue);
    });

    test('adhan times for work prayers come from the work mosque', () {
      final day = builder.dayFor(
        day: DateTime(2026, 7, 6),
        mosque: home,
        workProfile: profile,
        settings: settings,
      );
      final off = builder.dayFor(
        day: DateTime(2026, 7, 6),
        mosque: home,
        workProfile: profile.copyWith(enabled: false),
        settings: settings,
      );
      // Different coordinates → slightly different Dhuhr adhan.
      expect(day[1].adhanTime, isNot(off[1].adhanTime));
      // Fajr (home in both) is identical.
      expect(day[0].adhanTime, off[0].adhanTime);
    });
  });

  group('WorkProfile JSON round-trip', () {
    test('all fields survive', () {
      final original = profile.copyWith(
        weekdays: {DateTime.monday, DateTime.tuesday},
        prayers: {Prayer.asr},
      );
      final restored = WorkProfile.fromJson(original.toJson());

      expect(restored.enabled, isTrue);
      expect(restored.mosque?.name, 'Work Mosque');
      expect(restored.travelMinutes, 25);
      expect(restored.weekdays, {DateTime.monday, DateTime.tuesday});
      expect(restored.prayers, {Prayer.asr});
    });

    test('empty json gives the disabled default', () {
      final restored = WorkProfile.fromJson(const {});
      expect(restored.enabled, isFalse);
      expect(restored.mosque, isNull);
      expect(restored.weekdays, WorkProfile.defaultWeekdays);
      expect(restored.prayers, WorkProfile.defaultPrayers);
    });
  });
}
