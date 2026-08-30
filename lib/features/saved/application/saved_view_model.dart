import 'package:flutter/foundation.dart';

import 'package:brewdesk/features/saved/data/saved_venues_repository.dart';
import 'package:brewdesk/features/venues/domain/venue_repository.dart';
import 'package:brewdesk/features/venues/domain/venue.dart';

class SavedViewModel extends ChangeNotifier {
  SavedViewModel(this._venueRepository, this._savedVenues) {
    _savedVenues.addListener(load);
  }

  final VenueRepository _venueRepository;
  final SavedVenuesRepository _savedVenues;
  List<Venue> _venues = const [];
  List<String> _failedIds = const [];
  bool _loading = false;
  int _generation = 0;

  List<Venue> get venues => List.unmodifiable(_venues);

  /// Saved ids that failed to hydrate this load (brewdesk#11): the rest of
  /// the list still renders, and the screen surfaces one row per failure
  /// instead of silently dropping it.
  List<String> get failedIds => List.unmodifiable(_failedIds);
  bool get loading => _loading;

  Future<void> load() async {
    final generation = ++_generation;
    final ids = _savedVenues.ids;
    if (ids.isEmpty) {
      _venues = const [];
      _failedIds = const [];
      _loading = false;
      notifyListeners();
      return;
    }

    _loading = true;
    notifyListeners();
    final venues = <Venue>[];
    final failedIds = <String>[];
    for (final id in ids) {
      try {
        venues.add(await _venueRepository.venue(id));
      } on Object {
        // Keep the rest of the list useful when one saved venue disappears;
        // the id is surfaced instead so the row is honest, not silent.
        failedIds.add(id);
      }
    }
    if (generation != _generation) return;
    _venues = venues;
    _failedIds = failedIds;
    _loading = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _savedVenues.removeListener(load);
    super.dispose();
  }
}
