// Maps a WMO description key to the active locale's string.
import 'package:mar_weather/core/utils/wmo_mapping.dart';
import 'package:mar_weather/l10n/app_localizations.dart';

String wmoLabel(AppLocalizations l10n, int code) {
  return switch (wmoInfo(code).descriptionKey) {
    'wmoClear' => l10n.wmoClear,
    'wmoPartlyCloudy' => l10n.wmoPartlyCloudy,
    'wmoOvercast' => l10n.wmoOvercast,
    'wmoFog' => l10n.wmoFog,
    'wmoDrizzle' => l10n.wmoDrizzle,
    'wmoRain' => l10n.wmoRain,
    'wmoSnow' => l10n.wmoSnow,
    'wmoThunderstorm' => l10n.wmoThunderstorm,
    _ => l10n.wmoUnknown,
  };
}
