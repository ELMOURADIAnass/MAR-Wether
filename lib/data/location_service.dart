// "When in use" GPS service. Raw coordinates are returned to the
// caller and kept in memory only — they are never persisted.
import 'dart:async';

import 'package:geolocator/geolocator.dart';

import '../core/constants/app_constants.dart';
import '../core/errors/app_failure.dart';

/// A GPS fix without platform types leaking into providers.
class GeoPoint {
  const GeoPoint(this.lat, this.lon);
  final double lat;
  final double lon;
}

/// Wraps geolocator with typed failures for every documented case.
class LocationService {
  const LocationService();

  /// High-accuracy position with a 10-second timeout.
  Future<Result<GeoPoint>> currentPosition() async {
    final bool enabled = await Geolocator.isLocationServiceEnabled();
    if (!enabled) {
      return const Err<GeoPoint>(
        LocationFailure(LocationFailureKind.serviceDisabled),
      );
    }
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    switch (permission) {
      case LocationPermission.denied:
        return const Err<GeoPoint>(
          LocationFailure(LocationFailureKind.permissionDenied),
        );
      case LocationPermission.deniedForever:
        return const Err<GeoPoint>(
          LocationFailure(LocationFailureKind.permissionDeniedForever),
        );
      case LocationPermission.whileInUse:
      case LocationPermission.always:
        break;
      case LocationPermission.unableToDetermine:
        return const Err<GeoPoint>(
          LocationFailure(LocationFailureKind.unknown),
        );
    }
    try {
      final Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: LocationConstants.gpsTimeout,
        ),
      );
      return Ok<GeoPoint>(GeoPoint(position.latitude, position.longitude));
    } on TimeoutException {
      return const Err<GeoPoint>(
        LocationFailure(LocationFailureKind.timeout),
      );
    } catch (e) {
      return Err<GeoPoint>(
        LocationFailure(LocationFailureKind.unknown, e.toString()),
      );
    }
  }

  /// Best-effort last known fix (used before falling back to the
  /// default city). Null when none is available.
  Future<GeoPoint?> lastKnownPosition() async {
    try {
      final Position? position = await Geolocator.getLastKnownPosition();
      if (position == null) {
        return null;
      }
      return GeoPoint(position.latitude, position.longitude);
    } catch (_) {
      return null;
    }
  }

  /// Opens app settings (permission denied forever) — true on success.
  Future<bool> openAppSettings() => Geolocator.openAppSettings();

  /// Opens location settings (service disabled) — true on success.
  Future<bool> openLocationSettings() =>
      Geolocator.openLocationSettings();
}
