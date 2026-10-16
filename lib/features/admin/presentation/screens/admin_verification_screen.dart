import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/widgets/carecycle_bottom_nav.dart';
import '../../../auth/data/models/community_model.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/presentation/providers/community_provider.dart';

/// Layar Panel Admin untuk meninjau dan menyetujui / menolak verifikasi legalitas komunitas
class AdminVerificationScreen extends ConsumerStatefulWidget {
  const AdminVerificationScreen({super.key});

  @override
  ConsumerState<AdminVerificationScreen> createState() =>
      _AdminVerificationScreenState();
}

class _AdminVerificationScreenState
    extends ConsumerState<AdminVerificationScreen> {
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(adminVerificationNotifierProvider);
    final authState = ref.watch(authNotifierProvider);
    final adminUser = authState.user;

    // Tampilkan snackbar jika ada pesan sukses atau error
    ref.listen<AdminVerificationState>(adminVerificationNotifierProvider, (prev, next) {
      if (next.actionSuccessMessage != null &&
          next.actionSuccessMessage != prev?.actionSuccessMessage) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.actionSuccessMessage!),
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
      title: 'Panel Verifikasi Komunitas',
      bottomNavigationBar: const CareCycleBottomNav(currentIndex: 1),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          tooltip: 'Segarkan',
          onPressed: () {
            ref.read(adminVerificationNotifierProvider.notifier).loadCommunities();
          },
        ),
      ],
      body: Column(
        children: [
          // Filter Status Chips
          _buildFilterTabs(state.currentFilter),
          const Divider(height: 1),

          // Konten Antrean
          Expanded(
            child: state.isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: () async {
                      await ref
                          .read(adminVerificationNotifierProvider.notifier)
                          .loadCommunities();
                    },
                    child: state.communities.isEmpty
                        ? _buildEmptyState(state.currentFilter)
                        : ListView.separated(
                            padding: const EdgeInsets.all(AppSizes.md),
                            itemCount: state.communities.length,
                            separatorBuilder: (context, index) =>
                                const SizedBox(height: AppSizes.md),
                            itemBuilder: (context, index) {
                              final item = state.communities[index];
                              return _buildCommunityCard(item, adminUser?.id ?? '');
                            },
                          ),
                  ),
          ),
        ],
      ),
    );
  }

  /// Filter tabs/chips horizontal
  Widget _buildFilterTabs(String currentFilter) {
    final filters = [
      {'key': 'pending', 'label': 'Menunggu'},
      {'key': 'verified', 'label': 'Terverifikasi'},
      {'key': 'rejected', 'label': 'Ditolak'},
      {'key': 'all', 'label': 'Semua'},
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
                      .read(adminVerificationNotifierProvider.notifier)
                      .changeFilter(f['key']!);
                }
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  /// Tampilan jika antrean kosong
  Widget _buildEmptyState(String filter) {
    return ListView(
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.15),
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.task_alt_outlined,
                size: 64,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: AppSizes.md),
              Text(
                'Tidak ada komunitas pada status ini',
                style: TextStyle(
                  fontSize: AppSizes.fontMd,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Tarik layar ke bawah untuk memuat ulang data.',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Kartu rincian verifikasi komunitas
  Widget _buildCommunityCard(CommunityModel item, String adminId) {
    Color statusColor;
    switch (item.verificationStatus) {
      case 'verified':
        statusColor = AppColors.success;
        break;
      case 'rejected':
        statusColor = AppColors.error;
        break;
      default:
        statusColor = AppColors.warning;
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
            // Header: Nama Komunitas & Badge Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    item.communityName,
                    style: const TextStyle(
                      fontSize: AppSizes.fontMd,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                    border: Border.all(color: statusColor),
                  ),
                  child: Text(
                    item.verificationStatusDisplay,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),

            // Deskripsi / Visi Misi
            if (item.description != null && item.description!.isNotEmpty) ...[
              Text(
                item.description!,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondaryLight,
                ),
              ),
              const SizedBox(height: AppSizes.sm),
            ],

            // Alasan Penolakan (Jika ada)
            if (item.isRejected && item.rejectionReason != null) ...[
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.info, color: AppColors.error, size: 16),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Alasan Penolakan: ${item.rejectionReason}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.error,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSizes.sm),
            ],

            const Divider(),

            // Berkas Dokumen & Aksi
            Row(
              children: [
                // Tombol Buka Berkas Legalitas
                if (item.legalDocumentUrl != null &&
                    item.legalDocumentUrl!.isNotEmpty) ...[
                  OutlinedButton.icon(
                    icon: const Icon(Icons.file_open_outlined, size: 16),
                    label: const Text(
                      'Lihat Dokumen',
                      style: TextStyle(fontSize: 12),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                    ),
                    onPressed: () => _openUrl(item.legalDocumentUrl!),
                  ),
                ] else ...[
                  const Text(
                    'Belum ada dokumen',
                    style: TextStyle(
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                      color: Colors.grey,
                    ),
                  ),
                ],

                const Spacer(),

                // Tombol Setujui & Tolak
                if (item.isPending) ...[
                  TextButton.icon(
                    icon: const Icon(Icons.close, color: AppColors.error, size: 16),
                    label: const Text(
                      'Tolak',
                      style: TextStyle(color: AppColors.error, fontSize: 12),
                    ),
                    onPressed: () => _showRejectDialog(item.id, item.communityName),
                  ),
                  const SizedBox(width: 4),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.check, size: 16),
                    label: const Text('Setujui', style: TextStyle(fontSize: 12)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                    ),
                    onPressed: () => _confirmApproval(item.id, item.communityName, adminId),
                  ),
                ] else if (item.isRejected) ...[
                  ElevatedButton.icon(
                    icon: const Icon(Icons.check, size: 16),
                    label: const Text('Tinjau Ulang & Setujui', style: TextStyle(fontSize: 11)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                    onPressed: () => _confirmApproval(item.id, item.communityName, adminId),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Dialog konfirmasi persetujuan komunitas
  Future<void> _confirmApproval(String communityId, String communityName, String adminId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Konfirmasi Persetujuan'),
        content: Text('Apakah Anda yakin ingin menyetujui komunitas "$communityName"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Ya, Setujui', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await ref
          .read(adminVerificationNotifierProvider.notifier)
          .approveCommunity(communityId: communityId, adminId: adminId);
    }
  }

  /// Dialog input alasan penolakan verifikasi
  Future<void> _showRejectDialog(String communityId, String communityName) async {
    final controller = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Tolak Komunitas "$communityName"'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Masukkan alasan penolakan agar komunitas dapat memperbaikinya:',
                style: TextStyle(fontSize: 13),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: controller,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Alasan Penolakan *',
                  hintText: 'Contoh: Berkas tidak terbaca jelas atau akta tidak sah.',
                  border: OutlineInputBorder(),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Alasan penolakan wajib diisi';
                  }
                  return null;
                },
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
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.pop(ctx, true);
              }
            },
            child: const Text('Tolak', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await ref
          .read(adminVerificationNotifierProvider.notifier)
          .rejectCommunity(
            communityId: communityId,
            rejectionReason: controller.text.trim(),
          );
    }
  }

  /// Buka dokumen di web browser
  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tidak dapat membuka URL dokumen.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}
