import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/data/models/user_model.dart';
import '../../../items/data/models/item_model.dart';
import '../../data/repositories/admin_repository.dart';

/// Provider singleton instance AdminRepository
final adminRepositoryProvider = Provider<AdminRepository>((ref) {
  return AdminRepository();
});

// ================= USER MANAGEMENT PROVIDER =================

class AdminUsersState {
  final bool isLoading;
  final List<UserModel> users;
  final String currentRoleFilter; // 'all', 'donatur', 'komunitas', 'admin'
  final String searchQuery;
  final String? errorMessage;
  final String? successMessage;

  const AdminUsersState({
    this.isLoading = false,
    this.users = const [],
    this.currentRoleFilter = 'all',
    this.searchQuery = '',
    this.errorMessage,
    this.successMessage,
  });

  AdminUsersState copyWith({
    bool? isLoading,
    List<UserModel>? users,
    String? currentRoleFilter,
    String? searchQuery,
    String? errorMessage,
    String? successMessage,
    bool clearMessages = false,
  }) {
    return AdminUsersState(
      isLoading: isLoading ?? this.isLoading,
      users: users ?? this.users,
      currentRoleFilter: currentRoleFilter ?? this.currentRoleFilter,
      searchQuery: searchQuery ?? this.searchQuery,
      errorMessage: clearMessages ? null : (errorMessage ?? this.errorMessage),
      successMessage: clearMessages ? null : (successMessage ?? this.successMessage),
    );
  }
}

final adminUsersNotifierProvider =
    StateNotifierProvider<AdminUsersNotifier, AdminUsersState>((ref) {
  final repo = ref.watch(adminRepositoryProvider);
  return AdminUsersNotifier(repo);
});

class AdminUsersNotifier extends StateNotifier<AdminUsersState> {
  final AdminRepository _repository;

  AdminUsersNotifier(this._repository) : super(const AdminUsersState()) {
    loadUsers();
  }

  Future<void> loadUsers() async {
    state = state.copyWith(isLoading: true, clearMessages: true);
    try {
      final list = await _repository.getUsers(
        role: state.currentRoleFilter,
        searchQuery: state.searchQuery,
      );
      state = state.copyWith(isLoading: false, users: list);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Gagal memuat pengguna: ${e.toString()}',
      );
    }
  }

  void setRoleFilter(String role) {
    state = state.copyWith(currentRoleFilter: role);
    loadUsers();
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
    loadUsers();
  }

  Future<bool> changeUserRole(String userId, String newRole) async {
    state = state.copyWith(isLoading: true, clearMessages: true);
    try {
      final updated = await _repository.updateUserRole(
        userId: userId,
        newRole: newRole,
      );

      final updatedUsers = state.users.map((u) {
        return u.id == updated.id ? updated : u;
      }).toList();

      state = state.copyWith(
        isLoading: false,
        users: updatedUsers,
        successMessage: 'Peran ${updated.fullName} berhasil diubah menjadi ${updated.roleDisplay}!',
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Gagal mengubah peran: ${e.toString()}',
      );
      return false;
    }
  }
}

// ================= ANALYTICS PROVIDER =================

final adminStatsProvider = FutureProvider<PlatformStats>((ref) async {
  final repo = ref.watch(adminRepositoryProvider);
  return repo.getPlatformStats();
});

// ================= ITEM MODERATION PROVIDER =================

class AdminItemsState {
  final bool isLoading;
  final List<ItemModel> items;
  final String statusFilter; // 'all', 'available', 'requested', 'processing', 'completed', 'cancelled'
  final String categoryFilter;
  final String searchQuery;
  final String? errorMessage;
  final String? successMessage;

  const AdminItemsState({
    this.isLoading = false,
    this.items = const [],
    this.statusFilter = 'all',
    this.categoryFilter = 'all',
    this.searchQuery = '',
    this.errorMessage,
    this.successMessage,
  });

  AdminItemsState copyWith({
    bool? isLoading,
    List<ItemModel>? items,
    String? statusFilter,
    String? categoryFilter,
    String? searchQuery,
    String? errorMessage,
    String? successMessage,
    bool clearMessages = false,
  }) {
    return AdminItemsState(
      isLoading: isLoading ?? this.isLoading,
      items: items ?? this.items,
      statusFilter: statusFilter ?? this.statusFilter,
      categoryFilter: categoryFilter ?? this.categoryFilter,
      searchQuery: searchQuery ?? this.searchQuery,
      errorMessage: clearMessages ? null : (errorMessage ?? this.errorMessage),
      successMessage: clearMessages ? null : (successMessage ?? this.successMessage),
    );
  }
}

final adminItemsNotifierProvider =
    StateNotifierProvider<AdminItemsNotifier, AdminItemsState>((ref) {
  final repo = ref.watch(adminRepositoryProvider);
  return AdminItemsNotifier(repo);
});

class AdminItemsNotifier extends StateNotifier<AdminItemsState> {
  final AdminRepository _repository;

  AdminItemsNotifier(this._repository) : super(const AdminItemsState()) {
    loadItems();
  }

  Future<void> loadItems() async {
    state = state.copyWith(isLoading: true, clearMessages: true);
    try {
      final list = await _repository.getAllItemsForModeration(
        status: state.statusFilter,
        category: state.categoryFilter,
        searchQuery: state.searchQuery,
      );
      state = state.copyWith(isLoading: false, items: list);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Gagal memuat barang: ${e.toString()}',
      );
    }
  }

  void setStatusFilter(String status) {
    state = state.copyWith(statusFilter: status);
    loadItems();
  }

  void setCategoryFilter(String category) {
    state = state.copyWith(categoryFilter: category);
    loadItems();
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
    loadItems();
  }

  Future<bool> updateItemStatus(String itemId, String newStatus) async {
    state = state.copyWith(isLoading: true, clearMessages: true);
    try {
      final updated = await _repository.moderateItemStatus(
        itemId: itemId,
        newStatus: newStatus,
      );

      final updatedList = state.items.map((i) {
        return i.id == updated.id ? updated : i;
      }).toList();

      state = state.copyWith(
        isLoading: false,
        items: updatedList,
        successMessage: 'Status barang "${updated.name}" berhasil diubah menjadi ${updated.statusDisplay}!',
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Gagal memperbarui status barang: ${e.toString()}',
      );
      return false;
    }
  }
}
