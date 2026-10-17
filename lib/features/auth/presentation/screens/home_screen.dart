import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/utils/gamification_calculator.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/widgets/carecycle_bottom_nav.dart';
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
      titleWidget: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                'assets/images/logo.png',
                width: 32,
                height: 32,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                AppStrings.appName,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.2,
                ),
              ),
              Text(
                'Berbagi Berkelanjutan',
                style: TextStyle(
                  fontSize: 10,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white60
                      : Colors.black54,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ],
          ),
        ],
      ),
      bottomNavigationBar: const CareCycleBottomNav(currentIndex: 0),
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
              // Header Sambutan Modern
              Card(
                elevation: 0,
                color: Theme.of(context).cardColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                  side: BorderSide(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white12
                        : Colors.grey.shade200,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(AppSizes.md),
                  child: Row(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: AppColors.primarySwatch.shade50,
                          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                          border: Border.all(
                            color: AppColors.primaryLight.withOpacity(0.4),
                            width: 1.5,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            (user?.fullName.isNotEmpty == true
                                    ? user!.fullName[0]
                                    : 'U')
                                .toUpperCase(),
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
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
                                fontSize: AppSizes.fontMd,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              user?.isDonatur == true
                                  ? 'Siap menyelamatkan barang hari ini?'
                                  : (user?.isKomunitas == true
                                      ? 'Kelola permohonan donasi sosial'
                                      : 'Pusat kendali & moderasi platform'),
                              style: TextStyle(
                                fontSize: 11.5,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 6),
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
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    user?.roleDisplay ?? 'Donatur',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w700,
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
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      community.verificationStatusDisplay,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.w700,
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

              // Card Gamifikasi / Care Points (untuk Donatur - Sesuai carecycle-prototype.html)
              if (user?.isDonatur == true) ...[
                Builder(
                  builder: (context) {
                    final points = user?.carePoints ?? 0;
                    final completedItems = points ~/ 10;
                    final level = GamificationCalculator.calculateLevel(completedItems);
                    final progress = GamificationCalculator.calculateProgress(completedItems);
                    final nextTarget = GamificationCalculator.getNextLevelTarget(completedItems);
                    final remainingPoints = (nextTarget - completedItems) * 10;

                    return Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF047857), Color(0xFF10B981)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF047857).withOpacity(0.3),
                            blurRadius: 14,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(AppSizes.md),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.eco_rounded,
                                      color: Colors.white,
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Care Points',
                                        style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      Text(
                                        '$points Poin',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 22,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.25),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.4),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.star_rounded,
                                      color: Colors.amberAccent,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Level: ${level.displayName}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: progress,
                              backgroundColor: Colors.black.withOpacity(0.2),
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                Colors.amberAccent,
                              ),
                              minHeight: 7,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '$completedItems Barang Diselamatkan',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 11,
                                ),
                              ),
                              Text(
                                remainingPoints > 0
                                    ? '$remainingPoints poin menuju level berikutnya 🏆'
                                    : 'Tingkat Tertinggi 🏆',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
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
              Text(
                user?.isAdmin == true
                    ? 'Manajemen Platform'
                    : user?.isKomunitas == true
                        ? 'Aktivitas Komunitas'
                        : 'Menu Donatur',
                style: const TextStyle(
                  fontSize: AppSizes.fontSm,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
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
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
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
          'Dokumen legalitas komunitas Anda saat ini sedang ditinjau oleh tim Admin KindShare.\n\nFitur pengajuan permintaan barang dan pembuatan kampanye akan aktif segera setelah admin menyetujui akun komunitas Anda.';
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
                iconBgColor: const Color(0xFFEFF6FF),
                iconColor: const Color(0xFF3B82F6),
                title: 'Permintaan Saya',
                subtitle: '2 sedang jalan',
                onTap: () {
                  context.pushNamed(AppRouter.communityRequests);
                },
              ),
            ),
            const SizedBox(width: AppSizes.sm),
            Expanded(
              child: _ActivityCard(
                icon: Icons.campaign_outlined,
                iconBgColor: const Color(0xFFFAF5FF),
                iconColor: const Color(0xFF9333EA),
                title: 'Open Campaign',
                subtitle: 'Galang donasi',
                isLocked: !isVerified,
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
                icon: Icons.add_circle_outline_rounded,
                iconBgColor: const Color(0xFFECFDF5),
                iconColor: const Color(0xFF047857),
                title: 'Ajukan Donasi',
                subtitle: 'Pilih dari katalog',
                onTap: () {
                  context.pushNamed(AppRouter.catalog);
                },
              ),
            ),
            const SizedBox(width: AppSizes.sm),
            Expanded(
              child: _ActivityCard(
                icon: Icons.storefront_outlined,
                iconBgColor: const Color(0xFFFFFBEB),
                iconColor: const Color(0xFFF59E0B),
                title: 'Katalog Publik',
                subtitle: 'Semua item donasi',
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
                icon: Icons.description_outlined,
                iconBgColor: const Color(0xFFF1F5F9),
                iconColor: const Color(0xFF334155),
                title: 'Legalitas Akun',
                subtitle: 'SK & Surat Izin',
                onTap: () {
                  context.pushNamed(AppRouter.communityVerification);
                },
              ),
            ),
            const SizedBox(width: AppSizes.sm),
            Expanded(
              child: _ActivityCard(
                icon: Icons.lightbulb_outline_rounded,
                iconBgColor: const Color(0xFFF0FDFA),
                iconColor: const Color(0xFF0D9488),
                title: 'Panduan SOP',
                subtitle: 'Tata cara terima',
                onTap: () {
                  _showDonationGuideDialog(context);
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSizes.md),
        // Tracking Pengiriman Berjalan (sesuai carecycle-prototype.html)
        _buildKomunitasDeliveryTracking(context),
      ],
    );
  }

  /// Widget pelacakan pengiriman aktif untuk Komunitas
  Widget _buildKomunitasDeliveryTracking(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Card(
      elevation: 0,
      color: isDark ? AppColors.cardDark : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        side: BorderSide(
          color: isDark ? Colors.white12 : Colors.grey.shade200,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Pengiriman Sedang Berjalan',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withOpacity(0.04) : Colors.grey.shade50,
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                border: Border.all(
                  color: isDark ? Colors.white12 : Colors.grey.shade200,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: const Color(0xFFECFDF5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                      child: Text('👕', style: TextStyle(fontSize: 18)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Baju Kaos Pria Size L',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'SiCepat Resi: CC-88192849',
                          style: TextStyle(fontSize: 10, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  OutlinedButton(
                    onPressed: () {
                      context.pushNamed(AppRouter.communityRequests);
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text('Konfirmasi', style: TextStyle(fontSize: 11)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
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
                icon: Icons.file_upload_outlined,
                iconBgColor: const Color(0xFFECFDF5),
                iconColor: const Color(0xFF047857),
                title: 'Unggah Donasi',
                subtitle: 'Scan AI & upload',
                onTap: () {
                  context.pushNamed(AppRouter.upload);
                },
              ),
            ),
            const SizedBox(width: AppSizes.sm),
            Expanded(
              child: _ActivityCard(
                icon: Icons.inventory_2_outlined,
                iconBgColor: const Color(0xFFEFF6FF),
                iconColor: const Color(0xFF3B82F6),
                title: 'Barang Saya',
                subtitle: '4 barang aktif',
                onTap: () {
                  context.pushNamed(AppRouter.myItems);
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
                icon: Icons.storefront_outlined,
                iconBgColor: const Color(0xFFFFFBEB),
                iconColor: const Color(0xFFF59E0B),
                title: 'Katalog Publik',
                subtitle: 'Jelajahi barang',
                onTap: () {
                  context.pushNamed(AppRouter.catalog);
                },
              ),
            ),
            const SizedBox(width: AppSizes.sm),
            Expanded(
              child: _ActivityCard(
                icon: Icons.campaign_outlined,
                iconBgColor: const Color(0xFFFAF5FF),
                iconColor: const Color(0xFF9333EA),
                title: 'Open Campaign',
                subtitle: 'Bantu komunitas',
                onTap: () {
                  context.pushNamed(AppRouter.campaign);
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
                icon: Icons.mark_email_read_outlined,
                iconBgColor: const Color(0xFFFFF1F2),
                iconColor: const Color(0xFFE11D48),
                title: 'Acc Permintaan',
                subtitle: '3 pengajuan',
                hasDot: true,
                onTap: () {
                  context.pushNamed(AppRouter.donorRequests);
                },
              ),
            ),
            const SizedBox(width: AppSizes.sm),
            Expanded(
              child: _ActivityCard(
                icon: Icons.military_tech_outlined,
                iconBgColor: const Color(0xFFF0FDFA),
                iconColor: const Color(0xFF0D9488),
                title: 'Dampak & Sertifikat',
                subtitle: 'Lihat jejak hijau',
                onTap: () {
                  context.pushNamed(AppRouter.profile);
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSizes.md),
        // Kampanye Mendesak Spotlight (sesuai carecycle-prototype.html)
        _buildCampaignSpotlight(context),
      ],
    );
  }

  /// Spotlight kampanye mendesak
  Widget _buildCampaignSpotlight(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Card(
      elevation: 0,
      color: isDark ? AppColors.cardDark : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        side: BorderSide(
          color: isDark ? Colors.white12 : Colors.grey.shade200,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.md),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Kampanye Mendesak',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                GestureDetector(
                  onTap: () => context.pushNamed(AppRouter.campaign),
                  child: const Text(
                    'Lihat Semua',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withOpacity(0.04)
                    : AppColors.primarySwatch.shade50.withOpacity(0.6),
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                border: Border.all(
                  color: AppColors.primaryLight.withOpacity(0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text('📚', style: TextStyle(fontSize: 14)),
                      const SizedBox(width: 6),
                      const Expanded(
                        child: Text(
                          'Buku Paket SD Panti Pelita',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'Verified',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryDark,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: const LinearProgressIndicator(
                      value: 0.7,
                      backgroundColor: Color(0xFFD1FAE5),
                      valueColor:
                          AlwaysStoppedAnimation<Color>(AppColors.primary),
                      minHeight: 6,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Terkumpul 35 dari 50 barang',
                        style: TextStyle(fontSize: 10, color: Colors.grey),
                      ),
                      Text(
                        '70%',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
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

  /// Dialog edukasi panduan donasi bijak
  void _showDonationGuideDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.lightbulb_outline_rounded, color: AppColors.primary),
            SizedBox(width: 8),
            Text('Panduan Donasi Bijak', style: TextStyle(fontSize: 16)),
          ],
        ),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '1. Pastikan Kelayakan Barang',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              Text(
                'Pakaian wajib bersih & tidak rusak berat. Elektronik harus berfungsi normal demi keamanan penerima.',
                style: TextStyle(fontSize: 12, color: Colors.black54),
              ),
              SizedBox(height: 8),
              Text(
                '2. Foto Jelas & Transparan',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              Text(
                'Sertakan foto dari berbagai sudut dan tulis deskripsi kondisi barang secara jujur.',
                style: TextStyle(fontSize: 12, color: Colors.black54),
              ),
              SizedBox(height: 8),
              Text(
                '3. Verifikasi & Acc oleh Admin',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              Text(
                'Permintaan donasi dari komunitas dikurasi dan di-acc secara terpusat oleh Admin demi kepastian penyaluran tepat sasaran.',
                style: TextStyle(fontSize: 12, color: Colors.black54),
              ),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Mengerti', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  /// Dialog audit log admin
  void _showAuditLogDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.assignment_outlined, color: Color(0xFF334155)),
            SizedBox(width: 8),
            Text('Audit Log Sistem', style: TextStyle(fontSize: 16)),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Status Enkripsi: AES-256 Aktif', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            SizedBox(height: 6),
            Text('• Verifikasi Komunitas [Yayasan Harapan] diajukan (Baru)', style: TextStyle(fontSize: 11)),
            SizedBox(height: 4),
            Text('• User [Budi Donatur] menyelesaikan donasi #ITM-01', style: TextStyle(fontSize: 11)),
            SizedBox(height: 4),
            Text('• Sinkronisasi database cloud realtime normal', style: TextStyle(fontSize: 11)),
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Tutup', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
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
                icon: Icons.verified_user_outlined,
                iconBgColor: const Color(0xFFF3E8FF),
                iconColor: const Color(0xFF7E22CE),
                title: 'Verifikasi Komunitas',
                subtitle: '3 permohonan',
                hasDot: true,
                dotColor: Colors.amber,
                onTap: () {
                  context.pushNamed(AppRouter.adminVerification);
                },
              ),
            ),
            const SizedBox(width: AppSizes.sm),
            Expanded(
              child: _ActivityCard(
                icon: Icons.handshake_outlined,
                iconBgColor: const Color(0xFFECFDF5),
                iconColor: const Color(0xFF047857),
                title: 'Acc Permintaan',
                subtitle: 'Persetujuan donasi',
                onTap: () {
                  context.pushNamed(AppRouter.donorRequests);
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
                icon: Icons.people_outline_rounded,
                iconBgColor: const Color(0xFFEFF6FF),
                iconColor: const Color(0xFF3B82F6),
                title: 'Kelola Pengguna',
                subtitle: '156 akun',
                onTap: () {
                  context.pushNamed(AppRouter.adminUsers);
                },
              ),
            ),
            const SizedBox(width: AppSizes.sm),
            Expanded(
              child: _ActivityCard(
                icon: Icons.bar_chart_rounded,
                iconBgColor: const Color(0xFFCCFBF1),
                iconColor: const Color(0xFF0F766E),
                title: 'Statistik Platform',
                subtitle: 'Dampak & Eco-data',
                onTap: () {
                  context.pushNamed(AppRouter.adminAnalytics);
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
                icon: Icons.security_outlined,
                iconBgColor: const Color(0xFFFFE4E6),
                iconColor: const Color(0xFFE11D48),
                title: 'Moderasi Barang',
                subtitle: 'Cek kelayakan',
                onTap: () {
                  context.pushNamed(AppRouter.adminItems);
                },
              ),
            ),
            const SizedBox(width: AppSizes.sm),
            Expanded(
              child: _ActivityCard(
                icon: Icons.campaign_outlined,
                iconBgColor: const Color(0xFFFEF3C7),
                iconColor: const Color(0xFFD97706),
                title: 'Semua Kampanye',
                subtitle: 'Monitoring dana',
                onTap: () {
                  context.pushNamed(AppRouter.campaign);
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
                icon: Icons.assignment_outlined,
                iconBgColor: const Color(0xFFF1F5F9),
                iconColor: const Color(0xFF334155),
                title: 'Audit Log',
                subtitle: 'Aktivitas real-time',
                onTap: () {
                  _showAuditLogDialog(context);
                },
              ),
            ),
            const SizedBox(width: AppSizes.sm),
            Expanded(
              child: _ActivityCard(
                icon: Icons.settings_outlined,
                iconBgColor: const Color(0xFFEEF2FF),
                iconColor: const Color(0xFF4338CA),
                title: 'Profil Admin',
                subtitle: 'Pengaturan sistem',
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
  final Color iconBgColor;
  final Color iconColor;
  final bool hasDot;
  final Color? dotColor;
  final bool isLocked;
  final VoidCallback onTap;

  const _ActivityCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.iconBgColor = const Color(0xFFECFDF5),
    this.iconColor = AppColors.primary,
    this.hasDot = false,
    this.dotColor,
    this.isLocked = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      elevation: 0,
      color: isDark ? AppColors.cardDark : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        side: BorderSide(
          color: isDark ? Colors.white12 : Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: iconBgColor,
                      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                    ),
                    child: Center(
                      child: Icon(icon, color: iconColor, size: 22),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12.5,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: 10.5,
                            color: isDark
                                ? Colors.white60
                                : AppColors.textSecondaryLight,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (hasDot)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: dotColor ?? const Color(0xFFF43F5E),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            if (isLocked)
              Positioned(
                top: 6,
                right: 8,
                child: Icon(
                  Icons.lock_rounded,
                  size: 13,
                  color: Colors.grey.shade400,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

