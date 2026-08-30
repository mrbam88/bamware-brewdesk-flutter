import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'venue_api.g.dart';

@Riverpod(keepAlive: true)
VenueApi venueApi(Ref ref) => VenueApi();

/// Thrown for a non-2xx engine response. The message names the engine so a
/// degraded-state card can tell "the engine is down" apart from "you're
/// offline" (brewdesk#11).
class VenueApiException implements Exception {
  const VenueApiException(this.message);
  final String message;

  @override
  String toString() => message;
}

/// Thrown when the request never reached the engine at all — no network
/// path, as opposed to a bad response from a reachable one. Kept distinct
/// from [VenueApiException] so the UI can show an offline-specific card with
/// connectivity-driven auto-retry (brewdesk#11) instead of a generic error.
class VenueOfflineException implements Exception {
  const VenueOfflineException();

  @override
  String toString() => 'No internet connection.';
}

/// Degraded-state fixtures for manual QA and CI, selected at launch via
/// `--dart-define=BREWDESK_SCENARIO=<name>` — mirrors iOS's `-UITestScenario`
/// / `ScenarioVenueService` (brewdesk#11). Never reaches the network.
enum VenueScenario {
  /// Three fixture venues, normal responses throughout.
  fixtureOK,

  /// Every call fails with a 500 — "the engine is down".
  engineDown,

  /// Every call fails with no network path at all.
  offline,

  /// Search resolves to zero venues; health is otherwise normal.
  emptyVenues,

  /// Search/venue/photo calls hang for [VenueApi.scenario]'s `slowDelay`
  /// (default 6s, iOS parity) before resolving to the fixtures.
  slow;

  static VenueScenario? fromName(String? name) => switch (name) {
    'fixtureOK' => VenueScenario.fixtureOK,
    'engineDown' => VenueScenario.engineDown,
    'offline' => VenueScenario.offline,
    'emptyVenues' => VenueScenario.emptyVenues,
    'slow' => VenueScenario.slow,
    _ => null,
  };
}

class VenueApi {
  VenueApi({http.Client? client, Uri? baseUri})
    : _client = client ?? _clientForEnvironment(),
      baseUri = baseUri ?? Uri.parse('https://venuekit-ashen.vercel.app');

  /// Launch/test seam that pins a degraded state deterministically instead
  /// of hitting the network — see [VenueScenario]. [slowDelay] is a test
  /// hook for [VenueScenario.slow]; production launches keep the 6s default.
  VenueApi.scenario(
    VenueScenario scenario, {
    Duration slowDelay = const Duration(seconds: 6),
  }) : _client = _ScenarioClient(scenario, slowDelay: slowDelay),
       baseUri = Uri.parse('https://venuekit-ashen.vercel.app');

  final http.Client _client;
  final Uri baseUri;

  static const _scenarioName = String.fromEnvironment('BREWDESK_SCENARIO');

  static http.Client _clientForEnvironment() {
    final scenario = VenueScenario.fromName(
      _scenarioName.isEmpty ? null : _scenarioName,
    );
    return scenario == null
        ? http.Client()
        : _ScenarioClient(scenario, slowDelay: const Duration(seconds: 6));
  }

  Future<Map<String, dynamic>> search({
    required double lat,
    required double lng,
    int radiusM = 5000,
  }) {
    return _jsonRequest(
      'POST',
      '/v1/venues/search',
      body: {'lat': lat, 'lng': lng, 'radius_m': radiusM, 'limit': 100},
    );
  }

  Future<Map<String, dynamic>> venue(String id) =>
      _jsonRequest('GET', '/v1/venues/${Uri.encodeComponent(id)}');

  Future<Map<String, dynamic>> photos(String id) =>
      _jsonRequest('GET', '/v1/venues/${Uri.encodeComponent(id)}/photos');

