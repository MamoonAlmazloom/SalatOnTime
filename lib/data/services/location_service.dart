import 'package:geolocator/geolocator.dart';

/// Wraps geolocator: permission handling + one-shot current position.
class LocationService {
  const LocationService();

  /// Returns the current position, or null if services are off or the
  /// user denied permission.
  Future<({double latitude, double longitude})?> getCurrentLocation() async {
    if (!await Geolocator.isLocationServiceEnabled()) return null;

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return null;
    }

    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 15),
        ),
      );
      return (latitude: position.latitude, longitude: position.longitude);
    } on Exception {
      return null;
    }
  }
}
