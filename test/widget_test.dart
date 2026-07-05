import 'package:flutter_test/flutter_test.dart';
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
}
