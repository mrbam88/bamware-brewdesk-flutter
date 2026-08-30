// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'venue_detail_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(VenueDetailController)
final venueDetailControllerProvider = VenueDetailControllerFamily._();

final class VenueDetailControllerProvider
    extends $AsyncNotifierProvider<VenueDetailController, VenueDetail> {
  VenueDetailControllerProvider._({
    required VenueDetailControllerFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'venueDetailControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$venueDetailControllerHash();

  @override
  String toString() {
    return r'venueDetailControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  VenueDetailController create() => VenueDetailController();

  @override
  bool operator ==(Object other) {
    return other is VenueDetailControllerProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$venueDetailControllerHash() =>
    r'9ded289bf1a4164304109a8b6c72bdf321bd2025';

final class VenueDetailControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          VenueDetailController,
          AsyncValue<VenueDetail>,
          VenueDetail,
          FutureOr<VenueDetail>,
          String
        > {
  VenueDetailControllerFamily._()
    : super(
        retry: null,
        name: r'venueDetailControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  VenueDetailControllerProvider call(String venueId) =>
      VenueDetailControllerProvider._(argument: venueId, from: this);

  @override
  String toString() => r'venueDetailControllerProvider';
}

abstract class _$VenueDetailController extends $AsyncNotifier<VenueDetail> {
  late final _$args = ref.$arg as String;
  String get venueId => _$args;

  FutureOr<VenueDetail> build(String venueId);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<VenueDetail>, VenueDetail>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<VenueDetail>, VenueDetail>,
              AsyncValue<VenueDetail>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}
