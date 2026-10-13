import 'package:flutter_test/flutter_test.dart';
import 'package:carecycle/core/utils/extensions.dart';

void main() {
  group('StringX', () {
    test('capitalize huruf pertama', () {
      expect('hello'.capitalize, 'Hello');
      expect('world'.capitalize, 'World');
    });

    test('capitalize string kosong tetap kosong', () {
      expect(''.capitalize, '');
    });

    test('isValidEmail mendeteksi email valid', () {
      expect('test@example.com'.isValidEmail, isTrue);
      expect('user.name@domain.co.id'.isValidEmail, isTrue);
    });

    test('isValidEmail mendeteksi email tidak valid', () {
      expect('notanemail'.isValidEmail, isFalse);
      expect('@domain.com'.isValidEmail, isFalse);
      expect('user@'.isValidEmail, isFalse);
      expect(''.isValidEmail, isFalse);
    });
  });

  group('DateTimeX', () {
    test('toIndonesianDate format benar', () {
      final date = DateTime(2026, 10, 13);
      expect(date.toIndonesianDate, '13 Oktober 2026');
    });

    test('toShortDate format benar', () {
      final date = DateTime(2026, 10, 13);
      expect(date.toShortDate, '13 Okt 2026');
    });

    test('toIndonesianDate bulan Januari', () {
      final date = DateTime(2026, 1, 1);
      expect(date.toIndonesianDate, '1 Januari 2026');
    });

    test('toIndonesianDate bulan Desember', () {
      final date = DateTime(2026, 12, 31);
      expect(date.toIndonesianDate, '31 Desember 2026');
    });
  });
}
