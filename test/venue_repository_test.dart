import 'package:brewdesk/data/repositories/venue_repository.dart';
import 'package:brewdesk/data/services/venue_api.dart';
import 'package:brewdesk/domain/models/venue.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  test('repository maps the privacy-safe search response', () async {
    final client = MockClient((request) async {
      expect(request.method, 'POST');
      expect(request.url.path, '/v1/venues/search');
      return http.Response('''
        {
          "count": 1,
          "meta": {"coverage": "baseline"},
          "venues": [{
            "id": "spot-1",
            "name": "Work Park",
            "lat": 40.7,
            "lng": -74.0,
            "neighborhood": "Downtown",
            "borough": "Manhattan",
            "venueType": "park",
            "attributes": {
              "wifi": {"value": "unknown", "source": "osm"},
              "outlets": {"value": "unknown", "source": "osm"},
              "laptopPolicy": {"value": "unknown", "source": "osm"},
              "noise": {"value": "unknown", "source": "osm"}
            },
            "vibeTags": [],
            "workScore": 55,
            "tier": "osm-baseline"
          }]
        }
      ''', 200);
    });
    final repository = VenueRepository(
      VenueApi(client: client, baseUri: Uri.parse('https://example.test')),
    );

    final result = await repository.search(lat: 40.7, lng: -74.0);

    expect(result.coverage, CoverageLevel.baseline);
    expect(result.venues.single.name, 'Work Park');
    expect(result.venues.single.tier, 'osm-baseline');
  });
}
