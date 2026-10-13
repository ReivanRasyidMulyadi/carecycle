import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Service untuk mengelola koneksi Supabase
class SupabaseService {
  SupabaseService._();

  /// Inisialisasi Supabase client
  static Future<void> init() async {
    await Supabase.initialize(
      url: dotenv.env['SUPABASE_URL'] ?? '',
      // ignore: deprecated_member_use
      anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
    );
  }

  /// Akses Supabase client
  static SupabaseClient get client => Supabase.instance.client;

  /// Akses auth
  static GoTrueClient get auth => client.auth;

  /// Akses database
  static SupabaseQueryBuilder Function(String table) get from => client.from;

  /// Akses storage
  static SupabaseStorageClient get storage => client.storage;

  /// Akses realtime
  static RealtimeClient get realtime => client.realtime;

  /// Cek apakah user sudah login
  static bool get isAuthenticated => client.auth.currentUser != null;

  /// Ambil current user
  static User? get currentUser => client.auth.currentUser;

  /// Ambil current user ID
  static String? get currentUserId => client.auth.currentUser?.id;
}
