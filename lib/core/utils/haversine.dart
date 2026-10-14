// Haversine distance and nearest-city lookup.
import 'dart:math' as math;

import '../../data/models/city.dart';

const double _earthRadiusKm = 6371.0;

double _toRadians(double degrees) => degrees * math.pi / 180.0;

/// Great-circle distance in kilometres between two WGS-84 points.
double haversineKm(double lat1, double lon1, double lat2, double lon2) {
  final double dLat = _toRadians(lat2 - lat1);
  final double dLon = _toRadians(lon2 - lon1);
  final double a =
      math.pow(math.sin(dLat / 2), 2) +
      math.cos(_toRadians(lat1)) *
          math.cos(_toRadians(lat2)) *
          math.pow(math.sin(dLon / 2), 2);
  return 2 * _earthRadiusKm * math.asin(math.sqrt(a));
}

/// Nearest city in [cities] to the given position, with distance in km.
({City city, double distanceKm}) nearestCity(
  List<City> cities,
  double lat,
  double lon,
) {
  City? best;
  double bestDist = double.infinity;
  for (final City city in cities) {
    final double dist = haversineKm(lat, lon, city.lat, city.lon);
    if (dist < bestDist) {
      bestDist = dist;
      best = city;
    }
  }
  if (best == null) {
    throw StateError('nearestCity called with an empty city list');
  }
  return (city: best, distanceKm: bestDist);
}
