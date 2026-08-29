import 'dart:io';

import 'package:brewdesk/data/services/takeout_import_service.dart';
import 'package:brewdesk/domain/models/venue.dart';
import 'package:flutter_test/flutter_test.dart';

Venue _venue({
  required String id,
  required String name,
  required double lat,
  required double lng,
}) => Venue.fromJson({
  'id': id,
  'name': name,
  'lat': lat,
  'lng': lng,
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
});

void main() {
  group('TakeoutParser', () {
    test('parses the GeoJSON FeatureCollection shape', () async {
      final content = await File('test/fixtures/takeout_saved_places.geojson')
          .readAsString();

      final places = TakeoutParser.parse(content);

      expect(places, hasLength(2));
      expect(places[0].name, 'Union Square Coffee');
      expect(places[0].lat, closeTo(40.7300, 0.0001));
      expect(places[0].lng, closeTo(-73.9900, 0.0001));
      expect(places[1].name, 'Some Random Bakery Far Away');
    });

    test(
      'parses the CSV Title,Note,URL shape, pulling coords from the Maps URL',
      () async {
        final content = await File('test/fixtures/takeout_saved_places.csv')
            .readAsString();

        final places = TakeoutParser.parse(content);

        expect(places, hasLength(2));
        expect(places[0].name, 'Union Square Coffee');
        expect(places[0].lat, closeTo(40.7300, 0.0001));
        expect(places[0].lng, closeTo(-73.9900, 0.0001));
        expect(places[1].name, 'Faraway Diner');
        expect(places[1].lat, closeTo(40.5000, 0.0001));
      },
    );

    test('throws on an unrecognized format', () {
      expect(
        () => TakeoutParser.parse('not json, not a title-header csv'),
        throwsA(isA<TakeoutImportException>()),
      );
    });
  });

  group('TakeoutMatcher', () {
    final venue = _venue(
      id: 'spot-usq',
      name: 'Union Square Coffee',
      lat: 40.7300,
      lng: -73.9900,
    );

    test('matches a known fixture pair by name and by distance', () {
      // Exact name match, coords aside.
      expect(
        TakeoutMatcher.matches(
          const TakeoutPlace(name: 'Union Square Coffee'),
          venue,
        ),
        isTrue,
      );

      // Coordinates within the threshold, different-cased name.
      expect(
        TakeoutMatcher.matches(
          const TakeoutPlace(
            name: 'union square coffee',
            lat: 40.7301,
            lng: -73.9899,
          ),
          venue,
        ),
        isTrue,
      );
    });

    test('rejects a place that is both far away and name-dissimilar', () {
      expect(
        TakeoutMatcher.matches(
          const TakeoutPlace(
            name: 'Some Random Bakery Far Away',
            lat: 40.5000,
            lng: -73.5000,
          ),
          venue,
        ),
        isFalse,
      );
    });

    test('matches on distance alone when the name differs entirely', () {
      expect(
        TakeoutMatcher.matches(
          const TakeoutPlace(
            name: 'Totally Different Name',
            lat: 40.7300,
            lng: -73.9900001,
          ),
          venue,
        ),
        isTrue, // within the radius, so distance carries the match.
      );
    });

    test('rejects a place within the radius but with no name overlap once far enough', () {
      // ~200m away (outside the 150m radius) and no name overlap.
      expect(
        TakeoutMatcher.matches(
          const TakeoutPlace(
            name: 'Totally Different Name',
            lat: 40.7318,
            lng: -73.9900,
          ),
          venue,
        ),
        isFalse,
      );
    });

    test('match() dedupes a venue matched by more than one place and separates unmatched', () {
      final places = [
        const TakeoutPlace(
          name: 'Union Square Coffee',
          lat: 40.7300,
          lng: -73.9900,
        ),
        const TakeoutPlace(name: 'union square coffee'),
        const TakeoutPlace(
          name: 'Some Random Bakery Far Away',
          lat: 40.5000,
          lng: -73.5000,
        ),
      ];

      final result = TakeoutMatcher.match(places, [venue]);

      expect(result.matched, hasLength(1));
      expect(result.matched.single.id, 'spot-usq');
      expect(result.unmatched, hasLength(1));
      expect(result.unmatched.single.name, 'Some Random Bakery Far Away');
    });
  });
}
