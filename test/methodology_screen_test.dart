import 'package:brewdesk/l10n/app_localizations.dart';
import 'package:brewdesk/ui/features/methodology/methodology_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'methodology screen renders the 4 score tiers and the scoring-order copy',
    (tester) async {
      // The page is one long scroll of cards; give the test surface enough
      // height that every section is built (ListView virtualizes off-screen
      // children), instead of scrolling to each assertion individually.
      tester.view.physicalSize = const Size(800, 4000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const MethodologyScreen(),
        ),
      );

      expect(find.text('How Work Fit works'), findsOneWidget);

      // The 4 score tiers, matching the Discover map's badge colors.
      expect(find.text('great'), findsOneWidget);
      expect(find.text('good'), findsOneWidget);
      expect(find.text('mixed'), findsOneWidget);
      expect(find.text('weak'), findsOneWidget);
      expect(find.text('75+'), findsOneWidget);
      expect(find.text('60–74'), findsOneWidget);
      expect(find.text('45–59'), findsOneWidget);
      expect(find.text('0–44'), findsOneWidget);

      // The scoring-order copy: laptop policy > seating > wifi > noise.
      expect(
        find.textContaining(
          'Laptop policy dominates (35%), then seating (25%), Wi-Fi (15%), '
          'outlets (15%), noise (10%)',
        ),
        findsOneWidget,
      );

      // Data origins: curated / OSM baseline / agent research.
      expect(
        find.textContaining('Curated', findRichText: true),
        findsOneWidget,
      );
      expect(
        find.textContaining('OSM baseline', findRichText: true),
        findsOneWidget,
      );
      expect(
        find.textContaining('Agent researched', findRichText: true),
        findsOneWidget,
      );
    },
  );
}
