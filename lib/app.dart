import 'package:flutter/material.dart';

import 'package:brewdesk/features/saved/data/saved_venues_repository.dart';
import 'package:brewdesk/features/venues/data/venue_repository.dart';
import 'package:brewdesk/core/location/location_service.dart';
import 'package:brewdesk/l10n/app_localizations.dart';
import 'package:brewdesk/core/theme/app_theme.dart';
import 'package:brewdesk/features/onboarding/presentation/onboarding_gate.dart';
import 'package:brewdesk/features/shell/presentation/app_shell.dart';

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
