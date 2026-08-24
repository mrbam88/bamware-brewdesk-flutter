import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'data/repositories/saved_venues_repository.dart';
import 'data/repositories/venue_repository.dart';
import 'data/services/location_service.dart';
import 'data/services/saved_venues_service.dart';
import 'data/services/venue_api.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final preferences = await SharedPreferences.getInstance();
  runApp(
    BrewDeskApp(
      venueRepository: VenueRepository(VenueApi()),
      savedVenues: SavedVenuesRepository(SavedVenuesService(preferences)),
      locationService: const LocationService(),
    ),
  );
}
