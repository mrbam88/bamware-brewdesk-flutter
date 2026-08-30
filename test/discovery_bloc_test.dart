// The flagship funnel, asserted as EXACT state sequences with bloc_test.
// Because DiscoveryState is a freezed value type, `expect` compares whole
// states by value — no matchers poking at loose fields. And because the
// bloc depends on the VenueRepository INTERFACE, the fake here is ~20 lines
// of pure Dart: no HTTP client, no widgets, no pumping.

import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:brewdesk/core/location/location_service.dart';
import 'package:brewdesk/core/networking/connectivity_service.dart';
import 'package:brewdesk/features/discovery/application/discovery_bloc.dart';
import 'package:brewdesk/features/venues/data/venue_api.dart';
import 'package:brewdesk/features/venues/domain/venue.dart';
import 'package:brewdesk/features/venues/domain/venue_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';

const _soho = LatLng(40.723, -74.0);

Venue _venue(String id) => Venue(
  id: id,
  name: id,
  lat: 40.7,
  lng: -74.0,
  neighborhood: 'SoHo',
  borough: 'Manhattan',
  venueType: 'cafe',
  attributes: const VenueAttributes(),
  vibeTags: const [],
  workScore: 60,
  tier: 'researched',
);

class _FakeVenueRepository implements VenueRepository {
  _FakeVenueRepository(this._responses);

  /// Consumed one per search call; the last one repeats.
  final List<Future<VenueSearchResult> Function()> _responses;
  int searchCalls = 0;

  @override
  Future<VenueSearchResult> search({
    required double lat,
    required double lng,
  }) {
    final index = searchCalls < _responses.length
        ? searchCalls
        : _responses.length - 1;
    searchCalls++;
    return _responses[index]();
  }

  @override
  Stream<ColdStartResult> coldStart({
    required double lat,
    required double lng,
  }) => throw UnimplementedError();

  @override
  Future<Venue> venue(String id, {bool refresh = false}) =>
      throw UnimplementedError();

  @override
  Future<List<VenuePhoto>> photos(String id) => throw UnimplementedError();
}

class _AcquiredLocationService extends LocationService {
  const _AcquiredLocationService();

  @override
  Future<LocationResult> resolve() async =>
      const LocationResult.acquired(_soho);
}

class _DeniedLocationService extends LocationService {
  const _DeniedLocationService();

  @override
  Future<LocationResult> resolve() async =>
      const LocationResult.unavailable(LocationFailureReason.denied);
}

class _FakeConnectivityService extends ConnectivityService {
  const _FakeConnectivityService(this._controller);

  final StreamController<bool> _controller;

  @override
  Stream<bool> get onlineChanges => _controller.stream;
}

/// A connectivity stream that must never be touched — proves the bloc only
/// subscribes after an offline failure.
class _UntouchableConnectivityService extends ConnectivityService {
  const _UntouchableConnectivityService();

  @override
  Stream<bool> get onlineChanges =>
      throw StateError('connectivity must only be watched after going offline');
}

VenueSearchResult _results(List<Venue> venues) =>
    VenueSearchResult(venues: venues, coverage: CoverageLevel.researched);

void main() {
  final spots = [_venue('spot-1'), _venue('spot-2')];

  blocTest<DiscoveryBloc, DiscoveryState>(
    'happy path: locating → searching at the acquired position → loaded',
    build: () => DiscoveryBloc(
      venueRepository: _FakeVenueRepository([() async => _results(spots)]),
      locationService: const _AcquiredLocationService(),
      connectivity: const _UntouchableConnectivityService(),
    ),
    act: (bloc) => bloc.add(const DiscoveryStarted()),
    expect: () => [
      const DiscoveryState.locating(),
      const DiscoveryState.searching(center: _soho),
      DiscoveryState.loaded(
        center: _soho,
        venues: spots,
        coverage: CoverageLevel.researched,
      ),
    ],
  );

  blocTest<DiscoveryBloc, DiscoveryState>(
    'permission denied: Manhattan fallback, with the REASON carried in '
    'every subsequent state instead of dying as a null',
    build: () => DiscoveryBloc(
      venueRepository: _FakeVenueRepository([() async => _results(spots)]),
      locationService: const _DeniedLocationService(),
      connectivity: const _UntouchableConnectivityService(),
    ),
    act: (bloc) => bloc.add(const DiscoveryStarted()),
    expect: () => [
      const DiscoveryState.locating(),
      const DiscoveryState.searching(
        center: DiscoveryBloc.manhattan,
        locationFailure: LocationFailureReason.denied,
      ),
      DiscoveryState.loaded(
        center: DiscoveryBloc.manhattan,
        venues: spots,
        coverage: CoverageLevel.researched,
        locationFailure: LocationFailureReason.denied,
      ),
    ],
  );

  blocTest<DiscoveryBloc, DiscoveryState>(
    'engine failure: failed(engine) with the server-provided message',
    build: () => DiscoveryBloc(
      venueRepository: _FakeVenueRepository([
        () async => throw const VenueApiException('engine returned 500'),
      ]),
      locationService: const _AcquiredLocationService(),
      connectivity: const _UntouchableConnectivityService(),
    ),
    act: (bloc) => bloc.add(const DiscoveryRetryPressed()),
    expect: () => [
      const DiscoveryState.locating(),
      const DiscoveryState.searching(center: _soho),
      const DiscoveryState.failed(
        center: _soho,
        failure: DiscoveryFailure.engine(message: 'engine returned 500'),
      ),
    ],
  );

  blocTest<DiscoveryBloc, DiscoveryState>(
    'empty results are a loaded state, not a failure — the empty view is a '
    'funnel exit of its own',
    build: () => DiscoveryBloc(
      venueRepository: _FakeVenueRepository([() async => _results(const [])]),
      locationService: const _AcquiredLocationService(),
      connectivity: const _UntouchableConnectivityService(),
    ),
    act: (bloc) => bloc.add(const DiscoveryStarted()),
    expect: () => [
      const DiscoveryState.locating(),
      const DiscoveryState.searching(center: _soho),
      const DiscoveryState.loaded(
        center: _soho,
        venues: [],
        coverage: CoverageLevel.researched,
      ),
    ],
  );

  group('offline auto-retry', () {
    late StreamController<bool> connectivity;

    setUp(() => connectivity = StreamController<bool>());
    tearDown(() => connectivity.close());

    blocTest<DiscoveryBloc, DiscoveryState>(
      'offline failure arms the connectivity watch; reconnection re-searches '
      'at the same center with NO user event',
      build: () => DiscoveryBloc(
        venueRepository: _FakeVenueRepository([
          () async => throw const VenueOfflineException(),
          () async => _results(spots),
        ]),
        locationService: const _AcquiredLocationService(),
        connectivity: _FakeConnectivityService(connectivity),
      ),
      act: (bloc) async {
        bloc.add(const DiscoveryStarted());
        // Let the offline failure land, then restore connectivity — the
        // subscription turns it into a DiscoveryConnectivityRestored event.
        await Future<void>.delayed(const Duration(milliseconds: 20));
        connectivity.add(true);
      },
      expect: () => [
        const DiscoveryState.locating(),
        const DiscoveryState.searching(center: _soho),
        const DiscoveryState.failed(
          center: _soho,
          failure: DiscoveryFailure.offline(),
        ),
        const DiscoveryState.searching(center: _soho),
        DiscoveryState.loaded(
          center: _soho,
          venues: spots,
          coverage: CoverageLevel.researched,
        ),
      ],
    );
  });
}
