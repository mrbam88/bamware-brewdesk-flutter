import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:brewdesk/features/venues/data/venue_repository.dart';
import 'package:brewdesk/features/venues/domain/venue.dart';

part 'venue_detail_controller.freezed.dart';
part 'venue_detail_controller.g.dart';

/// Everything the detail screen shows beyond the list payload: the
/// refreshed venue record plus its photo strip.
@Freezed(makeCollectionsUnmodifiable: false)
abstract class VenueDetail with _$VenueDetail {
  const factory VenueDetail({
    required Venue venue,
    required List<VenuePhoto> photos,
  }) = _VenueDetail;
}

// LEARN: `build(String venueId)` makes this a FAMILY — one independent
// provider instance (state, future, cache) per venue id, exactly TanStack's
// useQuery(['venue', id]). autoDispose (the codegen default) is the cache
// policy: while any detail screen for this venue is on screen the value is
// cached and shared; when the last watcher pops, it's evicted. Push the
// same venue again -> fresh fetch. That one line of policy replaced a
// view model class whose load() caught EVERY error and did nothing —
// callers now get a real AsyncError they must render on purpose.
@riverpod
class VenueDetailController extends _$VenueDetailController {
  @override
  Future<VenueDetail> build(String venueId) async {
    final repository = ref.watch(venueRepositoryProvider);
    // refresh: true bypasses the session cache — the list payload the
    // screen already shows IS that cache; this fetch is for what's newer.
    final results = await Future.wait<Object>([
      repository.venue(venueId, refresh: true),
      repository.photos(venueId),
    ]);
    return VenueDetail(
      venue: results[0] as Venue,
      photos: results[1] as List<VenuePhoto>,
    );
  }
}
