import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/community_model.dart';
import '../../data/repositories/community_repository.dart';

/// Provider instance untuk CommunityRepository
final communityRepositoryProvider = Provider<CommunityRepository>((ref) {
  return CommunityRepository();
});

/// State untuk antrean verifikasi di layar Admin
class AdminVerificationState {
  final bool isLoading;
  final List<CommunityModel> communities;
  final String currentFilter; // 'all', 'pending', 'verified', 'rejected'
  final String? errorMessage;
  final String? actionSuccessMessage;

  const AdminVerificationState({
    this.isLoading = false,
    this.communities = const [],
    this.currentFilter = 'pending',
    this.errorMessage,
    this.actionSuccessMessage,
  });

  AdminVerificationState copyWith({
    bool? isLoading,
    List<CommunityModel>? communities,
    String? currentFilter,
    String? errorMessage,
    String? actionSuccessMessage,
    bool clearMessages = false,
  }) {
    return AdminVerificationState(
      isLoading: isLoading ?? this.isLoading,
      communities: communities ?? this.communities,
      currentFilter: currentFilter ?? this.currentFilter,
      errorMessage: clearMessages ? null : (errorMessage ?? this.errorMessage),
      actionSuccessMessage: clearMessages
          ? null
          : (actionSuccessMessage ?? this.actionSuccessMessage),
    );
  }
}

/// Provider StateNotifier untuk manajemen antrean verifikasi Admin
final adminVerificationNotifierProvider = StateNotifierProvider<
    AdminVerificationNotifier, AdminVerificationState>((ref) {
  final repo = ref.watch(communityRepositoryProvider);
  return AdminVerificationNotifier(repo);
});

class AdminVerificationNotifier extends StateNotifier<AdminVerificationState> {
  final CommunityRepository _repository;

  AdminVerificationNotifier(this._repository)
      : super(const AdminVerificationState()) {
    loadCommunities();
  }

  /// Memuat daftar komunitas berdasarkan filter aktif
  Future<void> loadCommunities({String? filter}) async {
    final activeFilter = filter ?? state.currentFilter;
    state = state.copyWith(
      isLoading: true,
      currentFilter: activeFilter,
      clearMessages: true,
    );

    try {
      final list = await _repository.getCommunitiesList(
        statusFilter: activeFilter,
      );
      state = state.copyWith(
        isLoading: false,
        communities: list,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Gagal memuat antrean verifikasi: ${e.toString()}',
      );
    }
  }

  /// Ubah filter status komunitas
  void changeFilter(String newFilter) {
    if (state.currentFilter != newFilter) {
      loadCommunities(filter: newFilter);
    }
  }

  /// Menyetujui komunitas
  Future<bool> approveCommunity({
    required String communityId,
    required String adminId,
  }) async {
    state = state.copyWith(isLoading: true, clearMessages: true);
    try {
      final updated = await _repository.approveCommunity(
        communityId: communityId,
        adminId: adminId,
      );

      // Perbarui list lokal
      final updatedList = state.communities.map((c) {
        return c.id == updated.id ? updated : c;
      }).toList();

      state = state.copyWith(
        isLoading: false,
        communities: updatedList,
        actionSuccessMessage: 'Komunitas "${updated.communityName}" berhasil diverifikasi.',
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Gagal menyetujui komunitas: ${e.toString()}',
      );
      return false;
    }
  }

  /// Menolak komunitas dengan alasan
  Future<bool> rejectCommunity({
    required String communityId,
    required String rejectionReason,
  }) async {
    state = state.copyWith(isLoading: true, clearMessages: true);
    try {
      final updated = await _repository.rejectCommunity(
        communityId: communityId,
        rejectionReason: rejectionReason,
      );

      final updatedList = state.communities.map((c) {
        return c.id == updated.id ? updated : c;
      }).toList();

      state = state.copyWith(
        isLoading: false,
        communities: updatedList,
        actionSuccessMessage: 'Verifikasi komunitas "${updated.communityName}" ditolak.',
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Gagal menolak komunitas: ${e.toString()}',
      );
      return false;
    }
  }
}
