import 'package:latlong2/latlong.dart';

import '../../../data/services/location_service.dart';

/// Resolves to Union Square without ever calling Geolocator.
///
/// Used once the visitor picks "Use Union Square instead" in the location
/// intro step, so that choice can never trigger the OS location prompt.
class UnionSquareLocationService extends LocationService {
  const UnionSquareLocationService();

  static const unionSquare = LatLng(40.7359, -73.9911);

  @override
  Future<LatLng?> currentLocation() async => unionSquare;
}
