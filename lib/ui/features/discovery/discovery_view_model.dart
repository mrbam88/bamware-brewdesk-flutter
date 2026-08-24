import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';

import '../../../data/repositories/venue_repository.dart';
import '../../../data/services/location_service.dart';
import '../../../domain/models/venue.dart';

enum DiscoveryFilter { laptopFriendly, fastWifi, outlets, cafe, library, park }

class DiscoveryViewModel extends ChangeNotifier {
  DiscoveryViewModel(this._repository, this._locationService);

  static const manhattan = LatLng(40.7411, -73.9897);
  final VenueRepository _repository;
  final LocationService _locationService;

  List<Venue> _venues = const [];
  bool _loading = false;
  String? _error;
  String _query = '';
  CoverageLevel _coverage = CoverageLevel.researched;
  LatLng _center = manhattan;
  final Set<DiscoveryFilter> _filters = {};

  bool get loading => _loading;
  String? get error => _error;
  String get query => _query;
  CoverageLevel get coverage => _coverage;
  LatLng get center => _center;
  Set<DiscoveryFilter> get filters => Set.unmodifiable(_filters);

  List<Venue> get visibleVenues {
    final needle = _query.trim().toLowerCase();
    return _venues
        .where((venue) {
          if (needle.isNotEmpty &&
              !venue.name.toLowerCase().contains(needle) &&
              !venue.neighborhood.toLowerCase().contains(needle) &&
              !venue.vibeTags.any(
                (tag) => tag.toLowerCase().contains(needle),
              )) {
            return false;
          }
          if (_filters.contains(DiscoveryFilter.laptopFriendly) &&
              const {
                'discouraged',
                'weekends_banned',
              }.contains(venue.attributes.laptopPolicy.value)) {
            return false;
          }
          if (_filters.contains(DiscoveryFilter.fastWifi) &&
              const {'slow', 'ok'}.contains(venue.attributes.wifi.value)) {
            return false;
          }
          if (_filters.contains(DiscoveryFilter.outlets) &&
              venue.attributes.outlets.value == 'scarce') {
            return false;
          }
          final typeFilters = <String>{
            if (_filters.contains(DiscoveryFilter.cafe)) 'cafe',
            if (_filters.contains(DiscoveryFilter.library)) 'library',
            if (_filters.contains(DiscoveryFilter.park)) 'park',
          };
          return typeFilters.isEmpty || typeFilters.contains(venue.venueType);
        })
        .toList(growable: false);
  }

  Future<void> load({bool useDeviceLocation = true}) async {
    _loading = true;
    _error = null;
    notifyListeners();

    if (useDeviceLocation) {
      _center = await _locationService.currentLocation() ?? manhattan;
    }
    try {
      final result = await _repository.search(
        lat: _center.latitude,
        lng: _center.longitude,
      );
      _venues = result.venues;
      _coverage = result.coverage;
    } on Object {
      _error = 'We could not reach the spot service. Check your connection and try again.';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  void setQuery(String value) {
    _query = value;
    notifyListeners();
  }

  void toggleFilter(DiscoveryFilter filter) {
    if (!_filters.add(filter)) _filters.remove(filter);
    notifyListeners();
  }
}
