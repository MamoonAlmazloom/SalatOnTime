import 'package:flutter/material.dart';
import 'package:salat_app/l10n/app_localizations.dart';

import '../../../../data/repositories/settings_repository.dart';
import '../../../../domain/models/mosque.dart';
import '../../../../domain/models/timing_settings.dart';

/// Placeholder Home: confirms setup and shows the saved configuration.
/// Replaced by the live-countdown screen in the next milestone.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<(Mosque?, TimingSettings)> _load() async {
    final repository = SettingsRepository();
    return (await repository.loadMosque(), await repository.loadSettings());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.appTitle)),
      body: FutureBuilder<(Mosque?, TimingSettings)>(
        future: _load(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final (mosque, settings) = snapshot.data!;
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle,
                      size: 96, color: theme.colorScheme.primary),
                  const SizedBox(height: 24),
                  Text(l10n.homeSetupComplete,
                      style: theme.textTheme.headlineMedium),
                  const SizedBox(height: 16),
                  if (mosque != null)
                    Text(l10n.homeMosqueLine(mosque.name),
                        style: theme.textTheme.bodyLarge),
                  Text(l10n.homeTravelLine(settings.travelMinutes),
                      style: theme.textTheme.bodyLarge),
                  const SizedBox(height: 16),
                  Text(l10n.homeComingSoon,
                      style: theme.textTheme.bodyMedium,
                      textAlign: TextAlign.center),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
