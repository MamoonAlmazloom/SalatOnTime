import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/models/mosque.dart';
import '../../domain/models/timing_settings.dart';
import '../../domain/models/work_profile.dart';

/// Persists user configuration (mosque, timing settings, onboarding state)
/// in local storage. Single source of truth for settings.
class SettingsRepository {
  static const _kSettings = 'timing_settings';
  static const _kMosque = 'mosque';
  static const _kOnboarded = 'onboarding_complete';
  static const _kHomeLat = 'home_latitude';
  static const _kHomeLng = 'home_longitude';
  static const _kThemeMode = 'theme_mode';
  static const _kLocale = 'locale';
  static const _kHijriAdjust = 'hijri_adjustment';
  static const _kJumuahMosque = 'jumuah_mosque';
  static const _kWorkProfile = 'work_profile';

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

  /// Days added to the computed hijri date (-2..2) so users can match the
  /// official calendar when the astronomical estimate drifts.
  Future<int> loadHijriAdjustment() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_kHijriAdjust) ?? 0;
  }

  Future<void> saveHijriAdjustment(int days) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kHijriAdjust, days);
  }

  /// Optional different mosque for Jumu'ah (null = same as daily mosque).
  Future<Mosque?> loadJumuahMosque() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kJumuahMosque);
    if (raw == null) return null;
    return Mosque.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<void> saveJumuahMosque(Mosque? mosque) async {
    final prefs = await SharedPreferences.getInstance();
    if (mosque == null) {
      await prefs.remove(_kJumuahMosque);
    } else {
      await prefs.setString(_kJumuahMosque, jsonEncode(mosque.toJson()));
    }
  }

  /// The work/school second-place profile.
  Future<WorkProfile> loadWorkProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kWorkProfile);
    if (raw == null) return const WorkProfile();
    return WorkProfile.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<void> saveWorkProfile(WorkProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kWorkProfile, jsonEncode(profile.toJson()));
  }

  /// Locale name: 'system' (default), 'ar', or 'en'.
  Future<String?> loadLocaleName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kLocale);
  }

  Future<void> saveLocaleName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kLocale, name);
  }
}
