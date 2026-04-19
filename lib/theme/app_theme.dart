import 'package:flutter/material.dart';

class AppTheme {
  static const Color primary = Color(0xFF534AB7);
  static const Color primaryLight = Color(0xFFEEEDFE);
  static const Color accent = Color(0xFF1D9E75);
  static const Color danger = Color(0xFFE24B4A);
  static const Color border = Color(0xFFE0DFD8);
  static const Color bgSecondary = Color(0xFFF5F4F0);
  static const Color textMuted = Color(0xFF888780);

  static ThemeData get theme => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primary,
      brightness: Brightness.light,
    ),
    scaffoldBackgroundColor: const Color(0xFFF5F4F0),
    fontFamily: 'Roboto',
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: Color(0xFF2C2C2A),
      elevation: 0,
      surfaceTintColor: Colors.transparent,
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: border, width: 0.5),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: bgSecondary,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: border, width: 0.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: border, width: 0.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: primary, width: 1.5),
      ),
      labelStyle: const TextStyle(fontSize: 13, color: textMuted),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primary,
        textStyle: const TextStyle(fontSize: 13),
      ),
    ),
  );
}
