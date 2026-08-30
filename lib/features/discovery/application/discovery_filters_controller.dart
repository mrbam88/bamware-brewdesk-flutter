import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:brewdesk/features/discovery/domain/discovery_filters.dart';

part 'discovery_filters_controller.g.dart';

// LEARN: the "not everything needs the heavy pattern" exhibit. Filters are
// a value plus five mutators — a plain Notifier carries that with zero
// ceremony, while the fetch lifecycle next door justifies a full Bloc.
// Every mutator REPLACES state via copyWith; with a freezed value type
// there is no way to mutate in place and silently skip notification.
// RN analogy: a small Zustand store of UI preferences.
@riverpod
class DiscoveryFiltersController extends _$DiscoveryFiltersController {
  @override
  DiscoveryFilters build() => const DiscoveryFilters();

  void setQuery(String value) => state = state.copyWith(query: value);

  void setLaptopFriendly(bool value) =>
      state = state.copyWith(laptopFriendly: value);

  void setMinWifi(WifiLevel? value) => state = state.copyWith(minWifi: value);

  void setMinOutlets(OutletsLevel? value) =>
      state = state.copyWith(minOutlets: value);

  void setVenueType(WorkVenueType? value) =>
      state = state.copyWith(venueType: value);

  /// Clears the four filter dimensions; the search query is separate state
  /// with its own clear affordance (the search field's Cancel).
  void resetFilters() => state = DiscoveryFilters(query: state.query);
}
