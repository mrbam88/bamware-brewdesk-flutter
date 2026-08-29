import 'package:flutter/material.dart';

import 'data/repositories/saved_venues_repository.dart';
import 'data/repositories/venue_repository.dart';
import 'data/services/location_service.dart';
import 'l10n/app_localizations.dart';
import 'ui/core/app_theme.dart';
import 'ui/features/onboarding/onboarding_gate.dart';
import 'ui/features/shell/app_shell.dart';

class BrewDeskApp extends StatelessWidget {
  const BrewDeskApp({
    super.key,
    required this.venueRepository,
    required this.savedVenues,
    required this.locationService,
  });

  final VenueRepository venueRepository;
  final SavedVenuesRepository savedVenues;
  final LocationService locationService;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BrewDesk',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: OnboardingGate(
        locationService: locationService,
        builder: (context, resolvedLocationService) => AppShell(
          venueRepository: venueRepository,
          savedVenues: savedVenues,
          locationService: resolvedLocationService,
        ),
      ),
    );
  }
}
