// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'venue_api.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(venueApi)
final venueApiProvider = VenueApiProvider._();

final class VenueApiProvider
    extends $FunctionalProvider<VenueApi, VenueApi, VenueApi>
    with $Provider<VenueApi> {
  VenueApiProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'venueApiProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$venueApiHash();

  @$internal
  @override
  $ProviderElement<VenueApi> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  VenueApi create(Ref ref) {
    return venueApi(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(VenueApi value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<VenueApi>(value),
    );
  }
}

String _$venueApiHash() => r'784606a68d57a2a13f1362db539d0ddf8dbacadb';
