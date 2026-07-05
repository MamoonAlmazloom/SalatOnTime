import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../../data/repositories/settings_repository.dart';
import '../../../../data/services/notification_service.dart';
import '../../../../data/services/prayer_calculator_service.dart';
import '../../../../domain/models/mosque.dart';
import '../../../../domain/models/prayer.dart';
import '../../../../domain/models/prayer_timing.dart';
import '../../../../domain/models/timing_settings.dart';
import '../../../../domain/use_cases/leave_time_calculator.dart';
import '../../../../domain/use_cases/next_prayer_resolver.dart';
import '../../../../domain/use_cases/upcoming_alerts.dart';

/// Builders for localized notification text, injected from the widget layer
/// (view models have no BuildContext).
class NotificationTexts {
  final String Function(Prayer prayer) title;
  final String Function(Prayer prayer, String mosqueName) body;

  const NotificationTexts({required this.title, required this.body});
}

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
    await _syncNotifications();
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

  /// Schedules leave-time notifications for the next three days.
  Future<void> _syncNotifications() async {
    final m = mosque;
    final texts = _texts;
    if (m == null || texts == null || today.isEmpty) return;

    final now = DateTime.now();
    final dayAfter = _leaveCalculator.computeDay(
      adhanTimes: _calculator.timesFor(
        latitude: m.latitude,
        longitude: m.longitude,
        date: DateTime(now.year, now.month, now.day + 2, 12),
      ),
      settings: settings,
    );
    final alerts = upcomingLeaveAlerts(
      now: now,
      days: [today, tomorrow, dayAfter],
    );
    await _notifications.scheduleAll([
      for (final alert in alerts)
        (
          id: alert.id,
          title: texts.title(alert.timing.prayer),
          body: texts.body(alert.timing.prayer, m.name),
          when: alert.timing.leaveTime,
        ),
    ]);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
