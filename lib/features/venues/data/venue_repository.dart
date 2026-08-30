import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:brewdesk/features/venues/domain/venue.dart';
import 'package:brewdesk/features/venues/domain/venue_repository.dart';
import 'package:brewdesk/features/venues/data/venue_api.dart';
import 'package:brewdesk/features/venues/data/venue_dtos.dart';

part 'venue_repository.g.dart';

// LEARN: the repository depends on the API client via `ref.watch`, not by
// constructing it — the provider graph is the DI container. Swap
// `venueApiProvider` in a test (or a scenario launch) and every dependent
// provider sees the fake with no plumbing. RN analogy: module wiring you'd
// otherwise do with jest.mock, but first-class and per-scope.
// LEARN: the provider's declared type is the domain INTERFACE — consumers
// can't see (or downcast to) the HTTP implementation. This is where the
// dependency inversion is actually enforced.
@Riverpod(keepAlive: true)
VenueRepository venueRepository(Ref ref) =>
    ApiVenueRepository(ref.watch(venueApiProvider));

/// Loads the venues bundled for cold start. Defaults to the packaged
/// `assets/venue_snapshot.json`; tests substitute a fake.
typedef VenueSnapshotLoader = Future<List<Venue>> Function();

Future<List<Venue>> loadBundledVenueSnapshot() async {
  final raw = await rootBundle.loadString('assets/venue_snapshot.json');
  final json = jsonDecode(raw) as Map<String, dynamic>;
  // The snapshot is a captured search response, so it decodes through the
  // same DTO as the live endpoint — one contract, one decoder.
  return VenueSearchResponseDto.fromJson(json).toDomain().venues;
}

/// The production [VenueRepository]: engine HTTP API + bundled snapshot,
/// with a session-lifetime in-memory cache keyed by venue id.
class ApiVenueRepository implements VenueRepository {
  ApiVenueRepository(this._api, {VenueSnapshotLoader? snapshotLoader})
    : _loadSnapshot = snapshotLoader ?? loadBundledVenueSnapshot;

  final VenueApi _api;
  final VenueSnapshotLoader _loadSnapshot;
  final Map<String, Venue> _cache = {};

  @override
  Future<VenueSearchResult> search({
    required double lat,
    required double lng,
  }) async {
    final json = await _api.search(lat: lat, lng: lng);
    final result = VenueSearchResponseDto.fromJson(json).toDomain();
    for (final venue in result.venues) {
      _cache[venue.id] = venue;
    }
    return result;
  }

  @override
  Stream<ColdStartResult> coldStart({
    required double lat,
    required double lng,
  }) async* {
    List<Venue>? snapshotVenues;
    if (_cache.isEmpty) {
      snapshotVenues = await _loadSnapshot();
      for (final venue in snapshotVenues) {
        _cache[venue.id] = venue;
      }
      yield ColdStartResult(venues: snapshotVenues, isBundledSnapshot: true);
    }
    try {
      final live = await search(lat: lat, lng: lng);
      yield ColdStartResult(venues: live.venues, coverage: live.coverage);
    } on Object {
      if (snapshotVenues == null) rethrow;
      yield ColdStartResult(venues: snapshotVenues, isBundledSnapshot: true);
    }
  }

  @override
  Future<Venue> venue(String id, {bool refresh = false}) async {
    final cached = _cache[id];
    if (!refresh && cached != null) return cached;
    final json = await _api.venue(id);
    final venue = VenueEnvelopeDto.fromJson(json).venue.toDomain();
    _cache[id] = venue;
    return venue;
  }

  @override
  Future<List<VenuePhoto>> photos(String id) async {
    final json = await _api.photos(id);
    return PhotosResponseDto.fromJson(json)
        .photos
        .map((photo) => photo.toDomain(_api.baseUri))
        .toList(growable: false);
  }
}
