// Material 3 light/dark themes with Moroccan brand accents.
//
// Red (#C1272D) and green (#006233) appear in the home header only;
// gold (#D4A017) is reserved for small highlights. Body surfaces stay
// neutral so text contrast meets WCAG AA in both brightness modes.
// withOpacity is avoided (deprecated); withValues is used instead.
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants/app_constants.dart';

abstract final class AppTheme {
  static const Color _lightSeed = AppColors.red;
  static const Color _darkSeed = AppColors.red;

  /// Latin font family; Arabic script falls back to Cairo via
  /// [fontFamilyFallback] so mixed-language text renders correctly.
  static String get _arabicFamily => GoogleFonts.cairo().fontFamily ?? 'Cairo';

  static List<String> get _fallback => <String>[_arabicFamily];

  static ThemeData light() {
    final ColorScheme scheme = ColorScheme.fromSeed(
      seedColor: _lightSeed,
      brightness: Brightness.light,
    ).copyWith(
      // Warm sand tint for the Moroccan background identity. Content
      // colors (onSurface etc.) are unchanged, so contrast is kept.
      surface: const Color(0xFFFAF5EB),
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      textTheme: GoogleFonts.poppinsTextTheme().apply(
        fontFamilyFallback: _fallback,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        centerTitle: true,
      ),
      cardTheme: const CardThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
        margin: EdgeInsets.all(8),
      ),
    );
  }

  static ThemeData dark() {
    final ColorScheme scheme = ColorScheme.fromSeed(
      seedColor: _darkSeed,
      brightness: Brightness.dark,
    ).copyWith(surface: const Color(0xFF171310));
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      textTheme: GoogleFonts.poppinsTextTheme(
        ThemeData.dark().textTheme,
      ).apply(fontFamilyFallback: _fallback),
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        centerTitle: true,
      ),
      cardTheme: const CardThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
        margin: EdgeInsets.all(8),
      ),
    );
  }

  /// Header gradient for the home screen (zellige pattern sits on top).
  static LinearGradient headerGradient(Brightness brightness) {
    if (brightness == Brightness.dark) {
      return const LinearGradient(
        begin: AlignmentDirectional.topStart,
        end: AlignmentDirectional.bottomEnd,
        colors: <Color>[Color(0xFF8A1F24), Color(0xFF0B4429)],
      );
    }
    return const LinearGradient(
      begin: AlignmentDirectional.topStart,
      end: AlignmentDirectional.bottomEnd,
      colors: <Color>[Color(0xFFB4232A), AppColors.green],
    );
  }
}
