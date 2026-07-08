import 'package:flutter_test/flutter_test.dart';
import 'package:salat_app/domain/use_cases/calculation_method_locator.dart';

void main() {
  group('calculationMethodForLocation', () {
    test('Riyadh, Saudi Arabia -> ummAlQura', () {
      expect(
        calculationMethodForLocation(latitude: 24.7136, longitude: 46.6753),
        'ummAlQura',
      );
    });

    test('Kuala Lumpur, Malaysia -> malaysia', () {
      expect(
        calculationMethodForLocation(latitude: 3.1390, longitude: 101.6869),
        'malaysia',
      );
    });

    test('Rome, Italy -> muslimWorldLeague (no specific box)', () {
      expect(
        calculationMethodForLocation(latitude: 41.9028, longitude: 12.4964),
        'muslimWorldLeague',
      );
    });

    test('Cairo, Egypt -> egyptian', () {
      expect(
        calculationMethodForLocation(latitude: 30.0444, longitude: 31.2357),
        'egyptian',
      );
    });

    test('Karachi, Pakistan -> karachi', () {
      expect(
        calculationMethodForLocation(latitude: 24.8607, longitude: 67.0011),
        'karachi',
      );
    });

    test('New York, USA -> northAmerica', () {
      expect(
        calculationMethodForLocation(latitude: 40.7128, longitude: -74.0060),
        'northAmerica',
      );
    });

    test('Istanbul, Turkiye -> turkiye', () {
      expect(
        calculationMethodForLocation(latitude: 41.0082, longitude: 28.9784),
        'turkiye',
      );
    });

    test('Jakarta, Indonesia -> indonesian', () {
      expect(
        calculationMethodForLocation(latitude: -6.2088, longitude: 106.8456),
        'indonesian',
      );
    });

    test('Dubai, UAE -> dubai', () {
      expect(
        calculationMethodForLocation(latitude: 25.2048, longitude: 55.2708),
        'dubai',
      );
    });
  });
}
