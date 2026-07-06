import 'package:flutter/material.dart';
import 'package:salat_app/l10n/app_localizations.dart';

import '../../../core/app_theme.dart';
import '../view_models/onboarding_view_model.dart';

class WelcomeStep extends StatelessWidget {
  const WelcomeStep({super.key, required this.viewModel});

  final OnboardingViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    // Scrollable so small screens (or large font settings) never overflow;
    // ConstrainedBox keeps the content vertically centered on tall screens.
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight - 48),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
          Center(
            child: Container(
              width: 132,
              height: 132,
              decoration: BoxDecoration(
                gradient: AppTheme.heroGradient(theme.colorScheme),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.seed.withValues(alpha: 0.35),
                    blurRadius: 28,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: const Icon(Icons.mosque, size: 64, color: Colors.white),
            ),
          ),
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
            LocationState.denied => Column(
                children: [
                  Text(
                    l10n.locationDeniedNote,
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(color: theme.colorScheme.error),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: viewModel.requestLocation,
                    icon: const Icon(Icons.refresh),
                    label: Text(l10n.allowLocation),
                  ),
                ],
              ),
          },
            ],
          ),
        ),
      ),
    );
  }
}
