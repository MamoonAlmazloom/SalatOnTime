import 'dart:convert';

import 'package:http/http.dart' as http;

enum TravelMode { walking, driving }

/// Estimates travel time between two points using the public OSRM
/// instances hosted by FOSSGIS (routing.openstreetmap.de) — free, no key.
class RoutingService {
  final http.Client _client;

  RoutingService({http.Client? client}) : _client = client ?? http.Client();

  /// Route duration in whole minutes (rounded up), or null on any failure.
  Future<int?> travelMinutes({
    required double fromLatitude,
    required double fromLongitude,
    required double toLatitude,
    required double toLongitude,
    required TravelMode mode,
  }) async {
    final profile = mode == TravelMode.walking ? 'foot' : 'driving';
    final server = mode == TravelMode.walking ? 'routed-foot' : 'routed-car';
    final url = Uri.https(
      'routing.openstreetmap.de',
      '/$server/route/v1/$profile/'
      '$fromLongitude,$fromLatitude;$toLongitude,$toLatitude',
      {'overview': 'false'},
    );

    try {
      final response =
          await _client.get(url).timeout(const Duration(seconds: 12));
      if (response.statusCode != 200) return null;
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      if (body['code'] != 'Ok') return null;
      final routes = body['routes'] as List<dynamic>;
      if (routes.isEmpty) return null;
      final seconds =
          ((routes.first as Map<String, dynamic>)['duration'] as num)
              .toDouble();
      return (seconds / 60).ceil();
    } on Exception {
      return null;
    }
  }
}
