import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:brewdesk/features/saved/data/saved_venues_service.dart';

part 'saved_venue_ids.g.dart';

// LEARN: this replaces a ChangeNotifier that WAS the repository — data
// layer doubling as an event bus, with three screens hand-wiring
// addListener/removeListener to it (audit finding #3). As a Notifier, the
// saved-ids set is ordinary provider state: any widget that ref.watches it
// rebuilds on toggle, no subscription bookkeeping anywhere, and persistence
// is a store the notifier CALLS, not something it IS.
//
// RN analogy: a Zustand store with a persist middleware. Note the state is
// replaced ({...state}), never mutated — with value-typed state, mutation
// wouldn't notify (same lesson as never push-ing into a useState array).
//
// keepAlive: saved ids are app-lifetime state used by three tabs; letting
// them dispose and re-read prefs on every tab switch would buy nothing.
@Riverpod(keepAlive: true)
class SavedVenueIds extends _$SavedVenueIds {
  @override
  Set<String> build() => ref.watch(savedVenuesStoreProvider).load();

  Future<void> toggle(String id) async {
    final next = {...state};
    if (!next.add(id)) next.remove(id);
    state = next;
    await ref.read(savedVenuesStoreProvider).save(next);
  }
}
