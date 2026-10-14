// WMO weather-code mapping to localization keys and Material icons.
//
// Both icon variants are Material Icons (the weather_icons package is
// unmaintained — last release 2021, Dart 2 only — so it cannot be used
// with Dart 3). Day/night comes from Open-Meteo `current=is_day`.
import 'package:flutter/material.dart';

/// Localized description key (see ARB `wmo*` entries) + day/night icons.
class WmoInfo {
  const WmoInfo(this.descriptionKey, this.dayIcon, this.nightIcon);
  final String descriptionKey;
  final IconData dayIcon;
  final IconData nightIcon;
}

const WmoInfo _clear = WmoInfo('wmoClear', Icons.wb_sunny, Icons.nights_stay);
const WmoInfo _partlyCloudy = WmoInfo(
  'wmoPartlyCloudy',
  Icons.wb_cloudy,
  Icons.cloud_queue,
);
const WmoInfo _overcast = WmoInfo('wmoOvercast', Icons.cloud, Icons.cloud);
const WmoInfo _fog = WmoInfo('wmoFog', Icons.cloud_queue, Icons.cloud_queue);
const WmoInfo _drizzle = WmoInfo('wmoDrizzle', Icons.grain, Icons.grain);
const WmoInfo _rain = WmoInfo('wmoRain', Icons.water_drop, Icons.water_drop);
const WmoInfo _snow = WmoInfo('wmoSnow', Icons.ac_unit, Icons.ac_unit);
const WmoInfo _thunderstorm = WmoInfo(
  'wmoThunderstorm',
  Icons.thunderstorm,
  Icons.thunderstorm,
);
const WmoInfo _unknown = WmoInfo('wmoUnknown', Icons.cloud_off, Icons.cloud_off);

/// Maps an Open-Meteo WMO code to its display info. Unknown codes fall
/// back to [_unknown] instead of throwing.
WmoInfo wmoInfo(int code) {
  switch (code) {
    case 0:
    case 1:
      return _clear;
    case 2:
      return _partlyCloudy;
    case 3:
      return _overcast;
    case 45:
    case 48:
      return _fog;
    case 51:
    case 53:
    case 55:
    case 56:
    case 57:
      return _drizzle;
    case 61:
    case 63:
    case 65:
    case 66:
    case 67:
    case 80:
    case 81:
    case 82:
      return _rain;
    case 71:
    case 73:
    case 75:
    case 77:
    case 85:
    case 86:
      return _snow;
    case 95:
    case 96:
    case 99:
      return _thunderstorm;
    default:
      return _unknown;
  }
}

/// Convenience: picks the day or night icon for [code].
IconData wmoIcon(int code, {required bool isDay}) {
  final WmoInfo info = wmoInfo(code);
  return isDay ? info.dayIcon : info.nightIcon;
}

/// Display color for a WMO code. Fixed hues chosen to stay readable on
/// both light and dark surfaces (WCAG AA for large icons/text).
Color wmoColor(int code, {required bool isDay}) {
  switch (wmoInfo(code).descriptionKey) {
    case 'wmoClear':
      return isDay ? const Color(0xFFEAA200) : const Color(0xFF9FA8DA);
    case 'wmoPartlyCloudy':
    case 'wmoOvercast':
    case 'wmoFog':
      return const Color(0xFF78909C);
    case 'wmoDrizzle':
    case 'wmoRain':
      return const Color(0xFF42A5F5);
    case 'wmoSnow':
      return const Color(0xFF26C6DA);
    case 'wmoThunderstorm':
      return const Color(0xFF7E57C2);
    default:
      return const Color(0xFF78909C);
  }
}
