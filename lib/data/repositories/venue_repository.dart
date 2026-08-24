import '../../domain/models/venue.dart';
import '../services/venue_api.dart';

class VenueRepository {
  VenueRepository(this._api);

  final VenueApi _api;
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
