import 'package:shared_preferences/shared_preferences.dart';

class SavedVenuesService {
  const SavedVenuesService(this._preferences);

  static const _key = 'brewdesk.savedVenueIds';
  final SharedPreferences _preferences;

  Set<String> load() => _preferences.getStringList(_key)?.toSet() ?? <String>{};

  Future<void> save(Set<String> ids) =>
      _preferences.setStringList(_key, ids.toList(growable: false));
}
