import 'package:flutter/material.dart';

import 'package:brewdesk/core/widgets/glass_surface.dart';

import 'package:brewdesk/l10n/app_localizations.dart';
import 'package:brewdesk/features/discovery/presentation/discovery_screen.dart';
import 'package:brewdesk/features/profile/presentation/profile_screen.dart';
import 'package:brewdesk/features/saved/presentation/saved_screen.dart';

// LEARN: the selected tab stays plain setState on purpose. Ephemeral,
// single-widget UI state gains nothing from a provider or a Bloc — reaching
// for the heavy pattern everywhere is the Flutter equivalent of putting a
// text field's value in Redux.
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final screens = [
      const DiscoveryScreen(),
      SavedScreen(onBrowse: () => setState(() => _index = 0)),
      const ProfileScreen(),
    ];
    return Scaffold(
      // extendBody: the map/shelf run beneath the glass tab bar, matching
      // the iOS floating-bar-over-card look (brewdesk-flutter#30).
      extendBody: true,
      body: IndexedStack(index: _index, children: screens),
      bottomNavigationBar: GlassSurface(
        opacity: 0.6,
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
