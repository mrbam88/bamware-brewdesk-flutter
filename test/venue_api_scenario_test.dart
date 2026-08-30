// Scenario seam (brewdesk#11): `VenueApi.scenario(...)` fabricates every
// response for a `VenueScenario` with no network. These are plain `test()`s,
// not `testWidgets()` — the "slow" case genuinely waits out a short real
// delay, which is fine outside the FakeAsync zone testWidgets runs in.

import 'package:brewdesk/features/venues/data/venue_api.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('VenueApi.scenario', () {
    test(
      'fixtureOK returns fixture venues on search, venue, and photos',
      () async {
        final api = VenueApi.scenario(VenueScenario.fixtureOK);

        final search = await api.search(lat: 40.7, lng: -74.0);
        final venues = search['venues'] as List<dynamic>;
        expect(venues, isNotEmpty);

        final firstId = (venues.first as Map<String, dynamic>)['id'] as String;
        final venue = await api.venue(firstId);
        expect((venue['venue'] as Map<String, dynamic>)['id'], firstId);

        final photos = await api.photos(firstId);
        expect(photos['photos'], isA<List<dynamic>>());
      },
    );

    test('engineDown fails every call with a 500', () async {
      final api = VenueApi.scenario(VenueScenario.engineDown);

      await expectLater(
        () => api.search(lat: 40.7, lng: -74.0),
        throwsA(isA<VenueApiException>()),
      );
      await expectLater(
        () => api.venue('anything'),
        throwsA(isA<VenueApiException>()),
      );
    });

    test('offline fails every call with no network path', () async {
      final api = VenueApi.scenario(VenueScenario.offline);

      await expectLater(
        () => api.search(lat: 40.7, lng: -74.0),
        throwsA(isA<VenueOfflineException>()),
      );
    });

    test('emptyVenues resolves to zero venues', () async {
      final api = VenueApi.scenario(VenueScenario.emptyVenues);

      final search = await api.search(lat: 40.7, lng: -74.0);

      expect(search['venues'], isEmpty);
    });

    test('slow waits out the configured delay before resolving', () async {
      final api = VenueApi.scenario(
        VenueScenario.slow,
        slowDelay: const Duration(milliseconds: 30),
      );
      final stopwatch = Stopwatch()..start();

      final search = await api.search(lat: 40.7, lng: -74.0);

      stopwatch.stop();
      expect(
        stopwatch.elapsed,
        greaterThanOrEqualTo(const Duration(milliseconds: 25)),
      );
      expect(search['venues'], isNotEmpty);
    });
  });
}
