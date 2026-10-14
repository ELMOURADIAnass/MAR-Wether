// Offline city model. One entry per city/town in
// assets/data/morocco_cities.json.
import 'package:flutter/foundation.dart';

/// Immutable Moroccan city with trilingual names.
///
/// Coordinates point to the city centre and come from GeoNames /
/// OpenStreetMap. Entries that could not be verified carry
/// `verified: false` and are listed in the README.
@immutable
final class City {
  const City({
    required this.id,
    required this.nameFr,
    required this.nameAr,
    required this.nameEn,
    required this.region,
    required this.lat,
    required this.lon,
    this.verified = true,
    this.aliases = const <String>[],
  });

  final String id;
  final String nameFr;
  final String nameAr;
  final String nameEn;

  /// Administrative region name (e.g. "Casablanca-Settat").
  final String region;
  final double lat;
  final double lon;

  /// False when the coordinate could not be verified.
  final bool verified;

  /// Extra Latin-script spellings ("Fez", "Marrakesh", "Tangier"…).
  final List<String> aliases;

  /// Name in the requested language code ('ar', 'fr', 'en').
  String nameFor(String languageCode) {
    switch (languageCode) {
      case 'ar':
        return nameAr;
      case 'en':
        return nameEn;
      case 'fr':
      default:
        return nameFr;
    }
  }

  factory City.fromJson(Map<String, dynamic> json) {
    final Object? id = json['id'];
    final Object? nameFr = json['name_fr'];
    final Object? nameAr = json['name_ar'];
    final Object? nameEn = json['name_en'];
    final Object? region = json['region'];
    final Object? lat = json['lat'];
    final Object? lon = json['lon'];
    if (id is! String ||
        nameFr is! String ||
        nameAr is! String ||
        nameEn is! String ||
        region is! String ||
        lat is! num ||
        lon is! num) {
      throw const FormatException('Invalid city entry');
    }
    final Object? verified = json['verified'];
    final Object? aliases = json['aliases'];
    return City(
      id: id,
      nameFr: nameFr,
      nameAr: nameAr,
      nameEn: nameEn,
      region: region,
      lat: lat.toDouble(),
      lon: lon.toDouble(),
      verified: verified is bool ? verified : true,
      aliases: aliases is List
          ? aliases.whereType<String>().toList(growable: false)
          : const <String>[],
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'name_fr': nameFr,
      'name_ar': nameAr,
      'name_en': nameEn,
      'region': region,
      'lat': lat,
      'lon': lon,
      'verified': verified,
      if (aliases.isNotEmpty) 'aliases': aliases,
    };
  }

  @override
  bool operator ==(Object other) {
    return other is City && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
