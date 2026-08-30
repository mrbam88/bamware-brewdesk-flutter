import 'package:json_annotation/json_annotation.dart';

import 'package:brewdesk/features/venues/domain/venue.dart';

part 'venue_dtos.g.dart';

// LEARN: DTOs are the anti-corruption layer between the engine's wire
// format and the domain model. Everything the old hand-rolled fromJson did
// leniently — missing fields, absent attributes, snake_case `distance_m`,
// fractional workScore, photo URLs that are relative to the API host —
// happens HERE, once, so the domain never sees a half-decoded object.
// RN analogy: the mapping you'd do in an API client / TanStack `select`
// before data reaches components, formalized as types.
//
// The engine contract (`bamware-venue-engine/src/schema.ts`) is owned
// cross-repo: these classes must decode what it actually sends, and
// test/venue_contract_parity_test.dart holds them to it. Do not "fix" a
// mismatch here without flagging it — see docs/contracts.md.

/// Wire shape of one attribute claim. Defaults mirror the engine's rule
/// that an omitted fact means "unknown", never an error.
@JsonSerializable(createToJson: false)
class ClaimDto {
  const ClaimDto({
    this.value = 'unknown',
    this.source = 'unknown',
    this.detail,
    this.observedAt,
    this.confidence = 0,
  });

  factory ClaimDto.fromJson(Map<String, dynamic> json) =>
      _$ClaimDtoFromJson(json);

  /// Tolerant entry point: any non-map payload (absent key, null, garbage)
  /// decodes to the all-defaults "unknown" claim — the pre-refactor
  /// contract behavior the parity test pins down.
  static Claim decode(Object? raw) =>
      ClaimDto.fromJson(
        raw is Map<String, dynamic> ? raw : const {},
      ).toDomain();

  final String value;
  final String source;
  final String? detail;
  final String? observedAt;
  final double confidence;

  Claim toDomain() => Claim(
    value: value,
    source: source,
    detail: detail,
    observedAt: observedAt,
    confidence: confidence,
  );
}

@JsonSerializable(createToJson: false)
class VenueAttributesDto {
  const VenueAttributesDto({
    this.wifi,
    this.outlets,
    this.laptopPolicy,
    this.noise,
    this.seating,
    this.outdoorSeating,
  });

  factory VenueAttributesDto.fromJson(Map<String, dynamic> json) =>
      _$VenueAttributesDtoFromJson(json);

  static VenueAttributes decode(Object? raw) =>
      VenueAttributesDto.fromJson(
        raw is Map<String, dynamic> ? raw : const {},
      ).toDomain();

  final ClaimDto? wifi;
  final ClaimDto? outlets;
  final ClaimDto? laptopPolicy;
  final ClaimDto? noise;
  final ClaimDto? seating;
  final ClaimDto? outdoorSeating;

  VenueAttributes toDomain() => VenueAttributes(
    wifi: wifi?.toDomain() ?? Claim.unknown,
    outlets: outlets?.toDomain() ?? Claim.unknown,
    laptopPolicy: laptopPolicy?.toDomain() ?? Claim.unknown,
    noise: noise?.toDomain() ?? Claim.unknown,
    seating: seating?.toDomain() ?? Claim.unknown,
    outdoorSeating: outdoorSeating?.toDomain() ?? Claim.unknown,
  );
}

@JsonSerializable(createToJson: false)
class VenueDto {
  const VenueDto({
    required this.id,
    required this.lat,
    required this.lng,
    this.name = 'Unnamed spot',
    this.neighborhood = '',
    this.borough = '',
    this.venueType = 'cafe',
    this.attributes,
    this.vibeTags = const [],
    this.workScore = 0,
    this.tier = 'researched',
    this.address,
    this.hoursRaw,
    this.distanceM,
    this.website,
    this.phone,
    this.lastVerified,
  });

  factory VenueDto.fromJson(Map<String, dynamic> json) =>
      _$VenueDtoFromJson(json);

