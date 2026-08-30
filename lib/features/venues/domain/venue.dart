import 'package:freezed_annotation/freezed_annotation.dart';

part 'venue.freezed.dart';

// LEARN: the domain model is now freezed — immutable, with VALUE equality
// and copyWith generated. Value equality is not cosmetic: the Bloc/Riverpod
// layers decide "did state change?" by ==, so two Venue instances decoded
// from identical JSON must compare equal or every rebuild optimization
// breaks. RN analogy: what Immer/Redux Toolkit give a reducer, plus the
// deep-equality you wish React.memo had by default.
//
// Deliberately NO fromJson here. The domain layer doesn't know JSON exists;
// decoding (and the engine's lenient-contract rules) lives in the data
// layer's DTOs — see data/venue_dtos.dart. Domain has no Flutter imports
// either, so all of this is testable as plain Dart.

/// One venue fact with provenance: what the engine believes, where that
/// belief came from, and how confident it is. Unknown and estimated facts
/// must stay visibly honest (CONTEXT.md).
@freezed
abstract class Claim with _$Claim {
  const Claim._();

  const factory Claim({
    required String value,
    required String source,
    String? detail,
    String? observedAt,
    @Default(0) double confidence,
  }) = _Claim;

  /// The all-defaults claim a payload produces when it omits the attribute
  /// entirely — "we know nothing, and we say so".
  static const unknown = Claim(value: 'unknown', source: 'unknown');

  int get confidencePercent => (confidence * 100).round();

  /// `observedAt` truncated to a plain date (`yyyy-MM-dd`), or empty when
  /// the claim carries no observation date.
  String get dateKey {
    final raw = observedAt;
    if (raw == null || raw.length < 10) return raw ?? '';
    return raw.substring(0, 10);
  }

  /// Whether [other] shares this claim's source, confidence and date — the
  /// brewdesk#119 rule for whether a claim needs its own provenance line
  /// alongside a card-level stamp.
  bool matchesProvenance(Claim other) =>
      source == other.source &&
      confidencePercent == other.confidencePercent &&
      dateKey == other.dateKey;

  /// "Source · N% confidence · updated `<date>`" — shared by the Workability
  /// card's single stamp and any per-row line for a claim that disagrees
  /// with it (brewdesk#119).
  String get provenanceLine =>
      '$sourceLabel · $confidencePercent% confidence · '
      'updated ${dateKey.isEmpty ? 'an unknown date' : dateKey}';

  String get displayValue => value
      .replaceAll('_', ' ')
      .split(' ')
      .map(
        (word) => word.isEmpty
            ? word
            : '${word[0].toUpperCase()}${word.substring(1)}',
      )
      .join(' ');

  String get sourceLabel => switch (source) {
    'curated' => 'Curated',
    'osm' => 'OpenStreetMap',
    'estimate' => 'Unverified estimate',
    'speed_test' => 'Measured in app',
    'user_report' => 'Community report',
    'field_visit' || 'site_visit' => 'Field observed',
    'owner' => 'Owner reported',
    'agent' => 'AI researched',
    _ => source,
  };
}

@freezed
abstract class VenueAttributes with _$VenueAttributes {
  const VenueAttributes._();

  const factory VenueAttributes({
    @Default(Claim.unknown) Claim wifi,
    @Default(Claim.unknown) Claim outlets,
    @Default(Claim.unknown) Claim laptopPolicy,
    @Default(Claim.unknown) Claim noise,
    @Default(Claim.unknown) Claim seating,
    @Default(Claim.unknown) Claim outdoorSeating,
  }) = _VenueAttributes;

  /// The Workability card's single provenance stamp (brewdesk#119): the
  /// claim (source, confidence, date) shared by the most of wifi / outlets /
  /// laptopPolicy / noise. Ties break toward Wi-Fi's row order, the same
  /// order those rows render in. A row whose own claim doesn't match this
  /// stamp prints its own provenance line instead of staying quiet.
  Claim get workabilityCardStamp {
    final claims = [wifi, outlets, laptopPolicy, noise];
    final counts = <int, int>{};
    for (var i = 0; i < claims.length; i++) {
      for (var j = 0; j < claims.length; j++) {
        if (claims[j].matchesProvenance(claims[i])) {
          counts[i] = (counts[i] ?? 0) + 1;
        }
      }
    }
    var bestIndex = 0;
    var bestCount = 0;
    for (var i = 0; i < claims.length; i++) {
      final count = counts[i] ?? 0;
      if (count > bestCount) {
        bestCount = count;
        bestIndex = i;
      }
    }
    return claims[bestIndex];
  }
}

// NOTE: makeCollectionsUnmodifiable is off because freezed 3.2.3 emits a
// `final` constructor parameter for wrapped collections, which Dart 3.13
// rejects (fixed in freezed 4, blocked here by custom_lint's analyzer
// ceiling — see the deps commit). The lists passed in are already built
// with toList(growable: false).
@Freezed(makeCollectionsUnmodifiable: false)
abstract class Venue with _$Venue {
  const Venue._();

  const factory Venue({
    required String id,
    required String name,
    required double lat,
    required double lng,
    required String neighborhood,
    required String borough,
    required String venueType,
    required VenueAttributes attributes,
    required List<String> vibeTags,
    required int workScore,
    required String tier,
    String? address,
    String? hoursRaw,
    int? distanceM,
    String? website,
    String? phone,
    String? lastVerified,
  }) = _Venue;

  String get typeLabel => switch (venueType) {
    'cafe' => 'Cafe',
    'park' => 'Park',
    'library' => 'Library',
    'mall' => 'Mall',
    _ => 'Work spot',
  };

  String get distanceLabel {
    final meters = distanceM;
    if (meters == null) return neighborhood;
    if (meters < 1000) return '$meters m away';
    return '${(meters / 1609.344).toStringAsFixed(1)} mi away';
  }
}

@freezed
abstract class VenuePhoto with _$VenuePhoto {
  const factory VenuePhoto({required String url, String? attribution}) =
      _VenuePhoto;
}

enum CoverageLevel { researched, baseline, none }

@Freezed(makeCollectionsUnmodifiable: false)
abstract class VenueSearchResult with _$VenueSearchResult {
  const factory VenueSearchResult({
    required List<Venue> venues,
    required CoverageLevel coverage,
  }) = _VenueSearchResult;
}
