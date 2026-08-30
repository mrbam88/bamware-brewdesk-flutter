// One screen, all three AsyncValue states rendered on purpose: loading,
// error, data. `AsyncValue.when` makes the compiler demand handlers for all
// three; this test proves each branch actually reaches the screen. Before
// the refactor the Saved screen had NO error rendering at all — nothing
// forced anyone to write one.

import 'dart:async';

import 'package:brewdesk/features/saved/data/saved_venues_service.dart';
import 'package:brewdesk/features/saved/domain/saved_venues_store.dart';
import 'package:brewdesk/features/saved/presentation/saved_screen.dart';
import 'package:brewdesk/features/venues/data/venue_repository.dart';
import 'package:brewdesk/features/venues/domain/venue.dart';
import 'package:brewdesk/features/venues/domain/venue_repository.dart';
import 'package:brewdesk/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _MemoryStore implements SavedVenuesStore {
  const _MemoryStore(this.ids);
  final Set<String> ids;

  @override
  Set<String> load() => ids;

  @override
  Future<void> save(Set<String> next) async {}
}

class _ThrowingStore implements SavedVenuesStore {
  const _ThrowingStore();

  @override
  Set<String> load() => throw StateError('storage corrupted');

  @override
  Future<void> save(Set<String> next) async {}
}

class _FakeVenueRepository implements VenueRepository {
  _FakeVenueRepository({this.hang = false});

  /// When true, venue() never completes — pins the loading state open.
  final bool hang;

  @override
  Future<Venue> venue(String id, {bool refresh = false}) {
    if (hang) return Completer<Venue>().future;
    return Future.value(
      Venue(
        id: id,
        name: 'Union Hall',
        lat: 40.7,
        lng: -74.0,
        neighborhood: 'SoHo',
        borough: 'Manhattan',
        venueType: 'cafe',
        attributes: const VenueAttributes(),
        vibeTags: const [],
        workScore: 82,
        tier: 'researched',
      ),
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

Widget _harness({
  required SavedVenuesStore store,
  required VenueRepository repository,
}) {
  return ProviderScope(
    overrides: [
      savedVenuesStoreProvider.overrideWithValue(store),
      venueRepositoryProvider.overrideWithValue(repository),
    ],
    child: MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: SavedScreen(onBrowse: () {}),
    ),
  );
}

void main() {
  testWidgets('loading: an unresolved hydration renders the spinner', (
    tester,
  ) async {
    await tester.pumpWidget(
      _harness(
        store: const _MemoryStore({'spot-1'}),
        repository: _FakeVenueRepository(hang: true),
      ),
    );
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Union Hall'), findsNothing);
  });

  testWidgets('error: a failing ids store renders the error copy', (
    tester,
  ) async {
    await tester.pumpWidget(
      _harness(
        store: const _ThrowingStore(),
        repository: _FakeVenueRepository(),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.text("Your saved spots couldn't load. Pull to retry."),
      findsOneWidget,
    );
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('data: hydrated venues render as cards', (tester) async {
    await tester.pumpWidget(
      _harness(
        store: const _MemoryStore({'spot-1'}),
        repository: _FakeVenueRepository(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Union Hall'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });
}
