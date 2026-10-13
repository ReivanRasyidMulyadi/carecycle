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
          icon: const Icon(Icons.person_outline),
          tooltip: 'Profil Saya',
          onPressed: () {
            context.pushNamed(AppRouter.profile);
          },
        ),
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
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(authNotifierProvider.notifier).refreshCurrentUser();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
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
                            Wrap(
                              spacing: 6,
                              runSpacing: 4,
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
                                    community != null)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: community.isVerified
                                          ? AppColors.success
                                          : (community.isRejected
                                              ? AppColors.error
                                              : AppColors.warning),
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

              // Banner Notifikasi Status Verifikasi Khusus Komunitas
              if (user?.isKomunitas == true) ...[
                _buildCommunityVerificationBanner(context, community),
                const SizedBox(height: AppSizes.md),
              ],

              // Banner Pintas Khusus Admin
              if (user?.isAdmin == true) ...[
                _buildAdminBanner(context),
                const SizedBox(height: AppSizes.md),
              ],

              // Menu Pintas / Aktivitas Sesuai Role
              const Text(
                'Aktivitas CareCycle',
                style: TextStyle(
                  fontSize: AppSizes.fontMd,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppSizes.sm),

              // Kartu Aktivitas Berdasarkan Peran
              if (user?.isKomunitas == true)
                _buildKomunitasActivities(context, community)
              else if (user?.isAdmin == true)
                _buildAdminActivities(context)
              else
                _buildDonaturActivities(context),
            ],
          ),
        ),
      ),
    );
  }

  /// Banner status verifikasi dinamis untuk Komunitas
  Widget _buildCommunityVerificationBanner(BuildContext context, dynamic community) {
    final hasDoc = community?.legalDocumentUrl != null &&
        community!.legalDocumentUrl!.isNotEmpty;
    final isVerified = community?.isVerified == true;
    final isRejected = community?.isRejected == true;

    Color bgColor;
    Color borderColor;
    IconData icon;
    Color iconColor;
    String title;
    String desc;
    String buttonText;

    if (!hasDoc) {
      bgColor = Colors.orange.shade50;
      borderColor = Colors.orange.shade300;
      icon = Icons.warning_amber_rounded;
      iconColor = Colors.orange.shade800;
      title = 'Dokumen Legalitas Belum Dilengkapi';
      desc =
          'Unggah dokumen legalitas organisasi Anda. Komunitas belum dapat mengajukan permintaan donasi atau kampanye.';
      buttonText = 'Lengkapi Sekarang';
    } else if (isRejected) {
      bgColor = Colors.red.shade50;
      borderColor = Colors.red.shade300;
      icon = Icons.cancel_outlined;
      iconColor = AppColors.error;
      title = 'Verifikasi Komunitas Ditolak';
      final reason = community?.rejectionReason ?? 'Dokumen tidak valid';
      desc = 'Alasan: "$reason". Silakan unggah perbaikan berkas legalitas Anda.';
      buttonText = 'Unggah Ulang';
    } else if (isVerified) {
      bgColor = AppColors.primarySwatch.shade50;
      borderColor = AppColors.primary.withOpacity(0.4);
      icon = Icons.verified_user_rounded;
      iconColor = AppColors.primary;
      title = 'Komunitas Terverifikasi Resmi';
      desc =
          'Akun komunitas aktif! Anda dapat mengajukan permintaan barang dan membuka kampanye donasi.';
      buttonText = 'Lihat Profil Legalitas';
    } else {
      // Pending
      bgColor = Colors.amber.shade50;
      borderColor = Colors.amber.shade400;
      icon = Icons.hourglass_top_rounded;
      iconColor = Colors.amber.shade900;
      title = 'Dokumen Sedang Ditinjau Admin';
      desc =
          'Dokumen legalitas komunitas Anda sedang dalam peninjauan. Fitur pengajuan & kampanye aktif setelah disetujui.';
      buttonText = 'Cek Status Dokumen';
    }

    return Container(
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: iconColor, size: 24),
              const SizedBox(width: AppSizes.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: iconColor,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      desc,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: OutlinedButton.icon(
              icon: const Icon(Icons.arrow_forward, size: 14),
              label: Text(buttonText, style: const TextStyle(fontSize: 12)),
              style: OutlinedButton.styleFrom(
                foregroundColor: iconColor,
                side: BorderSide(color: iconColor),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              onPressed: () {
                context.pushNamed(AppRouter.communityVerification);
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Banner khusus akun Admin
  Widget _buildAdminBanner(BuildContext context) {
    return Card(
      elevation: 1,
      color: AppColors.primaryDark,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.md),
        child: Row(
          children: [
            const CircleAvatar(
              backgroundColor: Colors.white24,
              child: Icon(Icons.admin_panel_settings, color: Colors.white),
            ),
            const SizedBox(width: AppSizes.md),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Panel Administrator',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: AppSizes.fontSm,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Tinjau permohonan legalitas komunitas baru',
                    style: TextStyle(color: Colors.white70, fontSize: 11),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryLight,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 12),
              ),
              onPressed: () {
                context.pushNamed(AppRouter.adminVerification);
              },
              child: const Text('Buka', style: TextStyle(fontSize: 12)),
            ),
          ],
        ),
      ),
    );
  }

  /// Dialog peringatan jika komunitas belum terverifikasi mencoba mengajukan permintaan / kampanye
  void _showUnverifiedGuardDialog(BuildContext context, dynamic community) {
    final isPending = community?.isPending == true;
    final isRejected = community?.isRejected == true;

    String title;
    String message;

    if (isRejected) {
      title = 'Verifikasi Ditolak';
      message =
          'Pengajuan verifikasi komunitas Anda ditolak: "${community?.rejectionReason ?? "Dokumen tidak valid"}".\n\nSilakan perbaiki data & unggah ulang dokumen legalitas agar dapat mengajukan permintaan barang atau membuat kampanye.';
    } else if (isPending) {
      title = 'Menunggu Verifikasi Admin';
      message =
          'Dokumen legalitas komunitas Anda saat ini sedang ditinjau oleh tim Admin CareCycle.\n\nFitur pengajuan permintaan barang dan pembuatan kampanye akan aktif segera setelah admin menyetujui akun komunitas Anda.';
    } else {
      title = 'Dokumen Legalitas Belum Lengkap';
      message =
          'Untuk menjaga transparansi dan kepercayaan donatur, komunitas diwajibkan mengunggah berkas legalitas resmi terlebih dahulu.\n\nSilakan lengkapi profil dan berkas izin organisasi Anda sekarang.';
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.gpp_maybe, color: AppColors.warning),
            const SizedBox(width: 8),
            Expanded(child: Text(title, style: const TextStyle(fontSize: 16))),
          ],
        ),
        content: Text(message, style: const TextStyle(fontSize: 13)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Nanti Saja'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () {
              Navigator.pop(ctx);
              context.pushNamed(AppRouter.communityVerification);
            },
            child: const Text('Lengkapi Dokumen', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  /// Grid aktivitas untuk peran Komunitas
  Widget _buildKomunitasActivities(BuildContext context, dynamic community) {
    final isVerified = community?.isVerified == true;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _ActivityCard(
                icon: Icons.assignment_outlined,
                title: 'Ajukan Permintaan',
                subtitle: isVerified
                    ? 'Minta barang layak pakai'
                    : 'Perlu verifikasi admin 🔒',
                badgeColor: isVerified ? null : AppColors.warning,
                onTap: () {
                  if (!isVerified) {
                    _showUnverifiedGuardDialog(context, community);
                  } else {
                    context.pushNamed(AppRouter.request);
                  }
                },
              ),
            ),
            const SizedBox(width: AppSizes.sm),
            Expanded(
              child: _ActivityCard(
                icon: Icons.campaign_outlined,
                title: 'Open Campaign',
                subtitle: isVerified
                    ? 'Program donasi bersama'
                    : 'Perlu verifikasi admin 🔒',
                badgeColor: isVerified ? null : AppColors.warning,
                onTap: () {
                  if (!isVerified) {
                    _showUnverifiedGuardDialog(context, community);
                  } else {
                    context.pushNamed(AppRouter.campaign);
                  }
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
                icon: Icons.inventory_2_outlined,
                title: 'Katalog Publik',
                subtitle: 'Eksplorasi barang donatur',
                onTap: () {
                  context.pushNamed(AppRouter.catalog);
                },
              ),
            ),
            const SizedBox(width: AppSizes.sm),
            Expanded(
              child: _ActivityCard(
                icon: Icons.verified_user_outlined,
                title: 'Profil & Legalitas',
                subtitle: community?.verificationStatusDisplay ?? 'Status Dokumen',
                onTap: () {
                  context.pushNamed(AppRouter.communityVerification);
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Grid aktivitas untuk peran Donatur
  Widget _buildDonaturActivities(BuildContext context) {
    return Column(
      children: [
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
                subtitle: 'Dukung program donasi',
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
    );
  }

  /// Grid aktivitas untuk peran Admin
  Widget _buildAdminActivities(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _ActivityCard(
                icon: Icons.admin_panel_settings_outlined,
                title: 'Verifikasi Legalitas',
                subtitle: 'Antrean komunitas baru',
                onTap: () {
                  context.pushNamed(AppRouter.adminVerification);
                },
              ),
            ),
            const SizedBox(width: AppSizes.sm),
            Expanded(
              child: _ActivityCard(
                icon: Icons.inventory_2_outlined,
                title: 'Katalog Barang',
                subtitle: 'Pantau barang donasi',
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
                title: 'Semua Kampanye',
                subtitle: 'Kelola program komunitas',
                onTap: () {
                  context.pushNamed(AppRouter.campaign);
                },
              ),
            ),
            const SizedBox(width: AppSizes.sm),
            Expanded(
              child: _ActivityCard(
                icon: Icons.person_outline,
                title: 'Profil Admin',
                subtitle: 'Pengaturan akun',
                onTap: () {
                  context.pushNamed(AppRouter.profile);
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ActivityCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color? badgeColor;
  final VoidCallback onTap;

  const _ActivityCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.badgeColor,
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
              Icon(icon, color: badgeColor ?? AppColors.primary, size: 28),
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
                style: TextStyle(
                  fontSize: 11,
                  color: badgeColor ?? AppColors.textSecondaryLight,
                  fontWeight: badgeColor != null ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
