import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:brewdesk/features/venues/domain/venue.dart';

part 'discovery_filters.freezed.dart';

/// Wi-Fi floor for the tri-state Wi-Fi filter. `ok` and `fast` mirror the
/// engine's `WIFI_ORDER` tiers; "Any" is represented by a null selection.
enum WifiLevel { ok, fast }

/// Outlets floor for the tri-state Outlets filter. Mirrors the engine's
/// `OUTLET_ORDER` tiers; "Any" is represented by a null selection.
enum OutletsLevel { some, plenty }

enum WorkVenueType { cafe, library, park }

/// Client-side filter predicate tiers (brewdesk#77 parity with iOS
/// `VenueFilter`): a value outside the known vocabulary — most commonly
/// "unknown" — is never evidence against a venue, so only claims that are
/// known AND known to sit below the chosen floor get excluded.
const Map<String, int> _wifiTiers = {'slow': 1, 'ok': 2, 'fast': 3};
const Map<String, int> _amountTiers = {'scarce': 1, 'some': 2, 'plenty': 3};

// LEARN: filters + query are CLIENT state — what the visitor is asking of
// data that already loaded — so they live apart from the server state that
// the flagship bloc owns. This is the TanStack-vs-Zustand split: never let
// UI preferences share a store with fetch lifecycles. The type is a freezed
// value + a pure apply() function, so the whole feature unit-tests without
// a single widget or provider.
@freezed
abstract class DiscoveryFilters with _$DiscoveryFilters {
  const DiscoveryFilters._();

  const factory DiscoveryFilters({
    @Default('') String query,
    @Default(false) bool laptopFriendly,
    WifiLevel? minWifi,
    OutletsLevel? minOutlets,
    WorkVenueType? venueType,
  }) = _DiscoveryFilters;

  /// Active count across the four dimensions the filter menu owns — drives
  /// both the filter button's badge and the "Reset N filters" row. The
  /// query is search, not a filter, and never counts.
  int get activeCount => [
    laptopFriendly,
    minWifi != null,
    minOutlets != null,
    venueType != null,
  ].where((active) => active).length;

  List<Venue> apply(List<Venue> venues) {
    final needle = query.trim().toLowerCase();
    return venues
        .where((venue) {
          if (needle.isNotEmpty &&
              !venue.name.toLowerCase().contains(needle) &&
              !venue.neighborhood.toLowerCase().contains(needle) &&
              !venue.vibeTags.any(
                (tag) => tag.toLowerCase().contains(needle),
              )) {
            return false;
          }
          if (laptopFriendly &&
              const {
                'discouraged',
                'weekends_banned',
              }.contains(venue.attributes.laptopPolicy.value)) {
            return false;
          }
          if (minWifi != null) {
            final tier = _wifiTiers[venue.attributes.wifi.value];
            if (tier != null && tier < _wifiTiers[minWifi!.name]!) {
              return false;
            }
          }
          if (minOutlets != null) {
            final tier = _amountTiers[venue.attributes.outlets.value];
            if (tier != null && tier < _amountTiers[minOutlets!.name]!) {
              return false;
            }
          }
          if (venueType != null && venue.venueType != venueType!.name) {
            return false;
          }
          return true;
        })
        .toList(growable: false);
  }
}
