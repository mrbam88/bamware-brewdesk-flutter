import 'package:flutter/material.dart';

import '../../../data/repositories/saved_venues_repository.dart';
import '../../../data/repositories/venue_repository.dart';
import '../../../data/services/location_service.dart';
import '../discovery/discovery_screen.dart';
import '../profile/profile_screen.dart';
import '../saved/saved_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({
    super.key,
    required this.venueRepository,
    required this.savedVenues,
    required this.locationService,
  });

  final VenueRepository venueRepository;
  final SavedVenuesRepository savedVenues;
  final LocationService locationService;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final screens = [
      DiscoveryScreen(
        venueRepository: widget.venueRepository,
        savedVenues: widget.savedVenues,
        locationService: widget.locationService,
      ),
      SavedScreen(
        venueRepository: widget.venueRepository,
        savedVenues: widget.savedVenues,
        onBrowse: () => setState(() => _index = 0),
      ),
      const ProfileScreen(),
    ];
    return Scaffold(
      body: IndexedStack(index: _index, children: screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (value) => setState(() => _index = value),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.explore_outlined),
            selectedIcon: Icon(Icons.explore_rounded),
            label: 'Spots',
          ),
          NavigationDestination(
            icon: Icon(Icons.bookmark_border_rounded),
            selectedIcon: Icon(Icons.bookmark_rounded),
            label: 'Saved',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'You',
          ),
        ],
      ),
    );
  }
}
