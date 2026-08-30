class Claim {
  const Claim({
    required this.value,
    required this.source,
    this.detail,
    this.observedAt,
    this.confidence = 0,
  });

  final String value;
  final String source;
  final String? detail;
  final String? observedAt;

  /// 0.0–1.0, per the engine contract (`schema.ts` `Claim.confidence`).
  /// Defaults to 0 when the payload omits it, so older/partial responses
  /// still decode instead of throwing.
  final double confidence;

  factory Claim.fromJson(Object? raw) {
    final json = raw is Map<String, dynamic> ? raw : <String, dynamic>{};
    return Claim(
      value: json['value'] as String? ?? 'unknown',
      source: json['source'] as String? ?? 'unknown',
      detail: json['detail'] as String?,
      observedAt: json['observedAt'] as String?,
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0,
    );
  }

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
