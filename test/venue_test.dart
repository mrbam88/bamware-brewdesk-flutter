import 'package:brewdesk/features/venues/data/venue_dtos.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('venue decodes the live contract and coverage fields', () {
    final venue = VenueDto.decode({
      'id': 'spot-1',
      'name': 'Library Hall',
      'lat': 40.7,
      'lng': -74.0,
      'neighborhood': 'SoHo',
      'borough': 'Manhattan',
      'venueType': 'library',
      'attributes': {
        'wifi': {'value': 'fast', 'source': 'agent'},
        'outlets': {'value': 'some', 'source': 'curated'},
        'laptopPolicy': {'value': 'unrestricted', 'source': 'curated'},
        'noise': {'value': 'quiet', 'source': 'curated'},
      },
      'vibeTags': ['quiet'],
      'workScore': 81,
      'tier': 'researched',
      'distance_m': 321,
    });

    expect(venue.typeLabel, 'Library');
    expect(venue.workScore, 81);
    expect(venue.attributes.wifi.sourceLabel, 'AI researched');
    expect(venue.distanceLabel, '321 m away');
    expect(venue.attributes.seating.value, 'unknown');
  });
}
