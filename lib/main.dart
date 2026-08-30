import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:brewdesk/app.dart';
import 'package:brewdesk/core/di/app_providers.dart';
import 'package:brewdesk/core/observability/analytics.dart';
import 'package:brewdesk/core/observability/app_bloc_observer.dart';

// LEARN: main() used to hand-build the object graph (VenueRepository over
// VenueApi, SavedVenuesRepository over SharedPreferences) and thread it down
// four widget layers as constructor arguments. That wiring now lives in the
// providers next to each class; the only job left here is the one truly
// async pre-boot step — awaiting SharedPreferences — injected via override.
// ProviderScope is the Redux <Provider store=...> / React Context root: the
// place the whole graph is scoped, and the place tests swap it wholesale.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Every bloc transition in the app flows through this one observer —
  // see AppBlocObserver for why that's the point of the pattern.
  Bloc.observer = const AppBlocObserver(DebugAnalytics());
  final preferences = await SharedPreferences.getInstance();
  runApp(
    ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(preferences)],
      child: const BrewDeskApp(),
    ),
  );
}
