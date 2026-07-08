import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:workmanager/workmanager.dart';

import '../repositories/settings_repository.dart';
import 'alert_rescheduler.dart';
import 'notification_service.dart';

/// Notifications are only scheduled three days ahead, and only when the app
/// is opened. This WorkManager task tops the window back up twice a day so
/// alerts keep firing even if the app stays closed for weeks.

const _uniqueName = 'io.github.mamoonalmazloom.salatontime.refreshLeaveAlerts';
const _taskName = 'refreshLeaveAlerts';

@pragma('vm:entry-point')
void backgroundRefreshDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      await NotificationService.instance.initialize();
      await AlertRescheduler(
        repository: SettingsRepository(),
        notifications: NotificationService.instance,
      ).rescheduleFromStorage();
      return true;
    } on Exception {
      return false; // WorkManager retries with backoff.
    }
  });
}

/// Registers the periodic refresh. Safe to call on every launch. Android
/// only: iOS needs BGTaskScheduler entitlements, deferred with the iOS build.
Future<void> registerBackgroundRefresh() async {
  if (kIsWeb || !Platform.isAndroid) return;
  try {
    await Workmanager().initialize(backgroundRefreshDispatcher);
    await Workmanager().registerPeriodicTask(
      _uniqueName,
      _taskName,
      frequency: const Duration(hours: 12),
      existingWorkPolicy: ExistingPeriodicWorkPolicy.update,
    );
  } on Exception {
    // Best-effort: the app still schedules three days ahead on every open.
  }
}
