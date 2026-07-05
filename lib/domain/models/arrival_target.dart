/// Whether the user wants to arrive at the mosque by the adhan or the iqama.
enum ArrivalTarget {
  adhan,
  iqama;

  static ArrivalTarget fromName(String name) =>
      ArrivalTarget.values.firstWhere((t) => t.name == name);
}
