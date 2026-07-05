import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:salat_app/domain/models/mosque.dart';
import 'package:salat_app/domain/models/timing_settings.dart';
import 'package:salat_app/main.dart';
import 'package:salat_app/ui/features/onboarding/views/onboarding_flow.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('fresh install shows onboarding welcome step', (tester) async {
    await tester.pumpWidget(const SalatApp(onboarded: false));
    await tester.pumpAndSettle();

    expect(find.byType(OnboardingFlow), findsOneWidget);
    // English is the test default locale.
    expect(find.text('Reach your mosque on time'), findsWidgets);
    expect(find.text('Allow location'), findsOneWidget);
  });

  testWidgets('onboarding navigates forward and back', (tester) async {
    await tester.pumpWidget(const SalatApp(onboarded: false));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    expect(find.text('Mosque name'), findsOneWidget);

    await tester.tap(find.text('Back'));
    await tester.pumpAndSettle();
    expect(find.text('Allow location'), findsOneWidget);
  });

  testWidgets('home shows countdowns and all five prayers', (tester) async {
    SharedPreferences.setMockInitialValues({
      'onboarding_complete': true,
      'mosque': jsonEncode(
        const Mosque(name: 'Test Mosque', latitude: 24.7136, longitude: 46.6753)
            .toJson(),
      ),
      'timing_settings': jsonEncode(const TimingSettings().toJson()),
    });

    await tester.pumpWidget(const SalatApp(onboarded: true));
    // Home runs a periodic 1s ticker, so pumpAndSettle would never settle;
    // pump fixed frames instead.
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('Test Mosque'), findsOneWidget);
    expect(find.text('Fajr'), findsWidgets);
    expect(find.text("Today's prayers"), findsOneWidget);

    // Later prayers sit below the fold in the test viewport.
    await tester.drag(find.byType(ListView), const Offset(0, -400));
    await tester.pump();
    expect(find.text('Asr'), findsWidgets);
    expect(find.text('Maghrib'), findsWidgets);
    expect(find.text('Isha'), findsWidgets);

    // Unmount to dispose the ticking view model before the test ends.
    await tester.pumpWidget(const SizedBox());
  });
}
