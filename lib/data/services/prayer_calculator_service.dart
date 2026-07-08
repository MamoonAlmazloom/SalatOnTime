import 'package:adhan_dart/adhan_dart.dart' as adhan;

import '../../domain/models/prayer.dart';

/// Computes adhan times offline by wrapping the adhan_dart package.
/// The method defaults to Umm al-Qura (official for Saudi Arabia) and can be
/// switched from Settings (TimingSettings.calculationMethod).
class PrayerCalculatorService {
  const PrayerCalculatorService();

  static adhan.CalculationParameters _parameters(String method) =>
      switch (method) {
        'muslimWorldLeague' =>
          adhan.CalculationMethodParameters.muslimWorldLeague(),
        'egyptian' => adhan.CalculationMethodParameters.egyptian(),
        'karachi' => adhan.CalculationMethodParameters.karachi(),
        'northAmerica' => adhan.CalculationMethodParameters.northAmerica(),
        'dubai' => adhan.CalculationMethodParameters.dubai(),
        'qatar' => adhan.CalculationMethodParameters.qatar(),
        'kuwait' => adhan.CalculationMethodParameters.kuwait(),
        'gulfRegion' => adhan.CalculationMethodParameters.gulfRegion(),
        'moonsightingCommittee' =>
          adhan.CalculationMethodParameters.moonsightingCommittee(),
        'singapore' => adhan.CalculationMethodParameters.singapore(),
        'indonesian' => adhan.CalculationMethodParameters.indonesian(),
        'turkiye' => adhan.CalculationMethodParameters.turkiye(),
        'morocco' => adhan.CalculationMethodParameters.morocco(),
        'jordan' => adhan.CalculationMethodParameters.jordan(),
        'tehran' => adhan.CalculationMethodParameters.tehran(),
        _ => adhan.CalculationMethodParameters.ummAlQura(),
      };

  /// Adhan times for the calendar day of [date] at the given coordinates,
  /// returned in the device's local timezone.
  Map<Prayer, DateTime> timesFor({
    required double latitude,
    required double longitude,
    required DateTime date,
    String method = 'ummAlQura',
  }) {
    final prayerTimes = adhan.PrayerTimes(
      coordinates: adhan.Coordinates(latitude, longitude),
      date: date,
      calculationParameters: _parameters(method),
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
