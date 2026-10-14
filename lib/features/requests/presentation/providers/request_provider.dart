import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/models/request_model.dart';
import '../../data/repositories/request_repository.dart';

/// Provider instance untuk RequestRepository
final requestRepositoryProvider = Provider<RequestRepository>((ref) {
  return RequestRepository();
});

/// State untuk Permintaan Masuk ke Donatur
class DonorRequestsState {
  final bool isLoading;
  final List<RequestModel> requests;
  final String? newNotificationMessage;
  final String? errorMessage;
  final String? successMessage;

  const DonorRequestsState({
    this.isLoading = false,
    this.requests = const [],
    this.newNotificationMessage,
    this.errorMessage,
    this.successMessage,
  });

  int get pendingRequestsCount =>
      requests.where((r) => r.isSubmitted).length;

  DonorRequestsState copyWith({
    bool? isLoading,
    List<RequestModel>? requests,
    String? newNotificationMessage,
    String? errorMessage,
    String? successMessage,
    bool clearMessages = false,
  }) {
    return DonorRequestsState(
      isLoading: isLoading ?? this.isLoading,
      requests: requests ?? this.requests,
      newNotificationMessage: clearMessages
          ? null
          : (newNotificationMessage ?? this.newNotificationMessage),
      errorMessage: clearMessages ? null : (errorMessage ?? this.errorMessage),
      successMessage: clearMessages ? null : (successMessage ?? this.successMessage),
    );
  }
}

/// Provider StateNotifier untuk Permintaan Masuk Donatur & Supabase Realtime
final donorRequestsNotifierProvider = StateNotifierProvider<
    DonorRequestsNotifier, DonorRequestsState>((ref) {
  final repository = ref.watch(requestRepositoryProvider);
  final user = ref.watch(authNotifierProvider).user;
  return DonorRequestsNotifier(repository, user?.id);
});

class DonorRequestsNotifier extends StateNotifier<DonorRequestsState> {
  final RequestRepository _repository;
  final String? _donorId;
  StreamSubscription? _realtimeSubscription;

  DonorRequestsNotifier(this._repository, this._donorId)
      : super(const DonorRequestsState()) {
    if (_donorId != null) {
      loadIncomingRequests();
      _initRealtimeStream();
    }
  }

  /// Langganan Supabase Realtime Stream untuk menerima notifikasi in-app instan
  void _initRealtimeStream() {
    _realtimeSubscription = _repository.streamRequestsTable().listen((data) async {
      if (_donorId != null) {
        // Ambil data terbaru dan periksa apakah ada permintaan baru
        final previousCount = state.pendingRequestsCount;
        final latest = await _repository.getIncomingRequestsForDonor(_donorId);
        final newPendingCount = latest.where((r) => r.isSubmitted).length;

        String? alertMsg;
        if (newPendingCount > previousCount) {
          final newest = latest.firstWhere((r) => r.isSubmitted);
          alertMsg = '🔔 Permintaan donasi baru dari "${newest.communityName ?? "Komunitas"}" untuk "${newest.itemName ?? "barang Anda"}"!';
        }

        state = state.copyWith(
          requests: latest,
          newNotificationMessage: alertMsg,
        );
      }
    });
  }

  /// Memuat daftar permintaan masuk dari komunitas
  Future<void> loadIncomingRequests() async {
    if (_donorId == null) return;
    state = state.copyWith(isLoading: true, clearMessages: true);

    try {
      final list = await _repository.getIncomingRequestsForDonor(_donorId);
      state = state.copyWith(
        isLoading: false,
        requests: list,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Gagal memuat permintaan donasi: ${e.toString()}',
      );
    }
  }

  /// Setujui permintaan donasi & tentukan metode serah terima
  Future<bool> approveRequest({
    required String requestId,
    required String itemId,
    String? deliveryMethod,
    String? trackingNumber,
    String? notes,
  }) async {
    state = state.copyWith(isLoading: true, clearMessages: true);

    try {
      final updated = await _repository.approveRequest(
        requestId: requestId,
        itemId: itemId,
        deliveryMethod: deliveryMethod,
        trackingNumber: trackingNumber,
        notes: notes,
      );

      final updatedList = state.requests.map((r) {
        return r.id == updated.id ? updated : r;
      }).toList();

      state = state.copyWith(
        isLoading: false,
        requests: updatedList,
        successMessage:
            'Permintaan disetujui! Status barang berubah menjadi Sedang Diproses (In-Process).',
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Gagal menyetujui permintaan: ${e.toString()}',
      );
      return false;
    }
  }

  /// Tolak permintaan donasi
  Future<bool> rejectRequest({
    required String requestId,
    required String itemId,
    String? notes,
  }) async {
    state = state.copyWith(isLoading: true, clearMessages: true);

    try {
      final updated = await _repository.rejectRequest(
        requestId: requestId,
        itemId: itemId,
        notes: notes,
      );

      final updatedList = state.requests.map((r) {
        return r.id == updated.id ? updated : r;
      }).toList();

      state = state.copyWith(
        isLoading: false,
        requests: updatedList,
        successMessage: 'Permintaan donasi telah ditolak.',
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Gagal menolak permintaan: ${e.toString()}',
      );
      return false;
    }
  }

  /// Perbarui metode serah terima
  Future<bool> updateDeliveryDetails({
    required String requestId,
    required String deliveryMethod,
    String? trackingNumber,
    String? notes,
  }) async {
    try {
      final updated = await _repository.updateDeliveryDetails(
        requestId: requestId,
        deliveryMethod: deliveryMethod,
        trackingNumber: trackingNumber,
        notes: notes,
      );

      final updatedList = state.requests.map((r) {
        return r.id == updated.id ? updated : r;
      }).toList();

      state = state.copyWith(
        requests: updatedList,
        successMessage: 'Metode serah terima berhasil diperbarui!',
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Gagal memperbarui serah terima: ${e.toString()}',
      );
      return false;
    }
  }

  @override
  void dispose() {
    _realtimeSubscription?.cancel();
    super.dispose();
  }
}
