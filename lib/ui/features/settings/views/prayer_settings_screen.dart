import 'package:flutter/material.dart';
import 'package:salat_app/l10n/app_localizations.dart';

import '../../../../data/repositories/settings_repository.dart';
import '../../../../domain/models/arrival_target.dart';
import '../../../../domain/models/prayer.dart';
import '../../../../domain/models/timing_settings.dart';
import '../../../core/widgets/prayer_tuning_card.dart';

/// Per-prayer tuning (iqama offset, arrival target, bathroom minutes) on its
/// own page: set-once detail kept out of the main Settings scroll.
class PrayerSettingsScreen extends StatefulWidget {
  const PrayerSettingsScreen({super.key});

  @override
  State<PrayerSettingsScreen> createState() => _PrayerSettingsScreenState();
}

class _PrayerSettingsScreenState extends State<PrayerSettingsScreen> {
  final _repository = SettingsRepository();
  TimingSettings? _settings;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final settings = await _repository.loadSettings();
    if (!mounted) return;
    setState(() => _settings = settings);
  }

  Future<void> _update(TimingSettings updated) async {
    setState(() => _settings = updated);
    await _repository.saveSettings(updated);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final settings = _settings;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.sectionPerPrayer)),
      body: settings == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
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
