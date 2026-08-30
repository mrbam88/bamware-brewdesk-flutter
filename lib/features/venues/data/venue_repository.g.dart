// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'venue_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(venueRepository)
final venueRepositoryProvider = VenueRepositoryProvider._();

final class VenueRepositoryProvider
    extends
        $FunctionalProvider<VenueRepository, VenueRepository, VenueRepository>
    with $Provider<VenueRepository> {
  VenueRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'venueRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$venueRepositoryHash();

  @$internal
  @override
  $ProviderElement<VenueRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  VenueRepository create(Ref ref) {
    return venueRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(VenueRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<VenueRepository>(value),
    );
  }
}

String _$venueRepositoryHash() => r'4a32074f0bf357cd309d17e3365bbfee950d1573';
