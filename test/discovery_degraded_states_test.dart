// Widget tests for the discovery screen's intentional degraded states
// (brewdesk#11): engine-down, offline (+ auto-retry on reconnect),
// loaded-empty, and slow. Deliberately avoids `pumpAndSettle()` — flutter_map
// tiles and a slow/never-resolving request are exactly the "indeterminate
// spinner" the house rule warns about — and installs a fail-fast HttpClient
// so map tiles (real network by default) never attempt real I/O.

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:brewdesk/data/repositories/saved_venues_repository.dart';
import 'package:brewdesk/data/repositories/venue_repository.dart';
import 'package:brewdesk/data/services/connectivity_service.dart';
import 'package:brewdesk/data/services/saved_venues_service.dart';
import 'package:brewdesk/data/services/venue_api.dart';
import 'package:brewdesk/ui/features/discovery/discovery_screen.dart';
import 'package:brewdesk/ui/features/onboarding/union_square_location_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Blocks every real `dart:io` HTTP call (flutter_map's tile requests go
/// through this, not the app's `http.Client`) so no widget test ever waits
/// on a real network round trip.
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

class _FakeConnectivityService extends ConnectivityService {
  _FakeConnectivityService(this._controller);
  final StreamController<bool> _controller;

  @override
  Stream<bool> get onlineChanges => _controller.stream;
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
    'laptopPolicy': {'value': 'discouraged', 'source': 'curated'},
    'noise': {'value': 'quiet', 'source': 'curated'},
  },
  'vibeTags': <String>[],
  'workScore': 80,
  'tier': 'researched',
};

Future<Widget> _harness({
  required http.Client client,
  ConnectivityService? connectivity,
}) async {
  SharedPreferences.setMockInitialValues({});
  final preferences = await SharedPreferences.getInstance();
  return MaterialApp(
    home: DiscoveryScreen(
      venueRepository: VenueRepository(
        VenueApi(client: client, baseUri: Uri.parse('https://example.test')),
      ),
      savedVenues: SavedVenuesRepository(SavedVenuesService(preferences)),
      locationService: const UnionSquareLocationService(),
      connectivity: connectivity,
    ),
  );
}

/// Advances several frames without ever settling to "no more frames" —
/// flutter_map keeps scheduling work, so `pumpAndSettle` is not safe here.
Future<void> _pumpDiscovery(WidgetTester tester) async {
  for (var i = 0; i < 6; i++) {
    await tester.pump(const Duration(milliseconds: 20));
  }
}

