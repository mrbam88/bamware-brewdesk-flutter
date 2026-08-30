// Widget tests for VenueCard (brewdesk#28 redesign): the house rule that
// unknown attribute values render nothing — never a placeholder like
// "wifi unknown" — applies to the shelf/search-results card's wifi/outlets
// caption row and its provenance line.

import 'package:brewdesk/domain/models/venue.dart';
import 'package:brewdesk/l10n/app_localizations.dart';
import 'package:brewdesk/ui/core/venue_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Venue _venue({Map<String, dynamic>? wifi, Map<String, dynamic>? outlets}) {
  return Venue.fromJson({
    'id': 'spot-1',
    'name': 'Blue Bottle SoHo',
    'lat': 40.7,
    'lng': -74.0,
    'neighborhood': 'SoHo',
    'borough': 'Manhattan',
    'venueType': 'cafe',
    'attributes': {
      'wifi': wifi ?? {'value': 'unknown', 'source': 'osm'},
      'outlets': outlets ?? {'value': 'unknown', 'source': 'osm'},
      'laptopPolicy': {'value': 'unknown', 'source': 'osm'},
      'noise': {'value': 'unknown', 'source': 'osm'},
    },
    'vibeTags': const <String>[],
    'workScore': 55,
    'tier': 'osm-baseline',
  });
}

Widget _harness(Venue venue) {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(
      body: VenueCard(venue: venue, saved: false, onTap: () {}, onSave: () {}),
    ),
  );
}

void main() {
  testWidgets('unknown wifi and outlets render no caption row at all', (
    tester,
  ) async {
    await tester.pumpWidget(_harness(_venue()));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.wifi_rounded), findsNothing);
    expect(find.byIcon(Icons.power_rounded), findsNothing);
  });

  testWidgets('a known wifi value renders its caption, outlets stays silent', (
    tester,
  ) async {
    final venue = _venue(wifi: {'value': 'fast', 'source': 'curated'});
    await tester.pumpWidget(_harness(venue));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.wifi_rounded), findsOneWidget);
    expect(find.text('Fast'), findsOneWidget);
    expect(find.byIcon(Icons.power_rounded), findsNothing);
  });

  testWidgets(
    'no observation date on the card stamp means no provenance line',
    (tester) async {
      // No claim carries an observedAt, so workabilityCardStamp.dateKey is
      // empty — the provenance line is optional data and must not appear.
      await tester.pumpWidget(_harness(_venue()));
      await tester.pumpAndSettle();

      expect(find.textContaining('Updated'), findsNothing);
    },
  );

  testWidgets('a known observation date renders the provenance line', (
    tester,
  ) async {
    // workabilityCardStamp picks the claim most other claims agree with,
    // ties broken toward wifi (see VenueAttributes.workabilityCardStamp) —
    // wifi and outlets sharing a claim beats laptopPolicy/noise's own tie.
    final venue = _venue(
      wifi: {
        'value': 'fast',
        'source': 'curated',
        'observedAt': '2026-08-01',
        'confidence': 0.8,
      },
      outlets: {
        'value': 'plenty',
        'source': 'curated',
        'observedAt': '2026-08-01',
        'confidence': 0.8,
      },
    );
    await tester.pumpWidget(_harness(venue));
    await tester.pumpAndSettle();

    expect(find.text('Updated Aug 1 · Curated'), findsOneWidget);
  });
}
