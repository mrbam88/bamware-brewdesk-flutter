// The brewdesk#77 inclusive filter rule, tested as pure Dart. These cases
// used to run through a loaded DiscoveryViewModel over a fake HTTP client;
// with the predicate extracted to the domain (DiscoveryFilters.apply) they
// need no repository, no async, no widgets — the payoff of pulling logic
// out of stateful objects. The controller test at the bottom covers the
// Notifier wrapper with a ProviderContainer.

import 'package:brewdesk/features/discovery/application/discovery_filters_controller.dart';
import 'package:brewdesk/features/discovery/domain/discovery_filters.dart';
import 'package:brewdesk/features/venues/data/venue_dtos.dart';
import 'package:brewdesk/features/venues/domain/venue.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

Venue _venue({
  required String id,
  required String venueType,
  String wifi = 'unknown',
  String outlets = 'unknown',
  String laptopPolicy = 'unknown',
}) {
  return VenueDto.decode({
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
  });
}

Set<String> _ids(DiscoveryFilters filters, List<Venue> venues) =>
    filters.apply(venues).map((v) => v.id).toSet();

void main() {
  group('DiscoveryFilters.apply (brewdesk#77 inclusive rule)', () {
    test('unknown attribute values pass every active filter', () {
      final venues = [_venue(id: 'unknown-spot', venueType: 'cafe')];
      const filters = DiscoveryFilters(
        laptopFriendly: true,
        minWifi: WifiLevel.fast,
        minOutlets: OutletsLevel.plenty,
      );

      expect(_ids(filters, venues), contains('unknown-spot'));
    });

    test('wifi tri-state filters by minimum floor', () {
      final venues = [
        _venue(id: 'slow', venueType: 'cafe', wifi: 'slow'),
        _venue(id: 'ok', venueType: 'cafe', wifi: 'ok'),
        _venue(id: 'fast', venueType: 'cafe', wifi: 'fast'),
      ];

      expect(
        const DiscoveryFilters().apply(venues).length,
        3,
        reason: 'Any admits everything',
      );
      expect(_ids(const DiscoveryFilters(minWifi: WifiLevel.ok), venues), {
        'ok',
        'fast',
      });
      expect(_ids(const DiscoveryFilters(minWifi: WifiLevel.fast), venues), {
        'fast',
      });
    });

    test('outlets tri-state filters by minimum floor', () {
      final venues = [
        _venue(id: 'scarce', venueType: 'cafe', outlets: 'scarce'),
        _venue(id: 'some', venueType: 'cafe', outlets: 'some'),
        _venue(id: 'plenty', venueType: 'cafe', outlets: 'plenty'),
      ];

      expect(
        _ids(const DiscoveryFilters(minOutlets: OutletsLevel.some), venues),
        {'some', 'plenty'},
      );
      expect(
        _ids(const DiscoveryFilters(minOutlets: OutletsLevel.plenty), venues),
        {'plenty'},
      );
    });

    test('venue type filters to an exact match', () {
      final venues = [
        _venue(id: 'the-cafe', venueType: 'cafe'),
        _venue(id: 'the-library', venueType: 'library'),
        _venue(id: 'the-park', venueType: 'park'),
      ];

      expect(
        _ids(const DiscoveryFilters(venueType: WorkVenueType.library), venues),
        {'the-library'},
      );
    });

    test('laptop friendly excludes only known-discouraged venues', () {
      final venues = [
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
      ];

      expect(_ids(const DiscoveryFilters(laptopFriendly: true), venues), {
        'unrestricted',
        'unknown-policy',
      });
    });

    test('query matches name, neighborhood, and vibe tags', () {
      final venues = [
        _venue(id: 'Blue Bottle', venueType: 'cafe'),
        _venue(id: 'Reading Room', venueType: 'library'),
      ];

      expect(_ids(const DiscoveryFilters(query: 'blue'), venues), {
        'Blue Bottle',
      });
      expect(_ids(const DiscoveryFilters(query: 'soho'), venues), {
        'Blue Bottle',
        'Reading Room',
      });
    });
  });

  group('DiscoveryFiltersController', () {
    test('resetFilters clears every dimension but keeps the query', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(
        discoveryFiltersControllerProvider.notifier,
      );

      notifier.setQuery('espresso');
      notifier.setLaptopFriendly(true);
      notifier.setMinWifi(WifiLevel.fast);
      notifier.setMinOutlets(OutletsLevel.plenty);
      notifier.setVenueType(WorkVenueType.cafe);
      expect(container.read(discoveryFiltersControllerProvider).activeCount, 4);

      notifier.resetFilters();

      final filters = container.read(discoveryFiltersControllerProvider);
      expect(filters.activeCount, 0);
      expect(filters.laptopFriendly, isFalse);
      expect(filters.minWifi, isNull);
      expect(filters.minOutlets, isNull);
      expect(filters.venueType, isNull);
      expect(filters.query, 'espresso');
    });
  });
}
