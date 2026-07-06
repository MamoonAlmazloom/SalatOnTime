import 'package:flutter/material.dart';
import 'package:salat_app/l10n/app_localizations.dart';

import '../../../../data/repositories/settings_repository.dart';
import '../../../../data/services/location_service.dart';
import '../../../../data/services/routing_service.dart';
import '../../../../domain/models/alert_style.dart';
import '../../../../domain/models/arrival_target.dart';
import '../../../../domain/models/mosque.dart';
import '../../../../domain/models/prayer.dart';
import '../../../../domain/models/timing_settings.dart';
import '../../../core/theme_controller.dart';
import '../../../core/widgets/prayer_tuning_card.dart';
import '../../../core/widgets/stepper_row.dart';
import 'mosque_picker_screen.dart';

/// Full in-app settings: appearance, alerts, mosque/location, timing,
/// and per-prayer tuning. Every change is persisted immediately; the Home
/// screen refreshes and reschedules notifications when this screen closes.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _repository = SettingsRepository();
  final _locationService = const LocationService();
  final _routingService = RoutingService();

  TimingSettings? _settings;
  Mosque? _mosque;
  ({double latitude, double longitude})? _home;
  bool _busyLocation = false;
  bool _busyTravel = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final settings = await _repository.loadSettings();
    final mosque = await _repository.loadMosque();
    final home = await _repository.loadHomeLocation();
    if (!mounted) return;
    setState(() {
      _settings = settings;
      _mosque = mosque;
      _home = home;
    });
  }

  Future<void> _update(TimingSettings updated) async {
    setState(() => _settings = updated);
    await _repository.saveSettings(updated);
  }

  Future<void> _changeMosque() async {
    final result = await Navigator.of(context).push<Mosque>(
      MaterialPageRoute(builder: (_) => MosquePickerScreen(initial: _mosque)),
    );
    if (result != null) {
      setState(() => _mosque = result);
      await _repository.saveMosque(result);
    }
  }

  Future<void> _updateHomeLocation() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _busyLocation = true);
    final location = await _locationService.getCurrentLocation();
    if (!mounted) return;
    setState(() => _busyLocation = false);
    if (location == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.homeLocationFailed)),
      );
      return;
    }
    setState(() => _home = location);
    await _repository.saveHomeLocation(location.latitude, location.longitude);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.homeLocationUpdated)),
    );
  }

  Future<void> _recalculateTravel(TravelMode mode) async {
    final l10n = AppLocalizations.of(context)!;
    final home = _home;
    final mosque = _mosque;
    if (home == null || mosque == null) return;
    setState(() => _busyTravel = true);
    final minutes = await _routingService.travelMinutes(
      fromLatitude: home.latitude,
      fromLongitude: home.longitude,
      toLatitude: mosque.latitude,
      toLongitude: mosque.longitude,
      mode: mode,
    );
    if (!mounted) return;
    setState(() => _busyTravel = false);
    if (minutes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.travelCalcFailed)),
      );
      return;
    }
    await _update(_settings!.copyWith(travelMinutes: minutes));
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
                _SectionTitle(l10n.appearance),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: ValueListenableBuilder<ThemeMode>(
                      valueListenable: themeModeNotifier,
                      builder: (context, mode, _) =>
                          SegmentedButton<ThemeMode>(
                        expandedInsets: EdgeInsets.zero,
                        segments: [
                          ButtonSegment(
                            value: ThemeMode.system,
                            label: Text(l10n.themeSystem),
                          ),
                          ButtonSegment(
                            value: ThemeMode.light,
                            icon: const Icon(Icons.light_mode, size: 18),
                            label: Text(l10n.themeLight),
                          ),
                          ButtonSegment(
                            value: ThemeMode.dark,
                            icon: const Icon(Icons.dark_mode, size: 18),
                            label: Text(l10n.themeDark),
                          ),
                        ],
                        selected: {mode},
                        onSelectionChanged: (selection) {
                          themeModeNotifier.value = selection.first;
                          _repository.saveThemeModeName(selection.first.name);
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                _SectionTitle(l10n.alertStyleTitle),
                Card(
                  child: RadioGroup<AlertStyle>(
                    groupValue: settings.alertStyle,
                    onChanged: (style) {
                      if (style != null) {
                        _update(settings.copyWith(alertStyle: style));
                      }
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
                ),
                const SizedBox(height: 20),
                _SectionTitle(l10n.sectionMosque),
                Card(
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.mosque),
                        title: Text(_mosque?.name ?? l10n.mosqueNameDefault),
                        subtitle: Text(l10n.changeMosque),
                        trailing: const Icon(Icons.edit_location_alt),
                        onTap: _changeMosque,
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: _busyLocation
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2.5),
                              )
                            : const Icon(Icons.my_location),
                        title: Text(l10n.updateHomeLocation),
                        onTap: _busyLocation ? null : _updateHomeLocation,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                _SectionTitle(l10n.sectionTiming),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Column(
                      children: [
                        Padding(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(l10n.travelMinutesLabel,
                                    style: theme.textTheme.bodyLarge),
                              ),
                              StepperRow(
                                value: settings.travelMinutes,
                                unit: l10n.minutesShort,
                                onChanged: (v) => _update(settings.copyWith(
                                    travelMinutes: v.clamp(0, 180))),
                              ),
                            ],
                          ),
                        ),
                        if (_busyTravel)
                          const Padding(
                            padding: EdgeInsets.all(8),
                            child: CircularProgressIndicator(),
                          )
                        else
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                            child: Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: _home != null
                                        ? () => _recalculateTravel(
                                            TravelMode.walking)
                                        : null,
                                    icon:
                                        const Icon(Icons.directions_walk),
                                    label: Text(l10n.walking),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: _home != null
                                        ? () => _recalculateTravel(
                                            TravelMode.driving)
                                        : null,
                                    icon: const Icon(Icons.directions_car),
                                    label: Text(l10n.driving),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        SwitchListTile(
                          title: Text(
                              l10n.wuduToggle(settings.wuduMinutes)),
                          value: settings.wuduEnabled,
                          onChanged: (v) =>
                              _update(settings.copyWith(wuduEnabled: v)),
                          secondary: const Icon(Icons.water_drop),
                        ),
                        SwitchListTile(
                          title: Text(l10n.bathroomToggle),
                          value: settings.bathroomEnabled,
                          onChanged: (v) =>
                              _update(settings.copyWith(bathroomEnabled: v)),
                          secondary: const Icon(Icons.wc),
                        ),
                        Padding(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(l10n.safetyMarginLabel,
                                    style: theme.textTheme.bodyLarge),
                              ),
                              StepperRow(
                                value: settings.safetyMarginMinutes,
                                unit: l10n.minutesShort,
                                onChanged: (v) => _update(settings.copyWith(
                                    safetyMarginMinutes: v.clamp(0, 30))),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                _SectionTitle(l10n.sectionPerPrayer),
                for (final prayer in Prayer.values)
                  PrayerTuningCard(
                    prayer: prayer,
                    iqamaOffset: settings.iqamaOffsets[prayer] ?? 0,
                    target: settings.arrivalTargets[prayer] ??
                        ArrivalTarget.iqama,
                    onOffsetChanged: (v) => _update(settings.copyWith(
                      iqamaOffsets: {
                        ...settings.iqamaOffsets,
                        prayer: v.clamp(0, 60),
                      },
                    )),
                    onTargetChanged: (t) => _update(settings.copyWith(
                      arrivalTargets: {
                        ...settings.arrivalTargets,
                        prayer: t,
                      },
                    )),
                    bathroomMinutes: settings.bathroomEnabled
                        ? (settings.bathroomMinutes[prayer] ?? 3)
                        : null,
                    onBathroomMinutesChanged: (v) =>
                        _update(settings.copyWith(
                      bathroomMinutes: {
                        ...settings.bathroomMinutes,
                        prayer: v.clamp(1, 30),
                      },
                    )),
                  ),
              ],
            ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 4),
      child: Text(
        title,
        style: theme.textTheme.titleMedium?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
