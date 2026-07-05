import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../../data/repositories/settings_repository.dart';
import '../../../../data/services/prayer_calculator_service.dart';
import '../../../../domain/models/mosque.dart';
import '../../../../domain/models/prayer.dart';
import '../../../../domain/models/prayer_timing.dart';
import '../../../../domain/models/timing_settings.dart';
import '../../../../domain/use_cases/leave_time_calculator.dart';
import '../../../../domain/use_cases/next_prayer_resolver.dart';

/// Drives the Home screen: loads configuration, builds today's and
/// tomorrow's schedules, and ticks every second to refresh countdowns.
class HomeViewModel extends ChangeNotifier {
  HomeViewModel({required this._repository});

  final SettingsRepository _repository;
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

  Future<void> load() async {
    mosque = await _repository.loadMosque();
    settings = await _repository.loadSettings();
    _rebuildSchedules(DateTime.now());
    loading = false;
    _tick();
    _timer ??= Timer.periodic(const Duration(seconds: 1), (_) => _tick());
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
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
