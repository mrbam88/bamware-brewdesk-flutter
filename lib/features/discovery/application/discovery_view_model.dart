import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';

import 'package:brewdesk/core/location/location_service.dart';
import 'package:brewdesk/core/networking/connectivity_service.dart';
import 'package:brewdesk/features/venues/data/venue_api.dart';
import 'package:brewdesk/features/venues/domain/venue.dart';
import 'package:brewdesk/features/venues/domain/venue_repository.dart';

/// Which intentional degraded card [DiscoveryViewModel.error] describes
/// (brewdesk#11) — "the engine is down" reads and recovers differently from
/// "you're offline".
enum DiscoveryErrorKind { engine, offline }

/// The last ChangeNotifier standing, and only until the flagship bloc
/// replaces it: it now owns ONLY the fetch funnel (location → search →
/// venues/degraded states → reconnect retry). Query + filters moved to
/// [DiscoveryFiltersController] — client state and server state no longer
/// share an object.
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
  CoverageLevel _coverage = CoverageLevel.researched;
  LatLng _center = manhattan;

  bool get loading => _loading;
  String? get error => _error;
  DiscoveryErrorKind? get errorKind => _errorKind;
  CoverageLevel get coverage => _coverage;
  LatLng get center => _center;
  List<Venue> get venues => _venues;
  int get totalVenues => _venues.length;

  Future<void> load({bool useDeviceLocation = true}) async {
    _loading = true;
    _error = null;
    _errorKind = null;
    notifyListeners();

    if (useDeviceLocation) {
      _center = switch (await _locationService.resolve()) {
        LocationAcquired(:final position) => position,
        // The bloc phase surfaces the reason; the interim VM keeps the old
        // Manhattan fallback behavior.
        LocationUnavailable() => manhattan,
      };
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
}
