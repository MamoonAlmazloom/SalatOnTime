import 'package:geolocator/geolocator.dart';

/// Wraps geolocator: permission handling + one-shot current position.
class LocationService {
  const LocationService();

  /// Returns the current position, or null if services are off, the user
  /// denied permission, or anything hangs. Bounded at 30s overall so the
  /// UI can never spin forever (permission dialogs occasionally stall,
  /// especially on emulators).
  Future<({double latitude, double longitude})?> getCurrentLocation() async {
    try {
      return await _locate().timeout(const Duration(seconds: 30));
    } on Exception {
      return null;
    }
  }

  Future<({double latitude, double longitude})?> _locate() async {
    if (!await Geolocator.isLocationServiceEnabled()) return null;

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return null;
    }

    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 15),
      ),
    );
    return (latitude: position.latitude, longitude: position.longitude);
  }
}
