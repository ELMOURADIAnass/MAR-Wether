// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appName => 'MAR-Wether';

  @override
  String get searchHint => 'Rechercher une ville marocaine…';

  @override
  String get emptySearch => 'Tapez pour rechercher parmi les villes du Maroc';

  @override
  String get noResults => 'Aucune ville trouvée';

  @override
  String get locateMe => 'Me localiser';

  @override
  String get myLocation => 'Ma position';

  @override
  String get outsideMoroccoNotice =>
      'Hors du Maroc : météo de votre position exacte.';

  @override
  String nearestCityIs(String city, String distance) {
    return 'Ville la plus proche : $city · $distance km';
  }

  @override
  String get fallbackPositionNotice =>
      'Position exacte indisponible : dernière position connue utilisée.';

  @override
  String get fallbackCityNotice =>
      'Position indisponible : Casablanca affichée par défaut.';

  @override
  String get favorites => 'Favoris';

  @override
  String get noFavorites => 'Touchez l’étoile d’une ville pour l’ajouter ici.';

  @override
  String lastUpdated(String time) {
    return 'Dernière mise à jour : $time';
  }

  @override
  String get updatedJustNow => 'à l’instant';

  @override
  String updatedMinutesAgo(String minutes) {
    return 'il y a $minutes min';
  }

  @override
  String updatedHoursAgo(String hours) {
    return 'il y a $hours h';
  }

  @override
  String get retry => 'Réessayer';

  @override
  String get errorTitle => 'Quelque chose s’est mal passé';

  @override
  String get errorNetwork =>
      'Pas de connexion. Vérifiez Internet et réessayez.';

  @override
  String get errorServer => 'Le service météo est indisponible. Réessayez.';

  @override
  String offlineBanner(String time) {
    return 'Hors connexion : données en cache du $time.';
  }

  @override
  String feelsLike(String temp) {
    return 'Ressenti $temp';
  }

  @override
  String todayMinMax(String min, String max) {
    return 'Min $min · Max $max';
  }

  @override
  String get humidity => 'Humidité';

  @override
  String humidityValue(String value) {
    return '$value %';
  }

  @override
  String get windSpeed => 'Vent';

  @override
  String windValue(String value) {
    return '$value km/h';
  }

  @override
  String get hourlyTitle => 'Prochaines 24 heures';

  @override
  String get dailyTitle => 'Prévisions 7 jours';

  @override
  String get today => 'Aujourd’hui';

  @override
  String get addFavorite => 'Ajouter aux favoris';

  @override
  String get removeFavorite => 'Retirer des favoris';

  @override
  String get settings => 'Paramètres';

  @override
  String get language => 'Langue';

  @override
  String get unit => 'Unité';

  @override
  String get celsius => 'Celsius (°C)';

  @override
  String get fahrenheit => 'Fahrenheit (°F)';

  @override
  String get theme => 'Thème';

  @override
  String get themeSystem => 'Système';

  @override
  String get themeLight => 'Clair';

  @override
  String get themeDark => 'Sombre';

  @override
  String get about => 'À propos';

  @override
  String version(String version) {
    return 'Version $version';
  }

  @override
  String get aboutText =>
      'MAR-Wether — la météo du Maroc. Données : Open-Meteo (usage non commercial). Coordonnées des villes : GeoNames / OpenStreetMap.';

  @override
  String get privacyTitle => 'Politique de confidentialité';

  @override
  String get privacyText =>
      'MAR-Wether ne collecte aucune donnée. Votre position GPS reste en mémoire et n’est jamais enregistrée ; seuls vos favoris, votre dernière ville et vos préférences sont stockés sur l’appareil.';

  @override
  String get permissionDeniedTitle => 'Position nécessaire';

  @override
  String get permissionDeniedMessage =>
      'Autorisez la localisation pour afficher la météo de votre position.';

  @override
  String get permissionDeniedForeverTitle => 'Localisation bloquée';

  @override
  String get permissionDeniedForeverMessage =>
      'Activez la localisation dans les réglages de l’application.';

  @override
  String get serviceDisabledTitle => 'Localisation désactivée';

  @override
  String get serviceDisabledMessage =>
      'Activez les services de localisation de l’appareil.';

  @override
  String get requestAgain => 'Autoriser';

  @override
  String get openAppSettings => 'Ouvrir les réglages';

  @override
  String get openLocationSettings => 'Ouvrir les réglages de localisation';

  @override
  String get cancel => 'Annuler';

  @override
  String get ok => 'OK';

  @override
  String get wmoClear => 'Dégagé';

  @override
  String get wmoPartlyCloudy => 'Partiellement nuageux';

  @override
  String get wmoOvercast => 'Couvert';

  @override
  String get wmoFog => 'Brouillard';

  @override
  String get wmoDrizzle => 'Bruine';

  @override
  String get wmoRain => 'Pluie';

  @override
  String get wmoSnow => 'Neige';

  @override
  String get wmoThunderstorm => 'Orage';

  @override
  String get wmoUnknown => '—';
}
