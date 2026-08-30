import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:brewdesk/core/location/location_service.dart';
import 'package:brewdesk/core/location/union_square_location_service.dart';

part 'location_mode.g.dart';

/// Which location source the visitor chose in the location intro step:
/// the real device GPS, or the fixed Union Square fallback that must never
/// trigger the OS permission prompt.
enum LocationMode { device, unionSquare }

// LEARN: a `Notifier` is Riverpod's home for SMALL client-side state with a
// mutation API — the Zustand-store role. Onboarding writes it once; anyone
// who `ref.watch`es it (or a provider derived from it) rebuilds on change.
// Not persisted, matching the pre-refactor behavior: after a restart the app
// falls back to `LocationMode.device` (see ARCHITECTURE_AUDIT.md — flagged,
// not silently "fixed", because changing it is a product decision).
@Riverpod(keepAlive: true)
class LocationModeController extends _$LocationModeController {
  @override
  LocationMode build() => LocationMode.device;

  void select(LocationMode mode) => state = mode;
}

// LEARN: a DERIVED provider — selectors/computed state in RN terms. Widgets
// depend on "the location service to use" without knowing the mode exists;
// when onboarding flips the mode, only watchers of THIS provider react.
// `ref.watch` inside a provider body composes providers the same way it
// composes widgets.
@Riverpod(keepAlive: true)
LocationService effectiveLocationService(Ref ref) =>
    switch (ref.watch(locationModeControllerProvider)) {
      LocationMode.device => ref.watch(locationServiceProvider),
      LocationMode.unionSquare => const UnionSquareLocationService(),
    };
