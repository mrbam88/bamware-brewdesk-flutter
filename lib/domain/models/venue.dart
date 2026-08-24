class Claim {
  const Claim({
    required this.value,
    required this.source,
    this.detail,
    this.observedAt,
  });

  final String value;
  final String source;
  final String? detail;
  final String? observedAt;

  factory Claim.fromJson(Object? raw) {
    final json = raw is Map<String, dynamic> ? raw : <String, dynamic>{};
    return Claim(
      value: json['value'] as String? ?? 'unknown',
      source: json['source'] as String? ?? 'unknown',
      detail: json['detail'] as String?,
      observedAt: json['observedAt'] as String?,
    );
  }

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
    'osm' => 'OpenStreetMap',
    'estimate' => 'Unverified estimate',
    'speed_test' => 'Measured in app',
    'user_report' => 'Community report',
    'field_visit' || 'site_visit' => 'Field observed',
    'agent' => 'AI researched',
    _ => source,
  };
}

class VenueAttributes {
  const VenueAttributes({
    required this.wifi,
    required this.outlets,
    required this.laptopPolicy,
    required this.noise,
    required this.seating,
    required this.outdoorSeating,
  });

  final Claim wifi;
  final Claim outlets;
  final Claim laptopPolicy;
  final Claim noise;
  final Claim seating;
  final Claim outdoorSeating;

  factory VenueAttributes.fromJson(Object? raw) {
    final json = raw is Map<String, dynamic> ? raw : <String, dynamic>{};
    return VenueAttributes(
      wifi: Claim.fromJson(json['wifi']),
      outlets: Claim.fromJson(json['outlets']),
      laptopPolicy: Claim.fromJson(json['laptopPolicy']),
      noise: Claim.fromJson(json['noise']),
      seating: Claim.fromJson(json['seating']),
      outdoorSeating: Claim.fromJson(json['outdoorSeating']),
    );
  }
}

class Venue {
  const Venue({
    required this.id,
    required this.name,
    required this.lat,
    required this.lng,
    required this.neighborhood,
    required this.borough,
    required this.venueType,
    required this.attributes,
    required this.vibeTags,
    required this.workScore,
    required this.tier,
    this.address,
    this.hoursRaw,
    this.distanceM,
    this.website,
    this.phone,
    this.lastVerified,
  });

  final String id;
  final String name;
  final double lat;
  final double lng;
  final String? address;
  final String neighborhood;
  final String borough;
  final String? hoursRaw;
  final String venueType;
  final VenueAttributes attributes;
  final List<String> vibeTags;
  final int workScore;
  final int? distanceM;
  final String tier;
  final String? website;
  final String? phone;
  final String? lastVerified;

  factory Venue.fromJson(Map<String, dynamic> json) {
    return Venue(
      id: json['id'] as String,
      name: json['name'] as String? ?? 'Unnamed spot',
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
      address: json['address'] as String?,
      neighborhood: json['neighborhood'] as String? ?? '',
      borough: json['borough'] as String? ?? '',
      hoursRaw: json['hoursRaw'] as String?,
      venueType: json['venueType'] as String? ?? 'cafe',
      attributes: VenueAttributes.fromJson(json['attributes']),
      vibeTags: (json['vibeTags'] as List<dynamic>? ?? const []).cast<String>(),
      workScore: (json['workScore'] as num? ?? 0).round(),
      distanceM: (json['distance_m'] as num?)?.round(),
      tier: json['tier'] as String? ?? 'researched',
      website: json['website'] as String?,
      phone: json['phone'] as String?,
      lastVerified: json['lastVerified'] as String?,
    );
  }

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

class VenuePhoto {
  const VenuePhoto({required this.url, this.attribution});

  final String url;
  final String? attribution;

  factory VenuePhoto.fromJson(Map<String, dynamic> json, Uri baseUri) {
    final rawUrl = json['url'] as String;
    return VenuePhoto(
      url: baseUri.resolve(rawUrl).toString(),
      attribution: (json['contributorName'] ?? json['attribution']) as String?,
    );
  }
}

enum CoverageLevel { researched, baseline, none }

class VenueSearchResult {
  const VenueSearchResult({required this.venues, required this.coverage});

  final List<Venue> venues;
  final CoverageLevel coverage;
}
