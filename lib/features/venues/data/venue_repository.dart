import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:brewdesk/features/venues/domain/venue.dart';
import 'package:brewdesk/features/venues/data/venue_api.dart';
import 'package:brewdesk/features/venues/data/venue_dtos.dart';

part 'venue_repository.g.dart';

// LEARN: the repository depends on the API client via `ref.watch`, not by
// constructing it — the provider graph is the DI container. Swap
// `venueApiProvider` in a test (or a scenario launch) and every dependent
// provider sees the fake with no plumbing. RN analogy: module wiring you'd
// otherwise do with jest.mock, but first-class and per-scope.
@Riverpod(keepAlive: true)
VenueRepository venueRepository(Ref ref) =>
    VenueRepository(ref.watch(venueApiProvider));

/// Loads the venues bundled for cold start. Defaults to the packaged
/// `assets/venue_snapshot.json`; tests substitute a fake.
typedef VenueSnapshotLoader = Future<List<Venue>> Function();

/// A search result that may be showing the bundled cold-start snapshot
/// instead of (or ahead of) a live response. [note] is set only while
/// bundled data is on screen; UI that ignores it renders nothing extra.
class ColdStartResult {
  const ColdStartResult({required this.venues, this.coverage, this.note});

  final List<Venue> venues;
  final CoverageLevel? coverage;
  final String? note;

  bool get isBundledSnapshot => note != null;
}

const bundledSnapshotNote =
    'Showing bundled data. Live results will replace it once the network responds.';

Future<List<Venue>> loadBundledVenueSnapshot() async {
  final raw = await rootBundle.loadString('assets/venue_snapshot.json');
  final json = jsonDecode(raw) as Map<String, dynamic>;
  // The snapshot is a captured search response, so it decodes through the
  // same DTO as the live endpoint — one contract, one decoder.
  return VenueSearchResponseDto.fromJson(json).toDomain().venues;
}

class VenueRepository {
  VenueRepository(this._api, {VenueSnapshotLoader? snapshotLoader})
    : _loadSnapshot = snapshotLoader ?? loadBundledVenueSnapshot;

  final VenueApi _api;
  final VenueSnapshotLoader _loadSnapshot;
  final Map<String, Venue> _cache = {};

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

  /// Cold-start search: emits the bundled snapshot immediately when the
  /// cache is empty, then the live result once the network responds. If the
  /// live call fails, the snapshot stays on screen with [bundledSnapshotNote]
  /// rather than leaving the caller with nothing.
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
      yield ColdStartResult(venues: snapshotVenues, note: bundledSnapshotNote);
    }
    try {
      final live = await search(lat: lat, lng: lng);
      yield ColdStartResult(venues: live.venues, coverage: live.coverage);
    } on Object {
      if (snapshotVenues == null) rethrow;
      yield ColdStartResult(venues: snapshotVenues, note: bundledSnapshotNote);
    }
  }

  Future<Venue> venue(String id, {bool refresh = false}) async {
    final cached = _cache[id];
    if (!refresh && cached != null) return cached;
    final json = await _api.venue(id);
    final venue = VenueEnvelopeDto.fromJson(json).venue.toDomain();
    _cache[id] = venue;
    return venue;
  }

  Future<List<VenuePhoto>> photos(String id) async {
    final json = await _api.photos(id);
    return PhotosResponseDto.fromJson(json)
        .photos
        .map((photo) => photo.toDomain(_api.baseUri))
        .toList(growable: false);
  }
}
