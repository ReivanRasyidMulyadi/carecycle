import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/hive_service.dart';
import '../../data/models/community_model.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/auth_repository.dart';

/// Provider instance untuk AuthRepository
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

/// State untuk proses autentikasi
class AuthState {
  final bool isLoading;
  final UserModel? user;
  final CommunityModel? community;
  final String? errorMessage;

  const AuthState({
    this.isLoading = false,
    this.user,
    this.community,
    this.errorMessage,
  });

  bool get isAuthenticated => user != null;

  AuthState copyWith({
    bool? isLoading,
    UserModel? user,
    CommunityModel? community,
    String? errorMessage,
    bool clearError = false,
    bool clearUser = false,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      user: clearUser ? null : (user ?? this.user),
      community: clearUser ? null : (community ?? this.community),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

/// Provider state notifier untuk Auth
final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return AuthNotifier(repository);
});

/// StateNotifier untuk mengelola autentikasi pengguna
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repository;
  StreamSubscription? _authSubscription;

  AuthNotifier(this._repository) : super(const AuthState()) {
    _initialize();
  }

  /// Inisialisasi status autentikasi dari Hive dan Supabase
  Future<void> _initialize() async {
    state = state.copyWith(isLoading: true);

    try {
      // 1. Pulihkan sesi lokal dari Hive terlebih dahulu
      if (HiveService.isLoggedIn()) {
        final userId = HiveService.getUserId();
        final role = HiveService.getUserRole() ?? 'donatur';
        final email = HiveService.getCache('user_email') as String? ?? '';
        final name = HiveService.getUserName() ?? '';

        if (userId != null) {
          state = state.copyWith(
            user: UserModel(
              id: userId,
              email: email,
              fullName: name,
              role: role,
            ),
          );
        }
      }

      // 2. Sinkronkan dengan Supabase backend jika ada sesi aktif
      if (_repository.isAuthenticated) {
        final profile = await _repository.getCurrentProfile();
        if (profile != null) {
          CommunityModel? community;
          if (profile.isKomunitas) {
            community = await _repository.getCurrentCommunity(
              profileId: profile.id,
            );
          }
          state = state.copyWith(
            user: profile,
            community: community,
            isLoading: false,
          );
        } else {
          state = state.copyWith(isLoading: false);
        }
      } else {
        // Jika tidak ada sesi di Supabase dan Hive kosong
        if (!HiveService.isLoggedIn()) {
          state = state.copyWith(clearUser: true, isLoading: false);
        } else {
          state = state.copyWith(isLoading: false);
        }
      }
    } catch (_) {
      state = state.copyWith(isLoading: false);
    }

    // Pantau perubahan status sesi dari Supabase
    _authSubscription = _repository.onAuthStateChange.listen((data) async {
      final session = data.session;
      if (session == null) {
        state = state.copyWith(clearUser: true);
      }
    });
  }

  /// Masuk dengan email & kata sandi
  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final user = await _repository.signIn(
        email: email,
        password: password,
      );

      CommunityModel? community;
      if (user.isKomunitas) {
        community = await _repository.getCurrentCommunity(profileId: user.id);
      }

      state = state.copyWith(
        isLoading: false,
        user: user,
        community: community,
        clearError: true,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: _getReadableErrorMessage(e),
      );
      return false;
    }
  }

  /// Pendaftaran akun baru
  Future<bool> signUp({
    required String email,
    required String password,
    required String fullName,
    required String role,
    String? communityName,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final user = await _repository.signUp(
        email: email,
        password: password,
        fullName: fullName,
        role: role,
        communityName: communityName,
      );

      CommunityModel? community;
      if (user.isKomunitas) {
        community = await _repository.getCurrentCommunity(profileId: user.id);
      }

      state = state.copyWith(
        isLoading: false,
        user: user,
        community: community,
        clearError: true,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: _getReadableErrorMessage(e),
      );
      return false;
    }
  }

  /// Keluar dari akun
  Future<void> signOut() async {
    state = state.copyWith(isLoading: true);
    await _repository.signOut();
    state = const AuthState();
  }

  /// Perbarui objek komunitas dalam state aktif
  void updateCommunity(CommunityModel community) {
    state = state.copyWith(community: community);
  }

  /// Muat ulang profil dan status komunitas pengguna saat ini
  Future<void> refreshCurrentUser() async {
    if (state.user == null) return;
    try {
      final profile = await _repository.getCurrentProfile(userId: state.user!.id);
      if (profile != null) {
        CommunityModel? community;
        if (profile.isKomunitas) {
          community = await _repository.getCurrentCommunity(profileId: profile.id);
        }
        state = state.copyWith(user: profile, community: community);
      }
    } catch (_) {}
  }

  /// Perbarui informasi profil pengguna
  Future<bool> updateProfile({
    String? fullName,
    String? phoneNumber,
    String? address,
    String? avatarUrl,
  }) async {
    if (state.user == null) return false;
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final updated = await _repository.updateProfile(
        userId: state.user!.id,
        fullName: fullName,
        phoneNumber: phoneNumber,
        address: address,
        avatarUrl: avatarUrl,
      );

      state = state.copyWith(
        isLoading: false,
        user: updated,
        clearError: true,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: _getReadableErrorMessage(e),
      );
      return false;
    }
  }

  /// Ganti kata sandi akun
  Future<bool> changePassword(String newPassword) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      await _repository.updatePassword(newPassword);
      state = state.copyWith(
        isLoading: false,
        clearError: true,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: _getReadableErrorMessage(e),
      );
      return false;
    }
  }

  /// Helper untuk menerjemahkan pesan kesalahan ke Bahasa Indonesia
  String _getReadableErrorMessage(dynamic error) {
    final msg = error.toString().toLowerCase();
    if (msg.contains('invalid login credentials') ||
        msg.contains('invalid_credentials')) {
      return 'Email atau kata sandi tidak sesuai.';
    } else if (msg.contains('user already registered') ||
        msg.contains('user_already_exists')) {
      return 'Email ini sudah terdaftar sebelumnya.';
    } else if (msg.contains('password should be at least')) {
      return 'Kata sandi minimal harus 6 karakter.';
    } else if (msg.contains('network') || msg.contains('socketexception')) {
      return 'Gagal terhubung ke server. Periksa koneksi internet Anda.';
    }
    return error.toString().replaceFirst('Exception: ', '').replaceFirst('AuthException(message: ', '').replaceFirst(')', '');
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}
