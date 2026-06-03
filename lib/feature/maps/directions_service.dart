import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class DirectionsService {
  static Future<List<LatLng>?> getDirections(
    LatLng origin,
    LatLng destination,
  ) async {
    // OSRM public demo — free, no API key needed
    // For production traffic, self-host: https://project-osrm.org
    final url = Uri.parse(
      'https://router.project-osrm.org/route/v1/driving/'
      '${origin.longitude},${origin.latitude};'
      '${destination.longitude},${destination.latitude}'
      '?overview=full&geometries=geojson',
    );

    try {
      debugPrint(
        '🗺️ Getting directions from ${origin.latitude},${origin.longitude} '
        'to ${destination.latitude},${destination.longitude}',
      );

      final response = await http
          .get(url, headers: {'User-Agent': 'AmayAlert/1.0'})
          .timeout(const Duration(seconds: 15));

      if (response.statusCode != 200) {
        debugPrint('❌ OSRM HTTP ${response.statusCode}');
        return null;
      }

      final data = json.decode(response.body) as Map<String, dynamic>;
      if (data['code'] != 'Ok') {
        debugPrint('❌ OSRM code: ${data['code']}');
        return null;
      }

      final routes = data['routes'] as List;
      if (routes.isEmpty) return null;

      // GeoJSON coordinates are [longitude, latitude]
      final coords = routes.first['geometry']['coordinates'] as List;
      final points = coords
          .map((c) => LatLng(c[1] as double, c[0] as double))
          .toList();

      debugPrint('✅ OSRM returned ${points.length} route points');
      return points;
    } catch (e) {
      debugPrint('💥 OSRM error: $e');
      return null;
    }
  }

  static Future<String?> getRouteInfo(
    LatLng origin,
    LatLng destination,
  ) async {
    try {
      final distanceInMeters = _calculateDistance(origin, destination);
      if (distanceInMeters < 1000) {
        return '${distanceInMeters.round()} m • Walking route';
      } else {
        final distanceInKm = (distanceInMeters / 1000).toStringAsFixed(1);
        return '$distanceInKm km • Driving route';
      }
    } catch (e) {
      debugPrint('Exception while calculating route info: $e');
      return 'Route available';
    }
  }

  static double _calculateDistance(LatLng origin, LatLng destination) {
    const double earthRadius = 6371000;
    final double dLat = _toRadians(destination.latitude - origin.latitude);
    final double dLon = _toRadians(destination.longitude - origin.longitude);

    final double a =
        math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRadians(origin.latitude)) *
            math.cos(_toRadians(destination.latitude)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);

    final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadius * c;
  }

  static double _toRadians(double degrees) => degrees * (math.pi / 180);
}
