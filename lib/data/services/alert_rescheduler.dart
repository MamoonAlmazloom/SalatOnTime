import 'dart:convert';
import 'dart:ui';

import 'package:home_widget/home_widget.dart';
import 'package:salat_app/l10n/app_localizations.dart';

import '../../domain/models/prayer_timing.dart';
import '../../domain/use_cases/upcoming_alerts.dart';
import '../../ui/core/alert_messages.dart';
import '../../ui/core/prayer_names.dart';
import '../repositories/settings_repository.dart';
import 'notification_service.dart';
import 'schedule_builder.dart';

/// Builds localized notification text. The UI injects a BuildContext-backed
/// builder; background isolates use [notificationTextsForLocale]. [seed]
/// selects one of the rotating ayah/hadith message variants.
class NotificationTexts {
  final ({String title, String body}) Function(PrayerTiming timing, int seed)
      build;

  const NotificationTexts({required this.build});
}

/// The app language without a BuildContext: the stored locale name, falling
/// back to the device language (Arabic or English).
String resolveLanguageCode(String? localeName) => switch (localeName) {
      'ar' || 'en' => localeName!,
      _ => PlatformDispatcher.instance.locale.languageCode == 'ar'
          ? 'ar'
          : 'en',
    };

/// Localized texts resolved without a BuildContext.
NotificationTexts notificationTextsForLocale(String? localeName) {
  final code = resolveLanguageCode(localeName);
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

  static const _builder = ScheduleBuilder();

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
    final jumuahMosque = await repository.loadJumuahMosque();
    final workProfile = await repository.loadWorkProfile();

    final now = DateTime.now();
    final days = [
      for (var offset = 0; offset < 3; offset++)
        _builder.dayFor(
          day: DateTime(now.year, now.month, now.day + offset),
          mosque: mosque,
          jumuahMosque: jumuahMosque,
          workProfile: workProfile,
          settings: settings,
        ),
    ];

    // The notification header names the mosque the alert points to.
    String mosqueNameFor(PrayerTiming timing) {
      if (timing.isWork) return workProfile.mosque?.name ?? mosque.name;
      if (timing.isJumuah) return (jumuahMosque ?? mosque).name;
      return mosque.name;
    }

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
              subText: mosqueNameFor(alert.timing),
            );
          }(),
      ],
      style: settings.alertStyle,
    );

    await _pushWidgetData(
      days: days,
      now: now,
      mosqueNameFor: mosqueNameFor,
    );
  }

  /// Hands the upcoming schedule to the home-screen widget; the native
  /// provider picks the next entry and runs a live countdown to it.
  Future<void> _pushWidgetData({
    required List<List<PrayerTiming>> days,
    required DateTime now,
    required String Function(PrayerTiming) mosqueNameFor,
  }) async {
    try {
      final code = resolveLanguageCode(await repository.loadLocaleName());
      final l10n = lookupAppLocalizations(Locale(code));
      final entries = [
        for (final day in days)
          for (final timing in day)
            if (timing.leaveTime.isAfter(now))
              {
                'n': timingName(l10n, timing),
                'm': mosqueNameFor(timing),
                't': timing.leaveTime.millisecondsSinceEpoch,
              },
      ];
      await HomeWidget.saveWidgetData<String>(
        'schedule',
        jsonEncode({'leaveLabel': l10n.leaveIn, 'entries': entries}),
      );
      await HomeWidget.updateWidget(androidName: 'SalatWidgetProvider');
    } on Exception {
      // The widget is best-effort; alerts must never fail because of it.
    }
  }
}
