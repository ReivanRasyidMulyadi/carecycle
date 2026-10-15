import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/models/request_model.dart';
import '../providers/request_provider.dart';

/// Layar Permintaan Masuk untuk Donatur (dengan Supabase Realtime, Profil Komunitas, & Pilihan Serah Terima)
class DonorRequestsScreen extends ConsumerWidget {
  const DonorRequestsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(donorRequestsNotifierProvider);
    final user = ref.watch(authNotifierProvider).user;
    final isAdmin = user?.isAdmin == true;

    // Notifikasi Realtime Banner / Snackbar saat ada permohonan baru
    ref.listen<DonorRequestsState>(donorRequestsNotifierProvider, (prev, next) {
      if (next.newNotificationMessage != null &&
          next.newNotificationMessage != prev?.newNotificationMessage) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.notifications_active, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Expanded(child: Text(next.newNotificationMessage!)),
              ],
            ),
            backgroundColor: AppColors.primaryDark,
            duration: const Duration(seconds: 5),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      if (next.successMessage != null && next.successMessage != prev?.successMessage) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.successMessage!), backgroundColor: AppColors.success),
        );
      }
      if (next.errorMessage != null && next.errorMessage != prev?.errorMessage) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.errorMessage!), backgroundColor: AppColors.error),
        );
      }
    });

    return AppScaffold(
      title: isAdmin ? 'Persetujuan Permintaan Donasi' : 'Permintaan Donasi Masuk',
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          tooltip: 'Segarkan',
          onPressed: () {
            ref.read(donorRequestsNotifierProvider.notifier).loadIncomingRequests();
          },
        ),
      ],
      body: RefreshIndicator(
        onRefresh: () =>
            ref.read(donorRequestsNotifierProvider.notifier).loadIncomingRequests(),
        child: state.isLoading
            ? const Center(child: CircularProgressIndicator())
            : state.requests.isEmpty
                ? _buildEmptyState(context, isAdmin)
                : ListView.separated(
                    padding: const EdgeInsets.all(AppSizes.md),
                    itemCount: state.requests.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: AppSizes.md),
                    itemBuilder: (context, index) {
                      final req = state.requests[index];
                      return _buildRequestCard(context, ref, req, isAdmin);
                    },
                  ),
      ),
    );
  }

  /// Tampilan jika belum ada permohonan masuk
  Widget _buildEmptyState(BuildContext context, bool isAdmin) {
    return ListView(
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.2),
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.inbox_outlined, size: 64, color: Colors.grey.shade400),
              const SizedBox(height: AppSizes.md),
              Text(
                isAdmin
                    ? 'Belum Ada Permintaan Masuk'
                    : 'Belum Ada Permintaan Masuk',
                style: const TextStyle(
                  fontSize: AppSizes.fontLg,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                isAdmin
                    ? 'Permintaan donasi dari komunitas yang memerlukan persetujuan admin akan muncul di sini.'
                    : 'Permintaan dari komunitas terverifikasi akan muncul di sini secara realtime.',
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondaryLight),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Kartu permohonan masuk
  Widget _buildRequestCard(
    BuildContext context,
    WidgetRef ref,
    RequestModel req,
    bool isAdmin,
  ) {
    Color statusColor;
    if (req.isApproved) {
      statusColor = AppColors.success;
    } else if (req.isRejected) {
      statusColor = AppColors.error;
    } else {
      statusColor = Colors.amber.shade900;
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Baris Header: Nama Barang & Status Permintaan
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (req.itemPhotoUrl != null) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                    child: CachedNetworkImage(
                      imageUrl: req.itemPhotoUrl!,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      errorWidget: (context, url, error) => Container(
                        width: 50,
                        height: 50,
                        color: Colors.grey.shade200,
                        child: const Icon(Icons.image, size: 24),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSizes.sm),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        req.itemName ?? 'Barang Donasi',
                        style: const TextStyle(
                          fontSize: AppSizes.fontMd,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (req.createdAt != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          'Diajukan ${req.createdAt!.toIndonesianDate}',
                          style: const TextStyle(fontSize: 11, color: Colors.grey),
                        ),
                      ],
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: statusColor),
                  ),
                  child: Text(
                    req.statusDisplay,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 20),

            // Profil & Status Legalitas Komunitas Pemohon
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const CircleAvatar(
                        radius: 14,
                        backgroundColor: AppColors.primary,
                        child: Icon(Icons.apartment, size: 16, color: Colors.white),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          req.communityName ?? 'Komunitas Peduli',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.success.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.verified, size: 12, color: AppColors.success),
                            SizedBox(width: 3),
                            Text(
                              'Verified',
                              style: TextStyle(
                                fontSize: 10,
                                color: AppColors.success,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (req.communityDescription != null &&
                      req.communityDescription!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      req.communityDescription!,
                      style: const TextStyle(fontSize: 11, color: Colors.black54),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 10),

            // Alasan Permintaan
            const Text(
              'Alasan & Rencana Pemanfaatan:',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 2),
            Text(
              req.reason,
              style: const TextStyle(fontSize: 13, color: Colors.black87),
            ),
            const SizedBox(height: 8),

            // Info Metode Serah Terima (Jika sudah disetujui / ada opsi)
            if (req.deliveryMethod != null) ...[
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primarySwatch.shade50,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.local_shipping_outlined,
                            size: 16, color: AppColors.primary),
                        const SizedBox(width: 6),
                        Text(
                          'Metode Serah Terima: ${req.deliveryMethodDisplay}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    if (req.trackingNumber != null && req.trackingNumber!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        'No. Resi / Bukti: ${req.trackingNumber}',
                        style: const TextStyle(fontSize: 11),
                      ),
                    ],
                    if (req.notes != null && req.notes!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        'Catatan: ${req.notes}',
                        style: const TextStyle(fontSize: 11, color: Colors.black54),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 8),
            ],

            // Tombol Aksi (Hanya Admin yang berwenang Meng-acc / Menolak)
            if (req.isSubmitted) ...[
              const Divider(),
              if (isAdmin) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton.icon(
                      icon: const Icon(Icons.close, size: 16, color: AppColors.error),
                      label: const Text('Tolak', style: TextStyle(color: AppColors.error, fontSize: 12)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.error),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                      ),
                      onPressed: () => _confirmReject(context, ref, req),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.check, size: 16),
                      label: const Text('Acc Permintaan', style: TextStyle(fontSize: 12)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                      ),
                      onPressed: () => _showApprovalHandoverDialog(context, ref, req),
                    ),
                  ],
                ),
              ] else ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                    border: Border.all(color: Colors.amber.shade300),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.hourglass_top, size: 16, color: Colors.amber.shade800),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Menunggu persetujuan Admin CareCycle. Hanya admin yang berwenang menyetujui (meng-acc) permintaan donasi.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.amber.shade900,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ] else if (req.isApproved) ...[
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  icon: const Icon(Icons.edit_outlined, size: 16),
                  label: const Text('Ubah Detail Serah Terima', style: TextStyle(fontSize: 11)),
                  onPressed: () => _showUpdateHandoverDialog(context, ref, req),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Dialog pemilihan metode serah terima saat menyetujui permintaan
  Future<void> _showApprovalHandoverDialog(
    BuildContext context,
    WidgetRef ref,
    RequestModel req,
  ) async {
    String selectedMethod = req.deliveryMethod ?? 'courier';
    final resiController = TextEditingController(text: req.trackingNumber ?? '');
    final notesController = TextEditingController(text: req.notes ?? '');

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Acc Permintaan Donasi'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pilih metode serah terima untuk menyetujui (acc) permintaan dari komunitas "${req.communityName}":',
                      style: const TextStyle(fontSize: 13),
                    ),
                    const SizedBox(height: 12),

                    RadioListTile<String>(
                      title: const Text('Kurir / Ekspedisi (JNE, SiCepat, dll)', style: TextStyle(fontSize: 13)),
                      value: 'courier',
                      groupValue: selectedMethod,
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                      onChanged: (val) {
                        if (val != null) setDialogState(() => selectedMethod = val);
                      },
                    ),
                    RadioListTile<String>(
                      title: const Text('Antar Langsung ke Komunitas', style: TextStyle(fontSize: 13)),
                      value: 'self_deliver',
                      groupValue: selectedMethod,
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                      onChanged: (val) {
                        if (val != null) setDialogState(() => selectedMethod = val);
                      },
                    ),
                    RadioListTile<String>(
                      title: const Text('Dijemput Langsung oleh Komunitas', style: TextStyle(fontSize: 13)),
                      value: 'pickup',
                      groupValue: selectedMethod,
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                      onChanged: (val) {
                        if (val != null) setDialogState(() => selectedMethod = val);
                      },
                    ),
                    const SizedBox(height: 8),

                    if (selectedMethod == 'courier') ...[
                      TextField(
                        controller: resiController,
                        decoration: const InputDecoration(
                          labelText: 'Nomor Resi Pengiriman (Opsional)',
                          hintText: 'Masukkan resi jika sudah dikirim',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],

                    TextField(
                      controller: notesController,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: 'Catatan Koordinasi / Alamat',
                        hintText: 'Contoh: Alamat pengiriman atau nomor kontak WA',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text('Batal'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                  onPressed: () => Navigator.pop(ctx, true),
                  child: const Text('Acc & Proses', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );

    if (confirm == true) {
      await ref.read(donorRequestsNotifierProvider.notifier).approveRequest(
            requestId: req.id,
            itemId: req.itemId,
            deliveryMethod: selectedMethod,
            trackingNumber: resiController.text.trim().isNotEmpty
                ? resiController.text.trim()
                : null,
            notes: notesController.text.trim().isNotEmpty
                ? notesController.text.trim()
                : null,
          );
    }
  }

  /// Dialog ubah detail serah terima (setelah disetujui)
  Future<void> _showUpdateHandoverDialog(
    BuildContext context,
    WidgetRef ref,
    RequestModel req,
  ) async {
    String selectedMethod = req.deliveryMethod ?? 'courier';
    final resiController = TextEditingController(text: req.trackingNumber ?? '');
    final notesController = TextEditingController(text: req.notes ?? '');

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Ubah Detail Serah Terima'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    RadioListTile<String>(
                      title: const Text('Kurir / Ekspedisi', style: TextStyle(fontSize: 13)),
                      value: 'courier',
                      groupValue: selectedMethod,
                      contentPadding: EdgeInsets.zero,
                      onChanged: (val) {
                        if (val != null) setDialogState(() => selectedMethod = val);
                      },
                    ),
                    RadioListTile<String>(
                      title: const Text('Antar Langsung', style: TextStyle(fontSize: 13)),
                      value: 'self_deliver',
                      groupValue: selectedMethod,
                      contentPadding: EdgeInsets.zero,
                      onChanged: (val) {
                        if (val != null) setDialogState(() => selectedMethod = val);
                      },
                    ),
                    RadioListTile<String>(
                      title: const Text('Dijemput Komunitas', style: TextStyle(fontSize: 13)),
                      value: 'pickup',
                      groupValue: selectedMethod,
                      contentPadding: EdgeInsets.zero,
                      onChanged: (val) {
                        if (val != null) setDialogState(() => selectedMethod = val);
                      },
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: resiController,
                      decoration: const InputDecoration(
                        labelText: 'Nomor Resi / Bukti',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: notesController,
                      decoration: const InputDecoration(
                        labelText: 'Catatan Koordinasi',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text('Batal'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                  onPressed: () => Navigator.pop(ctx, true),
                  child: const Text('Simpan', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );

    if (confirm == true) {
      await ref.read(donorRequestsNotifierProvider.notifier).updateDeliveryDetails(
            requestId: req.id,
            deliveryMethod: selectedMethod,
            trackingNumber: resiController.text.trim().isNotEmpty
                ? resiController.text.trim()
                : null,
            notes: notesController.text.trim().isNotEmpty
                ? notesController.text.trim()
                : null,
          );
    }
  }

  /// Dialog konfirmasi tolak permintaan
  Future<void> _confirmReject(
    BuildContext context,
    WidgetRef ref,
    RequestModel req,
  ) async {
    final notesController = TextEditingController();

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Tolak Permintaan Donasi'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Apakah Anda yakin ingin menolak permohonan dari "${req.communityName}"?',
                style: const TextStyle(fontSize: 13),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: notesController,
                decoration: const InputDecoration(
                  labelText: 'Alasan Penolakan (Opsional)',
                  hintText: 'Barang sudah dialokasikan ke pihak lain, dll.',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Ya, Tolak', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      await ref.read(donorRequestsNotifierProvider.notifier).rejectRequest(
            requestId: req.id,
            itemId: req.itemId,
            notes: notesController.text.trim().isNotEmpty
                ? notesController.text.trim()
                : null,
          );
    }
  }
}
