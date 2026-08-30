import 'package:brewdesk/core/di/app_providers.dart';
import 'package:brewdesk/features/venues/data/venue_repository.dart';
import 'package:brewdesk/features/venues/data/venue_api.dart';
import 'package:brewdesk/features/venues/data/venue_dtos.dart';
import 'package:brewdesk/features/venues/domain/venue.dart';
import 'package:brewdesk/l10n/app_localizations.dart';
import 'package:brewdesk/features/venue_detail/presentation/venue_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

Venue _venue({
  Map<String, dynamic>? wifi,
  Map<String, dynamic>? outlets,
  Map<String, dynamic>? laptopPolicy,
  Map<String, dynamic>? noise,
  Map<String, dynamic>? seating,
  String? website,
}) {
  return VenueDto.decode({
    'id': 'spot-1',
    'name': 'Blue Bottle SoHo',
    'lat': 40.7,
    'lng': -74.0,
    'neighborhood': 'SoHo',
    'borough': 'Manhattan',
    'venueType': 'cafe',
    'attributes': {
      'wifi':
          wifi ??
          {
            'value': 'fast',
            'source': 'curated',
            'confidence': 0.8,
            'observedAt': '2026-08-01',
          },
      'outlets':
          outlets ??
          {
            'value': 'plenty',
            'source': 'curated',
            'confidence': 0.8,
            'observedAt': '2026-08-01',
          },
      'laptopPolicy':
          laptopPolicy ??
          {
            'value': 'unrestricted',
            'source': 'curated',
            'confidence': 0.8,
            'observedAt': '2026-08-01',
          },
      'noise':
          noise ??
          {
            'value': 'moderate',
            'source': 'curated',
            'confidence': 0.8,
            'observedAt': '2026-08-01',
          },
      'seating': ?seating,
    },
    'vibeTags': const <String>[],
    'workScore': 82,
    'tier': 'researched',
    'website': ?website,
  });
}

Future<Widget> _harness(
  Venue venue, {
  Future<void> Function(String)? share,
}) async {
  SharedPreferences.setMockInitialValues({});
  final preferences = await SharedPreferences.getInstance();
  final client = MockClient((request) async {
    return http.Response('{"venue": ${_encode(venue)}}', 200);
  });
  return ProviderScope(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(preferences),
      venueRepositoryProvider.overrideWithValue(
        ApiVenueRepository(
          VenueApi(client: client, baseUri: Uri.parse('https://example.test')),
        ),
      ),
    ],
    child: MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: VenueDetailScreen(initialVenue: venue, shareVenue: share),
    ),
  );
}

// Minimal re-encoder: the fetched venue doesn't need to differ from the
// initial one for these tests, and repository.load()'s photos call fails
// harmlessly (see VenueDetailViewModel.load's catch-all).
String _encode(Venue venue) =>
    '''
{
  "id": "${venue.id}",
  "name": "${venue.name}",
  "lat": ${venue.lat},
  "lng": ${venue.lng},
  "neighborhood": "${venue.neighborhood}",
  "borough": "${venue.borough}",
  "venueType": "${venue.venueType}",
  "attributes": {
    "wifi": {"value": "${venue.attributes.wifi.value}", "source": "${venue.attributes.wifi.source}", "confidence": ${venue.attributes.wifi.confidence}, "observedAt": "${venue.attributes.wifi.observedAt}"},
    "outlets": {"value": "${venue.attributes.outlets.value}", "source": "${venue.attributes.outlets.source}", "confidence": ${venue.attributes.outlets.confidence}, "observedAt": "${venue.attributes.outlets.observedAt}"},
    "laptopPolicy": {"value": "${venue.attributes.laptopPolicy.value}", "source": "${venue.attributes.laptopPolicy.source}", "confidence": ${venue.attributes.laptopPolicy.confidence}, "observedAt": "${venue.attributes.laptopPolicy.observedAt}"},
    "noise": {"value": "${venue.attributes.noise.value}", "source": "${venue.attributes.noise.source}", "confidence": ${venue.attributes.noise.confidence}, "observedAt": "${venue.attributes.noise.observedAt}"},
    "seating": {"value": "${venue.attributes.seating.value}", "source": "${venue.attributes.seating.source}", "confidence": ${venue.attributes.seating.confidence}, "observedAt": "${venue.attributes.seating.observedAt}"}
  },
  "vibeTags": [],
  "workScore": ${venue.workScore},
  "tier": "${venue.tier}",
  "website": ${venue.website == null ? 'null' : '"${venue.website}"'}
}
''';

