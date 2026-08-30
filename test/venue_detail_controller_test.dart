// Pure-Dart test of the venue-detail AsyncNotifier FAMILY: each venue id is
// its own provider instance with its own state — and errors now surface as
// AsyncError instead of being swallowed (the deleted view model's sin).

import 'package:brewdesk/features/venue_detail/application/venue_detail_controller.dart';
import 'package:brewdesk/features/venues/data/venue_repository.dart';
import 'package:brewdesk/features/venues/domain/venue.dart';
import 'package:brewdesk/features/venues/domain/venue_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

Venue _venue(String id, {int workScore = 60}) => Venue(
  id: id,
  name: id,
  lat: 40.7,
  lng: -74.0,
  neighborhood: 'SoHo',
  borough: 'Manhattan',
  venueType: 'cafe',
  attributes: const VenueAttributes(),
  vibeTags: const [],
  workScore: workScore,
  tier: 'researched',
);

class _FakeVenueRepository implements VenueRepository {
  _FakeVenueRepository({this.failPhotos = false});

  final bool failPhotos;
  final refreshedIds = <String>[];

  @override
  Future<Venue> venue(String id, {bool refresh = false}) async {
    if (refresh) refreshedIds.add(id);
    return _venue(id, workScore: 90);
  }

  @override
  Future<List<VenuePhoto>> photos(String id) async {
    if (failPhotos) throw StateError('photos down');
    return [VenuePhoto(url: 'https://example.test/$id.jpg')];
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
}

ProviderContainer _container(VenueRepository repository) {
  final container = ProviderContainer(
    overrides: [venueRepositoryProvider.overrideWithValue(repository)],
  );
  addTearDown(container.dispose);
  return container;
}

void main() {
  test('loads the refreshed venue and photos for exactly the family key', () async {
    final repository = _FakeVenueRepository();
    final container = _container(repository);

    final detail = await container.read(
      venueDetailControllerProvider('spot-1').future,
    );

    expect(detail.venue.id, 'spot-1');
    expect(detail.venue.workScore, 90, reason: 'refresh bypasses the cache');
    expect(detail.photos.single.url, 'https://example.test/spot-1.jpg');
    expect(repository.refreshedIds, ['spot-1']);
  });

  test('two ids are two independent provider instances', () async {
    final container = _container(_FakeVenueRepository());

    final a = await container.read(venueDetailControllerProvider('a').future);
    final b = await container.read(venueDetailControllerProvider('b').future);

    expect(a.venue.id, 'a');
    expect(b.venue.id, 'b');
  });

  test('a failure is a real AsyncError, not a silent no-op', () async {
    final container = _container(_FakeVenueRepository(failPhotos: true));

    await expectLater(
      container.read(venueDetailControllerProvider('spot-1').future),
      throwsStateError,
    );
  });
}
