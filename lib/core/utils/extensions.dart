import 'package:flutter/material.dart';

/// Extension pada BuildContext untuk akses cepat
extension BuildContextX on BuildContext {
  /// Akses cepat ke ThemeData
  ThemeData get theme => Theme.of(this);

  /// Akses cepat ke ColorScheme
  ColorScheme get colorScheme => Theme.of(this).colorScheme;

  /// Akses cepat ke TextTheme
  TextTheme get textTheme => Theme.of(this).textTheme;

  /// Akses cepat ke MediaQuery size
  Size get screenSize => MediaQuery.sizeOf(this);

  /// Akses cepat ke lebar layar
  double get screenWidth => MediaQuery.sizeOf(this).width;

  /// Akses cepat ke tinggi layar
  double get screenHeight => MediaQuery.sizeOf(this).height;

  /// Tampilkan SnackBar
  void showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError
            ? Theme.of(this).colorScheme.error
            : Theme.of(this).colorScheme.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}

/// Extension pada String
extension StringX on String {
  /// Capitalize huruf pertama
  String get capitalize {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  /// Cek apakah string adalah email valid
  bool get isValidEmail {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(this);
  }
}

/// Extension pada DateTime
extension DateTimeX on DateTime {
  /// Format tanggal Indonesia: "13 Oktober 2026"
  String get toIndonesianDate {
    const months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
    ];
    return '$day ${months[month - 1]} $year';
  }

  /// Format tanggal singkat: "13 Okt 2026"
  String get toShortDate {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
    ];
    return '$day ${months[month - 1]} $year';
  }
}
