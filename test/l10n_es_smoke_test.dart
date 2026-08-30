// Spanish locale widget smoke test (brewdesk#14): Spots, Saved, and You all
// render Spanish copy when the app locale is 'es'. Deliberately avoids
// `pumpAndSettle()` on the Spots tab — flutter_map keeps scheduling frames,
// which is exactly the "indeterminate spinner" the house rule warns about —
// and installs a fail-fast HttpClient so map tiles (real network by
// default) never attempt real I/O.

import 'dart:convert';
import 'dart:io';

import 'package:brewdesk/core/di/app_providers.dart';
import 'package:brewdesk/core/location/location_mode.dart';
import 'package:brewdesk/features/venues/data/venue_repository.dart';
import 'package:brewdesk/features/venues/data/venue_api.dart';
import 'package:brewdesk/l10n/app_localizations.dart';
import 'package:brewdesk/core/location/union_square_location_service.dart';
import 'package:brewdesk/features/shell/presentation/app_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FailFastHttpClient implements HttpClient {
  @override
  Future<HttpClientRequest> getUrl(Uri url) =>
      Future<HttpClientRequest>.error(const SocketException('blocked in test'));

  @override
  Future<HttpClientRequest> openUrl(String method, Uri url) =>
      Future<HttpClientRequest>.error(const SocketException('blocked in test'));

  @override
  void close({bool force = false}) {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// Advances several frames without ever settling to "no more frames" —
/// flutter_map keeps scheduling work, so `pumpAndSettle` is not safe here.
///
/// 20 iterations of 20ms comfortably clears the branded loading state's
/// ~300ms reduce-flicker floor (brewdesk#33) so the Spots-tab assertions
/// below don't race it.
Future<void> _pumpDiscovery(WidgetTester tester) async {
  for (var i = 0; i < 20; i++) {
    await tester.pump(const Duration(milliseconds: 20));
  }
}

Future<Widget> _harness() async {
  SharedPreferences.setMockInitialValues({});
  final preferences = await SharedPreferences.getInstance();
  final client = MockClient(
    (request) async =>
        http.Response(jsonEncode({'meta': {}, 'venues': []}), 200),
  );
  return ProviderScope(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(preferences),
      venueRepositoryProvider.overrideWithValue(
        ApiVenueRepository(
          VenueApi(client: client, baseUri: Uri.parse('https://example.test')),
        ),
      ),
      effectiveLocationServiceProvider.overrideWithValue(
        const UnionSquareLocationService(),
      ),
    ],
    child: const MaterialApp(
      locale: Locale('es'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: AppShell(),
    ),
  );
}

void main() {
  setUp(() {
    PackageInfo.setMockInitialValues(
      appName: 'BrewDesk',
      packageName: 'io.bamware.brewdesk',
      version: '1.0.0',
      buildNumber: '1',
      buildSignature: '',
    );
  });

  testWidgets('Spots, Saved, and You render Spanish strings', (tester) async {
    // The You tab is one long scroll of cards; give the test surface enough
    // height that every row is built (ListView virtualizes off-screen
    // children) instead of scrolling to each row individually.
    tester.view.physicalSize = const Size(800, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await HttpOverrides.runZoned(() async {
      await tester.pumpWidget(await _harness());
      await _pumpDiscovery(tester);

      // Bottom nav is always built, regardless of tab content load state.
      expect(find.text('Lugares'), findsOneWidget);
      expect(find.text('Guardados'), findsOneWidget);
      expect(find.text('Tú'), findsOneWidget);

      // Spots tab (default): search hint and the empty-result state, both
      // localized strings authored directly in DiscoveryScreen.
      expect(find.text('Buscar lugares para trabajar'), findsOneWidget);
      expect(find.text('No hay lugares en esta vista.'), findsOneWidget);

      // Saved tab: no saved ids, so it resolves straight to the empty state.
      await tester.tap(find.text('Guardados'));
      await tester.pumpAndSettle();
      expect(find.text('Guarda tu próximo lugar de trabajo'), findsOneWidget);

      // You tab: the compact list (brewdesk-flutter#32).
      await tester.tap(find.text('Tú'));
      await tester.pumpAndSettle();
      expect(find.text('Cómo funciona la puntuación'), findsOneWidget);
      expect(find.text('Compartir la app'), findsOneWidget);
      expect(find.text('Acerca de'), findsOneWidget);

      // About row → detail screen, where the hero card now lives.
      await tester.tap(find.text('Acerca de'));
      await tester.pumpAndSettle();
      expect(find.text('Tu ciudad es tu oficina.'), findsOneWidget);
    }, createHttpClient: (context) => _FailFastHttpClient());
  });
}
