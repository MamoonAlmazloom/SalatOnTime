import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:salat_app/l10n/app_localizations.dart';

import '../../../../data/repositories/settings_repository.dart';
import '../../../../data/services/notification_service.dart';
import '../../../../domain/models/timing_settings.dart';

/// Plain-language checklist for "my alert was late / never came": the three
/// phone settings that break prayer alerts, each with a one-tap fix, plus a
/// test notification to confirm everything works.
class AlertTroubleshootingScreen extends StatefulWidget {
  const AlertTroubleshootingScreen({super.key});

  @override
  State<AlertTroubleshootingScreen> createState() =>
      _AlertTroubleshootingScreenState();
}

class _AlertTroubleshootingScreenState extends State<AlertTroubleshootingScreen>
    with WidgetsBindingObserver {
  final _notifications = NotificationService.instance;
  final _repository = SettingsRepository();

  bool _notificationsOk = true;
  bool _exactOk = true;
  TimingSettings _settings = const TimingSettings();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _recheck();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Returning from a system settings screen: refresh the statuses.
    if (state == AppLifecycleState.resumed) _recheck();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _recheck() async {
    final notifOk = await _notifications.notificationsEnabled();
    final exactOk = await _notifications.canScheduleExact();
    final settings = await _repository.loadSettings();
    if (!mounted) return;
    setState(() {
      _notificationsOk = notifOk;
      _exactOk = exactOk;
      _settings = settings;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.troubleshootEntry)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(l10n.troubleshootIntro, style: theme.textTheme.bodyLarge),
          const SizedBox(height: 16),
          _CheckCard(
            icon: Icons.notifications_outlined,
            title: l10n.checkNotifTitle,
            body: _notificationsOk ? l10n.checkNotifOkBody : l10n.notifOffBody,
            ok: _notificationsOk,
            actionLabel: l10n.notifOffButton,
            onAction: () => AppSettings.openAppSettings(
                type: AppSettingsType.notification),
          ),
          const SizedBox(height: 12),
          _CheckCard(
            icon: Icons.alarm_on,
            title: l10n.checkExactTitle,
            body: _exactOk ? l10n.checkExactOkBody : l10n.checkExactBody,
            ok: _exactOk,
            actionLabel: l10n.openSettingsLabel,
            onAction: _notifications.requestExactAlarms,
          ),
          const SizedBox(height: 12),
          _CheckCard(
            icon: Icons.battery_saver,
            title: l10n.checkBatteryTitle,
            body: l10n.checkBatteryBody,
            // The sleeping-apps list cannot be read by apps; always show the
            // manual-check state with a shortcut into the battery settings.
            ok: null,
            actionLabel: l10n.openSettingsLabel,
            onAction: () => AppSettings.openAppSettings(
                type: AppSettingsType.batteryOptimization),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () => _notifications.showTest(
              title: l10n.testAlertTitle,
              body: l10n.testAlertBody,
              style: _settings.alertStyle,
            ),
            icon: const Icon(Icons.notification_add),
            label: Text(l10n.testAlertButton),
          ),
        ],
      ),
    );
  }
}

class _CheckCard extends StatelessWidget {
  const _CheckCard({
    required this.icon,
    required this.title,
    required this.body,
    required this.ok,
    required this.actionLabel,
    required this.onAction,
  });

  final IconData icon;
  final String title;
  final String body;

  /// true = working, false = needs attention, null = cannot auto-detect.
  final bool? ok;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final (chipLabel, chipColor) = switch (ok) {
      true => (l10n.statusOk, scheme.primary),
      false => (l10n.statusNeedsAttention, scheme.error),
      null => (l10n.statusManualCheck, scheme.onSurfaceVariant),
    };

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon,
                    color: ok == false ? scheme.error : scheme.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: chipColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    chipLabel,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: chipColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(body, style: theme.textTheme.bodyMedium),
            if (ok != true) ...[
              const SizedBox(height: 10),
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: FilledButton.tonal(
                  onPressed: onAction,
                  child: Text(actionLabel),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
