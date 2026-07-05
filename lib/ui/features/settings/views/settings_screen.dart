import 'package:flutter/material.dart';
import 'package:salat_app/l10n/app_localizations.dart';

import '../../../../data/repositories/settings_repository.dart';
import '../../../../domain/models/alert_style.dart';
import '../../../../domain/models/timing_settings.dart';

/// In-app settings. Currently: alert style (standard vs alarm).
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _repository = SettingsRepository();
  TimingSettings? _settings;

  @override
  void initState() {
    super.initState();
    _repository.loadSettings().then((s) {
      if (mounted) setState(() => _settings = s);
    });
  }

  Future<void> _setAlertStyle(AlertStyle style) async {
    final updated = _settings!.copyWith(alertStyle: style);
    setState(() => _settings = updated);
    await _repository.saveSettings(updated);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final settings = _settings;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: settings == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(l10n.alertStyleTitle,
                    style: theme.textTheme.titleMedium
                        ?.copyWith(color: theme.colorScheme.primary)),
                const SizedBox(height: 8),
                RadioGroup<AlertStyle>(
                  groupValue: settings.alertStyle,
                  onChanged: (style) {
                    if (style != null) _setAlertStyle(style);
                  },
                  child: Column(
                    children: [
                      RadioListTile<AlertStyle>(
                        value: AlertStyle.standard,
                        title: Text(l10n.alertStandard),
                        subtitle: Text(l10n.alertStandardDesc),
                        secondary: const Icon(Icons.notifications),
                      ),
                      RadioListTile<AlertStyle>(
                        value: AlertStyle.alarm,
                        title: Text(l10n.alertAlarm),
                        subtitle: Text(l10n.alertAlarmDesc),
                        secondary: const Icon(Icons.alarm),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
