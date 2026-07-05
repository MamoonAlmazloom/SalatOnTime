import 'package:flutter/foundation.dart';

import '../../../../data/repositories/settings_repository.dart';
import '../../../../data/services/location_service.dart';
import '../../../../data/services/routing_service.dart';
import '../../../../domain/models/arrival_target.dart';
import '../../../../domain/models/mosque.dart';
import '../../../../domain/models/prayer.dart';
import '../../../../domain/models/timing_settings.dart';

/// Default map center when location is unavailable: Riyadh.
const defaultLatitude = 24.7136;
const defaultLongitude = 46.6753;

enum LocationState { initial, locating, granted, denied }

class OnboardingViewModel extends ChangeNotifier {
  final LocationService _locationService;
  final RoutingService _routingService;
  final SettingsRepository _repository;

  OnboardingViewModel({
    required this._locationService,
    required this._routingService,
    required this._repository,
  });

  // Step 1: location
  LocationState locationState = LocationState.initial;
  double? homeLatitude;
  double? homeLongitude;

  // Step 2: mosque pin (follows the map center)
  double mosqueLatitude = defaultLatitude;
  double mosqueLongitude = defaultLongitude;
  String mosqueName = '';

  // Steps 3-4 accumulate into the settings object.
  TimingSettings settings = const TimingSettings();

  bool calculatingTravel = false;
  bool travelCalcFailed = false;

  double get mapCenterLatitude => homeLatitude ?? defaultLatitude;
  double get mapCenterLongitude => homeLongitude ?? defaultLongitude;

  Future<void> requestLocation() async {
    locationState = LocationState.locating;
    notifyListeners();

    final location = await _locationService.getCurrentLocation();
    if (location == null) {
      locationState = LocationState.denied;
    } else {
      locationState = LocationState.granted;
      homeLatitude = location.latitude;
      homeLongitude = location.longitude;
      mosqueLatitude = location.latitude;
      mosqueLongitude = location.longitude;
    }
    notifyListeners();
  }

  void setMosquePosition(double latitude, double longitude) {
    mosqueLatitude = latitude;
    mosqueLongitude = longitude;
    // No notify: the map itself is the source of this change; rebuilding
    // the widget tree on every camera movement would fight the gesture.
  }

  void setMosqueName(String name) {
    mosqueName = name;
  }

  Future<void> calculateTravelTime(TravelMode mode) async {
    if (homeLatitude == null || homeLongitude == null) return;
    calculatingTravel = true;
    travelCalcFailed = false;
    notifyListeners();

    final minutes = await _routingService.travelMinutes(
      fromLatitude: homeLatitude!,
      fromLongitude: homeLongitude!,
      toLatitude: mosqueLatitude,
      toLongitude: mosqueLongitude,
      mode: mode,
    );
    if (minutes == null) {
      travelCalcFailed = true;
    } else {
      settings = settings.copyWith(travelMinutes: minutes);
    }
    calculatingTravel = false;
    notifyListeners();
  }

  void setTravelMinutes(int minutes) {
    settings = settings.copyWith(travelMinutes: minutes.clamp(0, 180));
    notifyListeners();
  }

  void setWuduEnabled(bool enabled) {
    settings = settings.copyWith(wuduEnabled: enabled);
    notifyListeners();
  }

  void setBathroomEnabled(bool enabled) {
    settings = settings.copyWith(bathroomEnabled: enabled);
    notifyListeners();
  }

  void setBathroomMinutes(int minutes) {
    settings = settings.copyWith(bathroomMinutes: minutes.clamp(1, 30));
    notifyListeners();
  }

  void setIqamaOffset(Prayer prayer, int minutes) {
    settings = settings.copyWith(
      iqamaOffsets: {...settings.iqamaOffsets, prayer: minutes.clamp(0, 60)},
    );
    notifyListeners();
  }

  void setArrivalTarget(Prayer prayer, ArrivalTarget target) {
    settings = settings.copyWith(
      arrivalTargets: {...settings.arrivalTargets, prayer: target},
    );
    notifyListeners();
  }

  Future<void> finish(String fallbackMosqueName) async {
    await _repository.completeOnboarding(
      mosque: Mosque(
        name: mosqueName.trim().isEmpty ? fallbackMosqueName : mosqueName.trim(),
        latitude: mosqueLatitude,
        longitude: mosqueLongitude,
      ),
      settings: settings,
      homeLatitude: homeLatitude,
      homeLongitude: homeLongitude,
    );
  }
}
