import 'package:flutter/material.dart';
import 'package:salat_app/l10n/app_localizations.dart';

import 'data/repositories/settings_repository.dart';
import 'data/services/location_service.dart';
import 'data/services/notification_service.dart';
import 'data/services/routing_service.dart';
import 'ui/core/app_theme.dart';
import 'ui/features/home/views/home_screen.dart';
import 'ui/features/onboarding/view_models/onboarding_view_model.dart';
import 'ui/features/onboarding/views/onboarding_flow.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.instance.initialize();
  final repository = SettingsRepository();
  final onboarded = await repository.isOnboardingComplete();
  runApp(SalatApp(onboarded: onboarded));
}

class SalatApp extends StatelessWidget {
  const SalatApp({super.key, required this.onboarded});

  final bool onboarded;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      home: onboarded
          ? const HomeScreen()
          : OnboardingFlow(
              viewModel: OnboardingViewModel(
                locationService: const LocationService(),
                routingService: RoutingService(),
                repository: SettingsRepository(),
              ),
            ),
    );
  }
}
