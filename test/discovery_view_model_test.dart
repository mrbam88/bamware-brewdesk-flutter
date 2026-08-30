import 'dart:convert';

import 'package:brewdesk/features/venues/data/venue_repository.dart';
import 'package:brewdesk/core/location/location_service.dart';
import 'package:brewdesk/features/venues/data/venue_api.dart';
import 'package:brewdesk/features/discovery/application/discovery_view_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

Map<String, Object?> _venue({
  required String id,
  required String venueType,
  String wifi = 'unknown',
  String outlets = 'unknown',
  String laptopPolicy = 'unknown',
}) {
  return {
    'id': id,
    'name': id,
    'lat': 40.7,
    'lng': -74.0,
    'neighborhood': 'SoHo',
    'borough': 'Manhattan',
    'venueType': venueType,
    'attributes': {
      'wifi': {'value': wifi, 'source': 'osm'},
      'outlets': {'value': outlets, 'source': 'osm'},
      'laptopPolicy': {'value': laptopPolicy, 'source': 'osm'},
      'noise': {'value': 'unknown', 'source': 'osm'},
    },
    'vibeTags': <String>[],
    'workScore': 60,
    'tier': 'researched',
  };
}

/// Builds a [DiscoveryViewModel] already loaded with [venues], routed
/// through a fake HTTP client the same way `venue_repository_test.dart`
/// does. `useDeviceLocation: false` keeps location plumbing (and its
/// platform channels) out of the test entirely.
Future<DiscoveryViewModel> _modelWithVenues(
  List<Map<String, Object?>> venues,
) async {
  final client = MockClient(
    (request) async =>
        http.Response(jsonEncode({'meta': {}, 'venues': venues}), 200),
  );
  final repository = ApiVenueRepository(
    VenueApi(client: client, baseUri: Uri.parse('https://example.test')),
  );
  final model = DiscoveryViewModel(repository, const LocationService());
  await model.load(useDeviceLocation: false);
  return model;
}

void main() {
  group('DiscoveryViewModel filtering (brewdesk#77 inclusive rule)', () {
    test('unknown attribute values pass every active filter', () async {
      final model = await _modelWithVenues([
        _venue(id: 'unknown-spot', venueType: 'cafe'),
      ]);

      model.setLaptopFriendly(true);
      model.setMinWifi(WifiLevel.fast);
      model.setMinOutlets(OutletsLevel.plenty);

      expect(model.visibleVenues.map((v) => v.id), contains('unknown-spot'));
    });

    test('wifi tri-state filters by minimum floor', () async {
      final model = await _modelWithVenues([
        _venue(id: 'slow', venueType: 'cafe', wifi: 'slow'),
        _venue(id: 'ok', venueType: 'cafe', wifi: 'ok'),
        _venue(id: 'fast', venueType: 'cafe', wifi: 'fast'),
      ]);

      expect(model.visibleVenues.length, 3, reason: 'Any admits everything');

      model.setMinWifi(WifiLevel.ok);
      expect(model.visibleVenues.map((v) => v.id).toSet(), {'ok', 'fast'});

      model.setMinWifi(WifiLevel.fast);
      expect(model.visibleVenues.map((v) => v.id).toSet(), {'fast'});
    });

    test('outlets tri-state filters by minimum floor', () async {
      final model = await _modelWithVenues([
        _venue(id: 'scarce', venueType: 'cafe', outlets: 'scarce'),
        _venue(id: 'some', venueType: 'cafe', outlets: 'some'),
        _venue(id: 'plenty', venueType: 'cafe', outlets: 'plenty'),
      ]);

      model.setMinOutlets(OutletsLevel.some);
      expect(model.visibleVenues.map((v) => v.id).toSet(), {'some', 'plenty'});

      model.setMinOutlets(OutletsLevel.plenty);
      expect(model.visibleVenues.map((v) => v.id).toSet(), {'plenty'});
    });

    test('venue type filters to an exact match', () async {
      final model = await _modelWithVenues([
        _venue(id: 'the-cafe', venueType: 'cafe'),
        _venue(id: 'the-library', venueType: 'library'),
        _venue(id: 'the-park', venueType: 'park'),
      ]);

      model.setVenueType(WorkVenueType.library);

      expect(model.visibleVenues.map((v) => v.id).toSet(), {'the-library'});
    });

    test('laptop friendly excludes only known-discouraged venues', () async {
      final model = await _modelWithVenues([
        _venue(
          id: 'discouraged',
          venueType: 'cafe',
          laptopPolicy: 'discouraged',
        ),
        _venue(
          id: 'unrestricted',
          venueType: 'cafe',
          laptopPolicy: 'unrestricted',
        ),
        _venue(id: 'unknown-policy', venueType: 'cafe'),
      ]);

      model.setLaptopFriendly(true);

      expect(model.visibleVenues.map((v) => v.id).toSet(), {
        'unrestricted',
        'unknown-policy',
      });
    });

    test('resetFilters clears every dimension and the active count', () async {
      final model = await _modelWithVenues([
        _venue(
          id: 'slow-scarce',
          venueType: 'park',
          wifi: 'slow',
          outlets: 'scarce',
        ),
      ]);

      model.setLaptopFriendly(true);
      model.setMinWifi(WifiLevel.fast);
      model.setMinOutlets(OutletsLevel.plenty);
      model.setVenueType(WorkVenueType.cafe);
      expect(model.activeFilterCount, 4);
      expect(model.visibleVenues, isEmpty);

      model.resetFilters();

      expect(model.activeFilterCount, 0);
      expect(model.laptopFriendly, isFalse);
      expect(model.minWifi, isNull);
      expect(model.minOutlets, isNull);
      expect(model.venueType, isNull);
      expect(model.visibleVenues.map((v) => v.id), contains('slow-scarce'));
    });
  });
}
