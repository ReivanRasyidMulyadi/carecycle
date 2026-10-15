import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/models/campaign_model.dart';
import '../providers/campaign_provider.dart';

/// Layar Open Campaign (Daftar Kampanye Sosial Donasi Bersama)
class CampaignScreen extends ConsumerStatefulWidget {
  const CampaignScreen({super.key});

  @override
  ConsumerState<CampaignScreen> createState() => _CampaignScreenState();
}

class _CampaignScreenState extends ConsumerState<CampaignScreen> {
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(campaignNotifierProvider);
    final authState = ref.watch(authNotifierProvider);
    final user = authState.user;
    final community = authState.community;
    final isYayasanVerified = user?.isKomunitas == true && community?.isVerified == true;

    ref.listen<CampaignState>(campaignNotifierProvider, (prev, next) {
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
      title: 'Open Campaign',
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          tooltip: 'Segarkan',
          onPressed: () {
            ref.read(campaignNotifierProvider.notifier).loadCampaigns();
          },
        ),
      ],
      floatingActionButton: isYayasanVerified
          ? FloatingActionButton.extended(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add),
              label: const Text('Buat Kampanye'),
              onPressed: () => _showCreateCampaignDialog(community!.id),
            )
          : null,
      body: Column(
        children: [
          // Filter Tabs (Semua, Aktif, Selesai)
          _buildFilterTabs(state.statusFilter),
          const Divider(height: 1),

          // Campaign Cards
          Expanded(
            child: state.isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: () async {
                      await ref.read(campaignNotifierProvider.notifier).loadCampaigns();
                    },
                    child: state.campaigns.isEmpty
                        ? _buildEmptyState(isYayasanVerified)
                        : ListView.separated(
                            padding: const EdgeInsets.all(AppSizes.md),
                            itemCount: state.campaigns.length,
                            separatorBuilder: (context, index) =>
                                const SizedBox(height: AppSizes.md),
                            itemBuilder: (context, index) {
                              final camp = state.campaigns[index];
                              return _buildCampaignCard(camp, user);
                            },
                          ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTabs(String currentFilter) {
    final filters = [
      {'key': 'all', 'label': 'Semua'},
      {'key': 'active', 'label': 'Sedang Berjalan'},
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
                      .read(campaignNotifierProvider.notifier)
                      .setStatusFilter(f['key']!);
                }
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildEmptyState(bool isYayasan) {
    return ListView(
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.2),
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.campaign_outlined, size: 64, color: Colors.grey.shade400),
              const SizedBox(height: AppSizes.md),
              const Text(
                'Belum Ada Kampanye',
                style: TextStyle(
                  fontSize: AppSizes.fontMd,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                isYayasan
                    ? 'Tekan tombol "Buat Kampanye" untuk menginisiasi program donasi.'
                    : 'Program kampanye sosial dari yayasan terverifikasi akan muncul di sini.',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCampaignCard(CampaignModel camp, dynamic user) {
    final progress = camp.progressPercentage;
    final isOwner = user?.id == camp.communityId;
    final isAdmin = user?.isAdmin == true;
    final isDonatur = user?.isDonatur == true;

    Color badgeColor;
    if (camp.isCompleted) {
      badgeColor = AppColors.success;
    } else if (camp.isCancelled) {
      badgeColor = AppColors.error;
    } else {
      badgeColor = AppColors.primary;
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
            // Header: Judul & Status Badge
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        camp.title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(Icons.apartment, size: 14, color: AppColors.primary),
                          const SizedBox(width: 4),
                          Text(
                            camp.communityName ?? 'Yayasan / Komunitas',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: badgeColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: badgeColor),
                  ),
                  child: Text(
                    camp.statusDisplay,
                    style: TextStyle(
                      color: badgeColor,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Deskripsi
            Text(
              camp.description,
              style: const TextStyle(fontSize: 12, color: Colors.black87),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),

            // Kategori Target & Batas Waktu
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'Kategori: ${camp.categoryDisplay}',
                    style: const TextStyle(fontSize: 11, color: Colors.black87),
                  ),
                ),
                const Spacer(),
                if (camp.endDate != null)
                  Text(
                    'Target: ${camp.endDate!.toIndonesianDate}',
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  ),
              ],
            ),
            const SizedBox(height: 10),

            // Progress Bar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Terkumpul: ${camp.collectedQuantity} dari ${camp.targetQuantity} barang',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                ),
                Text(
                  '${(progress * 100).toInt()}%',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: progress >= 1.0 ? AppColors.success : AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.grey.shade200,
                color: progress >= 1.0 ? AppColors.success : AppColors.primary,
                minHeight: 6,
              ),
            ),
            const Divider(height: 20),

            // Tombol Aksi sesuai peran
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (isAdmin || isOwner) ...[
                  if (camp.isActive)
                    TextButton(
                      style: TextButton.styleFrom(foregroundColor: AppColors.error),
                      onPressed: () => _confirmCloseCampaign(camp.id),
                      child: const Text('Tutup Kampanye', style: TextStyle(fontSize: 12)),
                    ),
                ],
                if (isDonatur && camp.isActive) ...[
                  ElevatedButton.icon(
                    icon: const Icon(Icons.volunteer_activism, size: 16),
                    label: const Text('Dukung Donasi', style: TextStyle(fontSize: 12)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                    ),
                    onPressed: () => _showPledgeDialog(camp.id, user.id, camp.title),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showPledgeDialog(String campaignId, String donorId, String campaignTitle) {
    final qtyController = TextEditingController(text: '1');
    final notesController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text('Dukung "$campaignTitle"'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Berapa banyak barang yang ingin Anda komitmenkan untuk disalurkan ke program ini?',
                  style: TextStyle(fontSize: 13),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: qtyController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Jumlah Barang *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) return 'Wajib diisi';
                    final n = int.tryParse(val.trim());
                    if (n == null || n <= 0) return 'Masukkan angka lebih dari 0';
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: notesController,
                  decoration: const InputDecoration(
                    labelText: 'Catatan (Opsional)',
                    hintText: 'Contoh: 3 pasang sepatu anak & seragam',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  final qty = int.parse(qtyController.text.trim());
                  Navigator.pop(ctx);
                  await ref.read(campaignNotifierProvider.notifier).pledgeCampaign(
                        campaignId: campaignId,
                        donorId: donorId,
                        quantity: qty,
                        notes: notesController.text.trim(),
                      );
                }
              },
              child: const Text('Kirim Dukungan', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _showCreateCampaignDialog(String communityId) {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    final qtyController = TextEditingController(text: '20');
    String selectedCategory = 'clothing';
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Buat Kampanye Sosial'),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        controller: titleController,
                        decoration: const InputDecoration(
                          labelText: 'Judul Kampanye *',
                          hintText: 'Contoh: 100 Baju Layak untuk Anak Panti',
                          border: OutlineInputBorder(),
                        ),
                        validator: (val) => val == null || val.trim().isEmpty
                            ? 'Judul kampanye wajib diisi'
                            : null,
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: descController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'Deskripsi Program *',
                          hintText: 'Jelaskan tujuan dan siapa target penerima manfaatnya...',
                          border: OutlineInputBorder(),
                        ),
                        validator: (val) => val == null || val.trim().isEmpty
                            ? 'Deskripsi wajib diisi'
                            : null,
                      ),
                      const SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        value: selectedCategory,
                        decoration: const InputDecoration(
                          labelText: 'Kategori Barang *',
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'clothing', child: Text('Pakaian')),
                          DropdownMenuItem(value: 'electronics', child: Text('Elektronik')),
                          DropdownMenuItem(value: 'books', child: Text('Buku & Edukasi')),
                          DropdownMenuItem(value: 'furniture', child: Text('Perabotan')),
                          DropdownMenuItem(value: 'toys', child: Text('Mainan Anak')),
                        ],
                        onChanged: (val) {
                          if (val != null) {
                            setDialogState(() => selectedCategory = val);
                          }
                        },
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: qtyController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Target Jumlah Barang *',
                          border: OutlineInputBorder(),
                        ),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) return 'Wajib diisi';
                          final n = int.tryParse(val.trim());
                          if (n == null || n <= 0) return 'Masukkan angka > 0';
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Batal'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      final title = titleController.text.trim();
                      final desc = descController.text.trim();
                      final qty = int.parse(qtyController.text.trim());
                      Navigator.pop(ctx);

                      await ref.read(campaignNotifierProvider.notifier).createCampaign(
                            communityId: communityId,
                            title: title,
                            description: desc,
                            targetCategory: selectedCategory,
                            targetQuantity: qty,
                            endDate: DateTime.now().add(const Duration(days: 30)),
                          );
                    }
                  },
                  child: const Text('Terbitkan', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _confirmCloseCampaign(String campaignId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Tutup Kampanye?'),
        content: const Text('Kampanye akan ditandai sebagai selesai dan tidak dapat menerima dukungan lagi.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () async {
              Navigator.pop(ctx);
              await ref
                  .read(campaignNotifierProvider.notifier)
                  .updateStatus(campaignId, 'completed');
            },
            child: const Text('Ya, Selesaikan', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
