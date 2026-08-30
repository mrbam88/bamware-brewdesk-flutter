import 'dart:async';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'location_service.freezed.dart';
part 'location_service.g.dart';

// LEARN: services register as providers colocated with their class — the
// provider IS the module's export. `keepAlive: true` because codegen
// providers default to autoDispose (state is torn down when the last
// listener unsubscribes); an app-wide stateless service has nothing to
// dispose and no reason to churn. RN analogy: a module-level singleton,
// except tests can swap it per-scope instead of monkey-patching the import.
@Riverpod(keepAlive: true)
LocationService locationService(Ref ref) => const LocationService();

/// Why a location could not be produced. Each reason reads (and recovers)
/// differently: settings deep-link for [deniedForever], a re-prompt for
/// [denied], a retry for [timeout] — and every one is a distinct funnel
/// exit worth counting.
enum LocationFailureReason { servicesOff, denied, deniedForever, timeout }

// LEARN: this sealed result is the flagship lesson in miniature. The old
// API was `Future<LatLng?>` — services-off, permission-denied,
// denied-forever, and GPS timeout ALL collapsed into one null, and the
// caller silently substituted Manhattan (audit finding #1). A sealed
// hierarchy makes the caller switch on every case, exhaustively, at
// compile time. RN analogy: a discriminated union result instead of
// `null | LatLng`, with the exhaustiveness TypeScript's `never` check
// gives you.
@freezed
sealed class LocationResult with _$LocationResult {
  const factory LocationResult.acquired(LatLng position) = LocationAcquired;

  const factory LocationResult.unavailable(LocationFailureReason reason) =
      LocationUnavailable;
}

class LocationService {
  const LocationService();

  Future<LocationResult> resolve() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        return const LocationResult.unavailable(
          LocationFailureReason.servicesOff,
        );
      }
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever) {
        return const LocationResult.unavailable(
          LocationFailureReason.deniedForever,
        );
      }
      if (permission == LocationPermission.denied) {
        return const LocationResult.unavailable(LocationFailureReason.denied);
      }
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 8),
        ),
      );
      return LocationResult.acquired(
        LatLng(position.latitude, position.longitude),
      );
    } on TimeoutException {
      return const LocationResult.unavailable(LocationFailureReason.timeout);
    } on Object {
      // Anything else the platform throws reads as a timeout-class failure:
      // transient, retryable, not a permissions problem.
      return const LocationResult.unavailable(LocationFailureReason.timeout);
    }
  }
}
