import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:brewdesk/app.dart';
import 'package:brewdesk/core/di/app_providers.dart';

// LEARN: main() used to hand-build the object graph (VenueRepository over
// VenueApi, SavedVenuesRepository over SharedPreferences) and thread it down
// four widget layers as constructor arguments. That wiring now lives in the
// providers next to each class; the only job left here is the one truly
// async pre-boot step — awaiting SharedPreferences — injected via override.
// ProviderScope is the Redux <Provider store=...> / React Context root: the
// place the whole graph is scoped, and the place tests swap it wholesale.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final preferences = await SharedPreferences.getInstance();
  runApp(
    ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(preferences)],
      child: const BrewDeskApp(),
    ),
  );
}
