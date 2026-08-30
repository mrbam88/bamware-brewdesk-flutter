import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:latlong2/latlong.dart';

import 'package:brewdesk/core/location/location_service.dart';
import 'package:brewdesk/core/networking/connectivity_service.dart';
import 'package:brewdesk/features/venues/data/venue_api.dart';
import 'package:brewdesk/features/venues/domain/venue.dart';
import 'package:brewdesk/features/venues/domain/venue_repository.dart';

part 'discovery_bloc.freezed.dart';

// ---------------------------------------------------------------------------
// Events — everything that can happen TO the funnel, as a sealed vocabulary.
// LEARN: Redux actions with a closed set: a handler must exist for each, and
// nothing else can occur. Widgets add() these; they never call methods that
// mutate state directly.
// ---------------------------------------------------------------------------

sealed class DiscoveryEvent {
  const DiscoveryEvent();
}

/// First load, and the "use my location" FAB: resolve location, then search.
final class DiscoveryStarted extends DiscoveryEvent {
  const DiscoveryStarted();
}

/// The error card's Try again button.
final class DiscoveryRetryPressed extends DiscoveryEvent {
  const DiscoveryRetryPressed();
}

/// Dispatched by the bloc's own connectivity subscription (armed only while
/// offline-failed) — an autonomous event source, not a user action.
final class DiscoveryConnectivityRestored extends DiscoveryEvent {
  const DiscoveryConnectivityRestored();
}

// ---------------------------------------------------------------------------
// States — the funnel's phases, sealed so illegal combinations (loading AND
// errored, error text WITHOUT an error) cannot be constructed, and every
// `switch` over them is checked for exhaustiveness by the compiler.
// LEARN: the old view model held four loose fields (loading/error/errorKind/
// venues) that could disagree; this is the same information as one value
// that is always exactly one phase.
// ---------------------------------------------------------------------------

@Freezed(makeCollectionsUnmodifiable: false)
sealed class DiscoveryState with _$DiscoveryState {
  const DiscoveryState._();

  /// Resolving the device location (the OS permission prompt may be up).
  /// [staleVenues] keeps whatever was on screen during a re-locate.
  const factory DiscoveryState.locating({
    @Default(<Venue>[]) List<Venue> staleVenues,
  }) = DiscoveryLocating;

  /// Location settled (successfully or via [locationFailure] + fallback
  /// center); the venue search is in flight.
  const factory DiscoveryState.searching({
    required LatLng center,
    LocationFailureReason? locationFailure,
    @Default(<Venue>[]) List<Venue> staleVenues,
  }) = DiscoverySearching;

  /// Results are on screen — possibly zero of them (the empty view is a
  /// success, not an error).
  const factory DiscoveryState.loaded({
    required LatLng center,
    required List<Venue> venues,
    required CoverageLevel coverage,
    LocationFailureReason? locationFailure,
  }) = DiscoveryLoaded;

  /// The search failed in a [failure]-specific way. Offline arms the
  /// auto-retry subscription; engine failures wait for the user.
  const factory DiscoveryState.failed({
    required LatLng center,
    required DiscoveryFailure failure,
    LocationFailureReason? locationFailure,
    @Default(<Venue>[]) List<Venue> staleVenues,
  }) = DiscoveryFailed;

  /// The venues this phase can show: live results, or what was on screen
  /// before the phase began (so a retry never blanks the shelf).
  List<Venue> get venuesOrStale => switch (this) {
    DiscoveryLocating(:final staleVenues) => staleVenues,
    DiscoverySearching(:final staleVenues) => staleVenues,
    DiscoveryLoaded(:final venues) => venues,
    DiscoveryFailed(:final staleVenues) => staleVenues,
  };

  /// Where the map should sit; null only before the first location resolve.
  LatLng? get centerOrNull => switch (this) {
    DiscoveryLocating() => null,
    DiscoverySearching(:final center) => center,
    DiscoveryLoaded(:final center) => center,
    DiscoveryFailed(:final center) => center,
  };

  LocationFailureReason? get locationFailure => switch (this) {
    DiscoveryLocating() => null,
    DiscoverySearching(:final locationFailure) => locationFailure,
    DiscoveryLoaded(:final locationFailure) => locationFailure,
    DiscoveryFailed(:final locationFailure) => locationFailure,
  };
}

/// The typed failure taxonomy (brewdesk#11): "you're offline" and "the
/// engine is down" read and recover differently, so they are different
/// TYPES, not different strings.
@freezed
sealed class DiscoveryFailure with _$DiscoveryFailure {
  /// The request never reached the engine. Auto-retry is armed: the bloc
  /// re-searches the moment connectivity returns, no user action needed.
  const factory DiscoveryFailure.offline() = DiscoveryOffline;

