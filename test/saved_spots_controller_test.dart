// Pure-Dart AsyncNotifier test: a ProviderContainer with two fakes at the
// edges (store + repository), no widgets. Riverpod's test story IS the
// production wiring — the same graph, different leaves.

import 'package:brewdesk/features/saved/application/saved_spots.dart';
import 'package:brewdesk/features/saved/application/saved_venue_ids.dart';
import 'package:brewdesk/features/saved/data/saved_venues_service.dart';
import 'package:brewdesk/features/saved/domain/saved_venues_store.dart';
import 'package:brewdesk/features/venues/data/venue_repository.dart';
import 'package:brewdesk/features/venues/domain/venue.dart';
import 'package:brewdesk/features/venues/domain/venue_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _MemoryStore implements SavedVenuesStore {
  _MemoryStore(this.ids);
  Set<String> ids;

  @override
  Set<String> load() => ids;

  @override
  Future<void> save(Set<String> next) async => ids = next;
}

class _FakeVenueRepository implements VenueRepository {
  _FakeVenueRepository({this.failingIds = const {}});

  final Set<String> failingIds;

  @override
  Future<Venue> venue(String id, {bool refresh = false}) async {
    if (failingIds.contains(id)) throw StateError('missing venue $id');
    return Venue(
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
  }

  @override
  Future<VenueSearchResult> search({
    required double lat,
    required double lng,
  }) => throw UnimplementedError();

  @override
  Stream<ColdStartResult> coldStart({
    required double lat,
    required double lng,
  }) => throw UnimplementedError();

  @override
  Future<List<VenuePhoto>> photos(String id) => throw UnimplementedError();
}

ProviderContainer _container({
  required SavedVenuesStore store,
  required VenueRepository repository,
}) {
  final container = ProviderContainer(
    overrides: [
      savedVenuesStoreProvider.overrideWithValue(store),
      venueRepositoryProvider.overrideWithValue(repository),
    ],
  );
  addTearDown(container.dispose);
  // LEARN: savedSpotsControllerProvider is autoDispose — with no listener
  // its state is torn down between reads. A test (like a screen) must hold
  // a subscription for the cache to behave; this is the cache policy
  // showing up in the test, not test boilerplate.
  container.listen(savedSpotsControllerProvider, (_, _) {});
  return container;
}

void main() {
  test('hydrates saved ids; a failing id gets reported, not dropped', () async {
    final container = _container(
      store: _MemoryStore({'spot-ok', 'spot-missing'}),
      repository: _FakeVenueRepository(failingIds: {'spot-missing'}),
    );

    final spots = await container.read(savedSpotsControllerProvider.future);

    expect(spots.venues.map((v) => v.id), ['spot-ok']);
    expect(spots.failedIds, ['spot-missing']);
    expect(spots.isEmpty, isFalse);
  });

  test('a toggle re-runs hydration automatically — no generation counter, '
      'no manual listener', () async {
    final container = _container(
      store: _MemoryStore({'spot-a'}),
      repository: _FakeVenueRepository(),
    );
    expect(
      (await container.read(savedSpotsControllerProvider.future)).venues.length,
      1,
    );

    await container.read(savedVenueIdsProvider.notifier).toggle('spot-b');

    final spots = await container.read(savedSpotsControllerProvider.future);
    expect(spots.venues.map((v) => v.id).toSet(), {'spot-a', 'spot-b'});
  });

  test('no saved ids resolves to the empty state without touching the '
      'repository', () async {
    final container = _container(
      store: _MemoryStore({}),
      // Every repository method throws UnimplementedError if called.
      repository: _FakeVenueRepository(failingIds: const {}),
    );

    final spots = await container.read(savedSpotsControllerProvider.future);
    expect(spots.isEmpty, isTrue);
  });
}
