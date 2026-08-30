import 'package:brewdesk/core/location/location_service.dart';
import 'package:brewdesk/core/location/union_square_location_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';

void main() {
  test('resolves to the fixed Union Square coordinate', () async {
    const service = UnionSquareLocationService();

    final location = switch (await service.resolve()) {
      LocationAcquired(:final position) => position,
      LocationUnavailable() => null,
    };

    expect(location, const LatLng(40.7359, -73.9911));
    expect(location, UnionSquareLocationService.unionSquare);
  });
}
