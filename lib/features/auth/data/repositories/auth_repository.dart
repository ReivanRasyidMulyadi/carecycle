import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/services/hive_service.dart';
import '../../../../core/services/supabase_service.dart';
import '../models/community_model.dart';
import '../models/user_model.dart';

/// Repository untuk menangani proses autentikasi & pengelolaan akun pengguna
class AuthRepository {
  final SupabaseClient _client;

  AuthRepository({SupabaseClient? client})
      : _client = client ?? SupabaseService.client;

  /// Stream perubahan status autentikasi Supabase
  Stream<AuthState> get onAuthStateChange => _client.auth.onAuthStateChange;

  /// User Supabase yang sedang login saat ini
  User? get currentAuthUser => _client.auth.currentUser;

  /// Cek apakah ada sesi login aktif
  bool get isAuthenticated => _client.auth.currentUser != null;

  /// Registrasi akun baru (Donatur atau Komunitas)
  Future<UserModel> signUp({
    required String email,
    required String password,
    required String fullName,
    required String role, // 'donatur' atau 'komunitas'
    String? communityName,
  }) async {
    final response = await _client.auth.signUp(
      email: email.trim(),
      password: password,
      data: {
        'full_name': fullName.trim(),
        'role': role,
        if (communityName != null && communityName.trim().isNotEmpty)
          'community_name': communityName.trim(),
      },
    );

    final user = response.user;
    if (user == null) {
      throw const AuthException('Pendaftaran gagal. Pengguna tidak ditemukan.');
    }

    // Ambil data profile dari tabel profiles (telah dibuat via database trigger)
    UserModel? profile = await getCurrentProfile(userId: user.id);

    // Fallback jika database trigger memerlukan beberapa milidetik
    profile ??= UserModel(
      id: user.id,
      email: email.trim(),
      fullName: fullName.trim(),
      role: role,
    );

    // Simpan ke Hive untuk cache sesi lokal
    await HiveService.saveSession(
      userId: profile.id,
      role: profile.role,
      email: profile.email,
      name: profile.fullName,
    );

    return profile;
  }

  /// Masuk dengan email dan kata sandi
  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    final response = await _client.auth.signInWithPassword(
      email: email.trim(),
      password: password,
    );

    final user = response.user;
    if (user == null) {
      throw const AuthException('Gagal masuk. Pengguna tidak ditemukan.');
    }

    // Ambil detail profil dari database
    final profile = await getCurrentProfile(userId: user.id);
    if (profile == null) {
      throw const AuthException('Data profil pengguna tidak ditemukan.');
    }

    // Simpan sesi ke Hive
    await HiveService.saveSession(
      userId: profile.id,
      role: profile.role,
      email: profile.email,
      name: profile.fullName,
    );

    return profile;
  }

  /// Keluar dari akun (logout)
  Future<void> signOut() async {
    await Future.wait([
      _client.auth.signOut(),
      HiveService.clearSession(),
    ]);
  }

  /// Ambil data profil pengguna saat ini dari tabel profiles
  Future<UserModel?> getCurrentProfile({String? userId}) async {
    final targetId = userId ?? _client.auth.currentUser?.id;
    if (targetId == null) return null;

    final data = await _client
        .from('profiles')
        .select()
        .eq('id', targetId)
        .maybeSingle();

    if (data == null) return null;
    return UserModel.fromJson(data);
  }

  /// Ambil data komunitas untuk pengguna aktif (jika rolenya komunitas)
  Future<CommunityModel?> getCurrentCommunity({String? profileId}) async {
    final targetId = profileId ?? _client.auth.currentUser?.id;
    if (targetId == null) return null;

    final data = await _client
        .from('communities')
        .select()
        .eq('profile_id', targetId)
        .maybeSingle();

    if (data == null) return null;
    return CommunityModel.fromJson(data);
  }

  /// Perbarui informasi profil pengguna
  Future<UserModel> updateProfile({
    required String userId,
    String? fullName,
    String? phoneNumber,
    String? address,
    String? avatarUrl,
  }) async {
    final updates = <String, dynamic>{
      if (fullName != null) 'full_name': fullName.trim(),
      if (phoneNumber != null) 'phone_number': phoneNumber.trim(),
      if (address != null) 'address': address.trim(),
      if (avatarUrl != null) 'avatar_url': avatarUrl,
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    };

    final data = await _client
        .from('profiles')
        .update(updates)
        .eq('id', userId)
        .select()
        .single();

    final updatedUser = UserModel.fromJson(data);

    // Perbarui cache Hive
    await HiveService.saveSession(
      userId: updatedUser.id,
      role: updatedUser.role,
      email: updatedUser.email,
      name: updatedUser.fullName,
    );

    return updatedUser;
  }
}
