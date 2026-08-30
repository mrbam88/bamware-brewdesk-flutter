import 'dart:async';

import 'package:brewdesk/features/venues/data/venue_repository.dart';
import 'package:brewdesk/features/venues/domain/venue_repository.dart';
import 'package:brewdesk/features/venues/data/venue_api.dart';
import 'package:brewdesk/features/venues/data/venue_dtos.dart';
import 'package:brewdesk/features/venues/domain/venue.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

const _liveVenueJson = '''
  {
    "count": 1,
    "meta": {"coverage": "researched"},
    "venues": [{
      "id": "spot-live",
      "name": "Live Spot",
      "lat": 40.71,
      "lng": -74.01,
      "neighborhood": "Downtown",
      "borough": "Manhattan",
      "venueType": "cafe",
      "attributes": {
        "wifi": {"value": "fast", "source": "curated"},
        "outlets": {"value": "plenty", "source": "curated"},
        "laptopPolicy": {"value": "unrestricted", "source": "curated"},
        "noise": {"value": "quiet", "source": "curated"}
      },
      "vibeTags": [],
      "workScore": 80,
      "tier": "researched"
    }]
  }
''';

Venue _snapshotVenue() => VenueDto.decode(const {
  'id': 'spot-snapshot',
  'name': 'Snapshot Spot',
  'lat': 40.73,
  'lng': -73.99,
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
  'workScore': 85,
  'tier': 'researched',
});

void main() {
  test('repository maps the privacy-safe search response', () async {
    final client = MockClient((request) async {
      expect(request.method, 'POST');
      expect(request.url.path, '/v1/venues/search');
      return http.Response('''
        {
          "count": 1,
          "meta": {"coverage": "baseline"},
          "venues": [{
            "id": "spot-1",
            "name": "Work Park",
            "lat": 40.7,
            "lng": -74.0,
            "neighborhood": "Downtown",
            "borough": "Manhattan",
            "venueType": "park",
            "attributes": {
              "wifi": {"value": "unknown", "source": "osm"},
              "outlets": {"value": "unknown", "source": "osm"},
              "laptopPolicy": {"value": "unknown", "source": "osm"},
              "noise": {"value": "unknown", "source": "osm"}
            },
            "vibeTags": [],
            "workScore": 55,
            "tier": "osm-baseline"
          }]
        }
      ''', 200);
    });
    final repository = ApiVenueRepository(
      VenueApi(client: client, baseUri: Uri.parse('https://example.test')),
    );

    final result = await repository.search(lat: 40.7, lng: -74.0);

    expect(result.coverage, CoverageLevel.baseline);
    expect(result.venues.single.name, 'Work Park');
    expect(result.venues.single.tier, 'osm-baseline');
  });

  group('coldStart', () {
    test('emits the bundled snapshot before the network completes, then swaps in live results', () async {
      final networkGate = Completer<void>();
      final client = MockClient((request) async {
        await networkGate.future;
        return http.Response(_liveVenueJson, 200);
      });
      final repository = ApiVenueRepository(
        VenueApi(client: client, baseUri: Uri.parse('https://example.test')),
        snapshotLoader: () async => [_snapshotVenue()],
      );

      final events = <ColdStartResult>[];
      final subscription = repository
          .coldStart(lat: 40.7, lng: -74.0)
          .listen(events.add);

      // Let the (synchronous, fake) snapshot loader resolve and its event
      // land, without letting the still-gated network call resolve.
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      expect(events, hasLength(1));
      expect(events.single.isBundledSnapshot, isTrue);
      expect(events.single.isBundledSnapshot, isTrue);
      expect(events.single.venues.single.name, 'Snapshot Spot');

      networkGate.complete();
      await subscription.asFuture<void>();

      expect(events, hasLength(2));
      expect(events.last.isBundledSnapshot, isFalse);
      expect(events.last.isBundledSnapshot, isFalse);
      expect(events.last.venues.single.name, 'Live Spot');
      expect(events.last.coverage, CoverageLevel.researched);
    });

    test('keeps the snapshot and note visible when the live call fails (engine down)', () async {
      final client = MockClient((request) async => http.Response('down', 503));
      final repository = ApiVenueRepository(
        VenueApi(client: client, baseUri: Uri.parse('https://example.test')),
        snapshotLoader: () async => [_snapshotVenue()],
      );

      final events = await repository.coldStart(lat: 40.7, lng: -74.0).toList();

      expect(events, hasLength(2));
      for (final event in events) {
        expect(event.isBundledSnapshot, isTrue);
        expect(event.isBundledSnapshot, isTrue);
        expect(event.venues.single.name, 'Snapshot Spot');
      }
    });

    test('does not re-emit the snapshot once the cache is warm', () async {
      final client = MockClient(
        (request) async => http.Response(_liveVenueJson, 200),
      );
      final repository = ApiVenueRepository(
        VenueApi(client: client, baseUri: Uri.parse('https://example.test')),
        snapshotLoader: () async => [_snapshotVenue()],
      );

      // Warm the cache with a normal search first.
      await repository.search(lat: 40.7, lng: -74.0);

      final events = await repository.coldStart(lat: 40.7, lng: -74.0).toList();

      expect(events, hasLength(1));
      expect(events.single.isBundledSnapshot, isFalse);
    });
  });
}
