/// Rotating leave-time notification messages. Each variant pairs a call to
/// action with an authentic ayah or hadith encouraging prayer in the mosque
/// and on time. `{prayer}` is replaced at schedule time.
class AlertMessages {
  const AlertMessages._();

  static const _ar = <({String title, String body})>[
    (
      title: 'حان وقت الخروج لصلاة {prayer} 🕌',
      body:
          'اطلع الحين تلحق {prayer} في المسجد على الوقت. «أحب الأعمال إلى الله الصلاة على وقتها» — متفق عليه',
    ),
    (
      title: 'الجماعة بسبعٍ وعشرين درجة ✨',
      body:
          '«صلاة الجماعة أفضل من صلاة الفذ بسبع وعشرين درجة» — متفق عليه. اطلع الآن تدرك الجماعة في المسجد.',
    ),
    (
      title: 'ضيافة في الجنة 🌿',
      body:
          '«من غدا إلى المسجد أو راح، أعدّ الله له في الجنة نُزُلًا كلما غدا أو راح» — متفق عليه. انطلق الآن لصلاة {prayer}.',
    ),
    (
      title: 'نور يوم القيامة 💡',
      body:
          '«بشِّر المشّائين في الظُّلَم إلى المساجد بالنور التام يوم القيامة» — رواه أبو داود والترمذي. خروجك الآن يوصلك المسجد على الوقت.',
    ),
    (
      title: 'لا تفوّت صلاة {prayer} 🕌',
      body:
          '«لو يعلمون ما في العتمة والصبح لأتوهما ولو حبوًا» — متفق عليه. اطلع الحين وأدرك الجماعة.',
    ),
    (
      title: 'كل خطوة تُحسب لك 👣',
      body:
          '«إحدى خطوتيه تحطّ خطيئة، والأخرى ترفع درجة» — رواه مسلم. كل خطوة إلى المسجد في ميزانك، اطلع الآن لصلاة {prayer}.',
    ),
    (
      title: 'يلا لصلاة {prayer} 🚶',
      body:
          '﴿وَأَقِيمُوا الصَّلَاةَ وَآتُوا الزَّكَاةَ وَارْكَعُوا مَعَ الرَّاكِعِينَ﴾ [البقرة ٤٣] — حان وقت الخروج إلى المسجد.',
    ),
    (
      title: 'موعدك مع صلاة {prayer} ⏰',
      body:
          '﴿إِنَّ الصَّلَاةَ كَانَتْ عَلَى الْمُؤْمِنِينَ كِتَابًا مَوْقُوتًا﴾ [النساء ١٠٣] — اطلع الحين توصل المسجد على الوقت.',
    ),
    (
      title: 'حافظ على صلاتك 🤲',
      body:
          '﴿حَافِظُوا عَلَى الصَّلَوَاتِ وَالصَّلَاةِ الْوُسْطَىٰ﴾ [البقرة ٢٣٨] — وقتك للخروج لصلاة {prayer}.',
    ),
    (
      title: 'المسجد ينتظرك 🕌',
      body:
          '﴿فِي بُيُوتٍ أَذِنَ اللَّهُ أَن تُرْفَعَ وَيُذْكَرَ فِيهَا اسْمُهُ﴾ [النور ٣٦] — انطلق الآن لصلاة {prayer}.',
    ),
  ];

  static const _en = <({String title, String body})>[
    (
      title: 'Time to leave for {prayer} 🕌',
      body:
          'Leave now to reach the mosque for {prayer} on time. "The dearest of deeds to Allah is prayer at its proper time." — Bukhari & Muslim',
    ),
    (
      title: '27 degrees better ✨',
      body:
          '"Prayer in congregation is twenty-seven degrees better than prayer alone." — Bukhari & Muslim. Leave now to catch the jama\'ah at the mosque.',
    ),
    (
      title: 'A place prepared in Paradise 🌿',
      body:
          '"Whoever goes to the mosque morning or evening, Allah prepares for him a place in Paradise for every trip." — Bukhari & Muslim. Set out now for {prayer}.',
    ),
    (
      title: 'Light on the Day of Resurrection 💡',
      body:
          '"Give glad tidings of perfect light on the Day of Resurrection to those who walk to the mosques in darkness." — Abu Dawud & Tirmidhi. Leaving now gets you to the mosque on time.',
    ),
    (
      title: 'Don\'t miss {prayer} 🕌',
      body:
          '"If they knew what reward lies in Isha and Fajr, they would come even if they had to crawl." — Bukhari & Muslim. Leave now and catch the congregation.',
    ),
    (
      title: 'Every step counts 👣',
      body:
          '"One step erases a sin and the other raises him a rank." — Muslim. Every step to the mosque is in your favor; leave now for {prayer}.',
    ),
    (
      title: 'Off to {prayer} 🚶',
      body:
          '"And establish prayer and give zakah and bow with those who bow." [Al-Baqarah 43] — time to head out to the mosque.',
    ),
    (
      title: 'Your appointment with {prayer} ⏰',
      body:
          '"Indeed, prayer has been decreed upon the believers at specified times." [An-Nisa 103] — leave now to reach the mosque on time.',
    ),
    (
      title: 'Guard your prayer 🤲',
      body:
          '"Guard strictly the prayers, especially the middle prayer." [Al-Baqarah 238] — it\'s time to leave for {prayer}.',
    ),
    (
      title: 'The mosque awaits you 🕌',
      body:
          '"In houses which Allah has permitted to be raised, and His name remembered therein." [An-Nur 36] — set out now for {prayer}.',
    ),
  ];

  static List<({String title, String body})> variants(String languageCode) =>
      languageCode == 'ar' ? _ar : _en;

  /// Deterministically picks a variant and fills in the prayer name.
  static ({String title, String body}) pick({
    required String languageCode,
    required int seed,
    required String prayerName,
  }) {
    final list = variants(languageCode);
    final v = list[seed.abs() % list.length];
    String fill(String s) => s.replaceAll('{prayer}', prayerName);
    return (title: fill(v.title), body: fill(v.body));
  }
}
