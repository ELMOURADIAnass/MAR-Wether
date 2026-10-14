// Offline cities repository: loads the bundled dataset and filters it.
//
// Matching is case-/accent-insensitive across FR, EN, AR names plus
// aliases ("Fez", "Marrakesh", "Tangier", "Meknes", "Tetouan"…).
// Debounce (~300 ms) is handled by the search UI, not here.
import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../core/utils/text_normalization.dart';
import 'models/city.dart';

/// Loads and queries the offline Moroccan cities dataset.
class CitiesRepository {
  CitiesRepository({List<City>? cities}) : _cities = cities;

  List<City>? _cities;

  /// Loads the bundled JSON once; subsequent calls return the cache.
  Future<List<City>> load() async {
    final List<City>? cached = _cities;
    if (cached != null) {
      return cached;
    }
    final String raw = await rootBundle.loadString(
      'assets/data/morocco_cities.json',
    );
    final Object? decoded = jsonDecode(raw);
    if (decoded is! List) {
      throw const FormatException('Cities dataset must be a JSON array');
    }
    final List<City> parsed = decoded
        .whereType<Map<String, dynamic>>()
        .map(City.fromJson)
        .toList(growable: false);
    _cities = parsed;
    return parsed;
  }

  /// Returns cities matching [query] (empty query → empty list).
  List<City> search(List<City> cities, String query) {
    final String trimmed = query.trim();
    if (trimmed.isEmpty) {
      return const <City>[];
    }
    final String latinQuery = normalizeLatin(trimmed);
    final String arabicQuery = normalizeArabic(trimmed);
    final List<({City city, int rank})> hits = <({City city, int rank})>[];
    for (final City city in cities) {
      final int rank = _matchRank(city, latinQuery, arabicQuery);
      if (rank >= 0) {
        hits.add((city: city, rank: rank));
      }
    }
    // Prefix matches first, then alphabetical in French.
    hits.sort((a, b) {
      final int byRank = a.rank.compareTo(b.rank);
      return byRank != 0 ? byRank : a.city.nameFr.compareTo(b.city.nameFr);
    });
    return hits.map((h) => h.city).toList(growable: false);
  }

  /// Rank 0 = prefix match, 1 = contains match, -1 = no match.
  int _matchRank(City city, String latinQuery, String arabicQuery) {
    if (latinQuery.isNotEmpty) {
      final List<String> latinFields = <String>[
        normalizeLatin(city.nameFr),
        normalizeLatin(city.nameEn),
        normalizeLatin(city.region),
        for (final String a in city.aliases) normalizeLatin(a),
      ];
      bool contains = false;
      for (final String field in latinFields) {
        if (field.startsWith(latinQuery)) {
          return 0;
        }
        if (field.contains(latinQuery)) {
          contains = true;
        }
      }
      if (contains) {
        return 1;
      }
    }
    if (arabicQuery.isNotEmpty) {
      final String nameAr = normalizeArabic(city.nameAr);
      if (nameAr.startsWith(arabicQuery)) {
        return 0;
      }
      if (nameAr.contains(arabicQuery)) {
        return 1;
      }
    }
    return -1;
  }

  /// Lookup by id, or null when unknown.
  City? byId(List<City> cities, String id) {
    for (final City city in cities) {
      if (city.id == id) {
        return city;
      }
    }
    return null;
  }
}
