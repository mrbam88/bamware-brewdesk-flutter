import 'package:brewdesk/l10n/app_localizations.dart';
import 'package:brewdesk/ui/features/onboarding/onboarding_flow.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('walking Continue x2 reaches the location intro step', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: OnboardingFlow(onComplete: (_) {}),
      ),
    );

    expect(find.text('Your next desk might serve espresso.'), findsOneWidget);
    expect(find.text('Continue'), findsOneWidget);

    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(find.text('Know before you order.'), findsOneWidget);

    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(find.text('Every score shows its work.'), findsOneWidget);
    expect(find.text('Find my work spot'), findsOneWidget);

    await tester.tap(find.text('Find my work spot'));
    await tester.pumpAndSettle();

    expect(find.text('Start where you are.'), findsOneWidget);
    expect(find.text('Use my location'), findsOneWidget);
    expect(find.text('Use Union Square instead'), findsOneWidget);
  });

  testWidgets('"Use my location" completes with useDeviceLocation true', (
    tester,
  ) async {
    bool? received;
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: OnboardingFlow(onComplete: (value) => received = value),
      ),
    );

    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Find my work spot'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Use my location'));
    await tester.pumpAndSettle();

    expect(received, isTrue);
  });

  testWidgets(
    '"Use Union Square instead" completes with useDeviceLocation false',
    (tester) async {
      bool? received;
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: OnboardingFlow(onComplete: (value) => received = value),
        ),
      );

      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Find my work spot'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Use Union Square instead'));
      await tester.pumpAndSettle();

      expect(received, isFalse);
    },
  );
}
