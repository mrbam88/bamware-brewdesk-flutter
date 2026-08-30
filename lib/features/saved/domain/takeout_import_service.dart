import 'dart:convert';
import 'dart:math' as math;

import 'package:brewdesk/features/venues/domain/venue.dart';

/// One row parsed out of a Google Takeout "Saved Places" export. Coordinates
/// are optional — the CSV shape only carries them when the Maps URL column
/// includes them.
class TakeoutPlace {
  const TakeoutPlace({required this.name, this.lat, this.lng});

  final String name;
  final double? lat;
  final double? lng;
}

/// Thrown when a file is neither of the two Takeout export shapes.
class TakeoutImportException implements Exception {
  const TakeoutImportException(this.message);
  final String message;

  @override
  String toString() => message;
}

/// Parses Google Takeout "Saved Places" exports entirely on-device. Two
/// shapes exist in the wild: a GeoJSON FeatureCollection and a CSV
/// (Title,Note,URL — coordinates only inside the Maps URL, when present).
/// Ported from the iOS reference (BrewDeskKit/TakeoutImport.swift).
abstract final class TakeoutParser {
  static List<TakeoutPlace> parse(String content) {
    final geoJson = _parseGeoJson(content);
    if (geoJson != null) return geoJson;
    final csv = _parseCsv(content);
    if (csv != null) return csv;
    throw const TakeoutImportException('Unrecognized Takeout export format.');
  }

  // MARK: GeoJSON — {"type":"FeatureCollection","features":[...]}

  static List<TakeoutPlace>? _parseGeoJson(String content) {
    Object? decoded;
    try {
      decoded = jsonDecode(content);
    } on FormatException {
      return null;
    }
    if (decoded is! Map<String, dynamic>) return null;
    final features = decoded['features'];
    if (features is! List) return null;

    final places = <TakeoutPlace>[];
    for (final feature in features) {
      if (feature is! Map<String, dynamic>) continue;
      final properties =
          feature['properties'] as Map<String, dynamic>? ?? const {};
      final location =
          properties['location'] as Map<String, dynamic>? ?? const {};
      final name =
          (location['name'] as String?) ??
          (properties['Title'] as String?) ??
          (properties['name'] as String?);
      if (name == null || name.isEmpty) continue;

      double? lat;
      double? lng;
      final geometry = feature['geometry'] as Map<String, dynamic>?;
      final coords = geometry?['coordinates'];
      if (coords is List && coords.length == 2) {
        lng = (coords[0] as num?)?.toDouble();
        lat = (coords[1] as num?)?.toDouble();
      }
      places.add(TakeoutPlace(name: name, lat: lat, lng: lng));
    }
    return places.isEmpty ? null : places;
  }

  // MARK: CSV — header "Title,Note,URL" (RFC-4180 quoting on the title)

  static List<TakeoutPlace>? _parseCsv(String content) {
    final lines = content
        .split('\n')
        .where((line) => line.trim().isNotEmpty)
        .toList();
    if (lines.isEmpty) return null;
    final header = lines.first.toLowerCase().replaceAll('"', '');
    if (!header.startsWith('title')) return null;
    lines.removeAt(0);

    final places = <TakeoutPlace>[];
    for (final line in lines) {
      final fields = _splitCsvLine(line);
      if (fields.isEmpty) continue;
      final title = fields.first.trim();
      if (title.isEmpty) continue;
      // URL is the last column; unquoted commas inside it (`@lat,lng,17z`)
      // would otherwise split it apart.
      final url = fields.length >= 3 ? fields.sublist(2).join(',') : '';
      final coords = _coordinatesInMapsUrl(url);
      places.add(TakeoutPlace(name: title, lat: coords?.$1, lng: coords?.$2));
    }
    return places.isEmpty ? null : places;
  }

  static List<String> _splitCsvLine(String line) {
    final fields = <String>[];
    final current = StringBuffer();
    var inQuotes = false;
    for (final rune in line.runes) {
      final char = String.fromCharCode(rune);
      if (char == '"') {
        inQuotes = !inQuotes;
      } else if (char == ',' && !inQuotes) {
        fields.add(current.toString());
        current.clear();
      } else {
        current.write(char);
      }
    }
    fields.add(current.toString());
    return fields.map((field) => field.trim().replaceAll('\r', '')).toList();
  }

