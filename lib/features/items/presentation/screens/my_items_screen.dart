import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../data/models/item_model.dart';
import '../providers/item_provider.dart';

/// Layar daftar barang donasi milik pengguna aktif ("Barang Saya")
class MyItemsScreen extends ConsumerWidget {
  const MyItemsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(myItemsNotifierProvider);

    // Dengarkan pesan sukses atau error untuk menampilkan snackbar
    ref.listen<MyItemsState>(myItemsNotifierProvider, (prev, next) {
      if (next.successMessage != null && next.successMessage != prev?.successMessage) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.successMessage!),
            backgroundColor: AppColors.success,
          ),
        );
      }
      if (next.errorMessage != null && next.errorMessage != prev?.errorMessage) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: AppColors.error,
          ),
        );
      }
    });

    return AppScaffold(
      title: 'Barang Saya',
      actions: [
        IconButton(
          icon: const Icon(Icons.add_photo_alternate_outlined),
          tooltip: 'Unggah Donasi',
          onPressed: () {
            context.pushNamed(AppRouter.upload);
          },
        ),
      ],
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(myItemsNotifierProvider.notifier).loadItems();
          if (state.hasPendingDrafts) {
            await ref.read(myItemsNotifierProvider.notifier).syncPendingDrafts();
          }
        },
        child: Column(
          children: [
            // Banner Sinkronisasi jika terdapat draft offline yang belum terunggah
            if (state.hasPendingDrafts) ...[
              _buildSyncBanner(context, ref, state),
            ],

            // Konten Daftar Barang
            Expanded(
              child: state.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : state.items.isEmpty
                      ? _buildEmptyState(context)
                      : ListView.separated(
                          padding: const EdgeInsets.all(AppSizes.md),
                          itemCount: state.items.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: AppSizes.md),
                          itemBuilder: (context, index) {
                            final item = state.items[index];
                            return _buildItemCard(context, ref, item);
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  /// Banner indikator draft offline yang menunggu koneksi
  Widget _buildSyncBanner(
    BuildContext context,
    WidgetRef ref,
    MyItemsState state,
  ) {
    return Container(
      margin: const EdgeInsets.fromLTRB(AppSizes.md, AppSizes.md, AppSizes.md, 0),
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(color: Colors.amber.shade400),
      ),
      child: Row(
        children: [
          const Icon(Icons.cloud_upload_outlined, color: Colors.amber, size: 28),
          const SizedBox(width: AppSizes.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${state.pendingDraftsCount} Draft Menunggu Koneksi',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: Colors.amber.shade900,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Akan otomatis diunggah saat koneksi internet pulih.',
                  style: TextStyle(fontSize: 11),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSizes.xs),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            onPressed: state.isSyncing
                ? null
                : () {
                    ref.read(myItemsNotifierProvider.notifier).syncPendingDrafts();
                  },
            child: state.isSyncing
                ? const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Text('Sinkronkan', style: TextStyle(fontSize: 11)),
          ),
        ],
      ),
    );
  }

  /// Tampilan kosong ketika belum ada barang yang didonasikan
  Widget _buildEmptyState(BuildContext context) {
    return ListView(
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.18),
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey.shade400),
              const SizedBox(height: AppSizes.md),
              const Text(
                'Belum Ada Barang Donasi',
                style: TextStyle(
                  fontSize: AppSizes.fontLg,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Mulai donasikan barang layak pakai Anda kepada sesama yang membutuhkan.',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondaryLight),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSizes.lg),
              ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Donasikan Barang Sekarang'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                onPressed: () {
                  context.pushNamed(AppRouter.upload);
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Kartu barang donasi / draft
  Widget _buildItemCard(BuildContext context, WidgetRef ref, ItemModel item) {
    Color statusColor;
    if (item.isPendingSync) {
      statusColor = AppColors.warning;
    } else {
      switch (item.status) {
        case 'available':
          statusColor = AppColors.success;
          break;
        case 'requested':
          statusColor = Colors.orange;
          break;
        case 'processing':
          statusColor = AppColors.primary;
          break;
        case 'completed':
          statusColor = Colors.blueGrey;
          break;
        default:
          statusColor = Colors.grey;
      }
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Gambar barang
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(AppSizes.radiusMd)),
            child: _buildItemImage(item),
          ),

          Padding(
            padding: const EdgeInsets.all(AppSizes.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Judul & Badge Status
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        item.name,
                        style: const TextStyle(
                          fontSize: AppSizes.fontMd,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSizes.xs),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                        border: Border.all(color: statusColor),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (item.isPendingSync) ...[
                            const Icon(Icons.wifi_off, size: 12, color: AppColors.warning),
                            const SizedBox(width: 4),
                          ],
                          Text(
                            item.statusDisplay,
                            style: TextStyle(
                              color: statusColor,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),

                // Kategori & Kondisi Chip
                Wrap(
                  spacing: 6,
                  children: [
                    Chip(
                      label: Text(item.category, style: const TextStyle(fontSize: 11)),
                      backgroundColor: AppColors.primarySwatch.shade50,
                      padding: EdgeInsets.zero,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    Chip(
                      label: Text(item.condition, style: const TextStyle(fontSize: 11)),
                      backgroundColor: Colors.grey.shade100,
                      padding: EdgeInsets.zero,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ],
                ),
                const SizedBox(height: 6),

                // Deskripsi
                Text(
                  item.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondaryLight),
                ),
                const SizedBox(height: AppSizes.sm),

                const Divider(height: 1),
                const SizedBox(height: 8),

                // Footer: Tanggal & Aksi Hapus
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 13, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          item.createdAt != null
                              ? item.createdAt!.toIndonesianDate
                              : 'Hari ini',
                          style: const TextStyle(fontSize: 11, color: Colors.grey),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, size: 20, color: AppColors.error),
                      tooltip: 'Hapus Barang',
                      onPressed: () => _confirmDelete(context, ref, item),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Tampilkan gambar dari file lokal (draft) atau jaringan (online Supabase)
  Widget _buildItemImage(ItemModel item) {
    if (item.localPhotoPath != null && item.localPhotoPath!.isNotEmpty) {
      final file = File(item.localPhotoPath!);
      if (file.existsSync()) {
        return Image.file(
          file,
          height: 180,
          width: double.infinity,
          fit: BoxFit.cover,
        );
      }
    }

    if (item.photoUrls.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: item.photoUrls.first,
        height: 180,
        width: double.infinity,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          height: 180,
          color: Colors.grey.shade200,
          child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
        ),
        errorWidget: (context, url, error) => Container(
          height: 180,
          color: Colors.grey.shade200,
          child: const Center(
            child: Icon(Icons.broken_image, size: 48, color: Colors.grey),
          ),
        ),
      );
    }

    return Container(
      height: 140,
      color: AppColors.primarySwatch.shade50,
      child: const Center(
        child: Icon(Icons.inventory_2_outlined, size: 48, color: AppColors.primary),
      ),
    );
  }

  /// Konfirmasi hapus barang
  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    ItemModel item,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Barang'),
        content: Text('Apakah Anda yakin ingin menghapus "${item.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await ref
          .read(myItemsNotifierProvider.notifier)
          .deleteItem(item.id, isDraft: item.isDraft);
    }
  }
}
