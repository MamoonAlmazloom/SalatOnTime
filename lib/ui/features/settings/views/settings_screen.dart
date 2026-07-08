import 'package:flutter/material.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:salat_app/l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../data/repositories/settings_repository.dart';
import '../../../../data/services/location_service.dart';
import '../../../../data/services/routing_service.dart';
import '../../../../domain/models/alert_style.dart';
import '../../../../domain/models/mosque.dart';
import '../../../../domain/models/prayer.dart';
import '../../../../domain/models/timing_settings.dart';
import '../../../../domain/models/work_profile.dart';
import '../../../core/calculation_methods.dart';
import '../../../core/prayer_names.dart';
import '../../../core/theme_controller.dart';
import '../../../core/widgets/section_title.dart';
import '../../../core/widgets/stepper_row.dart';
import 'alert_troubleshooting_screen.dart';
import 'mosque_picker_screen.dart';
import 'prayer_settings_screen.dart';

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
  Mosque? _jumuahMosque;
  WorkProfile _workProfile = const WorkProfile();
  ({double latitude, double longitude})? _home;
  int _hijriAdjustment = 0;
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
    final jumuahMosque = await _repository.loadJumuahMosque();
    final workProfile = await _repository.loadWorkProfile();
    final home = await _repository.loadHomeLocation();
    final hijriAdjustment = await _repository.loadHijriAdjustment();
    if (!mounted) return;
    setState(() {
      _settings = settings;
      _mosque = mosque;
      _jumuahMosque = jumuahMosque;
      _workProfile = workProfile;
      _home = home;
      _hijriAdjustment = hijriAdjustment;
    });
  }

  Future<void> _updateWorkProfile(WorkProfile profile) async {
    setState(() => _workProfile = profile);
    await _repository.saveWorkProfile(profile);
  }

  Future<void> _pickWorkMosque() async {
    final result = await Navigator.of(context).push<Mosque>(
      MaterialPageRoute(
          builder: (_) =>
              MosquePickerScreen(initial: _workProfile.mosque ?? _mosque)),
    );
    if (result != null) {
      await _updateWorkProfile(_workProfile.copyWith(mosque: result));
    }
  }

  Future<void> _pickJumuahMosque() async {
    final result = await Navigator.of(context).push<Mosque>(
      MaterialPageRoute(
          builder: (_) =>
              MosquePickerScreen(initial: _jumuahMosque ?? _mosque)),
    );
    if (result != null) {
      setState(() => _jumuahMosque = result);
      await _repository.saveJumuahMosque(result);
    }
  }

  Future<void> _pickCalculationMethod() async {
    final l10n = AppLocalizations.of(context)!;
    final languageCode = Localizations.localeOf(context).languageCode;
    final settings = _settings!;
    final choice = await showDialog<String>(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text(l10n.calcMethodNote),
        contentPadding: const EdgeInsets.symmetric(vertical: 12),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
            child: Text(
              l10n.calcMethodExplanation,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          RadioGroup<String>(
            groupValue: settings.calculationMethod,
            onChanged: (key) => Navigator.pop(context, key),
            child: Column(
              children: [
                for (final option in calculationMethodOptions)
                  RadioListTile<String>(
                    value: option.key,
                    dense: true,
                    title: Text(option.label(languageCode)),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
    if (choice != null) {
      await _update(_settings!.copyWith(calculationMethod: choice));
    }
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

  /// The two styles carry long descriptions, so they live in a dialog
  /// instead of two tall radio tiles on the main scroll.
  Future<void> _pickAlertStyle() async {
    final l10n = AppLocalizations.of(context)!;
    final settings = _settings!;
    final choice = await showDialog<AlertStyle>(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text(l10n.alertStyleTitle),
        contentPadding: const EdgeInsets.symmetric(vertical: 12),
        children: [
          RadioGroup<AlertStyle>(
            groupValue: settings.alertStyle,
            onChanged: (style) => Navigator.pop(context, style),
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
    if (choice != null) {
      await _update(_settings!.copyWith(alertStyle: choice));
    }
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
                SectionTitle(l10n.sectionMosque),
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
                SectionTitle(l10n.sectionWorkPlace),
                Card(
                  child: Column(
                    children: [
                      SwitchListTile(
                        title: Text(l10n.workProfileToggle),
                        subtitle: Text(l10n.workProfileHint),
                        value: _workProfile.enabled,
                        onChanged: (v) async {
                          await _updateWorkProfile(
                              _workProfile.copyWith(enabled: v));
                          if (v && _workProfile.mosque == null) {
                            await _pickWorkMosque();
                          }
                        },
                        secondary: const Icon(Icons.work_outline),
                      ),
                      if (_workProfile.enabled) ...[
                        ListTile(
                          leading: const Icon(Icons.place_outlined),
                          title: Text(_workProfile.mosque?.name ??
                              l10n.mosqueStepTitle),
                          subtitle: Text(l10n.changeMosque),
                          trailing: const _Chevron(),
                          onTap: _pickWorkMosque,
                        ),
                        Padding(
                          padding:
                              const EdgeInsets.fromLTRB(16, 0, 16, 4),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(l10n.workTravelLabel,
                                    style: theme.textTheme.bodyLarge),
                              ),
                              StepperRow(
                                value: _workProfile.travelMinutes,
                                unit: l10n.minutesShort,
                                onChanged: (v) => _updateWorkProfile(
                                    _workProfile.copyWith(
                                        travelMinutes: v.clamp(0, 180))),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(
                              16, 8, 16, 0),
                          child: Align(
                            alignment: AlignmentDirectional.centerStart,
                            child: Text(l10n.workPrayersLabel,
                                style: theme.textTheme.bodyLarge),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 4,
                            children: [
                              for (final prayer in Prayer.values)
                                FilterChip(
                                  label: Text(prayerName(l10n, prayer)),
                                  selected:
                                      _workProfile.prayers.contains(prayer),
                                  onSelected: (selected) {
                                    final prayers = {..._workProfile.prayers};
                                    if (selected) {
                                      prayers.add(prayer);
                                    } else {
                                      prayers.remove(prayer);
                                    }
                                    _updateWorkProfile(_workProfile
                                        .copyWith(prayers: prayers));
                                  },
                                ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(
                              16, 12, 16, 0),
                          child: Align(
                            alignment: AlignmentDirectional.centerStart,
                            child: Text(l10n.workDaysLabel,
                                style: theme.textTheme.bodyLarge),
                          ),
                        ),
                        Padding(
                          padding:
                              const EdgeInsets.fromLTRB(16, 8, 16, 16),
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 4,
                            children: [
                              // Saturday-first week, matching the region.
                              for (final weekday in const [6, 7, 1, 2, 3, 4, 5])
                                FilterChip(
                                  label: Text(DateFormat.E(
                                          Localizations.localeOf(context)
                                              .languageCode)
                                      // 2026-01-05 is a Monday (weekday 1).
                                      .format(DateTime(2026, 1, 4 + weekday))),
                                  selected: _workProfile.weekdays
                                      .contains(weekday),
                                  onSelected: (selected) {
                                    final days = {..._workProfile.weekdays};
                                    if (selected) {
                                      days.add(weekday);
                                    } else {
                                      days.remove(weekday);
                                    }
                                    _updateWorkProfile(_workProfile
                                        .copyWith(weekdays: days));
                                  },
                                ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                SectionTitle(l10n.sectionTiming),
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
                        const SizedBox(height: 4),
                        const Divider(height: 1, indent: 16, endIndent: 16),
                        // Set-once per-prayer detail lives on its own page.
                        ListTile(
                          leading: const Icon(Icons.tune),
                          title: Text(l10n.sectionPerPrayer),
                          subtitle: Text(l10n.prayerSettingsHint),
                          trailing: const _Chevron(),
                          onTap: () async {
                            await Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (_) =>
                                      const PrayerSettingsScreen()),
                            );
                            await _load();
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SectionTitle(l10n.sectionJumuah),
                Card(
                  child: Column(
                    children: [
                      SwitchListTile(
                        title: Text(l10n.jumuahToggle),
                        subtitle: Text(l10n.jumuahHint),
                        value: settings.jumuahEnabled,
                        onChanged: (v) =>
                            _update(settings.copyWith(jumuahEnabled: v)),
                        secondary: const Icon(Icons.mosque),
                      ),
                      if (settings.jumuahEnabled) ...[
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(l10n.jumuahArriveEarlyLabel,
                                    style: theme.textTheme.bodyLarge),
                              ),
                              StepperRow(
                                value: settings.jumuahArriveEarlyMinutes,
                                unit: l10n.minutesShort,
                                onChanged: (v) => _update(settings.copyWith(
                                    jumuahArriveEarlyMinutes:
                                        v.clamp(0, 120))),
                              ),
                            ],
                          ),
                        ),
                        const Divider(height: 1, indent: 16, endIndent: 16),
                        SwitchListTile(
                          title: Text(l10n.jumuahDifferentMosqueToggle),
                          value: _jumuahMosque != null,
                          onChanged: (v) async {
                            if (v) {
                              await _pickJumuahMosque();
                            } else {
                              setState(() => _jumuahMosque = null);
                              await _repository.saveJumuahMosque(null);
                              await _update(settings.copyWith(
                                  clearJumuahTravelMinutes: true));
                            }
                          },
                          secondary: const Icon(Icons.alt_route),
                        ),
                        if (_jumuahMosque != null) ...[
                          ListTile(
                            leading: const Icon(Icons.place_outlined),
                            title: Text(_jumuahMosque!.name),
                            subtitle: Text(l10n.changeMosque),
                            trailing: const _Chevron(),
                            onTap: _pickJumuahMosque,
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.fromLTRB(16, 0, 16, 12),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(l10n.jumuahTravelLabel,
                                      style: theme.textTheme.bodyLarge),
                                ),
                                StepperRow(
                                  value: settings.jumuahTravelMinutes ??
                                      settings.travelMinutes,
                                  unit: l10n.minutesShort,
                                  onChanged: (v) => _update(
                                      settings.copyWith(
                                          jumuahTravelMinutes:
                                              v.clamp(0, 180))),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                SectionTitle(l10n.alertStyleTitle),
                Card(
                  child: Column(
                    children: [
                      ListTile(
                        leading: Icon(settings.alertStyle == AlertStyle.alarm
                            ? Icons.alarm
                            : Icons.notifications_outlined),
                        title: Text(settings.alertStyle == AlertStyle.alarm
                            ? l10n.alertAlarm
                            : l10n.alertStandard),
                        trailing: const _Chevron(),
                        onTap: _pickAlertStyle,
                      ),
                      const Divider(height: 1, indent: 16, endIndent: 16),
                      ListTile(
                        leading: const Icon(Icons.help_outline),
                        title: Text(l10n.troubleshootEntry),
                        trailing: const _Chevron(),
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (_) =>
                                  const AlertTroubleshootingScreen()),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                SectionTitle(l10n.appearance),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      children: [
                        ValueListenableBuilder<ThemeMode>(
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
                              _repository
                                  .saveThemeModeName(selection.first.name);
                            },
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: Text(l10n.hijriAdjustmentLabel,
                                  style: theme.textTheme.bodyLarge),
                            ),
                            StepperRow(
                              value: _hijriAdjustment,
                              min: -2,
                              onChanged: (v) async {
                                final days = v.clamp(-2, 2);
                                setState(() => _hijriAdjustment = days);
                                await _repository.saveHijriAdjustment(days);
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SectionTitle(l10n.language),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: ValueListenableBuilder<Locale?>(
                      valueListenable: localeNotifier,
                      builder: (context, locale, _) =>
                          SegmentedButton<String>(
                        expandedInsets: EdgeInsets.zero,
                        segments: [
                          ButtonSegment(
                            value: 'system',
                            label: Text(l10n.themeSystem),
                          ),
                          const ButtonSegment(
                            value: 'ar',
                            label: Text('العربية'),
                          ),
                          const ButtonSegment(
                            value: 'en',
                            label: Text('English'),
                          ),
                        ],
                        selected: {locale?.languageCode ?? 'system'},
                        onSelectionChanged: (selection) {
                          final name = selection.first;
                          localeNotifier.value = localeFromName(name);
                          _repository.saveLocaleName(name);
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SectionTitle(l10n.about),
                Card(
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.privacy_tip_outlined),
                        title: Text(l10n.privacyPolicy),
                        trailing: const Icon(Icons.open_in_new, size: 18),
                        onTap: () => launchUrl(
                          Uri.parse(
                              'https://mamoonalmazloom.github.io/SalatOnTime/privacy-policy'),
                          mode: LaunchMode.externalApplication,
                        ),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.calculate_outlined),
                        title: Text(l10n.calcMethodNote),
                        subtitle: Text(calculationMethodLabel(
                          settings.calculationMethod,
                          Localizations.localeOf(context).languageCode,
                        )),
                        trailing: const _Chevron(),
                        onTap: _pickCalculationMethod,
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

/// Direction-aware trailing chevron for navigation rows.
class _Chevron extends StatelessWidget {
  const _Chevron();

  @override
  Widget build(BuildContext context) {
    final rtl = Directionality.of(context) == TextDirection.rtl;
    return Icon(rtl ? Icons.chevron_left : Icons.chevron_right);
  }
}