  /// Maps URLs carry coordinates as `!3d<lat>!4d<lng>` or `@lat,lng,`.
  static (double, double)? _coordinatesInMapsUrl(String url) {
    final d3d4 = RegExp(r'!3d(-?\d+\.?\d*)!4d(-?\d+\.?\d*)').firstMatch(url);
    if (d3d4 != null) {
      final lat = double.tryParse(d3d4.group(1)!);
      final lng = double.tryParse(d3d4.group(2)!);
      if (lat != null && lng != null) return (lat, lng);
    }
    final at = RegExp(r'@(-?\d+\.?\d*),(-?\d+\.?\d*)').firstMatch(url);
    if (at != null) {
      final lat = double.tryParse(at.group(1)!);
      final lng = double.tryParse(at.group(2)!);
      if (lat != null && lng != null) return (lat, lng);
    }
    return null;
  }
}

/// A parsed set of places split by whether they matched a known venue.
class TakeoutMatchResult {
  const TakeoutMatchResult({required this.matched, required this.unmatched});

  final List<Venue> matched;
  final List<TakeoutPlace> unmatched;
}

/// Matches parsed Takeout places against the on-device venue catalog.
/// Ported thresholds from iOS (BrewDeskKit/TakeoutImport.swift): a place
/// matches a venue by normalized-name containment or by sitting within
/// [matchRadiusMeters] of it. Display-only decision — no fuzzy guessing
/// beyond that.
abstract final class TakeoutMatcher {
  static const matchRadiusMeters = 150.0;

  static TakeoutMatchResult match(
    List<TakeoutPlace> places,
    List<Venue> venues,
  ) {
    final matched = <Venue>[];
    final matchedIds = <String>{};
    final unmatched = <TakeoutPlace>[];

    for (final place in places) {
      Venue? found;
      for (final venue in venues) {
        if (matches(place, venue)) {
          found = venue;
          break;
        }
      }
      if (found != null) {
        if (matchedIds.add(found.id)) matched.add(found);
      } else {
        unmatched.add(place);
      }
    }
    return TakeoutMatchResult(matched: matched, unmatched: unmatched);
  }

  static bool matches(TakeoutPlace place, Venue venue) {
    final placeName = _normalize(place.name);
    final venueName = _normalize(venue.name);
    if (placeName == venueName) return true;
    if (placeName.length >= 5 && venueName.contains(placeName)) return true;
    if (venueName.length >= 5 && placeName.contains(venueName)) return true;
    final lat = place.lat;
    final lng = place.lng;
    if (lat != null && lng != null) {
      return _metersBetween(lat, lng, venue.lat, venue.lng) <=
          matchRadiusMeters;
    }
    return false;
  }

  static const _diacriticFolds = {
    'á': 'a',
    'à': 'a',
    'â': 'a',
    'ä': 'a',
    'ã': 'a',
    'å': 'a',
    'é': 'e',
    'è': 'e',
    'ê': 'e',
    'ë': 'e',
    'í': 'i',
    'ì': 'i',
    'î': 'i',
    'ï': 'i',
    'ó': 'o',
    'ò': 'o',
    'ô': 'o',
    'ö': 'o',
    'õ': 'o',
    'ú': 'u',
    'ù': 'u',
    'û': 'u',
    'ü': 'u',
    'ñ': 'n',
    'ç': 'c',
  };

  static String _normalize(String name) {
    final buffer = StringBuffer();
    for (final rune in name.toLowerCase().runes) {
      final char = String.fromCharCode(rune);
      buffer.write(_diacriticFolds[char] ?? char);
    }
    final folded = buffer.toString();
    final tokens = folded
        .split(RegExp(r'[^a-z0-9]+'))
        .where((token) => token.isNotEmpty);
    return tokens.join(' ');
  }

  static double _metersBetween(
    double lat1,
    double lng1,
    double lat2,
    double lng2,
  ) {
    const earthRadiusM = 6371000.0;
    final dLat = (lat2 - lat1) * math.pi / 180;
    final dLng = (lng2 - lng1) * math.pi / 180;
    final a =
        math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(lat1 * math.pi / 180) *
            math.cos(lat2 * math.pi / 180) *
            math.sin(dLng / 2) *
            math.sin(dLng / 2);
    return earthRadiusM * 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
  }
}
