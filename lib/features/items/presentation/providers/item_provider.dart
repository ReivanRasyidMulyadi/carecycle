import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/connectivity_service.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/models/item_model.dart';
import '../../data/repositories/item_repository.dart';

/// Provider instance untuk ItemRepository
final itemRepositoryProvider = Provider<ItemRepository>((ref) {
  return ItemRepository();
});

/// State untuk daftar barang saya (donatur)
class MyItemsState {
  final bool isLoading;
  final bool isSyncing;
  final List<ItemModel> items;
  final String? errorMessage;
  final String? successMessage;

  const MyItemsState({
    this.isLoading = false,
    this.isSyncing = false,
    this.items = const [],
    this.errorMessage,
    this.successMessage,
  });

  int get pendingDraftsCount => items.where((i) => i.isPendingSync).length;
  bool get hasPendingDrafts => pendingDraftsCount > 0;

  MyItemsState copyWith({
    bool? isLoading,
    bool? isSyncing,
    List<ItemModel>? items,
    String? errorMessage,
    String? successMessage,
    bool clearMessages = false,
  }) {
    return MyItemsState(
      isLoading: isLoading ?? this.isLoading,
      isSyncing: isSyncing ?? this.isSyncing,
      items: items ?? this.items,
      errorMessage: clearMessages ? null : (errorMessage ?? this.errorMessage),
      successMessage: clearMessages ? null : (successMessage ?? this.successMessage),
    );
  }
}

/// Provider StateNotifier untuk manajemen "Barang Saya"
final myItemsNotifierProvider =
    StateNotifierProvider<MyItemsNotifier, MyItemsState>((ref) {
  final repository = ref.watch(itemRepositoryProvider);
  final user = ref.watch(authNotifierProvider).user;
  return MyItemsNotifier(repository, user?.id);
});

class MyItemsNotifier extends StateNotifier<MyItemsState> {
  final ItemRepository _repository;
  final String? _donorId;
  StreamSubscription? _connectivitySubscription;

  MyItemsNotifier(this._repository, this._donorId) : super(const MyItemsState()) {
    if (_donorId != null) {
      loadItems();
      _initAutoSyncListener();
    }
  }

  /// Memantau konektivitas untuk auto-sync draft saat koneksi pulih
  void _initAutoSyncListener() {
    _connectivitySubscription =
        ConnectivityService.onConnectivityChanged.listen((results) async {
      final isConnected = !results.contains(ConnectivityResult.none);
      if (isConnected && _donorId != null && state.hasPendingDrafts) {
        await syncPendingDrafts();
      }
    });
  }

  /// Memuat daftar barang donasi milik user aktif
  Future<void> loadItems() async {
    if (_donorId == null) return;
    state = state.copyWith(isLoading: true, clearMessages: true);

    try {
      final list = await _repository.getMyItems(_donorId);
      state = state.copyWith(isLoading: false, items: list);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Gagal memuat barang donasi: ${e.toString()}',
      );
    }
  }

  /// Sinkronisasi manual atau otomatis semua draft tertunda
  Future<int> syncPendingDrafts() async {
    if (_donorId == null) return 0;
    state = state.copyWith(isSyncing: true, clearMessages: true);

    try {
      final syncedCount = await _repository.syncPendingDrafts(_donorId);
      final updatedList = await _repository.getMyItems(_donorId);

      state = state.copyWith(
        isSyncing: false,
        items: updatedList,
        successMessage: syncedCount > 0
            ? '$syncedCount barang draft berhasil disinkronkan ke server!'
            : null,
      );
      return syncedCount;
    } catch (e) {
      state = state.copyWith(
        isSyncing: false,
        errorMessage: 'Gagal sinkronisasi: ${e.toString()}',
      );
      return 0;
    }
  }

  /// Hapus barang donasi atau draft
  Future<bool> deleteItem(String itemId, {bool isDraft = false}) async {
    try {
      await _repository.deleteItem(itemId, isDraft: isDraft);
      final updatedList = state.items.where((i) => i.id != itemId).toList();
      state = state.copyWith(
        items: updatedList,
        successMessage: 'Barang berhasil dihapus.',
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Gagal menghapus barang: ${e.toString()}',
      );
      return false;
    }
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    super.dispose();
  }
}
