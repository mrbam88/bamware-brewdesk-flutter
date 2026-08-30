// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'saved_venues_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(savedVenuesStore)
final savedVenuesStoreProvider = SavedVenuesStoreProvider._();

final class SavedVenuesStoreProvider
    extends
        $FunctionalProvider<
          SavedVenuesStore,
          SavedVenuesStore,
          SavedVenuesStore
        >
    with $Provider<SavedVenuesStore> {
  SavedVenuesStoreProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'savedVenuesStoreProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$savedVenuesStoreHash();

  @$internal
  @override
  $ProviderElement<SavedVenuesStore> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SavedVenuesStore create(Ref ref) {
    return savedVenuesStore(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SavedVenuesStore value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SavedVenuesStore>(value),
    );
  }
}

String _$savedVenuesStoreHash() => r'ba3982eb6903513e15c0161f728e3277c337c8da';
