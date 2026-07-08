import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../../data/repositories/settings_repository.dart';
import '../../../../data/services/alert_rescheduler.dart';
import '../../../../data/services/notification_service.dart';
import '../../../../data/services/prayer_calculator_service.dart';
import '../../../../domain/models/mosque.dart';
import '../../../../domain/models/prayer.dart';
import '../../../../domain/models/prayer_timing.dart';
import '../../../../domain/models/timing_settings.dart';
import '../../../../domain/use_cases/leave_time_calculator.dart';
import '../../../../domain/use_cases/next_prayer_resolver.dart';

export '../../../../data/services/alert_rescheduler.dart'
    show NotificationTexts;

/// Drives the Home screen: loads configuration, builds today's and
/// tomorrow's schedules, and ticks every second to refresh countdowns.
class HomeViewModel extends ChangeNotifier {
  HomeViewModel({
    required this._repository,
    required this._notifications,
  });

  final SettingsRepository _repository;
  final NotificationService _notifications;
  static const _calculator = PrayerCalculatorService();
  static const _leaveCalculator = LeaveTimeCalculator();
  static const _resolver = NextPrayerResolver();

  Timer? _timer;
  bool loading = true;

  /// True when the user has notifications disabled for the app — the Home
  /// screen shows a prominent warning, since alerts are the core feature.
  bool notificationsOff = false;
  Mosque? mosque;
  TimingSettings settings = const TimingSettings();
  List<PrayerTiming> today = const [];
  List<PrayerTiming> tomorrow = const [];
  NextPrayerStatus? status;
  DateTime? _scheduleDay;

  /// Set by the widget layer once localizations are available; triggers
  /// (re)scheduling of the leave-time notifications.
  NotificationTexts? _texts;
  set notificationTexts(NotificationTexts texts) {
    _texts = texts;
    _syncNotifications();
  }

  Future<void> load() async {
    mosque = await _repository.loadMosque();
    settings = await _repository.loadSettings();
    _rebuildSchedules(DateTime.now());
    loading = false;
    _tick();
    _timer ??= Timer.periodic(const Duration(seconds: 1), (_) => _tick());
    await _notifications.requestPermissions();
    await recheckNotificationsEnabled();
    await _syncNotifications();
  }

  /// Re-reads the notification permission (e.g. after returning from the
  /// system settings screen) and updates the Home warning.
  Future<void> recheckNotificationsEnabled() async {
    final enabled = await _notifications.notificationsEnabled();
    if (notificationsOff != !enabled) {
      notificationsOff = !enabled;
      notifyListeners();
    }
  }

  void _rebuildSchedules(DateTime now) {
    final m = mosque;
    if (m == null) return;
    _scheduleDay = DateTime(now.year, now.month, now.day);

    Map<Prayer, DateTime> timesFor(DateTime day) => _calculator.timesFor(
          latitude: m.latitude,
          longitude: m.longitude,
          // Noon avoids calendar-day ambiguity in the astronomical math.
          date: DateTime(day.year, day.month, day.day, 12),
        );

    today = _leaveCalculator.computeDay(
        adhanTimes: timesFor(now), settings: settings);
    tomorrow = _leaveCalculator.computeDay(
        adhanTimes: timesFor(now.add(const Duration(days: 1))),
        settings: settings);
  }

  void _tick() {
    final now = DateTime.now();
    final day = DateTime(now.year, now.month, now.day);
    if (_scheduleDay != day) {
      _rebuildSchedules(now);
    }
    if (today.isNotEmpty) {
      status = _resolver.resolve(now: now, today: today, tomorrow: tomorrow);
    }
    notifyListeners();
  }

  Future<void> updateTravelMinutes(int minutes) async {
    settings = settings.copyWith(travelMinutes: minutes.clamp(0, 180));
    await _repository.saveSettings(settings);
    _rebuildSchedules(DateTime.now());
    _tick();
    await _syncNotifications();
  }

  /// Schedules leave-time notifications for the next three days via the
  /// shared rescheduler (also run by the background refresh task).
  Future<void> _syncNotifications() async {
    final texts = _texts;
    if (mosque == null || texts == null) return;
    await AlertRescheduler(
      repository: _repository,
      notifications: _notifications,
    ).reschedule(texts: texts);
  }

  /// Re-reads settings from storage (e.g. after the Settings screen closes)
  /// and rebuilds schedules + notifications.
  Future<void> refresh() async {
    settings = await _repository.loadSettings();
    mosque = await _repository.loadMosque();
    _rebuildSchedules(DateTime.now());
    _tick();
    await recheckNotificationsEnabled();
    await _syncNotifications();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
