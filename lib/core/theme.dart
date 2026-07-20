import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Design tokens copied 1:1 from assets/css/styles.css — do not "improve" or
/// re-interpret these. If the website's palette changes, update the source
/// values there first, then mirror them here.
class AppColors {
  // Brand blue
  static const brand50 = Color(0xFFEAF1FE);
  static const brand100 = Color(0xFFD3E3FC);
  static const brand400 = Color(0xFF6B9BF5);
  static const brand500 = Color(0xFF4A84F0);
  static const brand600 = Color(0xFF2F6FED);
  static const brand700 = Color(0xFF2558C4);
  static const brand900 = Color(0xFF16305E);

  // Warm CTA accent — reserved for the single primary action per screen
  static const cta500 = Color(0xFFFF6B4A);
  static const cta600 = Color(0xFFE5502F);

  static const accent500 = Color(0xFF10B981);
  static const accent600 = Color(0xFF059669);

  static const danger = Color(0xFFEF4444);
  static const dangerBgLight = Color(0xFFFEF2F2);
  static const warning = Color(0xFFF59E0B);
  static const warningBgLight = Color(0xFFFFFBEB);
  static const success = Color(0xFF10B981);
  static const successBgLight = Color(0xFFECFDF5);
  static const info = Color(0xFF3B82F6);
  static const infoBgLight = Color(0xFFEFF6FF);

  // Light theme neutrals
  static const inkLight900 = Color(0xFF0F172A);
  static const inkLight800 = Color(0xFF1E293B);
  static const inkLight700 = Color(0xFF334155);
  static const inkLight500 = Color(0xFF64748B);
  static const inkLight400 = Color(0xFF94A3B8);
  static const surfaceLight = Color(0xFFF7F6F3);
  static const cardLight = Color(0xFFFFFFFF);
  static const borderLight = Color(0xFFE6E9F2);

  // Dark theme neutrals (from :root[data-theme="dark"])
  static const inkDark900 = Color(0xFFF1F5F9);
  static const inkDark800 = Color(0xFFE2E8F0);
  static const inkDark700 = Color(0xFFCBD5E1);
  static const inkDark500 = Color(0xFF97A3B5);
  static const inkDark400 = Color(0xFF6B7889);
  static const surfaceDark = Color(0xFF0F1419);
  static const cardDark = Color(0xFF171D26);
  static const borderDark = Color(0xFF262F3B);
}

class AppRadius {
  static const sm = 8.0;
  static const md = 14.0;
  static const lg = 20.0;
}

class AppTheme {
  static TextTheme _textTheme(Color heading, Color body) {
    // Headings use Plus Jakarta Sans (800 weight), body uses Inter — matches
    // `.brand-mark,.ac-title` and `h1..h6` rules in styles.css exactly.
    final headingFont = GoogleFonts.plusJakartaSansTextTheme();
    final bodyFont = GoogleFonts.interTextTheme();
    return bodyFont.copyWith(
      displayLarge: headingFont.displayLarge?.copyWith(color: heading, fontWeight: FontWeight.w800, letterSpacing: -0.02),
      displayMedium: headingFont.displayMedium?.copyWith(color: heading, fontWeight: FontWeight.w800, letterSpacing: -0.02),
      headlineLarge: headingFont.headlineLarge?.copyWith(color: heading, fontWeight: FontWeight.w700, letterSpacing: -0.02),
      headlineMedium: headingFont.headlineMedium?.copyWith(color: heading, fontWeight: FontWeight.w700, letterSpacing: -0.02),
      headlineSmall: headingFont.headlineSmall?.copyWith(color: heading, fontWeight: FontWeight.w700, letterSpacing: -0.02),
      titleLarge: headingFont.titleLarge?.copyWith(color: heading, fontWeight: FontWeight.w800),
      titleMedium: headingFont.titleMedium?.copyWith(color: heading, fontWeight: FontWeight.w700),
      bodyLarge: bodyFont.bodyLarge?.copyWith(color: body),
      bodyMedium: bodyFont.bodyMedium?.copyWith(color: body),
      bodySmall: bodyFont.bodySmall?.copyWith(color: body),
    );
  }

  static ThemeData get light => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: AppColors.surfaceLight,
        colorScheme: const ColorScheme.light(
          primary: AppColors.brand600,
          secondary: AppColors.cta500,
          surface: AppColors.cardLight,
          error: AppColors.danger,
        ),
        cardColor: AppColors.cardLight,
        dividerColor: AppColors.borderLight,
        textTheme: _textTheme(AppColors.inkLight900, AppColors.inkLight800),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.surfaceLight,
          foregroundColor: AppColors.inkLight900,
          elevation: 0,
          centerTitle: false,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.brand600,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
            textStyle: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.cardLight,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.md), borderSide: const BorderSide(color: AppColors.borderLight)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.md), borderSide: const BorderSide(color: AppColors.borderLight)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.md), borderSide: const BorderSide(color: AppColors.brand600, width: 1.5)),
        ),
      );

  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.surfaceDark,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.brand400,
          secondary: AppColors.cta500,
          surface: AppColors.cardDark,
          error: AppColors.danger,
        ),
        cardColor: AppColors.cardDark,
        dividerColor: AppColors.borderDark,
        textTheme: _textTheme(AppColors.inkDark900, AppColors.inkDark800),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.surfaceDark,
          foregroundColor: AppColors.inkDark900,
          elevation: 0,
          centerTitle: false,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.brand600,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
            textStyle: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.cardDark,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.md), borderSide: const BorderSide(color: AppColors.borderDark)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.md), borderSide: const BorderSide(color: AppColors.borderDark)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.md), borderSide: const BorderSide(color: AppColors.brand400, width: 1.5)),
        ),
      );
}
