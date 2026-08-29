import 'package:brewdesk/domain/models/venue.dart';
import 'package:brewdesk/domain/use_cases/map_marker_planner.dart';
import 'package:flutter_test/flutter_test.dart';

Venue _venue({
  required String id,
  double lat = 40.7,
  double lng = -74.0,
  int workScore = 60,
}) {
  return Venue.fromJson({
    'id': id,
    'name': id,
    'lat': lat,
    'lng': lng,
    'neighborhood': 'SoHo',
    'borough': 'Manhattan',
    'venueType': 'cafe',
    'attributes': <String, Object?>{},
    'vibeTags': <String>[],
    'workScore': workScore,
    'tier': 'researched',
  });
}

void main() {
  group('MapMarkerPlanner.plan', () {
    test('empty input stays empty', () {
      expect(MapMarkerPlanner.plan(const []), isEmpty);
    });

    test('fewer-than-limit input is unchanged', () {
      final venues = List.generate(
        10,
        (i) => _venue(id: 'spot-$i', lat: 40.7 + i, workScore: i),
      );

      expect(MapMarkerPlanner.plan(venues), same(venues));
    });

    test('input exactly at the limit is unchanged', () {
      final venues = List.generate(
        MapMarkerPlanner.markerLimit,
        (i) => _venue(id: 'spot-$i', lat: 40.7 + i, workScore: i),
      );

      expect(MapMarkerPlanner.plan(venues), same(venues));
    });

    test('city-scale input renders no more than the marker limit', () {
      final venues = List.generate(
        200,
        (i) => _venue(id: 'spot-$i', lat: 40.7 + i, workScore: i),
      );

      final plan = MapMarkerPlanner.plan(venues);

      expect(plan.length, MapMarkerPlanner.markerLimit);
    });

    test('over-limit input keeps the highest Work Fit venues', () {
      final venues = List.generate(
        200,
        (i) => _venue(id: 'spot-$i', lat: 40.7 + i, workScore: i),
      );

      final plan = MapMarkerPlanner.plan(venues);

      // Scores 199 down to 176 are the top 24.
      final expectedScores = List.generate(
        MapMarkerPlanner.markerLimit,
        (i) => 199 - i,
      );
      expect(plan.map((v) => v.workScore), expectedScores);
    });

    test('over-limit input avoids duplicate coordinates', () {
      final venues = [
        for (var i = 0; i < 30; i++)
          _venue(id: 'low-$i', lat: 40.7, lng: -74.0, workScore: 10 + i),
        _venue(id: 'best-at-shared-spot', lat: 40.7, lng: -74.0, workScore: 99),
      ];

      final plan = MapMarkerPlanner.plan(venues);

      final coordinates = plan.map((v) => '${v.lat},${v.lng}').toSet();
      expect(coordinates.length, plan.length);
      expect(plan.first.id, 'best-at-shared-spot');
    });

    test('ties break deterministically by id', () {
      // Zero-padded so string id order matches the intended pick order.
      final venues = [
        for (var i = 0; i < 30; i++)
          _venue(
            id: 'spot-${i.toString().padLeft(2, '0')}',
            lat: 40.7 + i,
            workScore: 50,
          ),
      ];

      final plan = MapMarkerPlanner.plan(venues);

      expect(
        plan.map((v) => v.id),
        List.generate(
          MapMarkerPlanner.markerLimit,
          (i) => 'spot-${i.toString().padLeft(2, '0')}',
        ),
      );
    });
  });
}
