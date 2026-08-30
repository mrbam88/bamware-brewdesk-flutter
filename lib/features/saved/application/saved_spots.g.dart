// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'saved_spots.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(SavedSpotsController)
final savedSpotsControllerProvider = SavedSpotsControllerProvider._();

final class SavedSpotsControllerProvider
    extends $AsyncNotifierProvider<SavedSpotsController, SavedSpots> {
  SavedSpotsControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'savedSpotsControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$savedSpotsControllerHash();

  @$internal
  @override
  SavedSpotsController create() => SavedSpotsController();
}

String _$savedSpotsControllerHash() =>
    r'05785144e929e79aecd28b5c521af63baa556fa2';

abstract class _$SavedSpotsController extends $AsyncNotifier<SavedSpots> {
  FutureOr<SavedSpots> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<SavedSpots>, SavedSpots>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<SavedSpots>, SavedSpots>,
              AsyncValue<SavedSpots>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
