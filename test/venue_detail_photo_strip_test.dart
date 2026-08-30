// Detail photo strip collapse (brewdesk#11): when every photo fails to
// load, the whole strip disappears — no placeholder, no broken tiles left
// sitting on screen. Uses a fail-fast dart:io HttpClient override so the
// image failure is synchronous and deterministic, never a real network wait.

import 'dart:convert';
import 'dart:io';

import 'package:brewdesk/features/saved/data/saved_venues_repository.dart';
import 'package:brewdesk/features/venues/data/venue_repository.dart';
import 'package:brewdesk/features/saved/data/saved_venues_service.dart';
import 'package:brewdesk/features/venues/data/venue_api.dart';
import 'package:brewdesk/features/venues/domain/venue.dart';
import 'package:brewdesk/l10n/app_localizations.dart';
import 'package:brewdesk/features/venue_detail/presentation/venue_detail_screen.dart';
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

const _venueJson = {
  'id': 'spot-1',
  'name': 'Blue Bottle SoHo',
  'lat': 40.7,
  'lng': -74.0,
  'neighborhood': 'SoHo',
  'borough': 'Manhattan',
  'venueType': 'cafe',
  'attributes': {
    'wifi': {'value': 'fast', 'source': 'curated'},
    'outlets': {'value': 'plenty', 'source': 'curated'},
    'laptopPolicy': {'value': 'unrestricted', 'source': 'curated'},
    'noise': {'value': 'moderate', 'source': 'curated'},
  },
  'vibeTags': <String>[],
  'workScore': 82,
  'tier': 'researched',
};

void main() {
  testWidgets(
    'every photo failing to load collapses the strip — no placeholder, no broken tiles',
    (tester) async {
      await HttpOverrides.runZoned(() async {
        SharedPreferences.setMockInitialValues({});
        final preferences = await SharedPreferences.getInstance();
        final client = MockClient((request) async {
          if (request.url.path.endsWith('/photos')) {
            return http.Response(
              jsonEncode({
                'photos': [
                  {'url': 'https://example.test/broken-1.jpg'},
                  {'url': 'https://example.test/broken-2.jpg'},
                ],
              }),
              200,
            );
          }
          return http.Response(jsonEncode({'venue': _venueJson}), 200);
        });

        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: VenueDetailScreen(
              initialVenue: Venue.fromJson(_venueJson),
              venueRepository: VenueRepository(
                VenueApi(
                  client: client,
                  baseUri: Uri.parse('https://example.test'),
                ),
              ),
              savedVenues: SavedVenuesRepository(
                SavedVenuesService(preferences),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byKey(const Key('venue-photo-strip')), findsNothing);
        expect(find.text('Workability'), findsOneWidget);
        expect(find.byType(Image), findsNothing);
      }, createHttpClient: (context) => _FailFastHttpClient());
    },
  );
}
