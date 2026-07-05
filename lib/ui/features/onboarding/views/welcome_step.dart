import 'package:flutter/material.dart';
import 'package:salat_app/l10n/app_localizations.dart';

import '../view_models/onboarding_view_model.dart';

class WelcomeStep extends StatelessWidget {
  const WelcomeStep({super.key, required this.viewModel});

  final OnboardingViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Icon(Icons.mosque, size: 96, color: theme.colorScheme.primary),
          const SizedBox(height: 32),
          Text(
            l10n.welcomeTitle,
            style: theme.textTheme.headlineMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            l10n.welcomeBody,
            style: theme.textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          switch (viewModel.locationState) {
            LocationState.initial => FilledButton.icon(
                onPressed: viewModel.requestLocation,
                icon: const Icon(Icons.my_location),
                label: Text(l10n.allowLocation),
              ),
            LocationState.locating =>
              const Center(child: CircularProgressIndicator()),
            LocationState.granted => Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle, color: theme.colorScheme.primary),
                  const SizedBox(width: 8),
                  Text(l10n.locationGranted),
                ],
              ),
            LocationState.denied => Text(
                l10n.locationDeniedNote,
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: theme.colorScheme.error),
                textAlign: TextAlign.center,
              ),
          },
        ],
      ),
    );
  }
}
