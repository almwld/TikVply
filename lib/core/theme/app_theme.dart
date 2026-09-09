import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';

class AppTheme {
  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: AppColors.primary,
    scaffoldBackgroundColor: AppColors.light,
    colorScheme: const ColorScheme.light(primary: AppColors.primary, secondary: AppColors.secondary, tertiary: AppColors.accent, surface: AppColors.light, error: AppColors.error),
    fontFamily: GoogleFonts.cairo().fontFamily,
    appBarTheme: AppBarTheme(backgroundColor: AppColors.light, foregroundColor: AppColors.dark, elevation: 0, centerTitle: true, systemOverlayStyle: SystemUiOverlayStyle.dark, titleTextStyle: GoogleFonts.cairo(fontSize: 19, fontWeight: FontWeight.w700, color: AppColors.dark)),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(backgroundColor: Colors.white, selectedItemColor: AppColors.primary, unselectedItemColor: AppColors.textSecondary, type: BottomNavigationBarType.fixed, elevation: 6),
    textTheme: TextTheme(
      displayLarge: GoogleFonts.cairo(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.dark), displayMedium: GoogleFonts.cairo(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.dark), displaySmall: GoogleFonts.cairo(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.dark),
      headlineLarge: GoogleFonts.cairo(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.dark), headlineMedium: GoogleFonts.cairo(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.dark), headlineSmall: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.dark),
      titleLarge: GoogleFonts.cairo(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.dark), titleMedium: GoogleFonts.cairo(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.dark), titleSmall: GoogleFonts.cairo(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.dark),
      bodyLarge: GoogleFonts.cairo(fontSize: 16, color: AppColors.dark), bodyMedium: GoogleFonts.cairo(fontSize: 14, color: AppColors.dark), bodySmall: GoogleFonts.cairo(fontSize: 12, color: AppColors.textSecondary), labelLarge: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.primary), labelMedium: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary), labelSmall: GoogleFonts.cairo(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, elevation: 2, padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 11), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), textStyle: GoogleFonts.cairo(fontSize: 15, fontWeight: FontWeight.w700))),
    outlinedButtonTheme: OutlinedButtonThemeData(style: OutlinedButton.styleFrom(foregroundColor: AppColors.primary, side: const BorderSide(color: AppColors.primary), padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 11), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), textStyle: GoogleFonts.cairo(fontSize: 15, fontWeight: FontWeight.w700))),
    textButtonTheme: TextButtonThemeData(style: TextButton.styleFrom(foregroundColor: AppColors.primary, textStyle: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.w600))),
    inputDecorationTheme: InputDecorationTheme(filled: true, fillColor: Colors.grey[100], contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary, width: 2)), errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.error)), hintStyle: GoogleFonts.cairo(color: AppColors.textHint, fontSize: 13)),
    cardTheme: CardThemeData(color: Colors.white, elevation: 2, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
    dividerTheme: const DividerThemeData(color: AppColors.borderLight, thickness: 1, space: 1), iconTheme: const IconThemeData(color: AppColors.dark, size: 23), chipTheme: ChipThemeData(backgroundColor: AppColors.primary.withValues(alpha: 0.1), labelStyle: GoogleFonts.cairo(fontSize: 12, color: AppColors.primary), padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 3), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
  );
}
