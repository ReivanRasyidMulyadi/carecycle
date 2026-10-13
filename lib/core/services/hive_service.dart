import 'package:hive_flutter/hive_flutter.dart';

/// Service untuk mengelola Hive local storage
class HiveService {
  // Box names
  static const String sessionBox = 'session';
  static const String settingsBox = 'settings';
  static const String draftsBox = 'drafts';
  static const String cacheBox = 'cache';

  // Settings keys
  static const String themeKey = 'is_dark_mode';
  static const String onboardingKey = 'has_seen_onboarding';

  // Session keys
  static const String userIdKey = 'user_id';
  static const String userRoleKey = 'user_role';
  static const String userEmailKey = 'user_email';
  static const String userNameKey = 'user_name';
  static const String isLoggedInKey = 'is_logged_in';

  /// Inisialisasi Hive dan buka semua box
  static Future<void> init() async {
    await Hive.initFlutter();
    await Future.wait([
      Hive.openBox(sessionBox),
      Hive.openBox(settingsBox),
      Hive.openBox(draftsBox),
      Hive.openBox(cacheBox),
    ]);
  }

  // ===== SETTINGS =====

  /// Ambil preferensi dark mode
  static bool isDarkMode() {
    final box = Hive.box(settingsBox);
    return box.get(themeKey, defaultValue: false) as bool;
  }

  /// Simpan preferensi dark mode
  static Future<void> setDarkMode(bool value) async {
    final box = Hive.box(settingsBox);
    await box.put(themeKey, value);
  }

  /// Cek apakah sudah lihat onboarding
  static bool hasSeenOnboarding() {
    final box = Hive.box(settingsBox);
    return box.get(onboardingKey, defaultValue: false) as bool;
  }

  /// Set sudah lihat onboarding
  static Future<void> setHasSeenOnboarding(bool value) async {
    final box = Hive.box(settingsBox);
    await box.put(onboardingKey, value);
  }

  // ===== SESSION =====

  /// Simpan data sesi login
  static Future<void> saveSession({
    required String userId,
    required String role,
    required String email,
    required String name,
  }) async {
    final box = Hive.box(sessionBox);
    await box.putAll({
      userIdKey: userId,
      userRoleKey: role,
      userEmailKey: email,
      userNameKey: name,
      isLoggedInKey: true,
    });
  }

  /// Ambil status login
  static bool isLoggedIn() {
    final box = Hive.box(sessionBox);
    return box.get(isLoggedInKey, defaultValue: false) as bool;
  }

  /// Ambil role pengguna
  static String? getUserRole() {
    final box = Hive.box(sessionBox);
    return box.get(userRoleKey) as String?;
  }

  /// Ambil user ID
  static String? getUserId() {
    final box = Hive.box(sessionBox);
    return box.get(userIdKey) as String?;
  }

  /// Ambil nama pengguna
  static String? getUserName() {
    final box = Hive.box(sessionBox);
    return box.get(userNameKey) as String?;
  }

  /// Hapus sesi (logout)
  static Future<void> clearSession() async {
    final box = Hive.box(sessionBox);
    await box.clear();
  }

  // ===== DRAFTS =====

  /// Simpan draft upload barang
  static Future<void> saveDraft(String id, Map<String, dynamic> data) async {
    final box = Hive.box(draftsBox);
    await box.put(id, data);
  }

  /// Ambil semua draft
  static List<Map<String, dynamic>> getAllDrafts() {
    final box = Hive.box(draftsBox);
    return box.values
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
  }

  /// Hapus draft berdasarkan ID
  static Future<void> deleteDraft(String id) async {
    final box = Hive.box(draftsBox);
    await box.delete(id);
  }

  // ===== CACHE =====

  /// Simpan cache data
  static Future<void> setCache(String key, dynamic value) async {
    final box = Hive.box(cacheBox);
    await box.put(key, value);
  }

  /// Ambil cache data
  static dynamic getCache(String key) {
    final box = Hive.box(cacheBox);
    return box.get(key);
  }

  /// Hapus semua cache
  static Future<void> clearCache() async {
    final box = Hive.box(cacheBox);
    await box.clear();
  }

  /// Hapus semua data Hive
  static Future<void> clearAll() async {
    await Future.wait([
      Hive.box(sessionBox).clear(),
      Hive.box(settingsBox).clear(),
      Hive.box(draftsBox).clear(),
      Hive.box(cacheBox).clear(),
    ]);
  }
}
