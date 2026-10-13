import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/connectivity_service.dart';
import '../services/hive_service.dart';

/// Provider untuk tema (dark mode toggle)
final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>(
  (ref) => ThemeModeNotifier(),
);

/// Notifier untuk mengelola tema
class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier()
      : super(
          HiveService.isDarkMode() ? ThemeMode.dark : ThemeMode.light,
        );

  /// Toggle dark mode
  void toggle() {
    final isDark = state == ThemeMode.dark;
    state = isDark ? ThemeMode.light : ThemeMode.dark;
    HiveService.setDarkMode(!isDark);
  }

  /// Set mode secara eksplisit
  void setMode(ThemeMode mode) {
    state = mode;
    HiveService.setDarkMode(mode == ThemeMode.dark);
  }
}

/// Provider untuk status konektivitas
final connectivityProvider = StreamProvider<List<ConnectivityResult>>(
  (ref) => ConnectivityService.onConnectivityChanged,
);

/// Provider helper: apakah sedang online
final isOnlineProvider = FutureProvider<bool>(
  (ref) => ConnectivityService.isConnected(),
);
