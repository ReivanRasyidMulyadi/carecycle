import 'package:flutter_test/flutter_test.dart';
import 'package:carecycle/core/utils/gamification_calculator.dart';

void main() {
  group('GamificationCalculator', () {
    test('level Starter untuk 0 sampai 5 barang sukses', () {
      expect(GamificationCalculator.calculateLevel(0), DonorLevel.starter);
      expect(GamificationCalculator.calculateLevel(1), DonorLevel.starter);
      expect(GamificationCalculator.calculateLevel(3), DonorLevel.starter);
      expect(GamificationCalculator.calculateLevel(5), DonorLevel.starter);
      expect(DonorLevel.starter.displayName, 'Starter');
    });

    test('level Hero untuk 6 sampai 20 barang sukses', () {
      expect(GamificationCalculator.calculateLevel(6), DonorLevel.hero);
      expect(GamificationCalculator.calculateLevel(10), DonorLevel.hero);
      expect(GamificationCalculator.calculateLevel(15), DonorLevel.hero);
      expect(GamificationCalculator.calculateLevel(20), DonorLevel.hero);
      expect(DonorLevel.hero.displayName, 'Hero');
    });

    test('level Savior untuk lebih dari 20 barang sukses', () {
      expect(GamificationCalculator.calculateLevel(21), DonorLevel.savior);
      expect(GamificationCalculator.calculateLevel(50), DonorLevel.savior);
      expect(GamificationCalculator.calculateLevel(100), DonorLevel.savior);
      expect(DonorLevel.savior.displayName, 'Savior');
    });

    test('kalkulasi poin donasi', () {
      expect(GamificationCalculator.calculatePoints(0), 0);
      expect(GamificationCalculator.calculatePoints(5), 50);
      expect(GamificationCalculator.calculatePoints(10), 100);
      expect(GamificationCalculator.calculatePoints(-1), 0);
    });

    test('target level berikutnya', () {
      expect(GamificationCalculator.getNextLevelTarget(3), 6);
      expect(GamificationCalculator.getNextLevelTarget(5), 6);
      expect(GamificationCalculator.getNextLevelTarget(6), 21);
      expect(GamificationCalculator.getNextLevelTarget(15), 21);
      expect(GamificationCalculator.getNextLevelTarget(25), 25);
    });

    test('progress bar level kalkulasi dalam rentang 0.0 sampai 1.0', () {
      expect(GamificationCalculator.calculateProgress(0), 0.0);
      expect(GamificationCalculator.calculateProgress(3), 0.5);
      expect(GamificationCalculator.calculateProgress(25), 1.0);
    });
  });
}
