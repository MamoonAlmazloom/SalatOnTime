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

  testWidgets('bathroom toggle on travel step shows minutes stepper',
      (tester) async {
    // Pixel 3a-sized surface: the overflow only reproduces on narrow screens.
    tester.view.physicalSize = const Size(1080, 2220);
    tester.view.devicePixelRatio = 2.75;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const SalatApp(onboarded: false));
    await tester.pumpAndSettle();

    // Welcome → mosque map → travel step.
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('I need the bathroom before prayer'));
    await tester.pumpAndSettle();
    expect(find.text('Minutes for the bathroom'), findsOneWidget);
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

    // The hero header leaves only a couple of prayer rows visible at once,
    // so scroll each later prayer into view before asserting.
    for (final prayer in ['Asr', 'Maghrib', 'Isha']) {
      await tester.scrollUntilVisible(find.text(prayer), 80,
          scrollable: find.byType(Scrollable).first);
      expect(find.text(prayer), findsWidgets);
    }

    // Unmount to dispose the ticking view model before the test ends.
    await tester.pumpWidget(const SizedBox());
  });
}
