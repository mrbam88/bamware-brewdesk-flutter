// Regression test for the location-intro flow's "Use my location, but the
// OS prompt gets declined" path (brewdesk#10). The onboarding flow itself
// never fetches a location — it hands the real device LocationService
// through to DiscoveryViewModel unchanged, so a decline (currentLocation()
// resolving to null) must still leave the map populated via the existing
// Manhattan fallback. This exercises the production DiscoveryViewModel
// directly; it does not modify anything under lib/ui/features/discovery/.

import 'package:brewdesk/data/repositories/venue_repository.dart';
import 'package:brewdesk/data/services/location_service.dart';
import 'package:brewdesk/data/services/venue_api.dart';
import 'package:brewdesk/ui/features/discovery/discovery_view_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:latlong2/latlong.dart';

class _DeniedLocationService extends LocationService {
  const _DeniedLocationService();

  @override
  Future<LatLng?> currentLocation() async => null;
}

const _searchResponse = '''
{
  "count": 1,
  "meta": {"coverage": "baseline"},
  "venues": [{
    "id": "spot-1",
    "name": "Union Hall",
    "lat": 40.7,
    "lng": -74.0,
    "neighborhood": "Union Square",
    "borough": "Manhattan",
    "venueType": "cafe",
    "attributes": {
      "wifi": {"value": "unknown", "source": "osm"},
      "outlets": {"value": "unknown", "source": "osm"},
      "laptopPolicy": {"value": "unknown", "source": "osm"},
      "noise": {"value": "unknown", "source": "osm"}
    },
    "vibeTags": [],
    "workScore": 60,
    "tier": "osm-baseline"
  }]
}
''';

void main() {
  test('declining the OS location prompt still lands on a populated map '
      'via the Manhattan fallback', () async {
    final repository = VenueRepository(
      VenueApi(
        client: MockClient((_) async => http.Response(_searchResponse, 200)),
        baseUri: Uri.parse('https://example.test'),
      ),
    );
    final model = DiscoveryViewModel(
      repository,
      const _DeniedLocationService(),
    );

    await model.load();

    expect(model.error, isNull);
    expect(model.center, DiscoveryViewModel.manhattan);
    expect(model.visibleVenues, isNotEmpty);
  });
}
