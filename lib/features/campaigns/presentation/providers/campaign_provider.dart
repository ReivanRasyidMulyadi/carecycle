import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/campaign_model.dart';
import '../../data/repositories/campaign_repository.dart';

final campaignRepositoryProvider = Provider<CampaignRepository>((ref) {
  return CampaignRepository();
});

class CampaignState {
  final bool isLoading;
  final List<CampaignModel> campaigns;
  final String statusFilter; // 'all', 'active', 'completed'
  final String categoryFilter;
  final String? errorMessage;
  final String? successMessage;

  const CampaignState({
    this.isLoading = false,
    this.campaigns = const [],
    this.statusFilter = 'all',
    this.categoryFilter = 'all',
    this.errorMessage,
    this.successMessage,
  });

  CampaignState copyWith({
    bool? isLoading,
    List<CampaignModel>? campaigns,
    String? statusFilter,
    String? categoryFilter,
    String? errorMessage,
    String? successMessage,
    bool clearMessages = false,
  }) {
    return CampaignState(
      isLoading: isLoading ?? this.isLoading,
      campaigns: campaigns ?? this.campaigns,
      statusFilter: statusFilter ?? this.statusFilter,
      categoryFilter: categoryFilter ?? this.categoryFilter,
      errorMessage: clearMessages ? null : (errorMessage ?? this.errorMessage),
      successMessage: clearMessages ? null : (successMessage ?? this.successMessage),
    );
  }
}

final campaignNotifierProvider =
    StateNotifierProvider<CampaignNotifier, CampaignState>((ref) {
  final repo = ref.watch(campaignRepositoryProvider);
  return CampaignNotifier(repo);
});

class CampaignNotifier extends StateNotifier<CampaignState> {
  final CampaignRepository _repository;

  CampaignNotifier(this._repository) : super(const CampaignState()) {
    loadCampaigns();
  }

  Future<void> loadCampaigns() async {
    state = state.copyWith(isLoading: true, clearMessages: true);
    try {
      final list = await _repository.getCampaigns(
        status: state.statusFilter,
        category: state.categoryFilter,
      );
      state = state.copyWith(isLoading: false, campaigns: list);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Gagal memuat kampanye: ${e.toString()}',
      );
    }
  }

  void setStatusFilter(String status) {
    state = state.copyWith(statusFilter: status);
    loadCampaigns();
  }

  void setCategoryFilter(String category) {
    state = state.copyWith(categoryFilter: category);
    loadCampaigns();
  }

  Future<bool> createCampaign({
    required String communityId,
    required String title,
    required String description,
    required String targetCategory,
    required int targetQuantity,
    DateTime? endDate,
  }) async {
    state = state.copyWith(isLoading: true, clearMessages: true);
    try {
      final newCamp = await _repository.createCampaign(
        communityId: communityId,
        title: title,
        description: description,
        targetCategory: targetCategory,
        targetQuantity: targetQuantity,
        endDate: endDate,
      );

      state = state.copyWith(
        isLoading: false,
        campaigns: [newCamp, ...state.campaigns],
        successMessage: 'Kampanye "${newCamp.title}" berhasil diterbitkan!',
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Gagal membuat kampanye: ${e.toString()}',
      );
      return false;
    }
  }

  Future<bool> pledgeCampaign({
    required String campaignId,
    required String donorId,
    required int quantity,
    String? notes,
  }) async {
    state = state.copyWith(isLoading: true, clearMessages: true);
    try {
      await _repository.pledgeCampaign(
        campaignId: campaignId,
        donorId: donorId,
        quantity: quantity,
        notes: notes,
      );

      await loadCampaigns();
      state = state.copyWith(
        successMessage: 'Terima kasih! Komitmen donasi $quantity barang berhasil dicatat.',
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Gagal mendukung kampanye: ${e.toString()}',
      );
      return false;
    }
  }

  Future<bool> updateStatus(String campaignId, String newStatus) async {
    state = state.copyWith(isLoading: true, clearMessages: true);
    try {
      final updated = await _repository.updateCampaignStatus(
        campaignId: campaignId,
        newStatus: newStatus,
      );

      final list = state.campaigns.map((c) => c.id == updated.id ? updated : c).toList();
      state = state.copyWith(
        isLoading: false,
        campaigns: list,
        successMessage: 'Status kampanye berhasil diubah.',
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Gagal mengubah status: ${e.toString()}',
      );
      return false;
    }
  }
}
