import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';

import 'package:brewdesk/features/venues/data/venue_repository.dart';
import 'package:brewdesk/core/networking/connectivity_service.dart';
import 'package:brewdesk/core/location/location_service.dart';
import 'package:brewdesk/features/venues/data/venue_api.dart';
import 'package:brewdesk/features/venues/domain/venue.dart';

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

/// Which intentional degraded card [DiscoveryViewModel.error] describes
/// (brewdesk#11) — "the engine is down" reads and recovers differently from
/// "you're offline".
enum DiscoveryErrorKind { engine, offline }

class DiscoveryViewModel extends ChangeNotifier {
  DiscoveryViewModel(
    this._repository,
    this._locationService, {
    this._connectivity = const ConnectivityService(),
  });

  static const manhattan = LatLng(40.7411, -73.9897);
  final VenueRepository _repository;
  final LocationService _locationService;
  final ConnectivityService _connectivity;
  StreamSubscription<bool>? _connectivitySub;

  List<Venue> _venues = const [];
  bool _loading = false;
  String? _error;
  DiscoveryErrorKind? _errorKind;
  String _query = '';
  CoverageLevel _coverage = CoverageLevel.researched;
  LatLng _center = manhattan;

  bool _laptopFriendly = false;
  WifiLevel? _minWifi;
  OutletsLevel? _minOutlets;
  WorkVenueType? _venueType;

  bool get loading => _loading;
  String? get error => _error;
  DiscoveryErrorKind? get errorKind => _errorKind;
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
    _errorKind = null;
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
      _stopWatchingForReconnect();
    } on VenueOfflineException {
      _errorKind = DiscoveryErrorKind.offline;
      // No literal message here: the offline fallback copy is localized by
      // the widget from [errorKind]. See DiscoveryScreen._searchAndFilters.
      _error = null;
      _watchForReconnect();
    } on Object catch (error) {
      _errorKind = DiscoveryErrorKind.engine;
      // A VenueApiException message names the engine and comes straight
      // from the server, so it is shown as-is; a generic failure falls
      // back to the widget's localized copy (null here).
      _error = error is VenueApiException ? error.message : null;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// Subscribes to connectivity once, only after an offline failure — most
  /// loads succeed and should never touch the platform channel. Retries the
  /// same search automatically the moment the device comes back online, no
  /// user action required (brewdesk#11).
  void _watchForReconnect() {
    _connectivitySub ??= _connectivity.onlineChanges
        .where((online) => online)
        .listen((_) => load(useDeviceLocation: false));
  }

  void _stopWatchingForReconnect() {
    _connectivitySub?.cancel();
    _connectivitySub = null;
  }

  @override
  void dispose() {
    _stopWatchingForReconnect();
    super.dispose();
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