  /// One-step decode for callers (and tests) that hold raw venue JSON.
  static Venue decode(Map<String, dynamic> json) =>
      VenueDto.fromJson(json).toDomain();

  final String id;
  final String name;
  final double lat;
  final double lng;
  final String neighborhood;
  final String borough;
  final String venueType;
  final VenueAttributesDto? attributes;
  final List<String> vibeTags;

  /// The engine may send a fractional score; the app rounds once, here.
  final num workScore;
  final String tier;
  final String? address;
  final String? hoursRaw;

  // LEARN: the one snake_case field in an otherwise camelCase contract —
  // the DTO absorbs the inconsistency so the domain doesn't carry it.
  @JsonKey(name: 'distance_m')
  final num? distanceM;
  final String? website;
  final String? phone;
  final String? lastVerified;

  Venue toDomain() => Venue(
    id: id,
    name: name,
    lat: lat,
    lng: lng,
    neighborhood: neighborhood,
    borough: borough,
    venueType: venueType,
    attributes: attributes?.toDomain() ?? const VenueAttributes(),
    vibeTags: vibeTags,
    workScore: workScore.round(),
    tier: tier,
    address: address,
    hoursRaw: hoursRaw,
    distanceM: distanceM?.round(),
    website: website,
    phone: phone,
    lastVerified: lastVerified,
  );
}

@JsonSerializable(createToJson: false)
class VenuePhotoDto {
  const VenuePhotoDto({required this.url, this.contributorName, this.attribution});

  factory VenuePhotoDto.fromJson(Map<String, dynamic> json) =>
      _$VenuePhotoDtoFromJson(json);

  final String url;
  final String? contributorName;
  final String? attribution;

  /// [baseUri] resolves relative photo paths against the API host — a
  /// wire-format concern the domain [VenuePhoto] never sees.
  VenuePhoto toDomain(Uri baseUri) => VenuePhoto(
    url: baseUri.resolve(url).toString(),
    attribution: contributorName ?? attribution,
  );
}

@JsonSerializable(createToJson: false)
class SearchMetaDto {
  const SearchMetaDto({this.coverage});

  factory SearchMetaDto.fromJson(Map<String, dynamic> json) =>
      _$SearchMetaDtoFromJson(json);

  final String? coverage;
}

/// Envelope of `POST /v1/venues/search` — and, conveniently, of the bundled
/// cold-start snapshot, which is a captured search response.
@JsonSerializable(createToJson: false)
class VenueSearchResponseDto {
  const VenueSearchResponseDto({this.venues = const [], this.meta});

  factory VenueSearchResponseDto.fromJson(Map<String, dynamic> json) =>
      _$VenueSearchResponseDtoFromJson(json);

  final List<VenueDto> venues;
  final SearchMetaDto? meta;

  VenueSearchResult toDomain() => VenueSearchResult(
    venues: venues.map((v) => v.toDomain()).toList(growable: false),
    // An unknown or absent coverage string reads as researched — the
    // pre-refactor fallback, pinned by the contract parity test.
    coverage: switch (meta?.coverage) {
      'baseline' => CoverageLevel.baseline,
      'none' => CoverageLevel.none,
      _ => CoverageLevel.researched,
    },
  );
}

/// Envelope of `GET /v1/venues/{id}`.
@JsonSerializable(createToJson: false)
class VenueEnvelopeDto {
  const VenueEnvelopeDto({required this.venue});

  factory VenueEnvelopeDto.fromJson(Map<String, dynamic> json) =>
      _$VenueEnvelopeDtoFromJson(json);

  final VenueDto venue;
}

/// Envelope of `GET /v1/venues/{id}/photos`.
@JsonSerializable(createToJson: false)
class PhotosResponseDto {
  const PhotosResponseDto({this.photos = const []});

  factory PhotosResponseDto.fromJson(Map<String, dynamic> json) =>
      _$PhotosResponseDtoFromJson(json);

  final List<VenuePhotoDto> photos;
}
