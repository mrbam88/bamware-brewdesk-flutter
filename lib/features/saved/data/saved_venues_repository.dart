import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:brewdesk/core/di/app_providers.dart';
import 'package:brewdesk/features/saved/data/saved_venues_service.dart';

part 'saved_venues_repository.g.dart';

@Riverpod(keepAlive: true)
SavedVenuesRepository savedVenuesRepository(Ref ref) => SavedVenuesRepository(
  SavedVenuesService(ref.watch(sharedPreferencesProvider)),
);

class SavedVenuesRepository extends ChangeNotifier {
  SavedVenuesRepository(this._service) : _ids = _service.load();

  final SavedVenuesService _service;
  final Set<String> _ids;

  Set<String> get ids => Set.unmodifiable(_ids);

  bool contains(String id) => _ids.contains(id);

  Future<void> toggle(String id) async {
    if (!_ids.add(id)) _ids.remove(id);
    await _service.save(_ids);
    notifyListeners();
  }
}
