import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:brewdesk/core/di/app_providers.dart';
import 'package:brewdesk/features/saved/domain/saved_venues_store.dart';

part 'saved_venues_service.g.dart';

@Riverpod(keepAlive: true)
SavedVenuesStore savedVenuesStore(Ref ref) =>
    SavedVenuesService(ref.watch(sharedPreferencesProvider));

class SavedVenuesService implements SavedVenuesStore {
  const SavedVenuesService(this._preferences);

  static const _key = 'brewdesk.savedVenueIds';
  final SharedPreferences _preferences;

  @override
  Set<String> load() =>
      _preferences.getStringList(_key)?.toSet() ?? <String>{};

  @override
  Future<void> save(Set<String> ids) =>
      _preferences.setStringList(_key, ids.toList(growable: false));
}
