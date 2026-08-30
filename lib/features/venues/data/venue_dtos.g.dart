// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'venue_dtos.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ClaimDto _$ClaimDtoFromJson(Map<String, dynamic> json) => ClaimDto(
  value: json['value'] as String? ?? 'unknown',
  source: json['source'] as String? ?? 'unknown',
  detail: json['detail'] as String?,
  observedAt: json['observedAt'] as String?,
  confidence: (json['confidence'] as num?)?.toDouble() ?? 0,
);

VenueAttributesDto _$VenueAttributesDtoFromJson(Map<String, dynamic> json) =>
    VenueAttributesDto(
      wifi: json['wifi'] == null
          ? null
          : ClaimDto.fromJson(json['wifi'] as Map<String, dynamic>),
      outlets: json['outlets'] == null
          ? null
          : ClaimDto.fromJson(json['outlets'] as Map<String, dynamic>),
      laptopPolicy: json['laptopPolicy'] == null
          ? null
          : ClaimDto.fromJson(json['laptopPolicy'] as Map<String, dynamic>),
      noise: json['noise'] == null
          ? null
          : ClaimDto.fromJson(json['noise'] as Map<String, dynamic>),
      seating: json['seating'] == null
          ? null
          : ClaimDto.fromJson(json['seating'] as Map<String, dynamic>),
      outdoorSeating: json['outdoorSeating'] == null
          ? null
          : ClaimDto.fromJson(json['outdoorSeating'] as Map<String, dynamic>),
    );

VenueDto _$VenueDtoFromJson(Map<String, dynamic> json) => VenueDto(
  id: json['id'] as String,
  lat: (json['lat'] as num).toDouble(),
  lng: (json['lng'] as num).toDouble(),
  name: json['name'] as String? ?? 'Unnamed spot',
  neighborhood: json['neighborhood'] as String? ?? '',
  borough: json['borough'] as String? ?? '',
  venueType: json['venueType'] as String? ?? 'cafe',
  attributes: json['attributes'] == null
      ? null
      : VenueAttributesDto.fromJson(json['attributes'] as Map<String, dynamic>),
  vibeTags:
      (json['vibeTags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  workScore: json['workScore'] as num? ?? 0,
  tier: json['tier'] as String? ?? 'researched',
  address: json['address'] as String?,
  hoursRaw: json['hoursRaw'] as String?,
  distanceM: json['distance_m'] as num?,
  website: json['website'] as String?,
  phone: json['phone'] as String?,
  lastVerified: json['lastVerified'] as String?,
);

VenuePhotoDto _$VenuePhotoDtoFromJson(Map<String, dynamic> json) =>
    VenuePhotoDto(
      url: json['url'] as String,
      contributorName: json['contributorName'] as String?,
      attribution: json['attribution'] as String?,
    );

SearchMetaDto _$SearchMetaDtoFromJson(Map<String, dynamic> json) =>
    SearchMetaDto(coverage: json['coverage'] as String?);

VenueSearchResponseDto _$VenueSearchResponseDtoFromJson(
  Map<String, dynamic> json,
) => VenueSearchResponseDto(
  venues:
      (json['venues'] as List<dynamic>?)
          ?.map((e) => VenueDto.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  meta: json['meta'] == null
      ? null
      : SearchMetaDto.fromJson(json['meta'] as Map<String, dynamic>),
);

VenueEnvelopeDto _$VenueEnvelopeDtoFromJson(Map<String, dynamic> json) =>
    VenueEnvelopeDto(
      venue: VenueDto.fromJson(json['venue'] as Map<String, dynamic>),
    );

PhotosResponseDto _$PhotosResponseDtoFromJson(Map<String, dynamic> json) =>
    PhotosResponseDto(
      photos:
          (json['photos'] as List<dynamic>?)
              ?.map((e) => VenuePhotoDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );
