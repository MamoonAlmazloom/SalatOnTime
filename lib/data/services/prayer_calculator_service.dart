import 'package:adhan_dart/adhan_dart.dart' as adhan;

import '../../domain/models/prayer.dart';

/// Computes adhan times offline using the Umm al-Qura method (official for
/// Saudi Arabia). Wraps the adhan_dart package.
class PrayerCalculatorService {
  const PrayerCalculatorService();

  /// Adhan times for the calendar day of [date] at the given coordinates,
  /// returned in the device's local timezone.
  Map<Prayer, DateTime> timesFor({
    required double latitude,
    required double longitude,
    required DateTime date,
  }) {
    final prayerTimes = adhan.PrayerTimes(
      coordinates: adhan.Coordinates(latitude, longitude),
      date: date,
      calculationParameters: adhan.CalculationMethodParameters.ummAlQura(),
      precision: true,
    );
    return {
      Prayer.fajr: prayerTimes.fajr.toLocal(),
      Prayer.dhuhr: prayerTimes.dhuhr.toLocal(),
      Prayer.asr: prayerTimes.asr.toLocal(),
      Prayer.maghrib: prayerTimes.maghrib.toLocal(),
      Prayer.isha: prayerTimes.isha.toLocal(),
    };
  }
}
