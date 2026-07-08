import 'dart:ui';

import 'package:salat_app/l10n/app_localizations.dart';

import '../../domain/models/prayer_timing.dart';
import '../../domain/use_cases/leave_time_calculator.dart';
import '../../domain/use_cases/upcoming_alerts.dart';
import '../../ui/core/alert_messages.dart';
import '../../ui/core/prayer_names.dart';
import '../repositories/settings_repository.dart';
import 'notification_service.dart';
import 'prayer_calculator_service.dart';

/// Builds localized notification text. The UI injects a BuildContext-backed
/// builder; background isolates use [notificationTextsForLocale]. [seed]
/// selects one of the rotating ayah/hadith message variants.
class NotificationTexts {
  final ({String title, String body}) Function(PrayerTiming timing, int seed)
      build;

  const NotificationTexts({required this.build});
}

/// Localized texts resolved without a BuildContext: from the stored locale
/// name, falling back to the device language (Arabic or English).
NotificationTexts notificationTextsForLocale(String? localeName) {
  final code = switch (localeName) {
    'ar' || 'en' => localeName!,
    _ => PlatformDispatcher.instance.locale.languageCode == 'ar' ? 'ar' : 'en',
  };
  final l10n = lookupAppLocalizations(Locale(code));
  return NotificationTexts(
    build: (timing, seed) => AlertMessages.pick(
      languageCode: code,
      seed: seed,
      prayerName: timingName(l10n, timing),
    ),
  );
}

/// Recomputes the next three days of leave-time alerts from stored
/// configuration and (re)schedules their notifications. Shared by the Home
/// screen and the background refresh task so both stay in sync.
class AlertRescheduler {
  const AlertRescheduler({
    required this.repository,
    required this.notifications,
  });

  final SettingsRepository repository;
  final NotificationService notifications;

  static const _calculator = PrayerCalculatorService();
  static const _leaveCalculator = LeaveTimeCalculator();

  /// Background entry point: no BuildContext available, so the notification
  /// language comes from storage / the device locale.
  Future<void> rescheduleFromStorage() async {
    final localeName = await repository.loadLocaleName();
    await reschedule(texts: notificationTextsForLocale(localeName));
  }

  Future<void> reschedule({required NotificationTexts texts}) async {
    final mosque = await repository.loadMosque();
    if (mosque == null) return;
    final settings = await repository.loadSettings();

    final now = DateTime.now();
    final days = [
      for (var offset = 0; offset < 3; offset++)
        _leaveCalculator.computeDay(
          adhanTimes: _calculator.timesFor(
            latitude: mosque.latitude,
            longitude: mosque.longitude,
            // Noon avoids calendar-day ambiguity in the astronomical math.
            date: DateTime(now.year, now.month, now.day + offset, 12),
          ),
          settings: settings,
        ),
    ];

    final alerts = upcomingLeaveAlerts(now: now, days: days);
    await notifications.scheduleAll(
      [
        for (final alert in alerts)
          () {
            // Seed varies by prayer (id) and by calendar day so the same
            // prayer gets a different message tomorrow.
            final message = texts.build(
              alert.timing,
              alert.id + alert.timing.leaveTime.day * 3,
            );
            return (
              id: alert.id,
              title: message.title,
              body: message.body,
              when: alert.timing.leaveTime,
            );
          }(),
      ],
      style: settings.alertStyle,
      subText: mosque.name,
    );
  }
}
