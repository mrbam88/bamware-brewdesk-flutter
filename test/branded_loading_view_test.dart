import 'package:brewdesk/l10n/app_localizations.dart';
import 'package:brewdesk/core/theme/app_theme.dart';
import 'package:brewdesk/core/widgets/branded_loading_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<Widget> _harness() async {
  return MaterialApp(
    theme: AppTheme.light,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: const BrandedLoadingView(),
  );
}

void main() {
  testWidgets(
    'shows the deep-green full-bleed background, the wordmark, and a subtle progress ring',
    (tester) async {
      await tester.pumpWidget(await _harness());

      expect(find.text('BREWDESK'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      final coloredBox = tester.widget<ColoredBox>(
        find
            .descendant(
              of: find.byType(BrandedLoadingView),
              matching: find.byType(ColoredBox),
            )
            .first,
      );
      expect(coloredBox.color, AppColors.deepGreen);

      // A subtle ring, not a busy full-size spinner: thin stroke, small box.
      final indicator = tester.widget<CircularProgressIndicator>(
        find.byType(CircularProgressIndicator),
      );
      expect(indicator.strokeWidth, 2);
    },
  );

  testWidgets('carries an accessibility label for screen readers', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();

    await tester.pumpWidget(await _harness());

    expect(find.bySemanticsLabel('Loading BrewDesk'), findsOneWidget);

    handle.dispose();
  });

  testWidgets('renders the Spanish accessibility label under the es locale', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        locale: const Locale('es'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const BrandedLoadingView(),
      ),
    );

    expect(find.bySemanticsLabel('Cargando BrewDesk'), findsOneWidget);

    handle.dispose();
  });
}
