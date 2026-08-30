// Pure-Dart Riverpod test: no widgets, no pumping. A ProviderContainer with
// an overridden leaf (SharedPreferences) exercises the real provider chain
// prefs -> SavedVenuesStore -> SavedVenueIds — the Riverpod equivalent of
// testing a Zustand store with its persist layer faked at the edge.

import 'package:brewdesk/core/di/app_providers.dart';
import 'package:brewdesk/features/saved/application/saved_venue_ids.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<ProviderContainer> _container() async {
  final preferences = await SharedPreferences.getInstance();
  final container = ProviderContainer(
    overrides: [sharedPreferencesProvider.overrideWithValue(preferences)],
  );
  addTearDown(container.dispose);
  return container;
}

void main() {
  test('toggle adds then removes, and persists through the store', () async {
    SharedPreferences.setMockInitialValues({});
    final container = await _container();

    await container.read(savedVenueIdsProvider.notifier).toggle('spot-1');
    expect(container.read(savedVenueIdsProvider), {'spot-1'});

    // A fresh container over the same prefs = a fresh app launch.
    final relaunched = await _container();
    expect(relaunched.read(savedVenueIdsProvider), {'spot-1'});

    await relaunched.read(savedVenueIdsProvider.notifier).toggle('spot-1');
    expect(relaunched.read(savedVenueIdsProvider), isEmpty);
  });

  test('seeded ids load on first read', () async {
    SharedPreferences.setMockInitialValues({
      'brewdesk.savedVenueIds': ['a', 'b'],
    });
    final container = await _container();
    expect(container.read(savedVenueIdsProvider), {'a', 'b'});
  });
}
