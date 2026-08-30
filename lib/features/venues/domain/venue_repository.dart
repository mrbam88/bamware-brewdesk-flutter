import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:brewdesk/features/venues/domain/venue.dart';

part 'venue_repository.freezed.dart';

// LEARN: the repository INTERFACE lives in domain and speaks only domain
// types — no http, no DTOs, no Flutter. Application code (view models,
// Blocs, AsyncNotifiers) depends on this; the provider graph decides which
// implementation satisfies it (the HTTP one in the app, in-memory fakes in
// tests). That direction — abstractions in domain, implementations in data
// — is what "repositories behind interfaces" means; it's the DI seam
// dependency-inversion asks for. RN analogy: typing your API layer as an
// interface so a mock service worker / fake client can slide in.
abstract interface class VenueRepository {
  Future<VenueSearchResult> search({required double lat, required double lng});

  /// Cold-start search: emits the bundled snapshot immediately when the
  /// cache is empty, then the live result once the network responds. If the
  /// live call fails, the snapshot stays on screen (flagged) rather than
  /// leaving the caller with nothing.
  Stream<ColdStartResult> coldStart({
    required double lat,
    required double lng,
  });

  Future<Venue> venue(String id, {bool refresh = false});

  Future<List<VenuePhoto>> photos(String id);
}

/// A search result that may be showing the bundled cold-start snapshot
/// instead of (or ahead of) a live response. [isBundledSnapshot] is true
/// only while bundled data is on screen; the UI localizes its own copy for
/// that state (the data layer never ships display strings).
@Freezed(makeCollectionsUnmodifiable: false)
abstract class ColdStartResult with _$ColdStartResult {
  const factory ColdStartResult({
    required List<Venue> venues,
    CoverageLevel? coverage,
    @Default(false) bool isBundledSnapshot,
  }) = _ColdStartResult;
}
