import 'package:flutter/material.dart';

class AppColors {
  // === Brand — Government Blue Palette ===
  static const Color primary = Color(0xFF1D6BF3);   // Royal Blue (matches reference)
  static const Color secondary = Color(0xFF2563EB); // Blue accent
  static const Color danger = Color(0xFFDC2626);    // Emergency Red

  // === Semantic States ===
  static const Color success = Color(0xFF2E7D32);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFDC2626);
  static const Color info = Color(0xFF0284C7);

  // === Backgrounds ===
  static const Color scaffoldLight = Color(0xFFF8FAFC);
  static const Color scaffoldDark = Color(0xFF121212);
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color border = Color(0xFFE5E7EB);

  // === Text Colors ===
  static const Color textPrimaryLight = Color(0xFF111827);
  static const Color textSecondaryLight = Color(0xFF6B7280);
  static const Color textDisabledLight = Color(0xFF9CA3AF);

  static const Color textPrimaryDark = Color(0xFFFFFFFF);
  static const Color textSecondaryDark = Color(0xFFBDBDBD);
  static const Color textDisabledDark = Color(0xFF757575);

  // === Input Fields ===
  static const Color inputFillLight = Color(0xFFFFFFFF);
  static const Color inputFillDark = Color(0xFF1E1E1E);
  static const Color inputBorderLight = Color(0xFFE5E7EB);
  static const Color inputBorderDark = Color(0xFF555555);

  // === Neutral Scale ===
  static const Color gray50 = Color(0xFFF9FAFB);
  static const Color gray100 = Color(0xFFF3F4F6);
  static const Color gray200 = Color(0xFFE5E7EB);
  static const Color gray300 = Color(0xFFD1D5DB);
  static const Color gray400 = Color(0xFF9CA3AF);
  static const Color gray500 = Color(0xFF6B7280);
  static const Color gray600 = Color(0xFF4B5563);
  static const Color gray700 = Color(0xFF374151);
  static const Color gray800 = Color(0xFF1F2937);
  static const Color gray900 = Color(0xFF111827);

  // === Semantic Surface Tints ===
  static const Color dangerSurface = Color(0xFFFEF2F2);
  static const Color warningSurface = Color(0xFFFFFBEB);
  static const Color successSurface = Color(0xFFF0FDF4);
  static const Color infoSurface = Color(0xFFEFF6FF);
  static const Color primarySurface = Color(0xFFEFF6FF);
}

class AppTheme {
  static const TextTheme lightTextTheme = TextTheme(
    displayLarge: TextStyle(
      color: AppColors.textPrimaryLight,
      fontSize: 32,
      fontWeight: FontWeight.bold,
      letterSpacing: -0.5,
    ),
    displayMedium: TextStyle(
      color: AppColors.textPrimaryLight,
      fontSize: 28,
      fontWeight: FontWeight.bold,
      letterSpacing: -0.25,
    ),
    titleLarge: TextStyle(
      color: AppColors.textPrimaryLight,
      fontSize: 20,
      fontWeight: FontWeight.w600,
    ),
    titleMedium: TextStyle(
      color: AppColors.textPrimaryLight,
      fontSize: 16,
      fontWeight: FontWeight.w600,
    ),
    titleSmall: TextStyle(
      color: AppColors.textSecondaryLight,
      fontSize: 14,
      fontWeight: FontWeight.w500,
    ),
    bodyLarge: TextStyle(color: AppColors.textPrimaryLight, fontSize: 16, height: 1.5),
    bodyMedium: TextStyle(color: AppColors.textSecondaryLight, fontSize: 14, height: 1.5),
    bodySmall: TextStyle(color: AppColors.textDisabledLight, fontSize: 12, height: 1.4),
    labelLarge: TextStyle(
      color: AppColors.textPrimaryLight,
      fontSize: 14,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.1,
    ),
  );

  static const TextTheme darkTextTheme = TextTheme(
    displayLarge: TextStyle(color: AppColors.textPrimaryDark, fontSize: 32, fontWeight: FontWeight.bold),
    displayMedium: TextStyle(color: AppColors.textPrimaryDark, fontSize: 28, fontWeight: FontWeight.bold),
    titleLarge: TextStyle(color: AppColors.textPrimaryDark, fontSize: 20, fontWeight: FontWeight.w600),
    titleMedium: TextStyle(color: AppColors.textPrimaryDark, fontSize: 16, fontWeight: FontWeight.w600),
    bodyLarge: TextStyle(color: AppColors.textPrimaryDark, fontSize: 16),
    bodyMedium: TextStyle(color: AppColors.textSecondaryDark, fontSize: 14),
    bodySmall: TextStyle(color: AppColors.textDisabledDark, fontSize: 12),
  );

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: AppColors.primary,
    scaffoldBackgroundColor: AppColors.scaffoldLight,
    textTheme: lightTextTheme,
    colorScheme: const ColorScheme.light(
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      error: AppColors.error,
      surface: AppColors.cardBackground,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: AppColors.textPrimaryLight,
      onError: Colors.white,
      outline: AppColors.border,
    ),
    cardTheme: CardThemeData(
      color: AppColors.cardBackground,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.border),
      ),
      margin: EdgeInsets.zero,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.inputFillLight,
      labelStyle: const TextStyle(color: AppColors.textSecondaryLight, fontSize: 14),
      hintStyle: const TextStyle(color: AppColors.textDisabledLight, fontSize: 15),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        borderRadius: BorderRadius.circular(8),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: AppColors.inputBorderLight),
        borderRadius: BorderRadius.circular(8),
      ),
      errorBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: AppColors.error),
        borderRadius: BorderRadius.circular(8),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        borderRadius: BorderRadius.circular(8),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, letterSpacing: 0.1),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        side: const BorderSide(color: AppColors.primary),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary,
        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: AppColors.textPrimaryLight,
      elevation: 0,
      scrolledUnderElevation: 1,
      surfaceTintColor: Colors.white,
      centerTitle: false,
      titleTextStyle: TextStyle(
        color: AppColors.textPrimaryLight,
        fontSize: 18,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
      ),
      iconTheme: IconThemeData(color: AppColors.textPrimaryLight),
    ),
    dividerTheme: const DividerThemeData(
      color: AppColors.border,
      thickness: 1,
      space: 1,
    ),
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return AppColors.primary;
        return Colors.transparent;
      }),
      checkColor: WidgetStateProperty.all(Colors.white),
      side: const BorderSide(color: AppColors.gray400, width: 1.5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      elevation: 2,
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      contentTextStyle: const TextStyle(fontSize: 14),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.gray100,
      labelStyle: const TextStyle(color: AppColors.textSecondaryLight, fontSize: 13),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: AppColors.primary,
    scaffoldBackgroundColor: AppColors.scaffoldDark,
    textTheme: darkTextTheme,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.secondary,
      secondary: AppColors.secondary,
      error: AppColors.error,
      surface: AppColors.gray800,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: AppColors.textPrimaryDark,
      onError: Colors.white,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.inputFillDark,
      labelStyle: const TextStyle(color: AppColors.textSecondaryDark),
      hintStyle: const TextStyle(color: AppColors.textDisabledDark),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: AppColors.secondary, width: 1.5),
        borderRadius: BorderRadius.circular(8),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: AppColors.inputBorderDark),
        borderRadius: BorderRadius.circular(8),
      ),
      errorBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: AppColors.error),
        borderRadius: BorderRadius.circular(8),
      ),
    ),
  );
}
