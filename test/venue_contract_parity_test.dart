// Exhaustive Venue Engine contract-parity tests (#3).
//
// Authorities: ../bamware-venue-engine/src/schema.ts,
// ../bamware-ai/docs/brewdesk-mvp-contract.md, and this repo's CONTEXT.md.
//
// Goal: lock in the CURRENT documented decode fallbacks for every optional
// field on the wire, across researched, osm-baseline, and missing-field
// payloads, so Venue Engine contract drift breaks a Flutter test instead of
// shipping silently.
import 'package:brewdesk/features/venues/data/venue_repository.dart';
import 'package:brewdesk/features/venues/data/venue_api.dart';
import 'package:brewdesk/features/venues/data/venue_dtos.dart';
import 'package:brewdesk/features/venues/domain/venue.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

/// A fully-populated researched-tier attributes block: every claim carries
/// the same source/confidence/observedAt, so a workabilityCardStamp test can
/// flip one claim at a time without rebuilding the whole map.
Map<String, dynamic> _claim({
  String value = 'fast',
  String source = 'curated',
  double confidence = 0.8,
  String observedAt = '2026-08-01',
}) => {
  'value': value,
  'source': source,
  'confidence': confidence,
  'observedAt': observedAt,
};

Map<String, dynamic> _researchedVenueJson({
  Map<String, dynamic>? seating,
  Map<String, dynamic>? outdoorSeating,
  String? website,
  String? phone,
  num? distanceM,
  String? tier,
}) => {
  'id': 'spot-researched',
  'name': 'Researched Cafe',
  'lat': 40.72,
  'lng': -73.99,
  'neighborhood': 'East Village',
  'borough': 'Manhattan',
  'venueType': 'cafe',
  'attributes': {
    'wifi': _claim(),
    'outlets': _claim(value: 'plenty'),
    'laptopPolicy': _claim(value: 'unrestricted'),
    'noise': _claim(value: 'moderate'),
    'seating': ?seating,
    'outdoorSeating': ?outdoorSeating,
  },
  'vibeTags': ['cozy'],
  'workScore': 78,
  'tier': ?tier,
  'distance_m': ?distanceM,
  'website': ?website,
  'phone': ?phone,
};

Map<String, dynamic> _baselineVenueJson() => {
  'id': 'osm-node-1',
  'name': 'Baseline Spot',
  'lat': 40.73,
  'lng': -73.98,
  'neighborhood': 'Gramercy',
  'borough': 'Manhattan',
  'venueType': 'cafe',
  'attributes': {
    'wifi': {'value': 'unknown', 'source': 'osm', 'confidence': 0},
    'outlets': {'value': 'unknown', 'source': 'osm', 'confidence': 0},
    'laptopPolicy': {'value': 'unknown', 'source': 'osm', 'confidence': 0},
    'noise': {'value': 'unknown', 'source': 'osm', 'confidence': 0},
  },
  'vibeTags': <String>[],
  'workScore': 50,
  'tier': 'osm-baseline',
};

VenueApi _apiFor(Future<http.Response> Function(http.Request) handler) =>
    VenueApi(
      client: MockClient(handler),
      baseUri: Uri.parse('https://venue.example.test'),
    );

