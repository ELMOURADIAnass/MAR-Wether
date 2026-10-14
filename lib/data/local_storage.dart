// SharedPreferences persistence: favorites, last city, language,
// unit and theme. Only city ids/names are stored — never raw GPS
// coordinates.
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/constants/app_constants.dart';
import '../core/utils/temperature.dart';

/// Synchronous settings/favorites store over an async-loaded prefs.
class LocalStorage {
  LocalStorage(this._prefs);

  final SharedPreferences _prefs;

  static Future<LocalStorage> load() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return LocalStorage(prefs);
  }

  // Favorites (city ids).
  List<String> favoriteIds() {
    return _prefs.getStringList(CacheConstants.keyFavorites) ??
        const <String>[];
  }

  Future<void> setFavoriteIds(List<String> ids) {
    return _prefs.setStringList(CacheConstants.keyFavorites, ids);
  }

  // Last viewed city.
  String? lastCityId() => _prefs.getString(CacheConstants.keyLastCityId);

  Future<void> setLastCityId(String id) {
    return _prefs.setString(CacheConstants.keyLastCityId, id);
  }

  // Language ('ar' | 'fr' | 'en', null = device default).
  String? languageCode() => _prefs.getString(CacheConstants.keyLanguage);

  Future<void> setLanguageCode(String? code) async {
    if (code == null) {
      await _prefs.remove(CacheConstants.keyLanguage);
    } else {
      await _prefs.setString(CacheConstants.keyLanguage, code);
    }
  }

  // Temperature unit.
  TempUnit tempUnit() =>
      tempUnitFromString(_prefs.getString(CacheConstants.keyUnit));

  Future<void> setTempUnit(TempUnit unit) {
    return _prefs.setString(CacheConstants.keyUnit, unit.name);
  }

  // Theme mode.
  ThemeMode themeMode() {
    switch (_prefs.getString(CacheConstants.keyTheme)) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
      default:
        return ThemeMode.system;
    }
  }

  Future<void> setThemeMode(ThemeMode mode) {
    return _prefs.setString(CacheConstants.keyTheme, mode.name);
  }

  // Raw access for the weather cache (same prefs file, own key space).
  String? readString(String key) => _prefs.getString(key);
  Future<void> writeString(String key, String value) =>
      _prefs.setString(key, value);
  Future<void> remove(String key) => _prefs.remove(key);
  Set<String> keys() => _prefs.getKeys();
}
