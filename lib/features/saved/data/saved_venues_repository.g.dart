// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'saved_venues_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(savedVenuesRepository)
final savedVenuesRepositoryProvider = SavedVenuesRepositoryProvider._();

final class SavedVenuesRepositoryProvider
    extends
        $FunctionalProvider<
          SavedVenuesRepository,
          SavedVenuesRepository,
          SavedVenuesRepository
        >
    with $Provider<SavedVenuesRepository> {
  SavedVenuesRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'savedVenuesRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$savedVenuesRepositoryHash();

  @$internal
  @override
  $ProviderElement<SavedVenuesRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SavedVenuesRepository create(Ref ref) {
    return savedVenuesRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SavedVenuesRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SavedVenuesRepository>(value),
    );
  }
}

String _$savedVenuesRepositoryHash() =>
    r'21e13f6fd9510ad187721f9d152eba8e6a3d719f';
