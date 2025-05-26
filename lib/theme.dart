import 'package:flutter/material.dart';

class AppColors {
  // Base Colors
  static const Color accent = Color(0xFF00C2BA);
  static const Color accentHover = Color(0xFF02A8A0);
  static const Color background = Color(0xFF0D0C1D);
  static const Color card = Color(0xFF1D1934);
  static const Color text = Color(0xFFE4DDFF);
  static const Color muted = Color(0xFF9CA3AF);
  static const Color border = Color(0xFF36009C);
  static const Color error = Color(0xFFFF7B72);

  // Semantic
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFEAB308);
  static const Color danger = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);
  static const Color purple = Color(0xFF8B5CF6);
  static const Color pink = Color(0xFFEC4899);

  // Grayscale
  static const Color gray800 = Color(0xFF1F2937);
  static const Color gray700 = Color(0xFF374151);
  static const Color gray600 = Color(0xFF4B5563);
  static const Color gray500 = Color(0xFF6B7280);
  static const Color gray400 = Color(0xFF9CA3AF);
}

class AppSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
}

class AppTypography {
  static const String fontFamily = 'RobotoMono';

  static const TextStyle heading = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: AppColors.text,
  );

  static const TextStyle body = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.text,
  );

  static const TextStyle label = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.muted,
  );

  static const TextStyle badge = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );
}

final ThemeData appLightTheme = ThemeData(
  brightness: Brightness.light,
  fontFamily: AppTypography.fontFamily,
  scaffoldBackgroundColor: AppColors.background,
  textTheme: const TextTheme(
    bodyMedium: AppTypography.body,
    titleLarge: AppTypography.heading,
    labelMedium: AppTypography.label,
  ),
  colorScheme: ColorScheme.fromSeed(
    seedColor: AppColors.accent,
    brightness: Brightness.light,
    background: AppColors.background,
    primary: AppColors.accent,
    secondary: AppColors.accentHover,
    error: AppColors.error,
    surface: AppColors.card,
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: AppColors.gray800,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.border),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.accent),
    ),
    hintStyle: const TextStyle(color: AppColors.muted),
    labelStyle: const TextStyle(color: AppColors.text),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ButtonStyle(
      backgroundColor: MaterialStateProperty.all(AppColors.accent),
      foregroundColor: MaterialStateProperty.all(Colors.black),
      shape: MaterialStateProperty.all(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      padding: MaterialStateProperty.all(
        const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      ),
    ),
  ),
  chipTheme: ChipThemeData(
    backgroundColor: AppColors.card,
    labelStyle: AppTypography.badge,
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(50),
      side: const BorderSide(color: AppColors.border),
    ),
  ),
);

final ThemeData appDarkTheme = appLightTheme.copyWith(
  brightness: Brightness.dark,
  colorScheme: appLightTheme.colorScheme.copyWith(
    brightness: Brightness.dark,
    background: AppColors.background,
    surface: AppColors.card,
  ),
);
