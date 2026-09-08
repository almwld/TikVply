import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors
  static const Color primary = Color(0xFF6C63FF);      // Purple
  static const Color secondary = Color(0xFFFF6B6B);    // Red
  static const Color accent = Color(0xFF4ECDC4);       // Teal

  // Background Colors
  static const Color dark = Color(0xFF1A1A2E);         // Dark
  static const Color light = Color(0xFFF5F5F5);        // Light
  static const Color darkBg = Color(0xFF16213E);       // Dark Blue
  static const Color cardDark = Color(0xFF0F3460);     // Card Dark

  // Accent Colors
  static const Color gold = Color(0xFFD4AF37);         // Gold
  static const Color silver = Color(0xFFC0C0C0);       // Silver
  static const Color bronze = Color(0xFFCD7F32);       // Bronze

  // Text Colors
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB0B0B0);
  static const Color textHint = Color(0xFF757575);

  // Status Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);

  // Gradient Colors
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, secondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [accent, primary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient goldGradient = LinearGradient(
    colors: [gold, Color(0xFFFFD700), gold],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Overlay Colors
  static const Color overlayDark = Color(0x80000000);
  static const Color overlayLight = Color(0x40FFFFFF);

  // Border Colors
  static const Color borderLight = Color(0xFFE0E0E0);
  static const Color borderDark = Color(0xFF424242);
}
