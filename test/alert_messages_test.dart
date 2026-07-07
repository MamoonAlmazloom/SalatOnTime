import 'package:flutter_test/flutter_test.dart';
import 'package:salat_app/ui/core/alert_messages.dart';

void main() {
  group('AlertMessages', () {
    test('has 10 variants in both languages', () {
      expect(AlertMessages.variants('ar'), hasLength(10));
      expect(AlertMessages.variants('en'), hasLength(10));
    });

    test('placeholders are always replaced', () {
      for (final lang in ['ar', 'en']) {
        for (var seed = 0; seed < 10; seed++) {
          final m = AlertMessages.pick(
            languageCode: lang,
            seed: seed,
            prayerName: 'الفجر',
            mosqueName: 'مسجد النور',
          );
          expect(m.title.contains('{'), isFalse,
              reason: '$lang/$seed title: ${m.title}');
          expect(m.body.contains('{'), isFalse,
              reason: '$lang/$seed body: ${m.body}');
          expect(m.body, isNotEmpty);
        }
      }
    });

    test('seed rotates through different messages', () {
      final titles = {
        for (var seed = 0; seed < 10; seed++)
          AlertMessages.pick(
            languageCode: 'en',
            seed: seed,
            prayerName: 'Fajr',
            mosqueName: 'Mosque',
          ).title,
      };
      expect(titles.length, greaterThan(5));
    });

    test('unknown language falls back to English', () {
      final m = AlertMessages.pick(
        languageCode: 'fr',
        seed: 0,
        prayerName: 'Fajr',
        mosqueName: 'Mosque',
      );
      expect(m.title, contains('Fajr'));
    });
  });
}
