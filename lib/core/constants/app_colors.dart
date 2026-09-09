import 'package:flutter/material.dart';

class AppColors {
  // TikVply brand — derived from the app icon.
  static const Color primary = Color(0xFF0A8F83);
  static const Color primaryDark = Color(0xFF08756B);
  static const Color primaryLight = Color(0xFFE8F6F4);
  static const Color secondary = Color(0xFF0F6F68);
  static const Color accent = Color(0xFF35B8A9);

  static const Color dark = Color(0xFF173A37);
  static const Color light = Color(0xFFF7FAF9);
  static const Color darkBg = Color(0xFF102624);
  static const Color cardDark = Color(0xFF193B38);

  static const Color textPrimary = Color(0xFF173A37);
  static const Color textSecondary = Color(0xFF667A77);
  static const Color textHint = Color(0xFF8A9A97);

  static const Color success = Color(0xFF249B70);
  static const Color warning = Color(0xFFE29A35);
  static const Color error = Color(0xFFD94A4A);
  static const Color info = Color(0xFF3187B8);

  static const Color white = Color(0xFFFFFFFF);
  static const Color borderLight = Color(0xFFDDE9E7);
  static const Color borderDark = Color(0xFF31524F);
  static const Color overlayDark = Color(0x80000000);
  static const Color overlayLight = Color(0x40FFFFFF);

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF0A8F83), Color(0xFF08756B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
