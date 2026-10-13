import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

/// Service untuk memantau konektivitas jaringan
class ConnectivityService {
  ConnectivityService._();

  static final Connectivity _connectivity = Connectivity();

  /// Stream status konektivitas
  static Stream<List<ConnectivityResult>> get onConnectivityChanged =>
      _connectivity.onConnectivityChanged;

  /// Cek apakah saat ini terhubung ke internet
  static Future<bool> isConnected() async {
    final results = await _connectivity.checkConnectivity();
    return !results.contains(ConnectivityResult.none);
  }

  /// Cek konektivitas dan return tipe koneksi
  static Future<List<ConnectivityResult>> checkConnectivity() async {
    return await _connectivity.checkConnectivity();
  }
}
