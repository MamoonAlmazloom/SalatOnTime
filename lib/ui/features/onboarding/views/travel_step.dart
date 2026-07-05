import 'package:flutter/material.dart';
import 'package:salat_app/l10n/app_localizations.dart';

import '../../../../data/services/routing_service.dart';
import '../../../../domain/models/prayer.dart';
import '../view_models/onboarding_view_model.dart';
import 'stepper_row.dart';

class TravelStep extends StatelessWidget {
  const TravelStep({super.key, required this.viewModel});

  final OnboardingViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final hasLocation = viewModel.homeLatitude != null;

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text(l10n.travelMinutesLabel, style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        StepperRow(
          value: viewModel.settings.travelMinutes,
          unit: l10n.minutesShort,
          onChanged: viewModel.setTravelMinutes,
          big: true,
        ),
        const SizedBox(height: 16),
        if (viewModel.calculatingTravel)
          const Center(child: CircularProgressIndicator())
        else
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: hasLocation
                      ? () =>
                          viewModel.calculateTravelTime(TravelMode.walking)
                      : null,
                  icon: const Icon(Icons.directions_walk),
                  label: Text('${l10n.calculateForMe} (${l10n.walking})'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: hasLocation
                      ? () =>
                          viewModel.calculateTravelTime(TravelMode.driving)
                      : null,
                  icon: const Icon(Icons.directions_car),
                  label: Text('${l10n.calculateForMe} (${l10n.driving})'),
                ),
              ),
            ],
          ),
        if (!hasLocation)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              l10n.travelCalcNeedsLocation,
              style: theme.textTheme.bodySmall,
            ),
          ),
        if (viewModel.travelCalcFailed)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              l10n.travelCalcFailed,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: theme.colorScheme.error),
            ),
          ),
        const Divider(height: 48),
        SwitchListTile(
          title: Text(l10n.wuduToggle(viewModel.settings.wuduMinutes)),
          value: viewModel.settings.wuduEnabled,
          onChanged: viewModel.setWuduEnabled,
          secondary: const Icon(Icons.water_drop),
        ),
        SwitchListTile(
          title: Text(l10n.bathroomToggle),
          value: viewModel.settings.bathroomEnabled,
          onChanged: viewModel.setBathroomEnabled,
          secondary: const Icon(Icons.wc),
        ),
        if (viewModel.settings.bathroomEnabled)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(child: Text(l10n.bathroomMinutesLabel)),
                StepperRow(
                  value: viewModel
                          .settings.bathroomMinutes[Prayer.dhuhr] ??
                      3,
                  unit: l10n.minutesShort,
                  onChanged: viewModel.setBathroomMinutes,
                ),
              ],
            ),
          ),
      ],
    );
  }
}
