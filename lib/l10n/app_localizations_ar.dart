// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => 'MAR-Wether';

  @override
  String get searchHint => 'ابحث عن مدينة مغربية…';

  @override
  String get emptySearch => 'اكتب للبحث بين مدن المغرب';

  @override
  String get noResults => 'لا توجد مدينة مطابقة';

  @override
  String get locateMe => 'موقعي';

  @override
  String get myLocation => 'موقعي';

  @override
  String get outsideMoroccoNotice => 'خارج المغرب: أحوال الطقس لموقعك الحالي.';

  @override
  String nearestCityIs(String city, String distance) {
    return 'أقرب مدينة: $city · على بعد $distance كم';
  }

  @override
  String get fallbackPositionNotice =>
      'تعذّر تحديد الموقع بدقة: تم استخدام آخر موقع معروف.';

  @override
  String get fallbackCityNotice =>
      'تعذّر تحديد الموقع: يتم عرض الدار البيضاء افتراضيًا.';

  @override
  String get favorites => 'المفضلة';

  @override
  String get noFavorites => 'اضغط على النجمة لإضافة مدينة إلى المفضلة.';

  @override
  String lastUpdated(String time) {
    return 'آخر تحديث: $time';
  }

  @override
  String get updatedJustNow => 'الآن';

  @override
  String updatedMinutesAgo(String minutes) {
    return 'قبل $minutes د';
  }

  @override
  String updatedHoursAgo(String hours) {
    return 'قبل $hours س';
  }

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get errorTitle => 'حدث خطأ';

  @override
  String get errorNetwork => 'لا يوجد اتصال. تحقق من الإنترنت وحاول مجددًا.';

  @override
  String get errorServer => 'خدمة الطقس غير متوفرة. حاول مجددًا.';

  @override
  String offlineBanner(String time) {
    return 'بدون اتصال: بيانات مخزنة من $time.';
  }

  @override
  String feelsLike(String temp) {
    return 'الإحساس $temp';
  }

  @override
  String todayMinMax(String min, String max) {
    return 'الصغرى $min · الكبرى $max';
  }

  @override
  String get humidity => 'الرطوبة';

  @override
  String humidityValue(String value) {
    return '$value %';
  }

  @override
  String get windSpeed => 'الرياح';

  @override
  String windValue(String value) {
    return '$value كم/س';
  }

  @override
  String get hourlyTitle => 'الـ 24 ساعة القادمة';

  @override
  String get dailyTitle => 'توقعات 7 أيام';

  @override
  String get today => 'اليوم';

  @override
  String get addFavorite => 'إضافة إلى المفضلة';

  @override
  String get removeFavorite => 'إزالة من المفضلة';

  @override
  String get settings => 'الإعدادات';

  @override
  String get language => 'اللغة';

  @override
  String get unit => 'الوحدة';

  @override
  String get celsius => 'مئوية (°C)';

  @override
  String get fahrenheit => 'فهرنهايت (°F)';

  @override
  String get theme => 'المظهر';

  @override
  String get themeSystem => 'النظام';

  @override
  String get themeLight => 'فاتح';

  @override
  String get themeDark => 'داكن';

  @override
  String get about => 'حول التطبيق';

  @override
  String version(String version) {
    return 'الإصدار $version';
  }

  @override
  String get aboutText =>
      'MAR-Wether — أحوال الطقس في المغرب. البيانات: Open-Meteo (استخدام غير تجاري). الإحداثيات: GeoNames / OpenStreetMap.';

  @override
  String get privacyTitle => 'سياسة الخصوصية';

  @override
  String get privacyText =>
      'لا يجمع MAR-Wether أي بيانات. يبقى موقعك في الذاكرة ولا يُحفظ أبدًا؛ تُخزن فقط مدنك المفضلة وآخر مدينة وتفضيلاتك على جهازك.';

  @override
  String get permissionDeniedTitle => 'الموقع مطلوب';

  @override
  String get permissionDeniedMessage =>
      'اسمح بالوصول إلى الموقع لعرض طقس موقعك.';

  @override
  String get permissionDeniedForeverTitle => 'تم حظر الموقع';

  @override
  String get permissionDeniedForeverMessage =>
      'فعّل الموقع من إعدادات التطبيق.';

  @override
  String get serviceDisabledTitle => 'خدمة الموقع متوقفة';

  @override
  String get serviceDisabledMessage => 'فعّل خدمات الموقع في جهازك.';

  @override
  String get requestAgain => 'سماح';

  @override
  String get openAppSettings => 'فتح الإعدادات';

  @override
  String get openLocationSettings => 'فتح إعدادات الموقع';

  @override
  String get cancel => 'إلغاء';

  @override
  String get ok => 'حسنًا';

  @override
  String get wmoClear => 'صحو';

  @override
  String get wmoPartlyCloudy => 'غائم جزئيًا';

  @override
  String get wmoOvercast => 'غائم';

  @override
  String get wmoFog => 'ضباب';

  @override
  String get wmoDrizzle => 'رذاذ';

  @override
  String get wmoRain => 'مطر';

  @override
  String get wmoSnow => 'ثلج';

  @override
  String get wmoThunderstorm => 'عاصفة رعدية';

  @override
  String get wmoUnknown => '—';
}
