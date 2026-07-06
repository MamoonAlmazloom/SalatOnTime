import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/models/mosque.dart';
import '../../domain/models/timing_settings.dart';

/// Persists user configuration (mosque, timing settings, onboarding state)
/// in local storage. Single source of truth for settings.
class SettingsRepository {
  static const _kSettings = 'timing_settings';
  static const _kMosque = 'mosque';
  static const _kOnboarded = 'onboarding_complete';
  static const _kHomeLat = 'home_latitude';
  static const _kHomeLng = 'home_longitude';
  static const _kThemeMode = 'theme_mode';

  Future<bool> isOnboardingComplete() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_kOnboarded) ?? false;
  }

  Future<void> completeOnboarding({
    required Mosque mosque,
    required TimingSettings settings,
    double? homeLatitude,
    double? homeLongitude,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kMosque, jsonEncode(mosque.toJson()));
    await prefs.setString(_kSettings, jsonEncode(settings.toJson()));
    if (homeLatitude != null && homeLongitude != null) {
      await prefs.setDouble(_kHomeLat, homeLatitude);
      await prefs.setDouble(_kHomeLng, homeLongitude);
    }
    await prefs.setBool(_kOnboarded, true);
  }

  Future<TimingSettings> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kSettings);
    if (raw == null) return const TimingSettings();
    return TimingSettings.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<void> saveSettings(TimingSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kSettings, jsonEncode(settings.toJson()));
  }

  Future<Mosque?> loadMosque() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kMosque);
    if (raw == null) return null;
    return Mosque.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<void> saveMosque(Mosque mosque) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kMosque, jsonEncode(mosque.toJson()));
  }

  /// The user's home location captured during onboarding, if granted.
  Future<({double latitude, double longitude})?> loadHomeLocation() async {
    final prefs = await SharedPreferences.getInstance();
    final lat = prefs.getDouble(_kHomeLat);
    final lng = prefs.getDouble(_kHomeLng);
    if (lat == null || lng == null) return null;
    return (latitude: lat, longitude: lng);
  }

  Future<void> saveHomeLocation(double latitude, double longitude) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_kHomeLat, latitude);
    await prefs.setDouble(_kHomeLng, longitude);
  }

  /// Theme mode name: 'system' (default), 'light', or 'dark'.
  Future<String?> loadThemeModeName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kThemeMode);
  }

  Future<void> saveThemeModeName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kThemeMode, name);
  }
}
