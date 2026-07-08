import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../../domain/models/alert_style.dart';

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
        // Dedicated monochrome status-bar icon (white mosque silhouette);
        // the launcher icon would render as a flat blob up there.
        android: AndroidInitializationSettings('ic_notification'),
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

  /// Whether the user currently allows this app to post notifications.
  /// Returns true when unknown (e.g. tests without the plugin) so the UI
  /// never nags without evidence.
  Future<bool> notificationsEnabled() async {
    if (!_ready) return true;
    try {
      final android = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      if (android != null) {
        return await android.areNotificationsEnabled() ?? true;
      }
      final ios = _plugin.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>();
      final options = await ios?.checkPermissions();
      return options?.isEnabled ?? true;
    } on Exception {
      return true;
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

  /// Brand emerald: tints the small icon and app name in the notification.
  static const _brandColor = Color(0xFF0E7C66);

  /// Per-notification details: emerald accent, the logo as large icon, and
  /// BigText so the full ayah/hadith reads elegantly when expanded.
  /// Alarm-style plays on the alarm audio stream (rings through silent mode
  /// on most devices) and takes the screen when the phone is locked.
  static NotificationDetails _details({
    required AlertStyle style,
    required String title,
    required String body,
    String? subText,
  }) {
    const largeIcon = DrawableResourceAndroidBitmap('ic_notification_large');
    final styleInformation = BigTextStyleInformation(
      body,
      contentTitle: title,
    );
    final android = style == AlertStyle.alarm
        ? AndroidNotificationDetails(
            'leave_alerts_alarm',
            'Alarm-style leave alerts | تنبيهات بصوت المنبّه',
            channelDescription:
                'Loud alarm-like alerts fired when it is time to leave for prayer',
            importance: Importance.max,
            priority: Priority.max,
            category: AndroidNotificationCategory.alarm,
            audioAttributesUsage: AudioAttributesUsage.alarm,
            fullScreenIntent: true,
            color: _brandColor,
            largeIcon: largeIcon,
            styleInformation: styleInformation,
            subText: subText,
            ticker: title,
          )
        : AndroidNotificationDetails(
            'leave_alerts',
            'Leave-time alerts | تنبيهات وقت الخروج',
            channelDescription:
                'Alerts fired when it is time to leave home for prayer',
            importance: Importance.max,
            priority: Priority.high,
            category: AndroidNotificationCategory.reminder,
            color: _brandColor,
            largeIcon: largeIcon,
            styleInformation: styleInformation,
            subText: subText,
            ticker: title,
          );
    return NotificationDetails(
      android: android,
      iOS: const DarwinNotificationDetails(
        interruptionLevel: InterruptionLevel.timeSensitive,
      ),
    );
  }

  /// Cancels everything and schedules the given alerts. [subText] shows in
  /// the notification header (e.g. the mosque name).
  Future<void> scheduleAll(
    List<({int id, String title, String body, DateTime when})> alerts, {
    AlertStyle style = AlertStyle.standard,
    String? subText,
  }) async {
    if (!_ready) return;
    try {
      await _plugin.cancelAll();
      for (final alert in alerts) {
        final details = _details(
          style: style,
          title: alert.title,
          body: alert.body,
          subText: subText,
        );
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
