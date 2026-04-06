import 'package:flutter/material.dart';

/// App Theme Configuration
class AppTheme {
  // Primary Colors
  static const Color primary = Color(0xFF667eea); // Purple
  static const Color primaryDark = Color(0xFF764ba2); // Dark Purple
  static const Color primaryLight = Color(0xFFF0f4ff);

  // Secondary Colors
  static const Color secondary = Color(0xFF10b981); // Green (Success)
  static const Color success = Color(0xFF10b981);
  static const Color warning = Color(0xFFf59e0b); // Amber
  static const Color error = Color(0xFFef4444); // Red
  static const Color info = Color(0xFF3b82f6); // Blue

  // Neutral Colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color darkGray = Color(0xFF1f2937);
  static const Color gray = Color(0xFF6b7280);
  static const Color lightGray = Color(0xFFf3f4f6);
  static const Color borderGray = Color(0xFFe5e7eb);

  // Status Colors
  static const Color online = Color(0xFF10b981);
  static const Color offline = Color(0xFF6b7280);
  static const Color pending = Color(0xFFf59e0b);

  // Spacing
  static const double spacingXs = 4.0;
  static const double spacingSm = 8.0;
  static const double spacingMd = 16.0;
  static const double spacingLg = 24.0;
  static const double spacingXl = 32.0;

  // Border Radius
  static const double radiusSm = 4.0;
  static const double radiusMd = 8.0;
  static const double radiusLg = 12.0;
  static const double radiusXl = 16.0;

  // Font Sizes
  static const double fontXs = 10.0;
  static const double fontSm = 12.0;
  static const double fontMd = 14.0;
  static const double fontLg = 16.0;
  static const double fontXl = 18.0;
  static const double font2Xl = 20.0;
  static const double font3Xl = 24.0;

  /// Get light theme
  static ThemeData getLightTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: primary,
      scaffoldBackgroundColor: lightGray,
      appBarTheme: const AppBarTheme(
        backgroundColor: primary,
        foregroundColor: white,
        elevation: 2,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: white,
          fontSize: fontXl,
          fontWeight: FontWeight.w600,
        ),
      ),
      textTheme: const TextTheme(
        headlineSmall: TextStyle(
          fontSize: font3Xl,
          fontWeight: FontWeight.w700,
          color: darkGray,
        ),
        titleLarge: TextStyle(
          fontSize: fontXl,
          fontWeight: FontWeight.w600,
          color: darkGray,
        ),
        titleMedium: TextStyle(
          fontSize: fontLg,
          fontWeight: FontWeight.w500,
          color: gray,
        ),
        bodyLarge: TextStyle(
          fontSize: fontMd,
          fontWeight: FontWeight.w400,
          color: darkGray,
        ),
        bodyMedium: TextStyle(
          fontSize: fontSm,
          fontWeight: FontWeight.w400,
          color: gray,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: spacingMd,
          vertical: spacingMd,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: borderGray),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: borderGray),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: error, width: 2),
        ),
        filled: true,
        fillColor: white,
        hintStyle: const TextStyle(color: gray, fontSize: fontMd),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: white,
          padding: const EdgeInsets.symmetric(
            horizontal: spacingLg,
            vertical: spacingMd,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMd),
          ),
          textStyle:
              const TextStyle(fontSize: fontMd, fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          padding: const EdgeInsets.symmetric(
            horizontal: spacingLg,
            vertical: spacingMd,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMd),
          ),
          side: const BorderSide(color: primary),
        ),
      ),
      cardTheme: CardThemeData(
        color: white,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLg),
        ),
        margin: EdgeInsets.zero,
      ),
    );
  }

  /// Get dark theme
  static ThemeData getDarkTheme() {
    return getLightTheme().copyWith(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkGray,
    );
  }
}
