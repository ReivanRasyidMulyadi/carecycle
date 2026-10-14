import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../requests/presentation/providers/request_provider.dart';
import '../../data/models/item_model.dart';
import '../providers/item_provider.dart';

/// Layar Rincian Barang Donasi (dengan Supabase Realtime & Form Pengajuan Komunitas)
class ItemDetailScreen extends ConsumerStatefulWidget {
  final String itemId;

  const ItemDetailScreen({super.key, required this.itemId});

  @override
  ConsumerState<ItemDetailScreen> createState() => _ItemDetailScreenState();
}

class _ItemDetailScreenState extends ConsumerState<ItemDetailScreen> {
  ItemModel? _item;
  bool _isLoading = true;
  bool _isSubmittingRequest = false;

  @override
  void initState() {
    super.initState();
    _loadInitialItem();
  }

  Future<void> _loadInitialItem() async {
    final repo = ref.read(itemRepositoryProvider);
    final data = await repo.getItemById(widget.itemId);
    if (mounted) {
      setState(() {
        _item = data;
        _isLoading = false;
      });
    }
  }

  /// Menampilkan dialog form pengajuan permohonan donasi
  Future<void> _showRequestBottomSheet() async {
    final authState = ref.read(authNotifierProvider);
    final community = authState.community;
    if (community == null) return;

    final reasonController = TextEditingController();
    final notesController = TextEditingController();
    String selectedDelivery = 'courier';
    final formKey = GlobalKey<FormState>();

    final submit = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSizes.radiusLg)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: AppSizes.md,
                right: AppSizes.md,
                top: AppSizes.md,
                bottom: MediaQuery.of(context).viewInsets.bottom + AppSizes.md,
              ),
              child: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Ajukan Permintaan Donasi',
                            style: TextStyle(
                              fontSize: AppSizes.fontMd,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.pop(ctx, false),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Untuk barang: "${_item?.name ?? ""}"',
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      const Divider(),
                      const SizedBox(height: 8),

                      TextFormField(
                        controller: reasonController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'Alasan & Rencana Pemanfaatan *',
                          hintText: 'Jelaskan mengapa komunitas Anda membutuhkan barang ini dan siapa penerima manfaatnya',
                          border: OutlineInputBorder(),
                        ),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return 'Alasan permintaan wajib diisi';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppSizes.md),

                      const Text(
                        'Preferensi Serah Terima:',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      const SizedBox(height: 4),
                      RadioListTile<String>(
                        title: const Text('Kurir / Ekspedisi', style: TextStyle(fontSize: 13)),
                        value: 'courier',
                        groupValue: selectedDelivery,
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                        onChanged: (val) {
                          if (val != null) setModalState(() => selectedDelivery = val);
                        },
                      ),
                      RadioListTile<String>(
                        title: const Text('Antar Langsung ke Lokasi Komunitas', style: TextStyle(fontSize: 13)),
                        value: 'self_deliver',
                        groupValue: selectedDelivery,
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                        onChanged: (val) {
                          if (val != null) setModalState(() => selectedDelivery = val);
                        },
                      ),
                      RadioListTile<String>(
                        title: const Text('Dijemput oleh Komunitas', style: TextStyle(fontSize: 13)),
                        value: 'pickup',
                        groupValue: selectedDelivery,
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                        onChanged: (val) {
                          if (val != null) setModalState(() => selectedDelivery = val);
                        },
                      ),
                      const SizedBox(height: AppSizes.sm),

                      TextFormField(
                        controller: notesController,
                        decoration: const InputDecoration(
                          labelText: 'Catatan Koordinasi Kontak / Lokasi (Opsional)',
                          hintText: 'Contoh: Alamat sekretariat atau jam buka posko',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: AppSizes.lg),

                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: () {
                          if (formKey.currentState!.validate()) {
                            Navigator.pop(ctx, true);
                          }
                        },
                        child: const Text('Kirim Permintaan', style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );

    if (submit == true) {
      setState(() => _isSubmittingRequest = true);
      try {
        final reqRepo = ref.read(requestRepositoryProvider);
        await reqRepo.createRequest(
          itemId: widget.itemId,
          communityId: community.id,
          reason: reasonController.text.trim(),
          deliveryMethod: selectedDelivery,
          notes: notesController.text.trim().isNotEmpty
              ? notesController.text.trim()
              : null,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Permintaan berhasil dikirim ke Donatur!'),
              backgroundColor: AppColors.success,
            ),
          );
          _loadInitialItem();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal mengirim permintaan: ${e.toString()}'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      } finally {
        if (mounted) setState(() => _isSubmittingRequest = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final user = authState.user;
    final community = authState.community;

    return AppScaffold(
      title: 'Rincian Barang',
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _item == null
              ? const Center(child: Text('Barang tidak ditemukan.'))
              : StreamBuilder<ItemModel?>(
                  stream: ref.read(itemRepositoryProvider).streamItem(widget.itemId),
                  initialData: _item,
                  builder: (context, snapshot) {
                    final currentItem = snapshot.data ?? _item!;
                    final isOwner = user != null && user.id == currentItem.donorId;
                    final isKomunitas = user?.isKomunitas == true;
                    final isVerifiedCommunity = community?.isVerified == true;

                    return Column(
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Foto Utama Barang
                                _buildImageHeader(currentItem),

                                Padding(
                                  padding: const EdgeInsets.all(AppSizes.md),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Realtime Status Banner
                                      _buildStatusBanner(currentItem),
                                      const SizedBox(height: AppSizes.md),

                                      // Judul Barang
                                      Text(
                                        currentItem.name,
                                        style: const TextStyle(
                                          fontSize: AppSizes.fontXl,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: AppSizes.xs),

                                      // Chips Kategori & Kondisi
                                      Wrap(
                                        spacing: 8,
                                        children: [
                                          Chip(
                                            label: Text(currentItem.category),
                                            backgroundColor: AppColors.primarySwatch.shade50,
                                            labelStyle: const TextStyle(
                                              color: AppColors.primary,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                            ),
                                          ),
                                          Chip(
                                            label: Text(currentItem.condition),
                                            backgroundColor: Colors.grey.shade100,
                                            labelStyle: const TextStyle(fontSize: 12),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: AppSizes.md),

                                      // Lokasi & Tanggal
                                      Row(
                                        children: [
                                          const Icon(Icons.location_on, size: 16, color: Colors.grey),
                                          const SizedBox(width: 4),
                                          Text(
                                            currentItem.location,
                                            style: const TextStyle(color: Colors.grey, fontSize: 13),
                                          ),
                                          const Spacer(),
                                          if (currentItem.createdAt != null) ...[
                                            const Icon(Icons.access_time, size: 14, color: Colors.grey),
                                            const SizedBox(width: 4),
                                            Text(
                                              currentItem.createdAt!.toIndonesianDate,
                                              style: const TextStyle(color: Colors.grey, fontSize: 12),
                                            ),
                                          ],
                                        ],
                                      ),
                                      const Divider(height: 24),

                                      // Deskripsi
                                      const Text(
                                        'Deskripsi Barang',
                                        style: TextStyle(
                                          fontSize: AppSizes.fontMd,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        currentItem.description,
                                        style: const TextStyle(fontSize: 14, height: 1.5),
                                      ),
                                      const SizedBox(height: AppSizes.lg),

                                      // Peringatan jika Komunitas Belum Verified
                                      if (isKomunitas && !isVerifiedCommunity) ...[
                                        Container(
                                          padding: const EdgeInsets.all(AppSizes.md),
                                          decoration: BoxDecoration(
                                            color: Colors.amber.shade50,
                                            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                                            border: Border.all(color: Colors.amber.shade400),
                                          ),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  const Icon(Icons.lock_outline, color: Colors.amber),
                                                  const SizedBox(width: 8),
                                                  Text(
                                                    'Akses Pengajuan Dibatasi',
                                                    style: TextStyle(
                                                      fontWeight: FontWeight.bold,
                                                      color: Colors.amber.shade900,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 4),
                                              const Text(
                                                'Komunitas Anda belum terverifikasi. Harap unggah dokumen legalitas terlebih dahulu untuk mengajukan donasi barang.',
                                                style: TextStyle(fontSize: 12),
                                              ),
                                              const SizedBox(height: 8),
                                              OutlinedButton.icon(
                                                icon: const Icon(Icons.arrow_forward, size: 14),
                                                label: const Text('Buka Status Legalitas'),
                                                onPressed: () {
                                                  context.pushNamed(AppRouter.communityVerification);
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Bottom Action Bar
                        Container(
                          padding: const EdgeInsets.all(AppSizes.md),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 8,
                                offset: const Offset(0, -2),
                              ),
                            ],
                          ),
                          child: SafeArea(
                            child: isOwner
                                ? AppButton(
                                    label: 'Lihat Permintaan Masuk',
                                    icon: Icons.inbox,
                                    onPressed: () {
                                      context.pushNamed(AppRouter.donorRequests);
                                    },
                                  )
                                : isKomunitas
                                    ? AppButton(
                                        label: currentItem.isInProcess
                                            ? 'Barang Sedang Diproses'
                                            : 'Ajukan Permintaan Donasi',
                                        icon: Icons.volunteer_activism,
                                        isLoading: _isSubmittingRequest,
                                        onPressed: (isVerifiedCommunity && !currentItem.isInProcess)
                                            ? _showRequestBottomSheet
                                            : null,
                                      )
                                    : const SizedBox.shrink(),
                          ),
                        ),
                      ],
                    );
                  },
                ),
    );
  }

  /// Banner indikator status realtime barang
  Widget _buildStatusBanner(ItemModel item) {
    Color bg;
    Color border;
    IconData icon;
    Color color;
    String text;

    if (item.isInProcess) {
      bg = Colors.blue.shade50;
      border = Colors.blue.shade300;
      icon = Icons.sync;
      color = Colors.blue.shade800;
      text = 'Barang telah disetujui dan sedang dalam proses serah terima (In-Process).';
    } else if (item.isRequested) {
      bg = Colors.orange.shade50;
      border = Colors.orange.shade300;
      icon = Icons.hourglass_top;
      color = Colors.orange.shade800;
      text = 'Barang memiliki permohonan masuk yang sedang ditinjau Donatur.';
    } else {
      bg = AppColors.primarySwatch.shade50;
      border = AppColors.primary.withOpacity(0.3);
      icon = Icons.check_circle_outline;
      color = AppColors.primary;
      text = 'Barang tersedia dan dapat diajukan oleh Komunitas terverifikasi.';
    }

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppSizes.radiusSm),
        border: Border.all(color: border),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  /// Header foto barang
  Widget _buildImageHeader(ItemModel item) {
    if (item.photoUrls.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: item.photoUrls.first,
        height: 260,
        width: double.infinity,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          height: 260,
          color: Colors.grey.shade200,
          child: const Center(child: CircularProgressIndicator()),
        ),
        errorWidget: (context, url, error) => Container(
          height: 260,
          color: Colors.grey.shade200,
          child: const Icon(Icons.broken_image, size: 64, color: Colors.grey),
        ),
      );
    }

    return Container(
      height: 200,
      color: AppColors.primarySwatch.shade50,
      child: const Center(
        child: Icon(Icons.inventory_2_outlined, size: 72, color: AppColors.primary),
      ),
    );
  }
}
