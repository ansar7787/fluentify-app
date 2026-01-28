import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryYellow = Color(0xFFFFCC00);
  static const Color secondaryGreen = Color(0xFF2ECC71);
  static const Color accentBlue = Color(0xFF3498DB);
  static const Color darkBg = Color(0xFF121212);
  static const Color scaffoldBg = Color(0xFF121212);
  static const Color cardBg = Color(0xFF1E1E1E);

  // Premium Auth Colors
  static const Color authGradientStart = Color(0xFFFFF9E5); // Very light yellow
  static const Color authGradientEnd = Color(0xFFFFFFFF);
  static const Color blobOne = Color(0xFFFFE5B4); // Peach
  static const Color blobTwo = Color(0xFFE8F5E9); // Light Green
  static const Color blobThree = Color(0xFFE3F2FD); // Light Blue

  // Light Theme
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: primaryYellow,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryYellow,
        primary: primaryYellow,
        secondary: secondaryGreen,
        tertiary: accentBlue,
        surface: const Color(0xFFFFFFFF),
      ),
      scaffoldBackgroundColor: const Color(0xFFFFFFFF),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: Color(0xFF1A1A1A),
        elevation: 0,
        centerTitle: true,
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w800,
          color: Color(0xFF1A1A1A),
          letterSpacing: -0.5,
        ),
        headlineMedium: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: Color(0xFF1A1A1A),
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: Color(0xFF333333),
          height: 1.5,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryYellow,
          foregroundColor: Colors.black,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
      ),
    );
  }

  // Dark Theme
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: primaryYellow,
      scaffoldBackgroundColor: darkBg,
      colorScheme: ColorScheme.fromSeed(
        brightness: Brightness.dark,
        seedColor: primaryYellow,
        primary: primaryYellow,
        secondary: secondaryGreen,
        tertiary: accentBlue,
        surface: darkBg,
      ),
      cardColor: cardBg,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
    );
  }
}
