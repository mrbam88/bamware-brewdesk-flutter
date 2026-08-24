import 'dart:convert';

import 'package:http/http.dart' as http;

class VenueApiException implements Exception {
  const VenueApiException(this.message);
  final String message;

  @override
  String toString() => message;
}

class VenueApi {
  VenueApi({http.Client? client, Uri? baseUri})
    : _client = client ?? http.Client(),
      baseUri = baseUri ?? Uri.parse('https://venuekit-ashen.vercel.app');

  final http.Client _client;
  final Uri baseUri;

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

    final streamed = await _client
        .send(request)
        .timeout(const Duration(seconds: 15));
    final response = await http.Response.fromStream(streamed);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw VenueApiException('Venue service returned ${response.statusCode}.');
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
