/// Picks a sensible default adhan calculation method from coordinates,
/// entirely offline (rough bounding boxes for the countries/regions with an
/// official convention). Falls back to Muslim World League — the most
/// widely used method internationally — when no box matches.
///
/// This is a convenience default, not an authority: the user can always
/// override it from Settings.
String calculationMethodForLocation({
  required double latitude,
  required double longitude,
}) {
  bool inBox(double minLat, double maxLat, double minLng, double maxLng) =>
      latitude >= minLat &&
      latitude <= maxLat &&
      longitude >= minLng &&
      longitude <= maxLng;

  // Ordered narrowest/most specific first: small Gulf states sit inside
  // Saudi Arabia's broad bounding box, so they must be checked first.
  if (inBox(22.0, 26.1, 51.0, 56.5)) return 'dubai'; // UAE
  if (inBox(24.4, 26.2, 50.6, 51.7)) return 'qatar';
  if (inBox(28.5, 30.1, 46.5, 48.6)) return 'kuwait';
  if (inBox(24.0, 27.1, 50.3, 56.5)) return 'gulfRegion'; // Bahrain, Oman
  if (inBox(16.0, 32.5, 34.5, 55.7)) return 'ummAlQura'; // Saudi Arabia
  if (inBox(22.0, 31.7, 25.0, 36.9)) return 'egyptian';
  if (inBox(23.6, 37.1, 60.9, 77.9)) return 'karachi'; // Pakistan
  if (inBox(24.4, 71.4, -168.0, -52.0)) return 'northAmerica'; // US, Canada
  if (inBox(1.1, 6.7, 100.0, 119.5)) return 'malaysia';
  if (inBox(1.1, 1.5, 103.5, 104.1)) return 'singapore';
  if (inBox(-11.1, 6.1, 95.0, 141.1)) return 'indonesian';
  if (inBox(35.8, 42.2, 25.6, 44.9)) return 'turkiye';
  if (inBox(27.6, 36.0, -13.3, -0.9)) return 'morocco';
  if (inBox(29.1, 33.4, 34.9, 39.4)) return 'jordan';
  if (inBox(25.0, 39.8, 44.0, 63.4)) return 'tehran'; // Iran
  return 'muslimWorldLeague';
}
