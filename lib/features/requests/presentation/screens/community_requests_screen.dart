import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/router/app_router.dart';
import '../../data/models/request_model.dart';
import '../providers/request_provider.dart';

/// Halaman untuk Komunitas/Yayasan melihat dan melacak semua permintaan barang
/// yang telah mereka ajukan ke platform.
class CommunityRequestsScreen extends ConsumerStatefulWidget {
  const CommunityRequestsScreen({super.key});

  @override
  ConsumerState<CommunityRequestsScreen> createState() =>
      _CommunityRequestsScreenState();
}

class _CommunityRequestsScreenState
    extends ConsumerState<CommunityRequestsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _tabs = [
    'Semua',
    'Menunggu',
    'Disetujui',
    'Diterima',
    'Ditolak'
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<RequestModel> _filterRequests(
      List<RequestModel> list, int tabIndex) {
    switch (tabIndex) {
      case 1:
        return list.where((r) => r.isSubmitted).toList();
      case 2:
        return list.where((r) => r.isApproved).toList();
      case 3:
        return list.where((r) => r.isReceived).toList();
      case 4:
        return list.where((r) => r.isRejected).toList();
      default:
        return list;
    }
  }

  @override
  Widget build(BuildContext context) {
    final requestsAsync = ref.watch(communityRequestsNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Permintaan Donasi Saya',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          tabs: _tabs.map((tab) => Tab(text: tab)).toList(),
          onTap: (_) => setState(() {}),
        ),
      ),
      body: requestsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: AppColors.error),
                const SizedBox(height: 12),
                Text(
                  'Gagal memuat permintaan:\n$error',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.error),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => ref
                      .read(communityRequestsNotifierProvider.notifier)
                      .loadRequests(),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Coba Lagi'),
                ),
              ],
            ),
          ),
        ),
        data: (allRequests) {
          final filtered = _filterRequests(allRequests, _tabController.index);

          if (filtered.isEmpty) {
            return RefreshIndicator(
              onRefresh: () => ref
                  .read(communityRequestsNotifierProvider.notifier)
                  .loadRequests(),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.6,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.inbox_outlined,
                            size: 64,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _tabController.index == 0
                                ? 'Belum ada permohonan donasi'
                                : 'Tidak ada permohonan dengan status ini',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Jelajahi katalog donasi untuk mengajukan barang.',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade500,
                            ),
                          ),
                          const SizedBox(height: 18),
                          ElevatedButton.icon(
                            onPressed: () =>
                                context.pushNamed(AppRouter.catalog),
                            icon: const Icon(Icons.search),
                            label: const Text('Buka Katalog Donasi'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => ref
                .read(communityRequestsNotifierProvider.notifier)
                .loadRequests(),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: filtered.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final req = filtered[index];
                return _buildRequestCard(context, req);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildRequestCard(BuildContext context, RequestModel req) {
    Color statusColor;
    IconData statusIcon;
    switch (req.status) {
      case 'approved':
        statusColor = AppColors.info;
        statusIcon = Icons.local_shipping_outlined;
        break;
      case 'received':
        statusColor = AppColors.success;
        statusIcon = Icons.check_circle_outline;
        break;
      case 'rejected':
        statusColor = AppColors.error;
        statusIcon = Icons.cancel_outlined;
        break;
      case 'submitted':
      default:
        statusColor = AppColors.warning;
        statusIcon = Icons.hourglass_top_outlined;
        break;
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Chip & Tanggal
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: statusColor.withOpacity(0.4)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(statusIcon, size: 14, color: statusColor),
                      const SizedBox(width: 5),
                      Text(
                        req.statusDisplay,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                        ),
                      ),
                    ],
                  ),
                ),
                if (req.createdAt != null)
                  Text(
                    '${req.createdAt!.day}/${req.createdAt!.month}/${req.createdAt!.year}',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                  ),
              ],
            ),
            const SizedBox(height: 12),

            // Info Barang
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: req.itemPhotoUrl != null &&
                          req.itemPhotoUrl!.isNotEmpty
                      ? Image.network(
                          req.itemPhotoUrl!,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _buildFallbackPhoto(),
                        )
                      : _buildFallbackPhoto(),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        req.itemName ?? 'Barang Donasi',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (req.itemCategory != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          'Kategori: ${req.itemCategory}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Alasan Permohonan
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Alasan Kebutuhan:',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    req.reason,
                    style: const TextStyle(fontSize: 13),
                  ),
                ],
              ),
            ),

            // Informasi Pengiriman / Resi jika sudah di-approve
            if (req.isApproved || req.isReceived) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.local_shipping,
                          size: 16,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Metode: ${req.deliveryMethodDisplay}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryDark,
                          ),
                        ),
                      ],
                    ),
                    if (req.trackingNumber != null &&
                        req.trackingNumber!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Nomor Resi / Info: ${req.trackingNumber}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                    if (req.notes != null && req.notes!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Catatan: ${req.notes}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],

            // Action Button: Konfirmasi Barang Diterima
            if (req.isApproved) ...[
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _confirmReceiveDialog(context, req),
                  icon: const Icon(Icons.check_circle, size: 18),
                  label: const Text('Konfirmasi Barang Diterima'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.success,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFallbackPhoto() {
    return Container(
      width: 60,
      height: 60,
      color: Colors.grey.shade200,
      child: const Icon(Icons.inventory_2_outlined, color: Colors.grey),
    );
  }

  void _confirmReceiveDialog(BuildContext context, RequestModel req) {
    showDialog(
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          title: const Text('Konfirmasi Terima Barang'),
          content: Text(
            'Apakah barang "${req.itemName ?? "donasi"}" sudah benar-benar diterima oleh yayasan Anda?\n\n'
            'Tindakan ini akan menyelesaikan alur donasi barang ini.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: const Text('Belum'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                Navigator.pop(dialogCtx);
                final messenger = ScaffoldMessenger.of(context);
                final success = await ref
                    .read(communityRequestsNotifierProvider.notifier)
                    .confirmReceived(req.id, req.itemId);

                messenger.showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? 'Status donasi berhasil diselesaikan!'
                          : 'Gagal menyelesaikan donasi. Coba lagi.',
                    ),
                    backgroundColor:
                        success ? AppColors.success : AppColors.error,
                  ),
                );
              },
              child: const Text('Ya, Sudah Diterima'),
            ),
          ],
        );
      },
    );
  }
}
