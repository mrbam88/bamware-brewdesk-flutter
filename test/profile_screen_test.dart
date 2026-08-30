import 'package:brewdesk/l10n/app_localizations.dart';
import 'package:brewdesk/features/methodology/presentation/methodology_screen.dart';
import 'package:brewdesk/features/profile/presentation/about_screen.dart';
import 'package:brewdesk/features/profile/presentation/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // Once the About row is pushed, that screen is one long scroll of cards;
  // give the test surface enough height that every row is built (ListView
  // virtualizes off-screen children) instead of scrolling to each one.
  Future<void> pumpProfileScreen(
    WidgetTester tester, {
    Future<void> Function(String)? shareApp,
  }) async {
    tester.view.physicalSize = const Size(800, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: ProfileScreen(shareApp: shareApp),
      ),
    );
  }

  testWidgets('You tab is a compact list: scoring, share, and About rows', (
    tester,
  ) async {
    await pumpProfileScreen(tester);

    expect(find.text('How scoring works'), findsOneWidget);
    expect(find.text('Share the app'), findsOneWidget);
    expect(find.text('About'), findsOneWidget);

    // The content that used to splash the main surface no longer does —
    // it now lives behind the About row (brewdesk-flutter#32).
    expect(find.text('Your city is your office.'), findsNothing);
    expect(find.text('Support'), findsNothing);
  });

  testWidgets('How scoring works row navigates to the methodology screen', (
    tester,
  ) async {
    await pumpProfileScreen(tester);

    await tester.tap(find.text('How scoring works'));
    await tester.pumpAndSettle();

    expect(find.byType(MethodologyScreen), findsOneWidget);
    expect(find.text('How Work Fit works'), findsOneWidget);
  });

  testWidgets('About row opens the detail screen with the moved content', (
    tester,
  ) async {
    await pumpProfileScreen(tester);

    await tester.tap(find.text('About'));
    await tester.pumpAndSettle();

    expect(find.byType(AboutScreen), findsOneWidget);
    // The hero card and honesty cards moved here from the main You tab.
    expect(find.text('Your city is your office.'), findsOneWidget);
    expect(find.text('Accountless by design'), findsOneWidget);
    // The Support/Privacy/Terms/license/version block moved here too.
    expect(find.text('Support'), findsOneWidget);
  });

  testWidgets('Share the app row shares the app link', (tester) async {
    String? sharedText;
    await pumpProfileScreen(
      tester,
      shareApp: (text) async {
        sharedText = text;
      },
    );

    await tester.tap(find.text('Share the app'));
    await tester.pump();

    expect(sharedText, contains('https://bamware.io/brewdesk'));
  });
}
