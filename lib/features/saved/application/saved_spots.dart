import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:brewdesk/features/saved/application/saved_venue_ids.dart';
import 'package:brewdesk/features/venues/data/venue_repository.dart';
import 'package:brewdesk/features/venues/domain/venue.dart';

part 'saved_spots.freezed.dart';
part 'saved_spots.g.dart';

/// The Saved tab's hydrated state: the venues that loaded, plus the saved
/// ids that failed to hydrate this pass (brewdesk#11 — the rest of the list
/// still renders, and each failure gets an honest row instead of vanishing).
@Freezed(makeCollectionsUnmodifiable: false)
abstract class SavedSpots with _$SavedSpots {
  const SavedSpots._();

  const factory SavedSpots({
    required List<Venue> venues,
    required List<String> failedIds,
  }) = _SavedSpots;

  bool get isEmpty => venues.isEmpty && failedIds.isEmpty;
}

// LEARN: an AsyncNotifier is Riverpod's home for SERVER state — the
// useQuery of this codebase. Compare what the ChangeNotifier version
// (SavedViewModel, see git history) had to hand-roll and this doesn't:
//  - a `_generation` counter to drop stale responses: build() re-runs when
//    a watched dependency changes, and Riverpod ignores the superseded
//    future automatically;
//  - addListener/removeListener on the saved-ids repository: `ref.watch`
//    IS the subscription, disposed with the provider;
//  - three loose fields (venues/failedIds/loading) that could disagree:
//    AsyncValue<SavedSpots> is one value that is exactly one of
//    loading/error/data.
//
// autoDispose (the codegen default — no keepAlive flag) is deliberate:
// this cache lives while something on screen watches it. In practice the
// Saved tab sits in an IndexedStack so it's effectively app-lifetime, but
// the POLICY is "cached while watched", not "cached forever".
@riverpod
class SavedSpotsController extends _$SavedSpotsController {
  @override
  Future<SavedSpots> build() async {
    // Watching savedVenueIds means every toggle re-hydrates this list —
    // the reactive dependency the old code approximated with listeners.
    final ids = ref.watch(savedVenueIdsProvider);
    final repository = ref.watch(venueRepositoryProvider);
    if (ids.isEmpty) return const SavedSpots(venues: [], failedIds: []);

    final venues = <Venue>[];
    final failedIds = <String>[];
    for (final id in ids) {
      try {
        venues.add(await repository.venue(id));
      } on Object {
        failedIds.add(id);
      }
    }
    return SavedSpots(venues: venues, failedIds: failedIds);
  }
}
