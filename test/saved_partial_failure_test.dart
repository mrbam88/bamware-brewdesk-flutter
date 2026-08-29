// Saved screen partial-hydration failure (brewdesk#11): one saved id that
// fails to load must not take the rest of the list down with it, and the
// failure itself must be visible — not silently dropped.

import 'dart:convert';

import 'package:brewdesk/data/repositories/saved_venues_repository.dart';
import 'package:brewdesk/data/repositories/venue_repository.dart';
import 'package:brewdesk/data/services/saved_venues_service.dart';
import 'package:brewdesk/data/services/venue_api.dart';
import 'package:brewdesk/ui/features/saved/saved_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

Map<String, Object?> _venueJson(String id, {required String name}) => {
  'id': id,
  'name': name,
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
  'workScore': 75,
  'tier': 'researched',
};

void main() {
  testWidgets(
    'a saved id that fails to hydrate surfaces its own row; the rest of '
    'the list still renders',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      final preferences = await SharedPreferences.getInstance();
      final savedVenues = SavedVenuesRepository(
        SavedVenuesService(preferences),
      );
      await savedVenues.toggle('spot-ok');
      await savedVenues.toggle('spot-missing');

      final client = MockClient((request) async {
        if (request.url.path == '/v1/venues/spot-ok') {
          return http.Response(
            jsonEncode({'venue': _venueJson('spot-ok', name: 'Union Hall')}),
            200,
          );
        }
        return http.Response('not found', 404);
      });
      final repository = VenueRepository(
        VenueApi(client: client, baseUri: Uri.parse('https://example.test')),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: SavedScreen(
            venueRepository: repository,
            savedVenues: savedVenues,
            onBrowse: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Union Hall'), findsOneWidget);
      expect(find.text("Couldn't load this saved spot."), findsOneWidget);

      // The failed row offers a way to clean itself up.
      await tester.tap(find.text('Remove'));
      await tester.pumpAndSettle();

      expect(find.text("Couldn't load this saved spot."), findsNothing);
      expect(find.text('Union Hall'), findsOneWidget);
      expect(savedVenues.contains('spot-missing'), isFalse);
    },
  );
}
