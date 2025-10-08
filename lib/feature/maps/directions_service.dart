import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class DirectionsService {
  static Future<List<LatLng>?> getDirections(
    LatLng origin,
    LatLng destination,
  ) async {
    // Use the API key from your sample code that works for directions
    final String apiKey = 'AIzaSyDmgygVeipMUsrtGeZPZ9UzXRmcVdheIqw';
    // Fallback to env if needed: dotenv.get('GOOGLE_MAP', fallback: '');

    if (apiKey.isEmpty) {
      debugPrint('Google Maps API key not found');
      return null;
    }

    try {
      debugPrint(
        '🗺️ Getting directions from ${origin.latitude},${origin.longitude} to ${destination.latitude},${destination.longitude}',
      );
      debugPrint('🔑 Using API key: ${apiKey.substring(0, 10)}...');

      final polylinePoints = PolylinePoints(apiKey: apiKey);

      // TODO: Migrate to RoutesApiRequest when the API is stable
      // Currently using deprecated PolylineRequest as RoutesApiRequest migration is not complete
      final result = await polylinePoints.getRouteBetweenCoordinates(
        request: PolylineRequest(
          origin: PointLatLng(origin.latitude, origin.longitude),
          destination: PointLatLng(destination.latitude, destination.longitude),
          mode: TravelMode.driving,
        ),
      );

      debugPrint('📍 Polyline result: ${result.points.length} points');
      debugPrint('📍 Status: ${result.status}');
      debugPrint('📍 Error message: ${result.errorMessage}');

      if (result.points.length > 2) {
        debugPrint(
          '📍 First point: ${result.points.first.latitude}, ${result.points.first.longitude}',
        );
        debugPrint(
          '📍 Middle point: ${result.points[result.points.length ~/ 2].latitude}, ${result.points[result.points.length ~/ 2].longitude}',
        );
        debugPrint(
          '📍 Last point: ${result.points.last.latitude}, ${result.points.last.longitude}',
        );
      }

      if (result.points.isNotEmpty) {
        final latLngPoints = result.points
            .map((point) => LatLng(point.latitude, point.longitude))
            .toList();
        debugPrint('✅ Successfully got ${latLngPoints.length} route points');
        return latLngPoints;
      } else {
        debugPrint('❌ No route points found. Status: ${result.status}');
        debugPrint('❌ Error: ${result.errorMessage}');
        return null;
      }
    } catch (e) {
      debugPrint('💥 Exception while fetching directions: $e');
      return null;
    }
  }

  static Future<String?> getRouteInfo(LatLng origin, LatLng destination) async {
    try {
      // Calculate approximate distance using Haversine formula
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
    const double earthRadius = 6371000; // meters
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

  static double _toRadians(double degrees) {
    return degrees * (math.pi / 180);
  }
}
