import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../providers/auth_provider.dart';

/// Halaman Beranda (Home) utama setelah pengguna berhasil login
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final user = authState.user;
    final community = authState.community;

    return AppScaffold(
      title: AppStrings.appName,
      actions: [
        IconButton(
          icon: const Icon(Icons.logout),
          tooltip: AppStrings.logout,
          onPressed: () async {
            final confirm = await showDialog<bool>(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text(AppStrings.logout),
                content: const Text(AppStrings.logoutConfirm),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, false),
                    child: const Text(AppStrings.no),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(ctx, true),
                    child: const Text(AppStrings.yes),
                  ),
                ],
              ),
            );

            if (confirm == true) {
              await ref.read(authNotifierProvider.notifier).signOut();
              if (context.mounted) {
                context.goNamed(AppRouter.login);
              }
            }
          },
        ),
      ],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Sambutan
            Card(
              elevation: 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppSizes.md),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: AppColors.primarySwatch.shade100,
                      child: Text(
                        (user?.fullName.isNotEmpty == true
                                ? user!.fullName[0]
                                : 'U')
                            .toUpperCase(),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSizes.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Halo, ${user?.fullName ?? "Pengguna"} 👋',
                            style: const TextStyle(
                              fontSize: AppSizes.fontLg,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  user?.roleDisplay ?? 'Donatur',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              if (user?.isKomunitas == true &&
                                  community != null) ...[
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: community.isVerified
                                        ? AppColors.success
                                        : AppColors.warning,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    community.verificationStatusDisplay,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSizes.md),

            // Card Gamifikasi / Care Points (untuk Donatur)
            if (user?.isDonatur == true) ...[
              Card(
                color: AppColors.primaryDark,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(AppSizes.md),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            AppStrings.carePoints,
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: AppSizes.fontSm,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${user?.carePoints ?? 0} Poin',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: AppSizes.fontXxl,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.all(AppSizes.sm),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.eco,
                          color: AppColors.primaryLight,
                          size: 32,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSizes.md),
            ],

            // Banner Notifikasi Status Verifikasi (Khusus Komunitas Belum Verified)
            if (user?.isKomunitas == true &&
                community?.isVerified != true) ...[
              Container(
                padding: const EdgeInsets.all(AppSizes.md),
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                  border: Border.all(color: AppColors.warning),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, color: AppColors.warning),
                    SizedBox(width: AppSizes.sm),
                    Expanded(
                      child: Text(
                        'Komunitas Anda belum terverifikasi. Unggah dokumen legalitas untuk mulai mengajukan permintaan barang atau membuat kampanye.',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSizes.md),
            ],

            // Menu Pintas / Alur Fitur CareCycle
            const Text(
              'Aktivitas CareCycle',
              style: TextStyle(
                fontSize: AppSizes.fontMd,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSizes.sm),

            Row(
              children: [
                Expanded(
                  child: _ActivityCard(
                    icon: Icons.add_photo_alternate_outlined,
                    title: 'Unggah Donasi',
                    subtitle: 'Donasikan barang layak',
                    onTap: () {
                      context.pushNamed(AppRouter.upload);
                    },
                  ),
                ),
                const SizedBox(width: AppSizes.sm),
                Expanded(
                  child: _ActivityCard(
                    icon: Icons.inventory_2_outlined,
                    title: 'Katalog Publik',
                    subtitle: 'Eksplorasi barang donasi',
                    onTap: () {
                      context.pushNamed(AppRouter.catalog);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.sm),
            Row(
              children: [
                Expanded(
                  child: _ActivityCard(
                    icon: Icons.campaign_outlined,
                    title: 'Open Campaign',
                    subtitle: 'Program donasi bersama',
                    onTap: () {
                      context.pushNamed(AppRouter.campaign);
                    },
                  ),
                ),
                const SizedBox(width: AppSizes.sm),
                Expanded(
                  child: _ActivityCard(
                    icon: Icons.workspace_premium_outlined,
                    title: 'Dampak & Sertifikat',
                    subtitle: 'Pencapaian donasi Anda',
                    onTap: () {
                      context.pushNamed(AppRouter.profile);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ActivityCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ActivityCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: AppColors.primary, size: 28),
              const SizedBox(height: AppSizes.sm),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: AppSizes.fontSm,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondaryLight,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
