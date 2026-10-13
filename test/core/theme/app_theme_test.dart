import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:carecycle/core/theme/app_theme.dart';
import 'package:carecycle/core/constants/app_colors.dart';

void main() {
  group('AppTheme', () {
    group('Light Theme', () {
      final theme = AppTheme.lightTheme;

      test('menggunakan Material 3', () {
        expect(theme.useMaterial3, isTrue);
      });

      test('memiliki brightness light', () {
        expect(theme.brightness, Brightness.light);
      });

      test('menggunakan warna primary hijau #047857', () {
        expect(theme.colorScheme.primary, AppColors.primary);
      });

      test('menggunakan warna secondary hijau #10B981', () {
        expect(theme.colorScheme.secondary, AppColors.primaryLight);
      });

      test('scaffold background adalah backgroundLight', () {
        expect(theme.scaffoldBackgroundColor, AppColors.backgroundLight);
      });

      test('AppBar menggunakan warna primary', () {
        expect(theme.appBarTheme.backgroundColor, AppColors.primary);
      });

      test('AppBar text berwarna putih', () {
        expect(theme.appBarTheme.foregroundColor, Colors.white);
      });
    });

    group('Dark Theme', () {
      final theme = AppTheme.darkTheme;

      test('menggunakan Material 3', () {
        expect(theme.useMaterial3, isTrue);
      });

      test('memiliki brightness dark', () {
        expect(theme.brightness, Brightness.dark);
      });

      test('menggunakan warna primary hijau terang #10B981', () {
        expect(theme.colorScheme.primary, AppColors.primaryLight);
      });

      test('scaffold background adalah backgroundDark', () {
        expect(theme.scaffoldBackgroundColor, AppColors.backgroundDark);
      });
    });
  });

  group('AppColors', () {
    test('primary adalah #047857', () {
      expect(AppColors.primary, const Color(0xFF047857));
    });

    test('primaryLight adalah #10B981', () {
      expect(AppColors.primaryLight, const Color(0xFF10B981));
    });

    test('primarySwatch memiliki 10 shade', () {
      expect(AppColors.primarySwatch[50], isNotNull);
      expect(AppColors.primarySwatch[100], isNotNull);
      expect(AppColors.primarySwatch[200], isNotNull);
      expect(AppColors.primarySwatch[300], isNotNull);
      expect(AppColors.primarySwatch[400], isNotNull);
      expect(AppColors.primarySwatch[500], isNotNull);
      expect(AppColors.primarySwatch[600], isNotNull);
      expect(AppColors.primarySwatch[700], isNotNull);
      expect(AppColors.primarySwatch[800], isNotNull);
      expect(AppColors.primarySwatch[900], isNotNull);
    });

    test('warna level gamifikasi berbeda-beda', () {
      expect(AppColors.levelStarter, isNot(equals(AppColors.levelHero)));
      expect(AppColors.levelHero, isNot(equals(AppColors.levelSavior)));
      expect(AppColors.levelStarter, isNot(equals(AppColors.levelSavior)));
    });
  });
}
