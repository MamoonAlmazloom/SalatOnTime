import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

/// Schedules local "leave home now" notifications. All plugin calls are
/// guarded: on platforms/tests without the plugin they silently no-op.
class NotificationService {
  NotificationService._();

  /// Single shared instance: initialized once in main(), used everywhere.
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _ready = false;

  Future<void> initialize() async {
    try {
      tz.initializeTimeZones();
      final info = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(info.identifier));

      const initSettings = InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(
          // Permissions are requested explicitly via requestPermissions().
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      );
      _ready = (await _plugin.initialize(settings: initSettings)) ?? false;
    } on Exception {
      _ready = false;
    }
  }

  /// Requests notification (and Android exact-alarm) permissions.
  Future<void> requestPermissions() async {
    if (!_ready) return;
    try {
      final android = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      if (android != null) {
        await android.requestNotificationsPermission();
        if (!(await android.canScheduleExactNotifications() ?? false)) {
          await android.requestExactAlarmsPermission();
        }
      }
      await _plugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(alert: true, badge: true, sound: true);
    } on Exception {
      // Permission prompts failing must never break the app.
    }
  }

  /// Cancels everything and schedules the given alerts.
  Future<void> scheduleAll(
    List<({int id, String title, String body, DateTime when})> alerts,
  ) async {
    if (!_ready) return;
    try {
      await _plugin.cancelAll();
      const details = NotificationDetails(
        android: AndroidNotificationDetails(
          'leave_alerts',
          'Leave-time alerts | تنبيهات وقت الخروج',
          channelDescription:
              'Alerts fired when it is time to leave home for prayer',
          importance: Importance.max,
          priority: Priority.high,
          category: AndroidNotificationCategory.reminder,
        ),
        iOS: DarwinNotificationDetails(
          interruptionLevel: InterruptionLevel.timeSensitive,
        ),
      );
      for (final alert in alerts) {
        Future<void> schedule(AndroidScheduleMode mode) => _plugin.zonedSchedule(
              id: alert.id,
              title: alert.title,
              body: alert.body,
              scheduledDate: tz.TZDateTime.from(alert.when, tz.local),
              notificationDetails: details,
              androidScheduleMode: mode,
            );
        try {
          await schedule(AndroidScheduleMode.exactAllowWhileIdle);
        } on PlatformException {
          // Exact alarms denied: an inexact alert beats no alert.
          await schedule(AndroidScheduleMode.inexactAllowWhileIdle);
        }
      }
    } on Exception {
      // Scheduling failures (e.g. exact alarms denied) must not crash the UI.
    }
  }
}
