/// Persistence contract for the set of saved venue ids. The MVP backs this
/// with SharedPreferences (see data/saved_venues_service.dart); a future
/// account-synced backend would implement the same interface without the
/// application layer noticing.
abstract interface class SavedVenuesStore {
  Set<String> load();

  Future<void> save(Set<String> ids);
}
