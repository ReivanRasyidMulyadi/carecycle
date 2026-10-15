import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/utils/gamification_calculator.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../providers/auth_provider.dart';

/// Halaman Profil Pengguna lengkap dengan info akun, legalitas komunitas, dan toggle tema
class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final themeMode = ref.watch(themeModeProvider);
    final isDarkMode = themeMode == ThemeMode.dark;
    final user = authState.user;
    final community = authState.community;

    final completedItems = (user?.carePoints ?? 0) ~/ 10;
    final currentLevel = GamificationCalculator.calculateLevel(completedItems);

    return AppScaffold(
      title: AppStrings.profile,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Card Header Profil
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusLg),
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppSizes.lg),
                child: Column(
                  children: [
                    Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundColor: AppColors.primarySwatch.shade100,
                          child: Text(
                            (user?.fullName.isNotEmpty == true
                                    ? user!.fullName[0]
                                    : 'U')
                                .toUpperCase(),
                            style: const TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            user?.isAdmin == true
                                ? Icons.admin_panel_settings
                                : user?.isKomunitas == true
                                    ? Icons.groups
                                    : Icons.volunteer_activism,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSizes.md),
                    Text(
                      user?.fullName ?? 'Nama Pengguna',
                      style: const TextStyle(
                        fontSize: AppSizes.fontXl,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      user?.email ?? '',
                      style: const TextStyle(
                        color: AppColors.textSecondaryLight,
                        fontSize: AppSizes.fontSm,
                      ),
                    ),
                    const SizedBox(height: AppSizes.sm),
                    // Badge Peranan
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Chip(
                          avatar: Icon(
                            user?.isAdmin == true
                                ? Icons.admin_panel_settings
                                : user?.isKomunitas == true
                                    ? Icons.business
                                    : Icons.person,
                            size: 16,
                            color: Colors.white,
                          ),
                          label: Text(
                            user?.roleDisplay ?? 'Donatur',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          backgroundColor: AppColors.primary,
                        ),
                        if (user?.isKomunitas == true && community != null) ...[
                          const SizedBox(width: AppSizes.xs),
                          Chip(
                            avatar: Icon(
                              community.isVerified
                                  ? Icons.verified
                                  : Icons.hourglass_top,
                              size: 16,
                              color: Colors.white,
                            ),
                            label: Text(
                              community.verificationStatusDisplay,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            backgroundColor: community.isVerified
                                ? AppColors.success
                                : AppColors.warning,
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSizes.md),

            // Card Gamifikasi (Khusus Donatur)
            if (user?.isDonatur == true) ...[
              Card(
                elevation: 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(AppSizes.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                currentLevel.icon,
                                color: currentLevel.color,
                                size: 28,
                              ),
                              const SizedBox(width: AppSizes.sm),
                              Text(
                                'Level: ${currentLevel.displayName}',
                                style: TextStyle(
                                  fontSize: AppSizes.fontMd,
                                  fontWeight: FontWeight.bold,
                                  color: currentLevel.color,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            '${user?.carePoints ?? 0} Poin',
                            style: const TextStyle(
                              fontSize: AppSizes.fontLg,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSizes.sm),
                      LinearProgressIndicator(
                        value: GamificationCalculator.calculateProgress(
                          completedItems,
                        ),
                        backgroundColor: Colors.grey.shade200,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          currentLevel.color,
                        ),
                        borderRadius: BorderRadius.circular(4),
                        minHeight: 8,
                      ),
                      const SizedBox(height: AppSizes.xs),
                      Text(
                        currentLevel == DonorLevel.savior
                            ? 'Luar biasa! Anda berada di tingkat tertinggi Savior!'
                            : '$completedItems barang sukses didonasikan (target level berikutnya: ${GamificationCalculator.getNextLevelTarget(completedItems)} barang)',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSizes.md),
            ],

            // Informasi Organisasi (Khusus Komunitas)
            if (user?.isKomunitas == true && community != null) ...[
              Card(
                elevation: 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(AppSizes.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Informasi Komunitas',
                        style: TextStyle(
                          fontSize: AppSizes.fontMd,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Divider(),
                      _InfoRow(
                        label: 'Nama Organisasi',
                        value: community.communityName,
                      ),
                      _InfoRow(
                        label: 'Status Legalitas',
                        value: community.verificationStatusDisplay,
                        valueColor: community.isVerified
                            ? AppColors.success
                            : AppColors.warning,
                      ),
                      if (community.rejectionReason != null)
                        _InfoRow(
                          label: 'Alasan Penolakan',
                          value: community.rejectionReason!,
                          valueColor: AppColors.error,
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSizes.md),
            ],

            // Pengaturan Aplikasi
            Card(
              elevation: 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              ),
              child: Column(
                children: [
                  // Toggle Tema Gelap / Terang (Hive-persisted)
                  SwitchListTile(
                    secondary: Icon(
                      isDarkMode ? Icons.dark_mode : Icons.light_mode,
                      color: AppColors.primary,
                    ),
                    title: const Text(AppStrings.darkMode),
                    subtitle: Text(
                      isDarkMode
                          ? 'Mode gelap aktif (tersimpan lokal)'
                          : 'Mode terang aktif (tersimpan lokal)',
                      style: const TextStyle(fontSize: 12),
                    ),
                    value: isDarkMode,
                    onChanged: (val) {
                      ref.read(themeModeProvider.notifier).toggle();
                      context.showSnackBar(
                        val
                            ? 'Mode Gelap diaktifkan'
                            : 'Mode Terang diaktifkan',
                      );
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(
                      Icons.security_outlined,
                      color: AppColors.primary,
                    ),
                    title: const Text('Keamanan & Privasi'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      context.showSnackBar('Fitur keamanan aktif via Supabase RLS.');
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSizes.lg),

            // Tombol Keluar (Logout)
            AppButton(
              label: AppStrings.logout,
              isOutlined: true,
              icon: Icons.logout,
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
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondaryLight,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: valueColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
