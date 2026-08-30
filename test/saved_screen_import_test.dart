import 'dart:convert';
import 'dart:io';

import 'package:brewdesk/core/di/app_providers.dart';
import 'package:brewdesk/features/saved/application/saved_venue_ids.dart';
import 'package:brewdesk/features/venues/data/venue_repository.dart';
import 'package:brewdesk/features/venues/data/venue_api.dart';
import 'package:brewdesk/features/venues/data/venue_dtos.dart';
import 'package:brewdesk/l10n/app_localizations.dart';
import 'package:brewdesk/features/saved/presentation/saved_screen.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _venueJson = {
  'id': 'spot-usq',
  'name': 'Union Square Coffee',
  'lat': 40.7300,
  'lng': -73.9900,
  'neighborhood': 'Union Square',
  'borough': 'Manhattan',
  'venueType': 'cafe',
  'attributes': {
    'wifi': {'value': 'fast', 'source': 'curated'},
    'outlets': {'value': 'plenty', 'source': 'curated'},
    'laptopPolicy': {'value': 'unrestricted', 'source': 'curated'},
    'noise': {'value': 'moderate', 'source': 'curated'},
  },
  'vibeTags': <String>[],
  'workScore': 80,
  'tier': 'researched',
};

void main() {
  testWidgets(
    'importing a bundled Takeout fixture ends with the matched venue saved, '
    'with no network calls in the import path',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      final preferences = await SharedPreferences.getInstance();

      final requestLog = <String>[];
      final client = MockClient((request) async {
        requestLog.add(request.url.path);
        // Only the post-save detail fetch is allowed to hit this fake API —
        // never the import/match path itself.
        if (request.url.path == '/v1/venues/spot-usq') {
          return http.Response(jsonEncode({'venue': _venueJson}), 200);
        }
        fail('Unexpected network call during import: ${request.url}');
      });
      final venueRepository = ApiVenueRepository(
        VenueApi(client: client, baseUri: Uri.parse('https://example.test')),
      );

      // Synchronous read: real async I/O never completes inside
      // testWidgets' FakeAsync zone — the await would hang the suite.
      final fixtureBytes = File('test/fixtures/takeout_saved_places.csv')
          .readAsBytesSync();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(preferences),
            venueRepositoryProvider.overrideWithValue(venueRepository),
          ],
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: SavedScreen(
              onBrowse: () {},
              // Matching runs against this fixed catalog, not a live fetch —
              // proves the import path itself never touches the network.
              importVenuesLoader: () async => [VenueDto.decode(_venueJson)],
              importPickFile: () async => XFile.fromData(
                fixtureBytes,
                name: 'takeout_saved_places.csv',
                mimeType: 'text/csv',
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('import-takeout')));
      await tester.pumpAndSettle();

      // Import + match happened with zero network calls.
      expect(requestLog, isEmpty);

      expect(find.text('1 matched · 1 not in BrewDesk yet'), findsOneWidget);

      await tester.tap(find.byKey(const Key('import-confirm')));
      await tester.pumpAndSettle();

      final container = ProviderScope.containerOf(
        tester.element(find.byType(SavedScreen)),
      );
      expect(container.read(savedVenueIdsProvider).contains('spot-usq'), isTrue);
      expect(find.text('Union Square Coffee'), findsWidgets);
    },
  );

  testWidgets('cancelling the result sheet does not save anything', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final client = MockClient((request) async {
      fail('Unexpected network call: ${request.url}');
    });
    final venueRepository = ApiVenueRepository(
      VenueApi(client: client, baseUri: Uri.parse('https://example.test')),
    );

    // Synchronous read — see the note in the first test.
    final fixtureBytes = File('test/fixtures/takeout_saved_places.csv')
        .readAsBytesSync();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(preferences),
          venueRepositoryProvider.overrideWithValue(venueRepository),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: SavedScreen(
            onBrowse: () {},
            importVenuesLoader: () async => [VenueDto.decode(_venueJson)],
            importPickFile: () async => XFile.fromData(
              fixtureBytes,
              name: 'takeout_saved_places.csv',
              mimeType: 'text/csv',
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('import-takeout')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('import-cancel')));
    await tester.pumpAndSettle();

    final container = ProviderScope.containerOf(
      tester.element(find.byType(SavedScreen)),
    );
    expect(container.read(savedVenueIdsProvider).contains('spot-usq'), isFalse);
  });
}
