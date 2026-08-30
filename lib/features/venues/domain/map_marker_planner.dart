import 'package:brewdesk/features/venues/domain/venue.dart';

/// Deterministic marker planning for the MVP city-scale discovery map
/// (brewdesk#2). Deepens the earlier inline `.take(24)` safety cap: instead
/// of capping on whatever order the venues arrived in, it keeps the
/// highest Work Fit venues and collapses venues that share a coordinate,
/// so the map reads without a wall of overlapping score pins.
///
/// Representation only — no zoom-tiered density (pins/dots/clusters). The
/// iOS reference (`BrewDeskKit/MapAnnotationPlanner`) does that for a real
/// map camera; this app has one fixed city-scale view, so a single
/// score-priority downselect is the right amount of complexity for now.
abstract final class MapMarkerPlanner {
  /// Markers rendered at MVP city-scale.
  static const int markerLimit = 24;

  /// Plans which venues get a map pin.
  ///
  /// Below or at [markerLimit], the input passes through unchanged — there
  /// is nothing to prioritize away. Above it, venues sharing an exact
  /// coordinate are collapsed to the single highest Work Fit venue at that
  /// point, the remainder is ranked by Work Fit descending (id ascending
  /// breaks ties, for a deterministic order), and the result is capped at
  /// [markerLimit].
  static List<Venue> plan(List<Venue> venues) {
    if (venues.length <= markerLimit) return venues;

    final bestAtCoordinate = <String, Venue>{};
    for (final venue in venues) {
      final key = '${venue.lat},${venue.lng}';
      final current = bestAtCoordinate[key];
      if (current == null || venue.workScore > current.workScore) {
        bestAtCoordinate[key] = venue;
      }
    }

    final ranked = bestAtCoordinate.values.toList()
      ..sort((a, b) {
        final byScore = b.workScore.compareTo(a.workScore);
        return byScore != 0 ? byScore : a.id.compareTo(b.id);
      });

    return ranked.length <= markerLimit
        ? ranked
        : ranked.sublist(0, markerLimit);
  }
}
