import 'package:flutter/material.dart';

/// Konstanta warna untuk aplikasi CareCycle
class AppColors {
  AppColors._();

  // Primary Colors (Hijau Emerald)
  static const Color primary = Color(0xFF047857);
  static const Color primaryLight = Color(0xFF10B981);
  static const Color primaryDark = Color(0xFF065F46);

  // Surface Colors - Light
  static const Color backgroundLight = Color(0xFFF0FDF4);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color cardLight = Color(0xFFFFFFFF);

  // Surface Colors - Dark
  static const Color backgroundDark = Color(0xFF0F172A);
  static const Color surfaceDark = Color(0xFF1E293B);
  static const Color cardDark = Color(0xFF334155);

  // Text Colors
  static const Color textPrimaryLight = Color(0xFF1F2937);
  static const Color textSecondaryLight = Color(0xFF6B7280);
  static const Color textPrimaryDark = Color(0xFFF9FAFB);
  static const Color textSecondaryDark = Color(0xFF9CA3AF);

  // Status Colors
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // Gamification Level Colors
  static const Color levelStarter = Color(0xFF10B981);
  static const Color levelHero = Color(0xFF3B82F6);
  static const Color levelSavior = Color(0xFFF59E0B);

  // MaterialColor Swatch
  static const MaterialColor primarySwatch = MaterialColor(
    0xFF047857,
    <int, Color>{
      50: Color(0xFFECFDF5),
      100: Color(0xFFD1FAE5),
      200: Color(0xFFA7F3D0),
      300: Color(0xFF6EE7B7),
      400: Color(0xFF34D399),
      500: Color(0xFF10B981),
      600: Color(0xFF059669),
      700: Color(0xFF047857),
      800: Color(0xFF065F46),
      900: Color(0xFF064E3B),
    },
  );
}
