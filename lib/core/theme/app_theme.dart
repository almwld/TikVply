import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';

class AppTheme {
  static ThemeData get lightTheme {
    final scheme = ColorScheme.fromSeed(seedColor: AppColors.primary, brightness: Brightness.light).copyWith(
      primary: AppColors.primary,
      onPrimary: Colors.white,
      secondary: AppColors.secondary,
      surface: Colors.white,
      onSurface: AppColors.dark,
      error: AppColors.error,
    );
    final text = GoogleFonts.cairoTextTheme().apply(bodyColor: AppColors.dark, displayColor: AppColors.dark);
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: scheme,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.light,
      fontFamily: GoogleFonts.cairo().fontFamily,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: AppColors.dark,
        elevation: 0,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        titleTextStyle: GoogleFonts.cairo(fontSize: 19, fontWeight: FontWeight.w700, color: AppColors.dark),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(backgroundColor: Colors.white, selectedItemColor: AppColors.primary, unselectedItemColor: AppColors.textSecondary, type: BottomNavigationBarType.fixed, elevation: 6),
      textTheme: text.copyWith(
        displayLarge: GoogleFonts.cairo(fontSize: 32, fontWeight: FontWeight.bold),
        displayMedium: GoogleFonts.cairo(fontSize: 28, fontWeight: FontWeight.bold),
        headlineLarge: GoogleFonts.cairo(fontSize: 22, fontWeight: FontWeight.w700),
        headlineMedium: GoogleFonts.cairo(fontSize: 20, fontWeight: FontWeight.w700),
        titleLarge: GoogleFonts.cairo(fontSize: 17, fontWeight: FontWeight.w700),
        titleMedium: GoogleFonts.cairo(fontSize: 15, fontWeight: FontWeight.w600),
        bodyLarge: GoogleFonts.cairo(fontSize: 16),
        bodyMedium: GoogleFonts.cairo(fontSize: 14),
        bodySmall: GoogleFonts.cairo(fontSize: 12, color: AppColors.textSecondary),
        labelLarge: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.primary),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, elevation: 1, padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), textStyle: GoogleFonts.cairo(fontSize: 15, fontWeight: FontWeight.w700))),
      outlinedButtonTheme: OutlinedButtonThemeData(style: OutlinedButton.styleFrom(foregroundColor: AppColors.primary, side: const BorderSide(color: AppColors.primary), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)))),
      textButtonTheme: TextButtonThemeData(style: TextButton.styleFrom(foregroundColor: AppColors.primary)),
      inputDecorationTheme: InputDecorationTheme(filled: true, fillColor: const Color(0xFFF0F5F4), contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary, width: 2))),
      cardTheme: CardThemeData(color: Colors.white, elevation: 1, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
      dividerTheme: const DividerThemeData(color: AppColors.borderLight, thickness: 1, space: 1),
      iconTheme: const IconThemeData(color: AppColors.dark, size: 23),
    );
  }
}
