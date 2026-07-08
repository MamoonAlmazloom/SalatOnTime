/// Display catalogue for the supported adhan calculation methods.
/// Labels are proper nouns kept out of the ARB files; keys must match
/// PrayerCalculatorService._parameters.
class CalculationMethodOption {
  final String key;
  final String labelEn;
  final String labelAr;

  const CalculationMethodOption(this.key, this.labelEn, this.labelAr);

  String label(String languageCode) =>
      languageCode == 'ar' ? labelAr : labelEn;
}

const calculationMethodOptions = <CalculationMethodOption>[
  CalculationMethodOption(
      'ummAlQura', 'Umm al-Qura (Saudi Arabia)', 'أم القرى (السعودية)'),
  CalculationMethodOption(
      'muslimWorldLeague', 'Muslim World League', 'رابطة العالم الإسلامي'),
  CalculationMethodOption('egyptian', 'Egyptian General Authority',
      'الهيئة المصرية العامة للمساحة'),
  CalculationMethodOption('karachi', 'Karachi (Univ. of Islamic Sciences)',
      'كراتشي (جامعة العلوم الإسلامية)'),
  CalculationMethodOption(
      'northAmerica', 'ISNA (North America)', 'إسنا (أمريكا الشمالية)'),
  CalculationMethodOption('dubai', 'Dubai (UAE)', 'دبي (الإمارات)'),
  CalculationMethodOption('qatar', 'Qatar', 'قطر'),
  CalculationMethodOption('kuwait', 'Kuwait', 'الكويت'),
  CalculationMethodOption('gulfRegion', 'Gulf Region', 'منطقة الخليج'),
  CalculationMethodOption('moonsightingCommittee', 'Moonsighting Committee',
      'لجنة تحري رؤية الهلال'),
  CalculationMethodOption('singapore', 'Singapore', 'سنغافورة'),
  CalculationMethodOption('indonesian', 'Indonesia', 'إندونيسيا'),
  CalculationMethodOption('turkiye', 'Türkiye (Diyanet)', 'تركيا (ديانت)'),
  CalculationMethodOption('morocco', 'Morocco', 'المغرب'),
  CalculationMethodOption('jordan', 'Jordan', 'الأردن'),
  CalculationMethodOption('tehran', 'Tehran', 'طهران'),
];

/// Label for a stored method key, falling back to the key itself.
String calculationMethodLabel(String key, String languageCode) {
  for (final option in calculationMethodOptions) {
    if (option.key == key) return option.label(languageCode);
  }
  return key;
}
