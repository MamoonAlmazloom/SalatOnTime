import 'package:flutter/material.dart';
import 'package:salat_app/l10n/app_localizations.dart';

import '../../../../domain/models/arrival_target.dart';
import '../../../../domain/models/prayer.dart';
import '../../../core/widgets/prayer_tuning_card.dart';
import '../view_models/onboarding_view_model.dart';

class OffsetsStep extends StatelessWidget {
  const OffsetsStep({super.key, required this.viewModel});

  final OnboardingViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final settings = viewModel.settings;

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text(l10n.offsetsStepHint, style: theme.textTheme.bodyLarge),
        const SizedBox(height: 16),
        for (final prayer in Prayer.values)
          PrayerTuningCard(
            prayer: prayer,
            iqamaOffset: settings.iqamaOffsets[prayer] ?? 0,
            target: settings.arrivalTargets[prayer] ?? ArrivalTarget.iqama,
            onOffsetChanged: (v) => viewModel.setIqamaOffset(prayer, v),
            onTargetChanged: (t) => viewModel.setArrivalTarget(prayer, t),
            bathroomMinutes: settings.bathroomEnabled
                ? (settings.bathroomMinutes[prayer] ?? 3)
                : null,
            onBathroomMinutesChanged: (v) =>
                viewModel.setBathroomMinutesFor(prayer, v),
          ),
      ],
    );
  }
}
