/// The five daily prayers.
enum Prayer {
  fajr,
  dhuhr,
  asr,
  maghrib,
  isha;

  static Prayer fromName(String name) =>
      Prayer.values.firstWhere((p) => p.name == name);
}
