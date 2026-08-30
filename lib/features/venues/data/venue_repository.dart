import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import 'package:brewdesk/features/venues/domain/venue.dart';
import 'package:brewdesk/features/venues/data/venue_api.dart';

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
  return (json['venues'] as List<dynamic>? ?? const [])
      .cast<Map<String, dynamic>>()
      .map(Venue.fromJson)
      .toList(growable: false);
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
    final venues = (json['venues'] as List<dynamic>? ?? const [])
        .cast<Map<String, dynamic>>()
        .map(Venue.fromJson)
        .toList(growable: false);
    for (final venue in venues) {
      _cache[venue.id] = venue;
    }
    final coverageRaw =
        (json['meta'] as Map<String, dynamic>?)?['coverage'] as String?;
    return VenueSearchResult(
      venues: venues,
      coverage: switch (coverageRaw) {
        'baseline' => CoverageLevel.baseline,
        'none' => CoverageLevel.none,
        _ => CoverageLevel.researched,
      },
    );
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
    final venue = Venue.fromJson(json['venue'] as Map<String, dynamic>);
    _cache[id] = venue;
    return venue;
  }

  Future<List<VenuePhoto>> photos(String id) async {
    final json = await _api.photos(id);
    return (json['photos'] as List<dynamic>? ?? const [])
        .cast<Map<String, dynamic>>()
        .map((photo) => VenuePhoto.fromJson(photo, _api.baseUri))
        .toList(growable: false);
  }
}
