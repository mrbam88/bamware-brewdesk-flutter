import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:brewdesk/app.dart';
import 'package:brewdesk/features/saved/data/saved_venues_repository.dart';
import 'package:brewdesk/features/venues/data/venue_repository.dart';
import 'package:brewdesk/core/location/location_service.dart';
import 'package:brewdesk/features/saved/data/saved_venues_service.dart';
import 'package:brewdesk/features/venues/data/venue_api.dart';

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
