import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_strings.dart';

/// Enum level gamifikasi donatur
enum DonorLevel {
  starter,
  hero,
  savior;

  String get displayName {
    switch (this) {
      case DonorLevel.starter:
        return AppStrings.levelStarter;
      case DonorLevel.hero:
        return AppStrings.levelHero;
      case DonorLevel.savior:
        return AppStrings.levelSavior;
    }
  }

  Color get color {
    switch (this) {
      case DonorLevel.starter:
        return AppColors.levelStarter;
      case DonorLevel.hero:
        return AppColors.levelHero;
      case DonorLevel.savior:
        return AppColors.levelSavior;
    }
  }

  IconData get icon {
    switch (this) {
      case DonorLevel.starter:
        return Icons.eco;
      case DonorLevel.hero:
        return Icons.military_tech;
      case DonorLevel.savior:
        return Icons.workspace_premium;
    }
  }
}

/// Helper untuk menghitung level dan poin gamifikasi CareCycle
class GamificationCalculator {
  GamificationCalculator._();

  /// Menentukan level donatur berdasarkan jumlah barang sukses:
  /// - Starter: 1 - 5 barang sukses
  /// - Hero: 6 - 20 barang sukses
  /// - Savior: > 20 barang sukses
  static DonorLevel calculateLevel(int completedItemsCount) {
    if (completedItemsCount > 20) {
      return DonorLevel.savior;
    } else if (completedItemsCount >= 6) {
      return DonorLevel.hero;
    } else {
      return DonorLevel.starter;
    }
  }

  /// Menghitung poin tambahan (misal 10 poin per barang donasi sukses)
  static int calculatePoints(int completedItemsCount, {int pointsPerItem = 10}) {
    if (completedItemsCount < 0) return 0;
    return completedItemsCount * pointsPerItem;
  }

  /// Mengambil batas target berikutnya untuk naik level
  static int getNextLevelTarget(int completedItemsCount) {
    if (completedItemsCount <= 5) {
      return 6;
    } else if (completedItemsCount <= 20) {
      return 21;
    } else {
      return completedItemsCount; // Sudah tingkat maksimal (Savior)
    }
  }

  /// Menghitung persentase progress menuju level berikutnya (0.0 sampai 1.0)
  static double calculateProgress(int completedItemsCount) {
    if (completedItemsCount <= 0) return 0.0;
    if (completedItemsCount > 20) return 1.0;

    if (completedItemsCount <= 5) {
      return completedItemsCount / 6.0;
    } else {
      // Range 6 s/d 20 (total span 15 item)
      return (completedItemsCount - 5) / 15.0;
    }
  }
}
