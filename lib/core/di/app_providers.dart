import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'app_providers.g.dart';

// LEARN: SharedPreferences needs an async init (`getInstance`), but widgets
// want it synchronously. The standard Riverpod move: declare a provider that
// THROWS, await the instance once in main(), and hand it to the ProviderScope
// via `overrideWithValue`. Everything downstream reads it as plain sync state.
// RN analogy: awaiting your storage/config before ReactDOM/AppRegistry mounts,
// then passing it through a Context.Provider value — except here the graph is
// typed and the "forgot to provide it" failure is loud and immediate.
//
// Before this existed, `SharedPreferences.getInstance()` was called twice
// (main.dart AND OnboardingGate), giving onboarding a hidden async dependency
// and a spinner frame. One instance, one owner, injected everywhere.
@Riverpod(keepAlive: true)
SharedPreferences sharedPreferences(Ref ref) => throw UnimplementedError(
  'sharedPreferencesProvider must be overridden in main.dart before runApp.',
);
