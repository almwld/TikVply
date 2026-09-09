import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';

class DarkTheme {
  static ThemeData get darkTheme {
    const background = Color(0xFF0B0F14);
    const surface = Color(0xFF121820);
    const elevated = Color(0xFF19212B);
    const text = Color(0xFFF5F7FA);
    const muted = Color(0xFF9AA6B2);

    final base = ThemeData.dark(useMaterial3: true);
    return base.copyWith(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      primaryColor: AppColors.primary,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        secondary: AppColors.accent,
        tertiary: AppColors.secondary,
        surface: surface,
        error: AppColors.error,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        foregroundColor: text,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: GoogleFonts.cairo(fontSize: 19, fontWeight: FontWeight.w700, color: text),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: surface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: muted,
        type: BottomNavigationBarType.fixed,
        elevation: 12,
      ),
      textTheme: TextTheme(
        displayLarge: GoogleFonts.cairo(fontSize: 32, fontWeight: FontWeight.bold, color: text),
        displayMedium: GoogleFonts.cairo(fontSize: 28, fontWeight: FontWeight.bold, color: text),
        displaySmall: GoogleFonts.cairo(fontSize: 24, fontWeight: FontWeight.bold, color: text),
        headlineLarge: GoogleFonts.cairo(fontSize: 22, fontWeight: FontWeight.w700, color: text),
        headlineMedium: GoogleFonts.cairo(fontSize: 20, fontWeight: FontWeight.w700, color: text),
        headlineSmall: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.w700, color: text),
        titleLarge: GoogleFonts.cairo(fontSize: 17, fontWeight: FontWeight.w700, color: text),
        titleMedium: GoogleFonts.cairo(fontSize: 15, fontWeight: FontWeight.w600, color: text),
        titleSmall: GoogleFonts.cairo(fontSize: 13, fontWeight: FontWeight.w600, color: text),
        bodyLarge: GoogleFonts.cairo(fontSize: 16, color: text),
        bodyMedium: GoogleFonts.cairo(fontSize: 14, color: text),
        bodySmall: GoogleFonts.cairo(fontSize: 12, color: muted),
        labelLarge: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.primary),
        labelMedium: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary),
        labelSmall: GoogleFonts.cairo(fontSize: 10, fontWeight: FontWeight.w600, color: muted),
      ),
      cardTheme: CardThemeData(
        color: surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: Color(0xFF222C37))),
      ),
      listTileTheme: const ListTileThemeData(iconColor: muted, textColor: text, tileColor: surface, contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 3)),
      dividerTheme: const DividerThemeData(color: Color(0xFF26313D), thickness: 1, space: 1),
      iconTheme: const IconThemeData(color: text, size: 23),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: elevated,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.primary, width: 2)),
        hintStyle: GoogleFonts.cairo(color: muted, fontSize: 13),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) => states.contains(WidgetState.selected) ? AppColors.primary : muted),
        trackColor: WidgetStateProperty.resolveWith((states) => states.contains(WidgetState.selected) ? AppColors.primary.withValues(alpha: .35) : elevated),
      ),
    );
  }
}
