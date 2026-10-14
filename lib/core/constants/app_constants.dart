// Application-wide constants for MAR-Wether.
//
// Centralises API parameters, cache policy, timeouts and Moroccan
// brand colours so behaviour stays consistent across layers.
import 'package:flutter/material.dart';

/// Moroccan brand palette. Red/green are used for header accents only;
/// gold is reserved for small highlights (badges, active stars).
abstract final class AppColors {
  static const Color red = Color(0xFFC1272D);
  static const Color green = Color(0xFF006233);
  static const Color gold = Color(0xFFD4A017);
}

/// Open-Meteo request defaults.
abstract final class ApiConstants {
  static const String host = 'api.open-meteo.com';
  static const String forecastPath = '/v1/forecast';
  static const Duration httpTimeout = Duration(seconds: 12);
  static const int forecastDays = 7;
  static const String windSpeedUnit = 'kmh';
  static const String searchedTimezone = 'Africa/Casablanca';
  static const String gpsTimezone = 'auto';
}

/// Local cache policy.
abstract final class CacheConstants {
  /// Refresh automatically when cached data is older than this.
  static const Duration maxAge = Duration(minutes: 30);

  /// Keep at most this many cached cities, oldest evicted first.
  static const int maxEntries = 20;

  static const String keyPrefix = 'weather_cache_v1_';
  static const String keyFavorites = 'favorites_v1';
  static const String keyLastCityId = 'last_city_id_v1';
  static const String keyLanguage = 'language_code_v1';
  static const String keyUnit = 'temp_unit_v1';
  static const String keyTheme = 'theme_mode_v1';
}

/// Location request policy.
abstract final class LocationConstants {
  static const Duration gpsTimeout = Duration(seconds: 10);
  static const String defaultCityId = 'casablanca';
}

/// Supported locales. French is the fallback default.
abstract final class LocaleConstants {
  static const List<String> supportedCodes = <String>['fr', 'ar', 'en'];
  static const String fallbackCode = 'fr';
}
