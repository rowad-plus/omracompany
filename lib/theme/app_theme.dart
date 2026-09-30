import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'system_bars.dart';

/// نظام الألوان الأساسي للتطبيق — نفس هوية النسخة التجريبية على الويب.
class AppColors {
  static const bg = Color(0xFFF6F5F0);
  static const surface = Color(0xFFFFFFFF);
  static const surface2 = Color(0xFFEFEDE5);

  static const text = Color(0xFF1B211F);
  static const textSecondary = Color(0xFF5C655F);
  static const textMuted = Color(0xFF93998F);
  static const border = Color(0xFFE3E0D5);

  static const primary = Color(0xFF0F6E56);
  static const primaryDark = Color(0xFF085041);
  static const primaryLight = Color(0xFFE1F5EE);

  static const accent = Color(0xFFBA7517);
  static const accentLight = Color(0xFFFAEEDA);

  static const danger = Color(0xFFA32D2D);
  static const dangerLight = Color(0xFFFCEBEB);

  static const success = Color(0xFF3B6D11);
  static const successLight = Color(0xFFEAF3DE);

  static const info = Color(0xFF185FA5);
  static const infoLight = Color(0xFFE6F1FB);
}

class AppTheme {
  static ThemeData light() {
    final base = GoogleFonts.tajawalTextTheme();
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.bg,
      fontFamily: GoogleFonts.tajawal().fontFamily,
      textTheme: base.apply(
        bodyColor: AppColors.text,
        displayColor: AppColors.text,
      ),
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        secondary: AppColors.accent,
        error: AppColors.danger,
        surface: AppColors.surface,
      ),
      appBarTheme: const AppBarTheme(
        systemOverlayStyle: systemBarsStyle,
        backgroundColor: AppColors.bg,
        foregroundColor: AppColors.text,
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.border),
        ),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.4),
        ),
        labelStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 12.5),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(46),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.text,
          minimumSize: const Size.fromHeight(46),
          side: const BorderSide(color: AppColors.border),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ),
      dividerTheme: const DividerThemeData(color: AppColors.border, thickness: 1),
    );
  }
}
