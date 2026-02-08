import 'package:flutter/material.dart';

class AppColors {
  // Primary Palette
  static const Color primary = Color(0xFF2563EB); // Vibrant Blue
  static const Color secondary = Color(0xFF7C3AED); // Modern Purple/Indigo
  static const Color accent = Color(0xFF10B981); // Emerald Green
  static const Color yellow = Color(0xFFFACC15); // Vibrant Yellow

  // Semantic Colors
  static const Color success = Color(0xFF10B981);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF3B82F6);

  // Neutral Palette
  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Colors.white;
  static const Color textBody = Color(0xFF1E293B);
  static const Color textHeadline = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);

  // Dark Palette
  static const Color darkBackground = Color(0xFF0F172A);
  static const Color darkSurface = Color(0xFF1E293B);
  static const Color darkTextBody = Color(0xFFCBD5E1);
  static const Color darkTextHeadline = Color(0xFFF8FAFC);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, Color(0xFF1D4ED8)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient premiumGradient = LinearGradient(
    colors: [primary, secondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
