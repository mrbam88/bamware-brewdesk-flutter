// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'discovery_filters_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(DiscoveryFiltersController)
final discoveryFiltersControllerProvider =
    DiscoveryFiltersControllerProvider._();

final class DiscoveryFiltersControllerProvider
    extends $NotifierProvider<DiscoveryFiltersController, DiscoveryFilters> {
  DiscoveryFiltersControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'discoveryFiltersControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$discoveryFiltersControllerHash();

  @$internal
  @override
  DiscoveryFiltersController create() => DiscoveryFiltersController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DiscoveryFilters value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DiscoveryFilters>(value),
    );
  }
}

String _$discoveryFiltersControllerHash() =>
    r'f577b44b4e1d1e04c9a9de587718bda0ec466c12';

abstract class _$DiscoveryFiltersController
    extends $Notifier<DiscoveryFilters> {
  DiscoveryFilters build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<DiscoveryFilters, DiscoveryFilters>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<DiscoveryFilters, DiscoveryFilters>,
              DiscoveryFilters,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
