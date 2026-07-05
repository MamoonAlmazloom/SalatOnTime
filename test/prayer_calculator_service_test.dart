import 'package:flutter_test/flutter_test.dart';
import 'package:salat_app/data/services/prayer_calculator_service.dart';
import 'package:salat_app/domain/models/prayer.dart';

void main() {
  const service = PrayerCalculatorService();

  group('PrayerCalculatorService (Umm al-Qura, Riyadh)', () {
    // Reference times from api.aladhan.com (method=4, Umm al-Qura) for
    // Riyadh (24.7136, 46.6753) on 2026-07-06, timezone Asia/Riyadh (UTC+3):
    // Fajr 03:39, Dhuhr 11:58, Asr 15:20, Maghrib 18:46, Isha 20:16.
    // Expressed here in UTC so the test passes on any machine timezone.
    final expectedUtc = {
      Prayer.fajr: DateTime.utc(2026, 7, 6, 0, 39),
      Prayer.dhuhr: DateTime.utc(2026, 7, 6, 8, 58),
      Prayer.asr: DateTime.utc(2026, 7, 6, 12, 20),
      Prayer.maghrib: DateTime.utc(2026, 7, 6, 15, 46),
      Prayer.isha: DateTime.utc(2026, 7, 6, 17, 16),
    };

    test('matches published times within 3 minutes', () {
      final times = service.timesFor(
        latitude: 24.7136,
        longitude: 46.6753,
        // Noon local avoids any calendar-day ambiguity at midnight.
        date: DateTime(2026, 7, 6, 12),
      );

      for (final prayer in Prayer.values) {
        final diff =
            times[prayer]!.toUtc().difference(expectedUtc[prayer]!).abs();
        expect(
          diff,
          lessThanOrEqualTo(const Duration(minutes: 3)),
          reason: '${prayer.name}: got ${times[prayer]!.toUtc()} '
              'expected ~${expectedUtc[prayer]}',
        );
      }
    });

    test('times are strictly ordered fajr → isha', () {
      final times = service.timesFor(
        latitude: 24.7136,
        longitude: 46.6753,
        date: DateTime(2026, 7, 6, 12),
      );
      final ordered = Prayer.values.map((p) => times[p]!).toList();
      for (var i = 1; i < ordered.length; i++) {
        expect(ordered[i].isAfter(ordered[i - 1]), isTrue,
            reason: '${Prayer.values[i].name} must be after '
                '${Prayer.values[i - 1].name}');
      }
    });

    test('isha is exactly 90 minutes after maghrib (Umm al-Qura rule)', () {
      final times = service.timesFor(
        latitude: 24.7136,
        longitude: 46.6753,
        date: DateTime(2026, 7, 6, 12),
      );
      final gap = times[Prayer.isha]!.difference(times[Prayer.maghrib]!);
      expect((gap - const Duration(minutes: 90)).abs(),
          lessThanOrEqualTo(const Duration(minutes: 1)));
    });
  });
}
