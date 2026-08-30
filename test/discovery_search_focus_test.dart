// Widget test for the search-focus list (brewdesk#28, mockup 02): focusing
// the search field promotes the shelf to a vertical result list, and the
// header's Cancel action clears both focus and the query.
//
// Deliberately avoids `pumpAndSettle()` — flutter_map keeps scheduling
// frames — and installs a fail-fast HttpClient so map tiles (real network by
// default) never attempt real I/O.

import 'dart:convert';
import 'dart:io';

import 'package:brewdesk/data/repositories/saved_venues_repository.dart';
import 'package:brewdesk/data/repositories/venue_repository.dart';
import 'package:brewdesk/data/services/saved_venues_service.dart';
import 'package:brewdesk/data/services/venue_api.dart';
import 'package:brewdesk/l10n/app_localizations.dart';
import 'package:brewdesk/ui/features/discovery/discovery_screen.dart';
import 'package:brewdesk/ui/features/onboarding/union_square_location_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
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

Map<String, Object?> _venueJson(String id, {String name = 'Spot One'}) => {
  'id': id,
  'name': name,
  'lat': 40.7359,
  'lng': -73.9911,
  'neighborhood': 'Union Square',
  'borough': 'Manhattan',
  'venueType': 'cafe',
  'attributes': {
    'wifi': {'value': 'fast', 'source': 'curated'},
    'outlets': {'value': 'plenty', 'source': 'curated'},
    'laptopPolicy': {'value': 'unrestricted', 'source': 'curated'},
    'noise': {'value': 'quiet', 'source': 'curated'},
  },
  'vibeTags': <String>[],
  'workScore': 80,
  'tier': 'researched',
};

Future<Widget> _harness() async {
  SharedPreferences.setMockInitialValues({});
  final preferences = await SharedPreferences.getInstance();
  final client = MockClient(
    (request) async => http.Response(
      jsonEncode({
        'meta': {},
        'venues': [_venueJson('spot-1')],
      }),
      200,
    ),
  );
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: DiscoveryScreen(
      venueRepository: VenueRepository(
        VenueApi(client: client, baseUri: Uri.parse('https://example.test')),
      ),
      savedVenues: SavedVenuesRepository(SavedVenuesService(preferences)),
      locationService: const UnionSquareLocationService(),
    ),
  );
}

Future<void> _pumpDiscovery(WidgetTester tester) async {
  for (var i = 0; i < 6; i++) {
    await tester.pump(const Duration(milliseconds: 20));
  }
}

void main() {
  testWidgets(
    'focusing the search field shows the vertical list; Cancel clears focus and query',
    (tester) async {
      await HttpOverrides.runZoned(() async {
        await tester.pumpWidget(await _harness());
        await _pumpDiscovery(tester);

        // Not focused yet: no results list, no Cancel action.
        expect(find.byKey(const Key('search-results-list')), findsNothing);
        expect(find.byKey(const Key('search-cancel')), findsNothing);

        await tester.tap(find.byType(TextField));
        await _pumpDiscovery(tester);

        expect(find.byKey(const Key('search-results-list')), findsOneWidget);
        expect(find.byKey(const Key('search-cancel')), findsOneWidget);
        expect(find.text('Spot One'), findsOneWidget);

        await tester.enterText(find.byType(TextField), 'zzz-no-match');
        await _pumpDiscovery(tester);

        // The query no longer matches the one loaded venue.
        expect(find.text('Spot One'), findsNothing);

        await tester.tap(find.byKey(const Key('search-cancel')));
        await _pumpDiscovery(tester);

        // Cancel cleared both focus (list gone) and the query (venue is
        // back once the shelf takes over again).
        expect(find.byKey(const Key('search-results-list')), findsNothing);
        expect(find.byKey(const Key('search-cancel')), findsNothing);
        expect(find.text('Spot One'), findsWidgets);
        final field = tester.widget<TextField>(find.byType(TextField));
        expect(field.controller?.text, isEmpty);
      }, createHttpClient: (context) => _FailFastHttpClient());
    },
  );
}
