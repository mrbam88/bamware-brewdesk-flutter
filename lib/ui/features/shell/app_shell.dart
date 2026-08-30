import 'package:flutter/material.dart';

import '../../core/glass_surface.dart';

import '../../../data/repositories/saved_venues_repository.dart';
import '../../../data/repositories/venue_repository.dart';
import '../../../data/services/location_service.dart';
import '../../../l10n/app_localizations.dart';
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
    final l10n = AppLocalizations.of(context)!;
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
      // extendBody: the map/shelf run beneath the glass tab bar, matching
      // the iOS floating-bar-over-card look (brewdesk-flutter#30).
      extendBody: true,
      body: IndexedStack(index: _index, children: screens),
      bottomNavigationBar: GlassSurface(
        opacity: 0.78,
        child: NavigationBar(
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          selectedIndex: _index,
          onDestinationSelected: (value) => setState(() => _index = value),
          destinations: [
            NavigationDestination(
              icon: const Icon(Icons.explore_outlined),
              selectedIcon: const Icon(Icons.explore_rounded),
              label: l10n.navSpots,
            ),
            NavigationDestination(
              icon: const Icon(Icons.bookmark_border_rounded),
              selectedIcon: const Icon(Icons.bookmark_rounded),
              label: l10n.navSaved,
            ),
            NavigationDestination(
              icon: const Icon(Icons.person_outline_rounded),
              selectedIcon: const Icon(Icons.person_rounded),
              label: l10n.navYou,
            ),
          ],
        ),
      ),
    );
  }
}
