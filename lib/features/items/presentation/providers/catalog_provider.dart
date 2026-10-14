import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/connectivity_service.dart';
import '../../data/models/item_model.dart';
import '../providers/item_provider.dart';

/// State untuk Katalog Publik
class CatalogState {
  final bool isLoading;
  final List<ItemModel> items;
  final String selectedCategory;
  final String searchQuery;
  final bool isOffline;
  final String? errorMessage;

  const CatalogState({
    this.isLoading = false,
    this.items = const [],
    this.selectedCategory = 'Semua',
    this.searchQuery = '',
    this.isOffline = false,
    this.errorMessage,
  });

  CatalogState copyWith({
    bool? isLoading,
    List<ItemModel>? items,
    String? selectedCategory,
    String? searchQuery,
    bool? isOffline,
    String? errorMessage,
    bool clearError = false,
  }) {
    return CatalogState(
      isLoading: isLoading ?? this.isLoading,
      items: items ?? this.items,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      searchQuery: searchQuery ?? this.searchQuery,
      isOffline: isOffline ?? this.isOffline,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

/// Provider StateNotifier untuk Katalog Publik
final catalogNotifierProvider =
    StateNotifierProvider<CatalogNotifier, CatalogState>((ref) {
  final repository = ref.watch(itemRepositoryProvider);
  return CatalogNotifier(repository);
});

class CatalogNotifier extends StateNotifier<CatalogState> {
  final dynamic _repository;

  CatalogNotifier(this._repository) : super(const CatalogState()) {
    loadCatalog();
  }

  /// Memuat daftar barang katalog publik
  Future<void> loadCatalog() async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final isOnline = await ConnectivityService.isConnected();
      final items = await _repository.getPublicCatalog(
        category: state.selectedCategory == 'Semua' ? null : state.selectedCategory,
        searchQuery: state.searchQuery,
      );

      state = state.copyWith(
        isLoading: false,
        items: items,
        isOffline: !isOnline,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Gagal memuat katalog: ${e.toString()}',
      );
    }
  }

  /// Ubah filter kategori
  void setCategory(String category) {
    if (state.selectedCategory != category) {
      state = state.copyWith(selectedCategory: category);
      loadCatalog();
    }
  }

  /// Ubah query pencarian barang
  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
    loadCatalog();
  }

  /// Refresh katalog secara manual
  Future<void> refresh() async {
    await loadCatalog();
  }
}
