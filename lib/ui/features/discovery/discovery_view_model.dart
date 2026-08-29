import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';

import '../../../data/repositories/venue_repository.dart';
import '../../../data/services/location_service.dart';
import '../../../domain/models/venue.dart';

/// Wi-Fi floor for the tri-state Wi-Fi filter. `ok` and `fast` mirror the
/// engine's `WIFI_ORDER` tiers; "Any" is represented by a null selection.
enum WifiLevel { ok, fast }

/// Outlets floor for the tri-state Outlets filter. Mirrors the engine's
/// `OUTLET_ORDER` tiers; "Any" is represented by a null selection.
enum OutletsLevel { some, plenty }

enum WorkVenueType { cafe, library, park }

/// Client-side filter predicate for the discovery list (brewdesk#77 parity
/// with iOS `VenueFilter`): a value outside the known vocabulary — most
/// commonly "unknown" — is never evidence against a venue, so only claims
/// that are known AND known to sit below the chosen floor get excluded.
const Map<String, int> _wifiTiers = {'slow': 1, 'ok': 2, 'fast': 3};
const Map<String, int> _amountTiers = {'scarce': 1, 'some': 2, 'plenty': 3};

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

  bool _laptopFriendly = false;
  WifiLevel? _minWifi;
  OutletsLevel? _minOutlets;
  WorkVenueType? _venueType;

  bool get loading => _loading;
  String? get error => _error;
  String get query => _query;
  CoverageLevel get coverage => _coverage;
  LatLng get center => _center;
  int get totalVenues => _venues.length;

  bool get laptopFriendly => _laptopFriendly;
  WifiLevel? get minWifi => _minWifi;
  OutletsLevel? get minOutlets => _minOutlets;
  WorkVenueType? get venueType => _venueType;

  /// Active count across the four dimensions this menu owns — drives both
  /// the filter button's badge and the "Reset N filters" row.
  int get activeFilterCount => [
    _laptopFriendly,
    _minWifi != null,
    _minOutlets != null,
    _venueType != null,
  ].where((active) => active).length;

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
          if (_laptopFriendly &&
              const {
                'discouraged',
                'weekends_banned',
              }.contains(venue.attributes.laptopPolicy.value)) {
            return false;
          }
          if (_minWifi != null) {
            final tier = _wifiTiers[venue.attributes.wifi.value];
            if (tier != null && tier < _wifiTiers[_minWifi!.name]!) {
              return false;
            }
          }
          if (_minOutlets != null) {
            final tier = _amountTiers[venue.attributes.outlets.value];
            if (tier != null && tier < _amountTiers[_minOutlets!.name]!) {
              return false;
            }
          }
          if (_venueType != null && venue.venueType != _venueType!.name) {
            return false;
          }
          return true;
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

  void setLaptopFriendly(bool value) {
    _laptopFriendly = value;
    notifyListeners();
  }

  void setMinWifi(WifiLevel? value) {
    _minWifi = value;
    notifyListeners();
  }

  void setMinOutlets(OutletsLevel? value) {
    _minOutlets = value;
    notifyListeners();
  }

  void setVenueType(WorkVenueType? value) {
    _venueType = value;
    notifyListeners();
  }

  void resetFilters() {
    _laptopFriendly = false;
    _minWifi = null;
    _minOutlets = null;
    _venueType = null;
    notifyListeners();
  }
}
