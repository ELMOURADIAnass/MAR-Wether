import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('fr'),
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @appName.
  ///
  /// In fr, this message translates to:
  /// **'MAR-Wether'**
  String get appName;

  /// No description provided for @searchHint.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher une ville marocaine…'**
  String get searchHint;

  /// No description provided for @emptySearch.
  ///
  /// In fr, this message translates to:
  /// **'Tapez pour rechercher parmi les villes du Maroc'**
  String get emptySearch;

  /// No description provided for @noResults.
  ///
  /// In fr, this message translates to:
  /// **'Aucune ville trouvée'**
  String get noResults;

  /// No description provided for @locateMe.
  ///
  /// In fr, this message translates to:
  /// **'Me localiser'**
  String get locateMe;

  /// No description provided for @myLocation.
  ///
  /// In fr, this message translates to:
  /// **'Ma position'**
  String get myLocation;

  /// No description provided for @outsideMoroccoNotice.
  ///
  /// In fr, this message translates to:
  /// **'Hors du Maroc : météo de votre position exacte.'**
  String get outsideMoroccoNotice;

  /// No description provided for @nearestCityIs.
  ///
  /// In fr, this message translates to:
  /// **'Ville la plus proche : {city} · {distance} km'**
  String nearestCityIs(String city, String distance);

  /// No description provided for @fallbackPositionNotice.
  ///
  /// In fr, this message translates to:
  /// **'Position exacte indisponible : dernière position connue utilisée.'**
  String get fallbackPositionNotice;

  /// No description provided for @fallbackCityNotice.
  ///
  /// In fr, this message translates to:
  /// **'Position indisponible : Casablanca affichée par défaut.'**
  String get fallbackCityNotice;

  /// No description provided for @favorites.
  ///
  /// In fr, this message translates to:
  /// **'Favoris'**
  String get favorites;

  /// No description provided for @noFavorites.
  ///
  /// In fr, this message translates to:
  /// **'Touchez l’étoile d’une ville pour l’ajouter ici.'**
  String get noFavorites;

  /// No description provided for @lastUpdated.
  ///
  /// In fr, this message translates to:
  /// **'Dernière mise à jour : {time}'**
  String lastUpdated(String time);

  /// No description provided for @updatedJustNow.
  ///
  /// In fr, this message translates to:
  /// **'à l’instant'**
  String get updatedJustNow;

  /// No description provided for @updatedMinutesAgo.
  ///
  /// In fr, this message translates to:
  /// **'il y a {minutes} min'**
  String updatedMinutesAgo(String minutes);

  /// No description provided for @updatedHoursAgo.
  ///
  /// In fr, this message translates to:
  /// **'il y a {hours} h'**
  String updatedHoursAgo(String hours);

  /// No description provided for @retry.
  ///
  /// In fr, this message translates to:
  /// **'Réessayer'**
  String get retry;

  /// No description provided for @errorTitle.
  ///
  /// In fr, this message translates to:
  /// **'Quelque chose s’est mal passé'**
  String get errorTitle;

  /// No description provided for @errorNetwork.
  ///
  /// In fr, this message translates to:
  /// **'Pas de connexion. Vérifiez Internet et réessayez.'**
  String get errorNetwork;

  /// No description provided for @errorServer.
  ///
  /// In fr, this message translates to:
  /// **'Le service météo est indisponible. Réessayez.'**
  String get errorServer;

  /// No description provided for @offlineBanner.
  ///
  /// In fr, this message translates to:
  /// **'Hors connexion : données en cache du {time}.'**
  String offlineBanner(String time);

  /// No description provided for @feelsLike.
  ///
  /// In fr, this message translates to:
  /// **'Ressenti {temp}'**
  String feelsLike(String temp);

  /// No description provided for @todayMinMax.
  ///
  /// In fr, this message translates to:
  /// **'Min {min} · Max {max}'**
  String todayMinMax(String min, String max);

  /// No description provided for @humidity.
  ///
  /// In fr, this message translates to:
  /// **'Humidité'**
  String get humidity;

  /// No description provided for @humidityValue.
  ///
  /// In fr, this message translates to:
  /// **'{value} %'**
  String humidityValue(String value);

  /// No description provided for @windSpeed.
  ///
  /// In fr, this message translates to:
  /// **'Vent'**
  String get windSpeed;

  /// No description provided for @windValue.
  ///
  /// In fr, this message translates to:
  /// **'{value} km/h'**
  String windValue(String value);

  /// No description provided for @hourlyTitle.
  ///
  /// In fr, this message translates to:
  /// **'Prochaines 24 heures'**
  String get hourlyTitle;

  /// No description provided for @dailyTitle.
  ///
  /// In fr, this message translates to:
  /// **'Prévisions 7 jours'**
  String get dailyTitle;

  /// No description provided for @today.
  ///
  /// In fr, this message translates to:
  /// **'Aujourd’hui'**
  String get today;

  /// No description provided for @addFavorite.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter aux favoris'**
  String get addFavorite;

  /// No description provided for @removeFavorite.
  ///
  /// In fr, this message translates to:
  /// **'Retirer des favoris'**
  String get removeFavorite;

  /// No description provided for @settings.
  ///
  /// In fr, this message translates to:
  /// **'Paramètres'**
  String get settings;

  /// No description provided for @language.
  ///
  /// In fr, this message translates to:
  /// **'Langue'**
  String get language;

  /// No description provided for @unit.
  ///
  /// In fr, this message translates to:
  /// **'Unité'**
  String get unit;

  /// No description provided for @celsius.
  ///
  /// In fr, this message translates to:
  /// **'Celsius (°C)'**
  String get celsius;

  /// No description provided for @fahrenheit.
  ///
  /// In fr, this message translates to:
  /// **'Fahrenheit (°F)'**
  String get fahrenheit;

  /// No description provided for @theme.
  ///
  /// In fr, this message translates to:
  /// **'Thème'**
  String get theme;

  /// No description provided for @themeSystem.
  ///
  /// In fr, this message translates to:
  /// **'Système'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In fr, this message translates to:
  /// **'Clair'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In fr, this message translates to:
  /// **'Sombre'**
  String get themeDark;

  /// No description provided for @about.
  ///
  /// In fr, this message translates to:
  /// **'À propos'**
  String get about;

  /// No description provided for @version.
  ///
  /// In fr, this message translates to:
  /// **'Version {version}'**
  String version(String version);

  /// No description provided for @aboutText.
  ///
  /// In fr, this message translates to:
  /// **'MAR-Wether — la météo du Maroc. Données : Open-Meteo (usage non commercial). Coordonnées des villes : GeoNames / OpenStreetMap.'**
  String get aboutText;

  /// No description provided for @privacyTitle.
  ///
  /// In fr, this message translates to:
  /// **'Politique de confidentialité'**
  String get privacyTitle;

  /// No description provided for @privacyText.
  ///
  /// In fr, this message translates to:
  /// **'MAR-Wether ne collecte aucune donnée. Votre position GPS reste en mémoire et n’est jamais enregistrée ; seuls vos favoris, votre dernière ville et vos préférences sont stockés sur l’appareil.'**
  String get privacyText;

  /// No description provided for @permissionDeniedTitle.
  ///
  /// In fr, this message translates to:
  /// **'Position nécessaire'**
  String get permissionDeniedTitle;

  /// No description provided for @permissionDeniedMessage.
  ///
  /// In fr, this message translates to:
  /// **'Autorisez la localisation pour afficher la météo de votre position.'**
  String get permissionDeniedMessage;

  /// No description provided for @permissionDeniedForeverTitle.
  ///
  /// In fr, this message translates to:
  /// **'Localisation bloquée'**
  String get permissionDeniedForeverTitle;

  /// No description provided for @permissionDeniedForeverMessage.
  ///
  /// In fr, this message translates to:
  /// **'Activez la localisation dans les réglages de l’application.'**
  String get permissionDeniedForeverMessage;

  /// No description provided for @serviceDisabledTitle.
  ///
  /// In fr, this message translates to:
  /// **'Localisation désactivée'**
  String get serviceDisabledTitle;

  /// No description provided for @serviceDisabledMessage.
  ///
  /// In fr, this message translates to:
  /// **'Activez les services de localisation de l’appareil.'**
  String get serviceDisabledMessage;

  /// No description provided for @requestAgain.
  ///
  /// In fr, this message translates to:
  /// **'Autoriser'**
  String get requestAgain;

  /// No description provided for @openAppSettings.
  ///
  /// In fr, this message translates to:
  /// **'Ouvrir les réglages'**
  String get openAppSettings;

  /// No description provided for @openLocationSettings.
  ///
  /// In fr, this message translates to:
  /// **'Ouvrir les réglages de localisation'**
  String get openLocationSettings;

  /// No description provided for @cancel.
  ///
  /// In fr, this message translates to:
  /// **'Annuler'**
  String get cancel;

  /// No description provided for @ok.
  ///
  /// In fr, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @wmoClear.
  ///
  /// In fr, this message translates to:
  /// **'Dégagé'**
  String get wmoClear;

  /// No description provided for @wmoPartlyCloudy.
  ///
  /// In fr, this message translates to:
  /// **'Partiellement nuageux'**
  String get wmoPartlyCloudy;

  /// No description provided for @wmoOvercast.
  ///
  /// In fr, this message translates to:
  /// **'Couvert'**
  String get wmoOvercast;

  /// No description provided for @wmoFog.
  ///
  /// In fr, this message translates to:
  /// **'Brouillard'**
  String get wmoFog;

  /// No description provided for @wmoDrizzle.
  ///
  /// In fr, this message translates to:
  /// **'Bruine'**
  String get wmoDrizzle;

  /// No description provided for @wmoRain.
  ///
  /// In fr, this message translates to:
  /// **'Pluie'**
  String get wmoRain;

  /// No description provided for @wmoSnow.
  ///
  /// In fr, this message translates to:
  /// **'Neige'**
  String get wmoSnow;

  /// No description provided for @wmoThunderstorm.
  ///
  /// In fr, this message translates to:
  /// **'Orage'**
  String get wmoThunderstorm;

  /// No description provided for @wmoUnknown.
  ///
  /// In fr, this message translates to:
  /// **'—'**
  String get wmoUnknown;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
