// Saved screen partial-hydration failure (brewdesk#11): one saved id that
// fails to load must not take the rest of the list down with it, and the
// failure itself must be visible — not silently dropped.

import 'dart:convert';

import 'package:brewdesk/core/di/app_providers.dart';
import 'package:brewdesk/features/saved/application/saved_venue_ids.dart';
import 'package:brewdesk/features/venues/data/venue_repository.dart';
import 'package:brewdesk/features/venues/data/venue_api.dart';
import 'package:brewdesk/l10n/app_localizations.dart';
import 'package:brewdesk/features/saved/presentation/saved_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
      // Seed the persisted ids directly — the provider chain (prefs ->
      // store -> SavedVenueIds) reads them exactly as a real relaunch would.
      SharedPreferences.setMockInitialValues({
        'brewdesk.savedVenueIds': ['spot-ok', 'spot-missing'],
      });
      final preferences = await SharedPreferences.getInstance();

      final client = MockClient((request) async {
        if (request.url.path == '/v1/venues/spot-ok') {
          return http.Response(
            jsonEncode({'venue': _venueJson('spot-ok', name: 'Union Hall')}),
            200,
          );
        }
        return http.Response('not found', 404);
      });
      final repository = ApiVenueRepository(
        VenueApi(client: client, baseUri: Uri.parse('https://example.test')),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(preferences),
            venueRepositoryProvider.overrideWithValue(repository),
          ],
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: SavedScreen(onBrowse: () {}),
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
      final container = ProviderScope.containerOf(
        tester.element(find.byType(SavedScreen)),
      );
      expect(
        container.read(savedVenueIdsProvider).contains('spot-missing'),
        isFalse,
      );
    },
  );
}
