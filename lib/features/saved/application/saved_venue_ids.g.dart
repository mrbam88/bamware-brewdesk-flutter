// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'saved_venue_ids.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(SavedVenueIds)
final savedVenueIdsProvider = SavedVenueIdsProvider._();

final class SavedVenueIdsProvider
    extends $NotifierProvider<SavedVenueIds, Set<String>> {
  SavedVenueIdsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'savedVenueIdsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$savedVenueIdsHash();

  @$internal
  @override
  SavedVenueIds create() => SavedVenueIds();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Set<String> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Set<String>>(value),
    );
  }
}

String _$savedVenueIdsHash() => r'ff7a4104bda51d9671605e800a469409312b35a1';

abstract class _$SavedVenueIds extends $Notifier<Set<String>> {
  Set<String> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<Set<String>, Set<String>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Set<String>, Set<String>>,
              Set<String>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