void main() {
  testWidgets(
    'engine-down (500) shows an error card naming the engine, with retry',
    (tester) async {
      await HttpOverrides.runZoned(() async {
        final client = MockClient(
          (request) async => http.Response('down', 500),
        );
        await tester.pumpWidget(await _harness(client: client));
        await _pumpDiscovery(tester);

        expect(
          find.byKey(const Key('discovery-state-engine-error')),
          findsOneWidget,
        );
        expect(find.textContaining('venue engine'), findsOneWidget);
        expect(find.text('Try again'), findsOneWidget);
        expect(find.byKey(const Key('discovery-state-offline')), findsNothing);
      }, createHttpClient: (context) => _FailFastHttpClient());
    },
  );

  testWidgets('offline shows an offline card and recovers automatically once '
      'connectivity returns, with no user action', (tester) async {
    await HttpOverrides.runZoned(() async {
      var attempt = 0;
      final client = MockClient((request) async {
        attempt++;
        if (attempt == 1) throw const SocketException('offline');
        return http.Response(
          jsonEncode({
            'meta': {},
            'venues': [_venueJson('spot-1')],
          }),
          200,
        );
      });
      final connectivityController = StreamController<bool>();
      addTearDown(connectivityController.close);

      await tester.pumpWidget(
        await _harness(
          client: client,
          connectivity: _FakeConnectivityService(connectivityController),
        ),
      );
      await _pumpDiscovery(tester);

      expect(find.byKey(const Key('discovery-state-offline')), findsOneWidget);
      expect(find.textContaining('offline'), findsOneWidget);

      // Connectivity restored — no tap, no retry button pressed.
      connectivityController.add(true);
      await _pumpDiscovery(tester);

      expect(find.byKey(const Key('discovery-state-offline')), findsNothing);
      expect(attempt, 2);
    }, createHttpClient: (context) => _FailFastHttpClient());
  });

  testWidgets('loaded-empty shows "No spots in this view" and a working clear-filters '
      'action when a filter is why the list is empty', (tester) async {
    await HttpOverrides.runZoned(() async {
      final client = MockClient(
        (request) async => http.Response(
          jsonEncode({
            'meta': {},
            // laptopPolicy: discouraged — excluded once laptop-friendly is on.
            'venues': [_venueJson('spot-1')],
          }),
          200,
        ),
      );
      await tester.pumpWidget(await _harness(client: client));
      await _pumpDiscovery(tester);

      expect(find.text('Spot One'), findsWidgets);
      expect(find.byKey(const Key('discovery-clear-filters')), findsNothing);

      // Open the filter menu and turn on laptop-friendly, which this
      // fixture's `laptopPolicy: discouraged` fails. Filters apply live —
      // there is no separate "apply" step.
      await tester.tap(find.byTooltip('Filters'));
      await _pumpDiscovery(tester);
      await tester.tap(find.text('Laptop friendly'));
      await _pumpDiscovery(tester);
      // Close the popover (tap its full-screen barrier, away from the
      // panel) so it stops covering the shelf underneath.
      await tester.tapAt(const Offset(20, 20));
      await _pumpDiscovery(tester);

      expect(find.byKey(const Key('discovery-state-empty')), findsOneWidget);
      expect(find.text('No spots in this view.'), findsOneWidget);
      expect(find.byKey(const Key('discovery-clear-filters')), findsOneWidget);

      await tester.tap(find.byKey(const Key('discovery-clear-filters')));
      await _pumpDiscovery(tester);

      expect(find.text('Spot One'), findsWidgets);
      expect(find.byKey(const Key('discovery-state-empty')), findsNothing);
    }, createHttpClient: (context) => _FailFastHttpClient());
  });

  testWidgets('a truly empty engine result shows the empty state without a '
      'clear-filters action (nothing to clear)', (tester) async {
    await HttpOverrides.runZoned(() async {
      final client = MockClient(
        (request) async =>
            http.Response(jsonEncode({'meta': {}, 'venues': <Object?>[]}), 200),
      );
      await tester.pumpWidget(await _harness(client: client));
      await _pumpDiscovery(tester);

      expect(find.byKey(const Key('discovery-state-empty')), findsOneWidget);
      expect(find.text('No spots in this view.'), findsOneWidget);
      expect(find.byKey(const Key('discovery-clear-filters')), findsNothing);
    }, createHttpClient: (context) => _FailFastHttpClient());
  });

  testWidgets(
    'slow keeps an honest loading card on screen — no flash to content or error',
    (tester) async {
      await HttpOverrides.runZoned(() async {
        final gate = Completer<http.Response>();
        final client = MockClient((request) async => gate.future);
        await tester.pumpWidget(await _harness(client: client));

        // A single pump — enough for the first frame, not enough for a
        // request that never resolves. This is the whole point of the test.
        await tester.pump();

        expect(
          find.byKey(const Key('discovery-state-loading')),
          findsOneWidget,
        );
        expect(
          find.byKey(const Key('discovery-state-engine-error')),
          findsNothing,
        );
        expect(find.byKey(const Key('discovery-state-offline')), findsNothing);
        expect(find.text('Spot One'), findsNothing);

        // Resolve before teardown so the 15s request timeout's Timer is
        // cancelled instead of left pending (see house rule on hung tests).
        gate.complete(
          http.Response(
            jsonEncode({
              'meta': {},
              'venues': [_venueJson('spot-1')],
            }),
            200,
          ),
        );
        await _pumpDiscovery(tester);
      }, createHttpClient: (context) => _FailFastHttpClient());
    },
  );
}
