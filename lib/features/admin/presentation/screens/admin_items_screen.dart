import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../items/data/models/item_model.dart';
import '../providers/admin_provider.dart';

/// Layar Moderasi Barang untuk Administrator CareCycle
class AdminItemsScreen extends ConsumerStatefulWidget {
  const AdminItemsScreen({super.key});

  @override
  ConsumerState<AdminItemsScreen> createState() => _AdminItemsScreenState();
}

class _AdminItemsScreenState extends ConsumerState<AdminItemsScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(adminItemsNotifierProvider);

    ref.listen<AdminItemsState>(adminItemsNotifierProvider, (prev, next) {
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
      title: 'Moderasi Barang Donasi',
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          tooltip: 'Segarkan',
          onPressed: () {
            ref.read(adminItemsNotifierProvider.notifier).loadItems();
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
                hintText: 'Cari nama atau deskripsi barang...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          ref
                              .read(adminItemsNotifierProvider.notifier)
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
                ref.read(adminItemsNotifierProvider.notifier).setSearchQuery(val);
              },
            ),
          ),

          // Status Filter Chips
          _buildStatusFilterChips(state.statusFilter),
          const Divider(height: 1),

          // Items List
          Expanded(
            child: state.isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: () async {
                      await ref
                          .read(adminItemsNotifierProvider.notifier)
                          .loadItems();
                    },
                    child: state.items.isEmpty
                        ? _buildEmptyState()
                        : ListView.separated(
                            padding: const EdgeInsets.all(AppSizes.md),
                            itemCount: state.items.length,
                            separatorBuilder: (context, index) =>
                                const SizedBox(height: AppSizes.sm),
                            itemBuilder: (context, index) {
                              final item = state.items[index];
                              return _buildItemCard(item);
                            },
                          ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusFilterChips(String currentFilter) {
    final filters = [
      {'key': 'all', 'label': 'Semua'},
      {'key': 'available', 'label': 'Tersedia'},
      {'key': 'requested', 'label': 'Diminta'},
      {'key': 'processing', 'label': 'Diproses'},
      {'key': 'completed', 'label': 'Selesai'},
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
                      .read(adminItemsNotifierProvider.notifier)
                      .setStatusFilter(f['key']!);
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
              Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey.shade400),
              const SizedBox(height: AppSizes.md),
              const Text(
                'Tidak Ada Barang Ditemukan',
                style: TextStyle(
                  fontSize: AppSizes.fontMd,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Coba gunakan filter status atau kata kunci yang berbeda.',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildItemCard(ItemModel item) {
    Color statusColor;
    switch (item.status) {
      case 'available':
        statusColor = AppColors.success;
        break;
      case 'requested':
        statusColor = AppColors.warning;
        break;
      case 'processing':
        statusColor = Colors.blue;
        break;
      case 'completed':
        statusColor = Colors.purple;
        break;
      default:
        statusColor = Colors.grey;
    }

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.sm),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail
            ClipRRect(
              borderRadius: BorderRadius.circular(AppSizes.radiusSm),
              child: item.photoUrls.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: item.photoUrls.first,
                      width: 70,
                      height: 70,
                      fit: BoxFit.cover,
                      errorWidget: (_, __, ___) => Container(
                        width: 70,
                        height: 70,
                        color: Colors.grey.shade200,
                        child: const Icon(Icons.image, size: 28),
                      ),
                    )
                  : Container(
                      width: 70,
                      height: 70,
                      color: Colors.grey.shade200,
                      child: const Icon(Icons.inventory_2, size: 28, color: Colors.grey),
                    ),
            ),
            const SizedBox(width: AppSizes.sm),

            // Item Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          item.name,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: statusColor),
                        ),
                        child: Text(
                          item.statusDisplay,
                          style: TextStyle(
                            color: statusColor,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.description,
                    style: const TextStyle(fontSize: 12, color: Colors.black54),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: Text(
                          item.categoryDisplay,
                          style: const TextStyle(fontSize: 10, color: Colors.black87),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Kondisi: ${item.conditionDisplay}',
                        style: const TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                      const Spacer(),
                      // Moderation button
                      InkWell(
                        onTap: () => _showModerationDialog(item),
                        child: const Padding(
                          padding: EdgeInsets.all(4),
                          child: Row(
                            children: [
                              Icon(Icons.edit, size: 14, color: AppColors.primary),
                              SizedBox(width: 2),
                              Text(
                                'Moderasi',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showModerationDialog(ItemModel item) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text('Moderasi "${item.name}"'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Ubah status barang donasi:', style: TextStyle(fontSize: 13)),
              const SizedBox(height: 12),
              _buildStatusOption(item, 'available', 'Tersedia di Katalog', ctx),
              _buildStatusOption(item, 'processing', 'Sedang Diproses', ctx),
              _buildStatusOption(item, 'completed', 'Donasi Selesai', ctx),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Batal'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatusOption(
    ItemModel item,
    String targetStatus,
    String label,
    BuildContext dialogContext,
  ) {
    final isSelected = item.status == targetStatus;

    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
        color: isSelected ? AppColors.primary : Colors.grey,
        size: 20,
      ),
      title: Text(label, style: const TextStyle(fontSize: 13)),
      onTap: isSelected
          ? null
          : () async {
              Navigator.pop(dialogContext);
              await ref
                  .read(adminItemsNotifierProvider.notifier)
                  .updateItemStatus(item.id, targetStatus);
            },
    );
  }
}
