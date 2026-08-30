import 'package:flutter/foundation.dart';

import 'package:brewdesk/features/venues/domain/venue_repository.dart';
import 'package:brewdesk/features/venues/domain/venue.dart';

class VenueDetailViewModel extends ChangeNotifier {
  VenueDetailViewModel(Venue initialVenue, this._venueRepository)
    : _venue = initialVenue;

  final VenueRepository _venueRepository;
  Venue _venue;
  List<VenuePhoto> _photos = const [];

  Venue get venue => _venue;
  List<VenuePhoto> get photos => List.unmodifiable(_photos);

  Future<void> load() async {
    try {
      final results = await Future.wait<Object>([
        _venueRepository.venue(_venue.id, refresh: true),
        _venueRepository.photos(_venue.id),
      ]);
      _venue = results[0] as Venue;
      _photos = results[1] as List<VenuePhoto>;
      notifyListeners();
    } on Object {
      // The list payload already supports a complete fallback detail screen.
    }
  }
}
