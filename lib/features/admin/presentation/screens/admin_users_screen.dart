import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../auth/data/models/user_model.dart';
import '../providers/admin_provider.dart';

/// Layar Manajemen Pengguna untuk Administrator CareCycle
class AdminUsersScreen extends ConsumerStatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  ConsumerState<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends ConsumerState<AdminUsersScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(adminUsersNotifierProvider);

    ref.listen<AdminUsersState>(adminUsersNotifierProvider, (prev, next) {
      if (next.successMessage != null &&
          next.successMessage != prev?.successMessage) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.successMessage!),
            backgroundColor: AppColors.success,
          ),
        );
      }
      if (next.errorMessage != null &&
          next.errorMessage != prev?.errorMessage) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: AppColors.error,
          ),
        );
      }
    });

    return AppScaffold(
      title: 'Manajemen Pengguna',
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          tooltip: 'Segarkan',
          onPressed: () {
            ref.read(adminUsersNotifierProvider.notifier).loadUsers();
          },
        ),
      ],
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSizes.md, AppSizes.sm, AppSizes.md, 0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Cari nama atau email pengguna...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          ref
                              .read(adminUsersNotifierProvider.notifier)
                              .setSearchQuery('');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
              ),
              onChanged: (val) {
                ref.read(adminUsersNotifierProvider.notifier).setSearchQuery(val);
              },
            ),
          ),

          // Role Filter Chips
          _buildRoleFilterChips(state.currentRoleFilter),
          const Divider(height: 1),

          // Users List
          Expanded(
            child: state.isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: () async {
                      await ref
                          .read(adminUsersNotifierProvider.notifier)
                          .loadUsers();
                    },
                    child: state.users.isEmpty
                        ? _buildEmptyState()
                        : ListView.separated(
                            padding: const EdgeInsets.all(AppSizes.md),
                            itemCount: state.users.length,
                            separatorBuilder: (context, index) =>
                                const SizedBox(height: AppSizes.sm),
                            itemBuilder: (context, index) {
                              final u = state.users[index];
                              return _buildUserCard(u);
                            },
                          ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleFilterChips(String currentFilter) {
    final filters = [
      {'key': 'all', 'label': 'Semua'},
      {'key': 'donatur', 'label': 'Donatur'},
      {'key': 'komunitas', 'label': 'Komunitas'},
      {'key': 'admin', 'label': 'Admin'},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.md, vertical: 8),
      child: Row(
        children: filters.map((f) {
          final isSelected = currentFilter == f['key'];
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(f['label']!),
              selected: isSelected,
              selectedColor: AppColors.primarySwatch.shade100,
              labelStyle: TextStyle(
                color: isSelected ? AppColors.primary : Colors.black87,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              onSelected: (selected) {
                if (selected) {
                  ref
                      .read(adminUsersNotifierProvider.notifier)
                      .setRoleFilter(f['key']!);
                }
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildEmptyState() {
    return ListView(
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.2),
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.people_outline, size: 64, color: Colors.grey.shade400),
              const SizedBox(height: AppSizes.md),
              const Text(
                'Tidak Ada Pengguna Ditemukan',
                style: TextStyle(
                  fontSize: AppSizes.fontMd,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Coba gunakan kata kunci lain atau ubah filter peranan.',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUserCard(UserModel user) {
    Color roleColor;
    IconData roleIcon;

    if (user.isAdmin) {
      roleColor = Colors.purple;
      roleIcon = Icons.admin_panel_settings;
    } else if (user.isKomunitas) {
      roleColor = AppColors.info;
      roleIcon = Icons.groups;
    } else {
      roleColor = AppColors.primary;
      roleIcon = Icons.person;
    }

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        leading: CircleAvatar(
          backgroundColor: roleColor.withOpacity(0.15),
          child: Text(
            user.fullName.isNotEmpty ? user.fullName[0].toUpperCase() : 'U',
            style: TextStyle(color: roleColor, fontWeight: FontWeight.bold),
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                user.fullName,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: roleColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: roleColor),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(roleIcon, size: 12, color: roleColor),
                  const SizedBox(width: 4),
                  Text(
                    user.roleDisplay,
                    style: TextStyle(color: roleColor, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 2),
            Text(user.email, style: const TextStyle(fontSize: 12, color: Colors.black54)),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.workspace_premium, size: 13, color: Colors.amber.shade800),
                const SizedBox(width: 4),
                Text('${user.carePoints} Poin', style: const TextStyle(fontSize: 11)),
                if (user.createdAt != null) ...[
                  const Text(' • ', style: TextStyle(color: Colors.grey)),
                  Text(
                    'Bergabung ${user.createdAt!.toIndonesianDate}',
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ],
              ],
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.more_vert, size: 20),
          onPressed: () => _showUserActionModal(user),
        ),
      ),
    );
  }

  void _showUserActionModal(UserModel user) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSizes.radiusLg)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: AppColors.primarySwatch.shade100,
                      child: Text(
                        user.fullName.isNotEmpty ? user.fullName[0].toUpperCase() : 'U',
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.fullName,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          Text(user.email, style: const TextStyle(fontSize: 12, color: Colors.black54)),
                        ],
                      ),
                    ),
                  ],
                ),
                const Divider(height: 24),
                const Text(
                  'Ubah Peran Pengguna:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildRoleOptionButton(user, 'donatur', 'Donatur', ctx),
                    const SizedBox(width: 8),
                    _buildRoleOptionButton(user, 'komunitas', 'Komunitas', ctx),
                    const SizedBox(width: 8),
                    _buildRoleOptionButton(user, 'admin', 'Admin', ctx),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRoleOptionButton(
    UserModel user,
    String targetRole,
    String label,
    BuildContext modalContext,
  ) {
    final isCurrent = user.role == targetRole;

    return Expanded(
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          backgroundColor: isCurrent ? AppColors.primary : Colors.transparent,
          foregroundColor: isCurrent ? Colors.white : AppColors.primary,
          side: const BorderSide(color: AppColors.primary),
          padding: const EdgeInsets.symmetric(vertical: 8),
        ),
        onPressed: isCurrent
            ? null
            : () async {
                Navigator.pop(modalContext);
                await ref
                    .read(adminUsersNotifierProvider.notifier)
                    .changeUserRole(user.id, targetRole);
              },
        child: Text(label, style: const TextStyle(fontSize: 12)),
      ),
    );
  }
}
