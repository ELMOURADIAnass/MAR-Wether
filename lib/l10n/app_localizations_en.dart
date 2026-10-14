// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'MAR-Wether';

  @override
  String get searchHint => 'Search a Moroccan city…';

  @override
  String get emptySearch => 'Type to search among Moroccan cities';

  @override
  String get noResults => 'No matching city';

  @override
  String get locateMe => 'Locate me';

  @override
  String get myLocation => 'My location';

  @override
  String get outsideMoroccoNotice =>
      'Outside Morocco: weather for your exact position.';

  @override
  String nearestCityIs(String city, String distance) {
    return 'Nearest city: $city · $distance km';
  }

  @override
  String get fallbackPositionNotice =>
      'Exact fix unavailable: last known position used.';

  @override
  String get fallbackCityNotice =>
      'Position unavailable: showing Casablanca by default.';

  @override
  String get favorites => 'Favorites';

  @override
  String get noFavorites => 'Tap the star on a city to add it here.';

  @override
  String lastUpdated(String time) {
    return 'Last updated: $time';
  }

  @override
  String get updatedJustNow => 'just now';

  @override
  String updatedMinutesAgo(String minutes) {
    return '$minutes min ago';
  }

  @override
  String updatedHoursAgo(String hours) {
    return '$hours h ago';
  }

  @override
  String get retry => 'Retry';

  @override
  String get errorTitle => 'Something went wrong';

  @override
  String get errorNetwork => 'No connection. Check the internet and try again.';

  @override
  String get errorServer => 'Weather service unavailable. Try again.';

  @override
  String offlineBanner(String time) {
    return 'Offline: cached data from $time.';
  }

  @override
  String feelsLike(String temp) {
    return 'Feels like $temp';
  }

  @override
  String todayMinMax(String min, String max) {
    return 'Min $min · Max $max';
  }

  @override
  String get humidity => 'Humidity';

  @override
  String humidityValue(String value) {
    return '$value %';
  }

  @override
  String get windSpeed => 'Wind';

  @override
  String windValue(String value) {
    return '$value km/h';
  }

  @override
  String get hourlyTitle => 'Next 24 hours';

  @override
  String get dailyTitle => '7-day forecast';

  @override
  String get today => 'Today';

  @override
  String get addFavorite => 'Add to favorites';

  @override
  String get removeFavorite => 'Remove from favorites';

  @override
  String get settings => 'Settings';

  @override
  String get language => 'Language';

  @override
  String get unit => 'Unit';

  @override
  String get celsius => 'Celsius (°C)';

  @override
  String get fahrenheit => 'Fahrenheit (°F)';

  @override
  String get theme => 'Theme';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get about => 'About';

  @override
  String version(String version) {
    return 'Version $version';
  }

  @override
  String get aboutText =>
      'MAR-Wether — Morocco weather. Data: Open-Meteo (non-commercial use). City coordinates: GeoNames / OpenStreetMap.';

  @override
  String get privacyTitle => 'Privacy policy';

  @override
  String get privacyText =>
      'MAR-Wether collects no data. Your GPS position stays in memory and is never stored; only your favorites, last city and preferences are kept on the device.';

  @override
  String get permissionDeniedTitle => 'Location needed';

  @override
  String get permissionDeniedMessage =>
      'Allow location access to show the weather at your position.';

  @override
  String get permissionDeniedForeverTitle => 'Location blocked';

  @override
  String get permissionDeniedForeverMessage =>
      'Enable location in the app settings.';

  @override
  String get serviceDisabledTitle => 'Location services off';

  @override
  String get serviceDisabledMessage => 'Enable the device location services.';

  @override
  String get requestAgain => 'Allow';

  @override
  String get openAppSettings => 'Open settings';

  @override
  String get openLocationSettings => 'Open location settings';

  @override
  String get cancel => 'Cancel';

  @override
  String get ok => 'OK';

  @override
  String get wmoClear => 'Clear';

  @override
  String get wmoPartlyCloudy => 'Partly cloudy';

  @override
  String get wmoOvercast => 'Overcast';

  @override
  String get wmoFog => 'Fog';

  @override
  String get wmoDrizzle => 'Drizzle';

  @override
  String get wmoRain => 'Rain';

  @override
  String get wmoSnow => 'Snow';

  @override
  String get wmoThunderstorm => 'Thunderstorm';

  @override
  String get wmoUnknown => '—';
}
