import 'package:flutter/material.dart';
import 'package:salat_app/l10n/app_localizations.dart';

import '../../../../domain/models/arrival_target.dart';
import '../../../../domain/models/prayer.dart';
import '../../../core/prayer_names.dart';
import '../view_models/onboarding_view_model.dart';
import 'stepper_row.dart';

class OffsetsStep extends StatelessWidget {
  const OffsetsStep({super.key, required this.viewModel});

  final OnboardingViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text(l10n.offsetsStepHint, style: theme.textTheme.bodyLarge),
        const SizedBox(height: 16),
        for (final prayer in Prayer.values)
          Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(prayerName(l10n, prayer),
                          style: theme.textTheme.titleMedium),
                      StepperRow(
                        value: viewModel.settings.iqamaOffsets[prayer] ?? 0,
                        unit: l10n.minutesShort,
                        onChanged: (v) => viewModel.setIqamaOffset(prayer, v),
                      ),
                    ],
                  ),
                  if (viewModel.settings.bathroomEnabled) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: Text(l10n.bathroomMinutesLabel,
                              style: theme.textTheme.bodyMedium),
                        ),
                        StepperRow(
                          value:
                              viewModel.settings.bathroomMinutes[prayer] ?? 3,
                          unit: l10n.minutesShort,
                          onChanged: (v) =>
                              viewModel.setBathroomMinutesFor(prayer, v),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(l10n.arriveBy, style: theme.textTheme.bodyMedium),
                      SegmentedButton<ArrivalTarget>(
                        segments: [
                          ButtonSegment(
                            value: ArrivalTarget.adhan,
                            label: Text(l10n.targetAdhan),
                          ),
                          ButtonSegment(
                            value: ArrivalTarget.iqama,
                            label: Text(l10n.targetIqama),
                          ),
                        ],
                        selected: {
                          viewModel.settings.arrivalTargets[prayer] ??
                              ArrivalTarget.iqama
                        },
                        onSelectionChanged: (selection) => viewModel
                            .setArrivalTarget(prayer, selection.first),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