void main() {
  testWidgets('title equals the venue name', (tester) async {
    final venue = _venue();
    await tester.pumpWidget(await _harness(venue));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(AppBar, 'Blue Bottle SoHo'), findsOneWidget);
  });

  testWidgets(
    'claim rows render the card-level stamp; an agreeing claim shows no row line',
    (tester) async {
      // Every claim shares the same source/confidence/date, so all four
      // agree with the card-level stamp — no per-row line anywhere.
      final venue = _venue();
      await tester.pumpWidget(await _harness(venue));
      await tester.pumpAndSettle();

      expect(
        // brewdesk#28: dates humanize ("Aug 1" via intl DateFormat) instead
        // of showing the raw ISO date.
        find.text('Curated · 80% confidence · updated Aug 1'),
        findsOneWidget, // the card-level stamp only
      );
      expect(find.byKey(const Key('claim-provenance-line')), findsNothing);
    },
  );

  testWidgets('a disagreeing claim shows its own provenance line', (
    tester,
  ) async {
    final venue = _venue(
      noise: {
        'value': 'quiet',
        'source': 'estimate',
        'confidence': 0.3,
        'observedAt': '2026-07-01',
      },
    );
    await tester.pumpWidget(await _harness(venue));
    await tester.pumpAndSettle();

    // Card stamp is still the 3-way agreement (curated · 80% · Aug 1), date
    // humanized (brewdesk#28).
    expect(
      find.text('Curated · 80% confidence · updated Aug 1'),
      findsOneWidget,
    );
    // Only the disagreeing (noise) row prints its own line.
    expect(find.byKey(const Key('claim-provenance-line')), findsOneWidget);
    expect(
      find.text('Unverified estimate · 30% confidence · updated Jul 1'),
      findsOneWidget,
    );
  });

  testWidgets('seating row is absent when the claim is unknown', (
    tester,
  ) async {
    final withoutSeating = _venue();
    await tester.pumpWidget(await _harness(withoutSeating));
    await tester.pumpAndSettle();
    expect(find.text('Seating'), findsNothing);
  });

  testWidgets('seating row renders when the claim is present', (tester) async {
    final withSeating = _venue(
      seating: {
        'value': 'plenty',
        'source': 'curated',
        'confidence': 0.8,
        'observedAt': '2026-08-01',
      },
    );
    await tester.pumpWidget(await _harness(withSeating));
    await tester.pumpAndSettle();
    expect(find.text('Seating'), findsOneWidget);
  });

  testWidgets('minimal venue renders with optional fields absent', (
    tester,
  ) async {
    final venue = VenueDto.decode({
      'id': 'spot-min',
      'name': 'Minimal Spot',
      'lat': 40.7,
      'lng': -74.0,
      'neighborhood': 'SoHo',
      'borough': 'Manhattan',
      'venueType': 'cafe',
      'attributes': {
        'wifi': {'value': 'unknown', 'source': 'osm'},
        'outlets': {'value': 'unknown', 'source': 'osm'},
        'laptopPolicy': {'value': 'unknown', 'source': 'osm'},
        'noise': {'value': 'unknown', 'source': 'osm'},
      },
      'vibeTags': const <String>[],
      'workScore': 40,
      'tier': 'osm-baseline',
    });
    await tester.pumpWidget(await _harness(venue));
    await tester.pumpAndSettle();

    expect(find.byType(VenueDetailScreen), findsOneWidget);
    // No address line, no vibe chips, no seating row, no website row.
    expect(find.text('Seating'), findsNothing);
    expect(find.byIcon(Icons.language_rounded), findsNothing);
  });

  testWidgets('Share launches with the venue name in the shared text', (
    tester,
  ) async {
    String? sharedText;
    final venue = _venue();
    await tester.pumpWidget(
      await _harness(
        venue,
        share: (text) async {
          sharedText = text;
        },
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Share'));
    await tester.pumpAndSettle();

    expect(sharedText, isNotNull);
    expect(sharedText, contains('Blue Bottle SoHo'));
    expect(sharedText, contains('maps'));
  });
}
