// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'location_mode.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(LocationModeController)
final locationModeControllerProvider = LocationModeControllerProvider._();

final class LocationModeControllerProvider
    extends $NotifierProvider<LocationModeController, LocationMode> {
  LocationModeControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'locationModeControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$locationModeControllerHash();

  @$internal
  @override
  LocationModeController create() => LocationModeController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LocationMode value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LocationMode>(value),
    );
  }
}

String _$locationModeControllerHash() =>
    r'1dde42676319ab7c95c46eecb92a04b3d7196e40';

abstract class _$LocationModeController extends $Notifier<LocationMode> {
  LocationMode build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<LocationMode, LocationMode>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<LocationMode, LocationMode>,
              LocationMode,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(effectiveLocationService)
final effectiveLocationServiceProvider = EffectiveLocationServiceProvider._();

final class EffectiveLocationServiceProvider
    extends
        $FunctionalProvider<LocationService, LocationService, LocationService>
    with $Provider<LocationService> {
  EffectiveLocationServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'effectiveLocationServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$effectiveLocationServiceHash();

  @$internal
  @override
  $ProviderElement<LocationService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  LocationService create(Ref ref) {
    return effectiveLocationService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LocationService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LocationService>(value),
    );
  }
}

String _$effectiveLocationServiceHash() =>
    r'06182ae49212b1d49442f5e51165b540378d11be';
