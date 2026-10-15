import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/services/supabase_service.dart';
import '../../../auth/data/models/user_model.dart';
import '../../../items/data/models/item_model.dart';

/// Ringkasan statistik platform CareCycle untuk Admin
class PlatformStats {
  final int totalUsers;
  final int totalDonors;
  final int totalCommunities;
  final int totalAdmins;
  final int totalVerifiedCommunities;
  final int totalPendingCommunities;
  final int totalItems;
  final int availableItems;
  final int completedItems;
  final int totalRequests;
  final int pendingRequests;
  final int approvedRequests;
  final int rejectedRequests;
  final double estimatedWasteDivertedKg;

  const PlatformStats({
    this.totalUsers = 0,
    this.totalDonors = 0,
    this.totalCommunities = 0,
    this.totalAdmins = 0,
    this.totalVerifiedCommunities = 0,
    this.totalPendingCommunities = 0,
    this.totalItems = 0,
    this.availableItems = 0,
    this.completedItems = 0,
    this.totalRequests = 0,
    this.pendingRequests = 0,
    this.approvedRequests = 0,
    this.rejectedRequests = 0,
    this.estimatedWasteDivertedKg = 0.0,
  });
}

/// Repository untuk fitur-fitur manajemen lanjutan akun Administrator
class AdminRepository {
  final SupabaseClient _client;

  AdminRepository([SupabaseClient? client])
      : _client = client ?? SupabaseService.client;

  /// Ambil daftar semua pengguna dengan filter peran dan pencarian kata kunci
  Future<List<UserModel>> getUsers({
    String? role,
    String? searchQuery,
  }) async {
    var query = _client.from('profiles').select();

    if (role != null && role != 'all') {
      query = query.eq('role', role);
    }

    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      final q = '%${searchQuery.trim()}%';
      query = query.or('full_name.ilike.$q,email.ilike.$q');
    }

    final data = await query.order('created_at', ascending: false);
    return (data as List).map((e) => UserModel.fromJson(e)).toList();
  }

  /// Perbarui peran pengguna (misal mengangkat admin atau koreksi peran)
  Future<UserModel> updateUserRole({
    required String userId,
    required String newRole,
  }) async {
    final data = await _client
        .from('profiles')
        .update({'role': newRole})
        .eq('id', userId)
        .select()
        .single();

    return UserModel.fromJson(data);
  }

  /// Ambil agregasi statistik real-time platform CareCycle
  Future<PlatformStats> getPlatformStats() async {
    try {
      final profilesFuture = _client.from('profiles').select('id, role');
      final communitiesFuture = _client.from('communities').select('id, verification_status');
      final itemsFuture = _client.from('items').select('id, status');
      final requestsFuture = _client.from('requests').select('id, status');

      final results = await Future.wait([
        profilesFuture,
        communitiesFuture,
        itemsFuture,
        requestsFuture,
      ]);

      final profiles = results[0] as List;
      final communities = results[1] as List;
      final items = results[2] as List;
      final requests = results[3] as List;

      final totalUsers = profiles.length;
      final totalDonors = profiles.where((p) => p['role'] == 'donatur').length;
      final totalCommunities = profiles.where((p) => p['role'] == 'komunitas').length;
      final totalAdmins = profiles.where((p) => p['role'] == 'admin').length;

      final totalVerifiedCommunities =
          communities.where((c) => c['verification_status'] == 'verified').length;
      final totalPendingCommunities =
          communities.where((c) => c['verification_status'] == 'pending').length;

      final totalItems = items.length;
      final availableItems = items.where((i) => i['status'] == 'available').length;
      final completedItems = items.where((i) => i['status'] == 'completed').length;

      final totalRequests = requests.length;
      final pendingRequests = requests.where((r) => r['status'] == 'submitted').length;
      final approvedRequests = requests.where((r) => r['status'] == 'approved').length;
      final rejectedRequests = requests.where((r) => r['status'] == 'rejected').length;

      // Estimasi rata-rata 2.5 kg barang teralihkan per donasi sukses
      final estimatedWasteDivertedKg = (completedItems + approvedRequests) * 2.5;

      return PlatformStats(
        totalUsers: totalUsers,
        totalDonors: totalDonors,
        totalCommunities: totalCommunities,
        totalAdmins: totalAdmins,
        totalVerifiedCommunities: totalVerifiedCommunities,
        totalPendingCommunities: totalPendingCommunities,
        totalItems: totalItems,
        availableItems: availableItems,
        completedItems: completedItems,
        totalRequests: totalRequests,
        pendingRequests: pendingRequests,
        approvedRequests: approvedRequests,
        rejectedRequests: rejectedRequests,
        estimatedWasteDivertedKg: estimatedWasteDivertedKg,
      );
    } catch (_) {
      return const PlatformStats();
    }
  }

  /// Ambil daftar semua barang untuk moderasi admin
  Future<List<ItemModel>> getAllItemsForModeration({
    String? status,
    String? category,
    String? searchQuery,
  }) async {
    var query = _client.from('items').select();

    if (status != null && status != 'all') {
      query = query.eq('status', status);
    }

    if (category != null && category != 'all') {
      query = query.eq('category', category);
    }

    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      final q = '%${searchQuery.trim()}%';
      query = query.or('name.ilike.$q,description.ilike.$q');
    }

    final data = await query.order('created_at', ascending: false);
    return (data as List).map((e) => ItemModel.fromJson(e)).toList();
  }

  /// Moderasi status barang donasi (misal tandai selesai, batalkan, atau pulihkan)
  Future<ItemModel> moderateItemStatus({
    required String itemId,
    required String newStatus,
  }) async {
    final data = await _client
        .from('items')
        .update({'status': newStatus})
        .eq('id', itemId)
        .select()
        .single();

    return ItemModel.fromJson(data);
  }
}