  Future<Map<String, dynamic>> _jsonRequest(
    String method,
    String path, {
    Map<String, Object?>? body,
  }) async {
    final request = http.Request(method, baseUri.resolve(path));
    request.headers['Accept'] = 'application/json';
    if (body != null) {
      request.headers['Content-Type'] = 'application/json';
      request.body = jsonEncode(body);
    }

    final http.StreamedResponse streamed;
    try {
      streamed = await _client
          .send(request)
          .timeout(const Duration(seconds: 15));
    } on SocketException {
      throw const VenueOfflineException();
    }
    final response = await http.Response.fromStream(streamed);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw VenueApiException(
        'The venue engine returned an error (${response.statusCode}).',
      );
    }
    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw const VenueApiException(
        'Venue service returned an unexpected response.',
      );
    }
    return decoded;
  }
}

/// Fabricates every response for a [VenueScenario] — no network, no
/// persistence. See [VenueApi.scenario].
class _ScenarioClient extends http.BaseClient {
  _ScenarioClient(this.scenario, {required this.slowDelay});

  final VenueScenario scenario;
  final Duration slowDelay;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    if (scenario == VenueScenario.offline) {
      throw const SocketException(
        'No internet connection (scenario: offline).',
      );
    }
    if (scenario == VenueScenario.slow) {
      await Future<void>.delayed(slowDelay);
    }
    if (scenario == VenueScenario.engineDown) {
      return _respond('{"error":"engine down"}', statusCode: 500);
    }

    final path = request.url.path;
    if (path.endsWith('/photos')) {
      return _respond(jsonEncode({'photos': <Object?>[]}));
    }
    if (path == '/v1/venues/search') {
      return _respond(
        jsonEncode({
          'meta': {'coverage': 'researched'},
          'venues': scenario == VenueScenario.emptyVenues
              ? <Object?>[]
              : _fixtureVenues,
        }),
      );
    }
    // GET /v1/venues/{id}
    final id = Uri.decodeComponent(path.split('/').last);
    final match = _fixtureVenues.firstWhere(
      (venue) => venue['id'] == id,
      orElse: () => _fixtureVenues.first,
    );
    return _respond(jsonEncode({'venue': match}));
  }

  http.StreamedResponse _respond(String body, {int statusCode = 200}) {
    return http.StreamedResponse(
      Stream.value(utf8.encode(body)),
      statusCode,
      headers: {'content-type': 'application/json'},
    );
  }

  static final List<Map<String, Object?>> _fixtureVenues = [
    _fixtureVenue(
      id: 'fixture-roasters',
      name: 'Fixture Roasters',
      lat: 40.7365,
      lng: -73.9905,
      neighborhood: 'Union Square',
      venueType: 'cafe',
      workScore: 84,
    ),
    _fixtureVenue(
      id: 'fixture-reading-room',
      name: 'Fixture Reading Room',
      lat: 40.7340,
      lng: -73.9930,
      neighborhood: 'Greenwich Village',
      venueType: 'library',
      workScore: 71,
    ),
    _fixtureVenue(
      id: 'fixture-corner-cafe',
      name: 'Fixture Corner Cafe',
      lat: 40.7380,
      lng: -73.9890,
      neighborhood: 'Flatiron',
      venueType: 'cafe',
      workScore: 52,
    ),
  ];

  static Map<String, Object?> _fixtureVenue({
    required String id,
    required String name,
    required double lat,
    required double lng,
    required String neighborhood,
    required String venueType,
    required int workScore,
  }) {
    const observedAt = '2026-08-01T00:00:00Z';
    Map<String, Object?> claim(String value, {String source = 'curated'}) => {
      'value': value,
      'source': source,
      'confidence': 0.8,
      'observedAt': observedAt,
    };
    return {
      'id': id,
      'name': name,
      'lat': lat,
      'lng': lng,
      'neighborhood': neighborhood,
      'borough': 'Manhattan',
      'venueType': venueType,
      'attributes': {
        'wifi': claim('fast'),
        'outlets': claim('plenty'),
        'laptopPolicy': claim('unrestricted'),
        'noise': claim('moderate'),
      },
      'vibeTags': const ['fixture'],
      'workScore': workScore,
      'tier': 'researched',
    };
  }
}
