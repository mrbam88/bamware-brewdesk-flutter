import 'package:flutter/foundation.dart';

import '../../../data/repositories/saved_venues_repository.dart';
import '../../../data/repositories/venue_repository.dart';
import '../../../domain/models/venue.dart';

class SavedViewModel extends ChangeNotifier {
  SavedViewModel(this._venueRepository, this._savedVenues) {
    _savedVenues.addListener(load);
  }

  final VenueRepository _venueRepository;
  final SavedVenuesRepository _savedVenues;
  List<Venue> _venues = const [];
  bool _loading = false;
  int _generation = 0;

  List<Venue> get venues => List.unmodifiable(_venues);
  bool get loading => _loading;

  Future<void> load() async {
    final generation = ++_generation;
    final ids = _savedVenues.ids;
    if (ids.isEmpty) {
      _venues = const [];
      _loading = false;
      notifyListeners();
      return;
    }

    _loading = true;
    notifyListeners();
    final venues = <Venue>[];
    for (final id in ids) {
      try {
        venues.add(await _venueRepository.venue(id));
      } on Object {
        // Keep the rest of the list useful when one saved venue disappears.
      }
    }
    if (generation != _generation) return;
    _venues = venues;
    _loading = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _savedVenues.removeListener(load);
    super.dispose();
  }
}
