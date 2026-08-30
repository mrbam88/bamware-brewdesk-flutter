import 'dart:async';

import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'location_service.g.dart';

// LEARN: services register as providers colocated with their class — the
// provider IS the module's export. `keepAlive: true` because codegen
// providers default to autoDispose (state is torn down when the last
// listener unsubscribes); an app-wide stateless service has nothing to
// dispose and no reason to churn. RN analogy: a module-level singleton,
// except tests can swap it per-scope instead of monkey-patching the import.
@Riverpod(keepAlive: true)
LocationService locationService(Ref ref) => const LocationService();

class LocationService {
  const LocationService();

  Future<LatLng?> currentLocation() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) return null;
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return null;
      }
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 8),
        ),
      );
      return LatLng(position.latitude, position.longitude);
    } on TimeoutException {
      return null;
    } on Object {
      return null;
    }
  }
}