void main() {
  group('Venue.fromJson — optional-field fallbacks', () {
    test('researched payload decodes every claim and top-level field', () {
      final venue = VenueDto.decode(
        _researchedVenueJson(
          seating: _claim(value: 'plenty'),
          outdoorSeating: {
            'value': 'yes',
            'source': 'agent',
            'confidence': 0.6,
            'observedAt': '2026-08-10',
          },
          website: 'https://researchedcafe.example.com',
          phone: '+1 212-555-0100',
          distanceM: 450,
          tier: 'researched',
        ),
      );

      expect(venue.tier, 'researched');
      expect(venue.distanceM, 450);
      expect(venue.distanceLabel, '450 m away');
      expect(venue.website, 'https://researchedcafe.example.com');
      expect(venue.phone, '+1 212-555-0100');
      expect(venue.attributes.seating.value, 'plenty');
      expect(venue.attributes.outdoorSeating.value, 'yes');
      expect(venue.attributes.outdoorSeating.source, 'agent');
    });

    test(
      'missing seating and outdoorSeating claims fall back to an unknown claim',
      () {
        final venue = VenueDto.decode(_researchedVenueJson());

        expect(venue.attributes.seating.value, 'unknown');
        expect(venue.attributes.seating.source, 'unknown');
        expect(venue.attributes.seating.confidence, 0);
        expect(venue.attributes.outdoorSeating.value, 'unknown');
        expect(venue.attributes.outdoorSeating.source, 'unknown');
      },
    );

    test(
      'missing business info (website, phone) decodes to null, not a throw',
      () {
        final venue = VenueDto.decode(_researchedVenueJson());

        expect(venue.website, isNull);
        expect(venue.phone, isNull);
      },
    );

    test('missing distance_m falls back to the neighborhood label', () {
      final venue = VenueDto.decode(_researchedVenueJson());

      expect(venue.distanceM, isNull);
      expect(venue.distanceLabel, 'East Village');
    });

    test('missing tier defaults to researched (schema.ts default)', () {
      final venue = VenueDto.decode(_researchedVenueJson());

      expect(venue.tier, 'researched');
    });

    test('osm-baseline payload: unknown attributes, explicit tier, no business info', () {
      final venue = VenueDto.decode(_baselineVenueJson());

      expect(venue.tier, 'osm-baseline');
      expect(venue.attributes.wifi.value, 'unknown');
      expect(venue.attributes.wifi.source, 'osm');
      expect(venue.attributes.seating.value, 'unknown');
      expect(venue.website, isNull);
      expect(venue.phone, isNull);
      expect(venue.workScore, 50);
    });
  });

  group('Claim — confidence and provenance formatting', () {
    test('confidence missing from the payload defaults to 0', () {
      final claim = ClaimDto.decode({'value': 'unknown', 'source': 'osm'});

      expect(claim.confidence, 0);
      expect(claim.confidencePercent, 0);
    });

    test('confidence decodes and rounds to a whole percent', () {
      final claim = ClaimDto.decode({
        'value': 'fast',
        'source': 'curated',
        'confidence': 0.837,
      });

      expect(claim.confidence, closeTo(0.837, 0.0001));
      expect(claim.confidencePercent, 84);
    });

    test(
      'provenanceLine reports an unknown date when observedAt is missing',
      () {
        final claim = ClaimDto.decode({
          'value': 'unknown',
          'source': 'osm',
          'confidence': 0,
        });

        expect(
          claim.provenanceLine,
          'OpenStreetMap · 0% confidence · updated an unknown date',
        );
      },
    );

    test('provenanceLine formats source label, percent, and date key', () {
      final claim = ClaimDto.decode({
        'value': 'fast',
        'source': 'agent',
        'confidence': 0.6,
        'observedAt': '2026-08-10T00:00:00Z',
      });

      expect(
        claim.provenanceLine,
        'AI researched · 60% confidence · updated 2026-08-10',
      );
    });

    test(
      'completely empty claim payload decodes to the unknown/unknown fallback',
      () {
        final claim = ClaimDto.decode(<String, dynamic>{});

        expect(claim.value, 'unknown');
        expect(claim.source, 'unknown');
        expect(claim.confidence, 0);
        expect(claim.observedAt, isNull);
        expect(
          claim.provenanceLine,
          'unknown · 0% confidence · updated an unknown date',
        );
      },
    );

    test('a non-map claim payload (null) decodes to the same fallback', () {
      final claim = ClaimDto.decode(null);

      expect(claim.value, 'unknown');
      expect(claim.source, 'unknown');
    });
  });

  group('VenueAttributes.workabilityCardStamp', () {
    test('four claims that all disagree break the tie toward wifi', () {
      final attributes = VenueAttributesDto.decode({
        'wifi': _claim(
          source: 'curated',
          confidence: 0.9,
          observedAt: '2026-08-01',
        ),
        'outlets': _claim(
          source: 'osm',
          confidence: 0.2,
          observedAt: '2026-07-01',
        ),
        'laptopPolicy': _claim(
          source: 'estimate',
          confidence: 0.3,
          observedAt: '2026-06-01',
        ),
        'noise': _claim(
          source: 'agent',
          confidence: 0.5,
          observedAt: '2026-05-01',
        ),
      });

      expect(attributes.workabilityCardStamp.source, 'curated');
    });

    test('a 3-way agreement outvotes the one disagreeing claim', () {
      final attributes = VenueAttributesDto.decode({
        'wifi': _claim(
          source: 'curated',
          confidence: 0.8,
          observedAt: '2026-08-01',
        ),
        'outlets': _claim(
          source: 'curated',
          confidence: 0.8,
          observedAt: '2026-08-01',
        ),
        'laptopPolicy': _claim(
          source: 'estimate',
          confidence: 0.3,
          observedAt: '2026-07-01',
        ),
        'noise': _claim(
          source: 'curated',
          confidence: 0.8,
          observedAt: '2026-08-01',
        ),
      });

      final stamp = attributes.workabilityCardStamp;
      expect(stamp.source, 'curated');
      expect(stamp.confidencePercent, 80);
      expect(stamp.dateKey, '2026-08-01');
    });

    test('a 2-2 split breaks the tie toward wifi row order', () {
      final attributes = VenueAttributesDto.decode({
        'wifi': _claim(
          source: 'curated',
          confidence: 0.8,
          observedAt: '2026-08-01',
        ),
        'outlets': _claim(
          source: 'curated',
          confidence: 0.8,
          observedAt: '2026-08-01',
        ),
        'laptopPolicy': _claim(
          source: 'osm',
          confidence: 0.1,
          observedAt: '2026-01-01',
        ),
        'noise': _claim(
          source: 'osm',
          confidence: 0.1,
          observedAt: '2026-01-01',
        ),
      });

      // wifi and outlets agree (2), laptopPolicy and noise agree (2) — the
      // documented tie-break is wifi's row order (brewdesk#119).
      expect(attributes.workabilityCardStamp.source, 'curated');
      expect(attributes.workabilityCardStamp.confidencePercent, 80);
    });

    test('missing seating/outdoorSeating never influence the stamp', () {
      final attributes = VenueAttributesDto.decode({
        'wifi': _claim(
          source: 'curated',
          confidence: 0.8,
          observedAt: '2026-08-01',
        ),
        'outlets': _claim(
          source: 'curated',
          confidence: 0.8,
          observedAt: '2026-08-01',
        ),
        'laptopPolicy': _claim(
          source: 'curated',
          confidence: 0.8,
          observedAt: '2026-08-01',
        ),
        'noise': _claim(
          source: 'curated',
          confidence: 0.8,
          observedAt: '2026-08-01',
        ),
        // seating and outdoorSeating intentionally omitted.
      });

      expect(attributes.seating.value, 'unknown');
      expect(attributes.outdoorSeating.value, 'unknown');
      expect(attributes.workabilityCardStamp.source, 'curated');
    });
  });

  group('VenueRepository.search — meta.coverage mapping', () {
    test(
      'meta.coverage "researched" maps to CoverageLevel.researched',
      () async {
        final repository = ApiVenueRepository(
          _apiFor(
            (request) async => http.Response(
              _searchBody(
                coverage: 'researched',
                venue: _researchedVenueJson(),
              ),
              200,
            ),
          ),
        );

        final result = await repository.search(lat: 40.7, lng: -74.0);

        expect(result.coverage, CoverageLevel.researched);
        expect(result.venues.single.tier, 'researched');
      },
    );

    test('meta.coverage "baseline" maps to CoverageLevel.baseline', () async {
      final repository = ApiVenueRepository(
        _apiFor(
          (request) async => http.Response(
            _searchBody(coverage: 'baseline', venue: _baselineVenueJson()),
            200,
          ),
        ),
      );

      final result = await repository.search(lat: 40.7, lng: -74.0);

      expect(result.coverage, CoverageLevel.baseline);
      expect(result.venues.single.tier, 'osm-baseline');
    });

    test(
      'meta.coverage "none" maps to CoverageLevel.none with an empty list',
      () async {
        final repository = ApiVenueRepository(
          _apiFor(
            (request) async => http.Response(
              '{"count": 0, "meta": {"coverage": "none"}, "venues": []}',
              200,
            ),
          ),
        );

        final result = await repository.search(lat: 40.7, lng: -74.0);

        expect(result.coverage, CoverageLevel.none);
        expect(result.venues, isEmpty);
      },
    );

    test('a missing meta object defaults to CoverageLevel.researched', () async {
      final repository = ApiVenueRepository(
        _apiFor(
          (request) async => http.Response(
            '{"count": 1, "venues": [${_encodeJson(_researchedVenueJson())}]}',
            200,
          ),
        ),
      );

      final result = await repository.search(lat: 40.7, lng: -74.0);

      expect(result.coverage, CoverageLevel.researched);
    });

    test(
      'an empty venues list decodes without throwing when the key is absent',
      () async {
        final repository = ApiVenueRepository(
          _apiFor((request) async => http.Response('{"count": 0}', 200)),
        );

        final result = await repository.search(lat: 40.7, lng: -74.0);

        expect(result.venues, isEmpty);
      },
    );
  });

  group('VenueRepository.venue — detail decode', () {
    test('detail response with business info decodes website and phone', () async {
      final repository = ApiVenueRepository(
        _apiFor(
          (request) async => http.Response(
            '{"venue": ${_encodeJson(_researchedVenueJson(website: 'https://researchedcafe.example.com', phone: '+1 212-555-0100'))}, "observations": []}',
            200,
          ),
        ),
      );

      final venue = await repository.venue('spot-researched');

      expect(venue.website, 'https://researchedcafe.example.com');
      expect(venue.phone, '+1 212-555-0100');
    });

    test('detail response without business info decodes to null fields', () async {
      final repository = ApiVenueRepository(
        _apiFor(
          (request) async => http.Response(
            '{"venue": ${_encodeJson(_baselineVenueJson())}, "observations": []}',
            200,
          ),
        ),
      );

      final venue = await repository.venue('osm-node-1');

      expect(venue.website, isNull);
      expect(venue.phone, isNull);
      expect(venue.attributes.seating.value, 'unknown');
    });
  });

  group('VenueRepository.photos — relative URL resolution and attribution', () {
    test(
      'a relative photo URL resolves against the configured API base URL',
      () async {
        final repository = ApiVenueRepository(
          _apiFor(
            (request) async => http.Response(
              '{"photos": [{"url": "/v1/photo-proxy/abc123", "attribution": "Jane D."}]}',
              200,
            ),
          ),
        );

        final photos = await repository.photos('spot-researched');

        expect(photos, hasLength(1));
        expect(
          photos.single.url,
          'https://venue.example.test/v1/photo-proxy/abc123',
        );
        expect(photos.single.attribution, 'Jane D.');
      },
    );

    test(
      'an absolute Google-hosted photo URL is left unresolved (unchanged)',
      () async {
        final repository = ApiVenueRepository(
          _apiFor(
            (request) async => http.Response(
              '{"photos": [{"url": "https://lh3.googleusercontent.com/abc"}]}',
              200,
            ),
          ),
        );

        final photos = await repository.photos('spot-researched');

        expect(photos.single.url, 'https://lh3.googleusercontent.com/abc');
        expect(photos.single.attribution, isNull);
      },
    );

    test('a photo missing attribution decodes to a null attribution', () async {
      final repository = ApiVenueRepository(
        _apiFor(
          (request) async => http.Response(
            '{"photos": [{"url": "https://lh3.googleusercontent.com/no-attr"}]}',
            200,
          ),
        ),
      );

      final photos = await repository.photos('spot-researched');

      expect(photos.single.attribution, isNull);
    });

    test(
      'a missing photos key decodes to an empty list, never a throw',
      () async {
        final repository = ApiVenueRepository(
          _apiFor((request) async => http.Response('{}', 200)),
        );

        final photos = await repository.photos('spot-researched');

        expect(photos, isEmpty);
      },
    );
  });
}

String _searchBody({
  required String coverage,
  required Map<String, dynamic> venue,
}) =>
    '{"count": 1, "meta": {"coverage": "$coverage"}, "venues": [${_encodeJson(venue)}]}';

/// Minimal, dependency-free JSON encoder: avoids importing dart:convert's
/// jsonEncode just to inline these fixtures as literal MockClient bodies.
String _encodeJson(Object? value) {
  if (value == null) return 'null';
  if (value is String) return '"${value.replaceAll('"', '\\"')}"';
  if (value is num || value is bool) return '$value';
  if (value is Map) {
    final entries = value.entries
        .map((e) => '${_encodeJson(e.key)}: ${_encodeJson(e.value)}')
        .join(', ');
    return '{$entries}';
  }
  if (value is Iterable) {
    return '[${value.map(_encodeJson).join(', ')}]';
  }
  throw ArgumentError('Cannot encode $value');
}