  /// The engine answered badly (or something unexpected broke). [message]
  /// is the server-provided text when there is one; the UI localizes its
  /// own copy otherwise.
  const factory DiscoveryFailure.engine({String? message}) = DiscoveryEngineDown;
}

// ---------------------------------------------------------------------------
// The bloc
// ---------------------------------------------------------------------------

/// BrewDesk's flagship state machine: permission → locating → searching →
/// results / empty / offline (self-healing) / engine-down. Every session
/// runs this funnel; every transition is observed (see AppBlocObserver).
class DiscoveryBloc extends Bloc<DiscoveryEvent, DiscoveryState> {
  DiscoveryBloc({
    required VenueRepository venueRepository,
    required this._locationService,
    required this._connectivity,
  }) : _repository = venueRepository,
       super(const DiscoveryState.locating()) {
    // LEARN: event transformers are the concurrency policy, per event type.
    // restartable: a new Started (the FAB) CANCELS an in-flight load — the
    //   newest intent wins, like TanStack's query cancellation or RxJS
    //   switchMap. The old view model had no reentrancy guard at all; two
    //   overlapping load()s interleaved their field writes (audit #4).
    // droppable: retry-button spam is IGNORED while a retry runs — the
    //   opposite policy, on the event where mashing is the realistic race.
    on<DiscoveryStarted>(
      (event, emit) => _locateAndSearch(emit),
      transformer: restartable(),
    );
    on<DiscoveryRetryPressed>(
      (event, emit) => _locateAndSearch(emit),
      transformer: droppable(),
    );
    on<DiscoveryConnectivityRestored>(
      // Reuses the center already resolved — reconnecting doesn't move you.
      (event, emit) => _search(emit, center: _centerOrManhattan),
      transformer: restartable(),
    );
  }

  static const manhattan = LatLng(40.7411, -73.9897);

  final VenueRepository _repository;
  final LocationService _locationService;
  final ConnectivityService _connectivity;
  StreamSubscription<bool>? _connectivitySub;

  LatLng get _centerOrManhattan => state.centerOrNull ?? manhattan;

  Future<void> _locateAndSearch(Emitter<DiscoveryState> emit) async {
    emit(DiscoveryState.locating(staleVenues: state.venuesOrStale));
    final location = await _locationService.resolve();
    // LEARN: with restartable(), an await is a cancellation point — if a
    // newer event superseded this handler, its emitter is done and further
    // emits would be errors. Check after every await.
    if (emit.isDone) return;
    final (center, locationFailure) = switch (location) {
      LocationAcquired(:final position) => (position, null),
      // The fallback is unchanged (Manhattan) — but the REASON now rides
      // along in every subsequent state instead of dying here, so the UI
      // could explain it and the observer counts each funnel exit.
      LocationUnavailable(:final reason) => (manhattan, reason),
    };
    await _search(emit, center: center, locationFailure: locationFailure);
  }

  Future<void> _search(
    Emitter<DiscoveryState> emit, {
    required LatLng center,
    LocationFailureReason? locationFailure,
  }) async {
    emit(
      DiscoveryState.searching(
        center: center,
        locationFailure: locationFailure,
        staleVenues: state.venuesOrStale,
      ),
    );
    try {
      final result = await _repository.search(
        lat: center.latitude,
        lng: center.longitude,
      );
      if (emit.isDone) return;
      _stopWatchingForReconnect();
      emit(
        DiscoveryState.loaded(
          center: center,
          venues: result.venues,
          coverage: result.coverage,
          locationFailure: locationFailure,
        ),
      );
    } on VenueOfflineException {
      if (emit.isDone) return;
      _watchForReconnect();
      emit(
        DiscoveryState.failed(
          center: center,
          failure: const DiscoveryFailure.offline(),
          locationFailure: locationFailure,
          staleVenues: state.venuesOrStale,
        ),
      );
    } on Object catch (error) {
      if (emit.isDone) return;
      emit(
        DiscoveryState.failed(
          center: center,
          failure: DiscoveryFailure.engine(
            message: error is VenueApiException ? error.message : null,
          ),
          locationFailure: locationFailure,
          staleVenues: state.venuesOrStale,
        ),
      );
    }
  }

  /// Subscribes to connectivity once, only after an offline failure — most
  /// loads succeed and should never touch the platform channel. The
  /// subscription feeds the event queue rather than calling handlers
  /// directly, so auto-retries flow through the same observable, policy-
  /// carrying pipeline as user actions (brewdesk#11).
  void _watchForReconnect() {
    _connectivitySub ??= _connectivity.onlineChanges
        .where((online) => online)
        .listen((_) => add(const DiscoveryConnectivityRestored()));
  }

  void _stopWatchingForReconnect() {
    _connectivitySub?.cancel();
    _connectivitySub = null;
  }

  @override
  Future<void> close() {
    _stopWatchingForReconnect();
    return super.close();
  }
}
