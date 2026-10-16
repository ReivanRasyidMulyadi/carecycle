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
import '../../../../core/widgets/carecycle_bottom_nav.dart';
import '../providers/auth_provider.dart';

/// Halaman Profil Pengguna lengkap dengan edit data diri, ubah password, info akun, dan legalitas
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
      bottomNavigationBar: CareCycleBottomNav(
        currentIndex: user?.isKomunitas == true ? 3 : 4,
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(authNotifierProvider.notifier).refreshCurrentUser(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
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
                            radius: 42,
                            backgroundColor: AppColors.primarySwatch.shade100,
                            child: Text(
                              (user?.fullName.isNotEmpty == true
                                      ? user!.fullName[0]
                                      : 'U')
                                  .toUpperCase(),
                              style: const TextStyle(
                                fontSize: 38,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(5),
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
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        user?.email ?? '',
                        style: const TextStyle(
                          color: AppColors.textSecondaryLight,
                          fontSize: AppSizes.fontSm,
                        ),
                      ),
                      const SizedBox(height: AppSizes.sm),

                      // Badge Peranan & Status
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        alignment: WrapAlignment.center,
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
                                fontSize: 12,
                              ),
                            ),
                            backgroundColor: AppColors.primary,
                          ),
                          if (user?.isKomunitas == true && community != null)
                            Chip(
                              avatar: Icon(
                                community.isVerified
                                    ? Icons.verified
                                    : (community.isRejected
                                        ? Icons.cancel
                                        : Icons.hourglass_top),
                                size: 16,
                                color: Colors.white,
                              ),
                              label: Text(
                                community.verificationStatusDisplay,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                              backgroundColor: community.isVerified
                                  ? AppColors.success
                                  : (community.isRejected
                                      ? AppColors.error
                                      : AppColors.warning),
                            ),
                        ],
                      ),
                      const SizedBox(height: AppSizes.md),

                      // Tombol Aksi Edit Profil
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => _showEditProfileDialog(context, user),
                          icon: const Icon(Icons.edit_outlined, size: 18),
                          label: const Text('Edit Informasi Akun'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSizes.md),

              // Card Informasi Data Diri Lengkap
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
                          const Text(
                            'Informasi Akun',
                            style: TextStyle(
                              fontSize: AppSizes.fontMd,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit, size: 18, color: AppColors.primary),
                            tooltip: 'Ubah Data',
                            onPressed: () => _showEditProfileDialog(context, user),
                          ),
                        ],
                      ),
                      const Divider(height: 1),
                      const SizedBox(height: 8),
                      _InfoRow(
                        icon: Icons.person_outline,
                        label: 'Nama Lengkap',
                        value: user?.fullName ?? '-',
                      ),
                      _InfoRow(
                        icon: Icons.email_outlined,
                        label: 'Alamat Email',
                        value: user?.email ?? '-',
                      ),
                      _InfoRow(
                        icon: Icons.phone_outlined,
                        label: 'Nomor Telepon',
                        value: user?.phoneNumber?.isNotEmpty == true
                            ? user!.phoneNumber!
                            : 'Belum ditambahkan',
                        valueColor: user?.phoneNumber?.isNotEmpty == true
                            ? null
                            : Colors.grey.shade500,
                      ),
                      _InfoRow(
                        icon: Icons.location_on_outlined,
                        label: 'Alamat Domisili',
                        value: user?.address?.isNotEmpty == true
                            ? user!.address!
                            : 'Belum ditambahkan',
                        valueColor: user?.address?.isNotEmpty == true
                            ? null
                            : Colors.grey.shade500,
                      ),
                      if (user?.createdAt != null)
                        _InfoRow(
                          icon: Icons.calendar_today_outlined,
                          label: 'Bergabung Sejak',
                          value:
                              '${user!.createdAt!.day}/${user.createdAt!.month}/${user.createdAt!.year}',
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

              // Informasi Organisasi & Legalitas (Khusus Komunitas)
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Informasi Legalitas Komunitas',
                              style: TextStyle(
                                fontSize: AppSizes.fontMd,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextButton.icon(
                              onPressed: () =>
                                  context.pushNamed(AppRouter.communityVerification),
                              icon: const Icon(Icons.file_present_outlined, size: 16),
                              label: const Text('Kelola Berkas', style: TextStyle(fontSize: 12)),
                            ),
                          ],
                        ),
                        const Divider(height: 1),
                        const SizedBox(height: 8),
                        _InfoRow(
                          icon: Icons.corporate_fare_outlined,
                          label: 'Nama Organisasi',
                          value: community.communityName,
                        ),
                        _InfoRow(
                          icon: Icons.verified_user_outlined,
                          label: 'Status Legalitas',
                          value: community.verificationStatusDisplay,
                          valueColor: community.isVerified
                              ? AppColors.success
                              : (community.isRejected
                                  ? AppColors.error
                                  : AppColors.warning),
                        ),
                        if (community.rejectionReason != null)
                          _InfoRow(
                            icon: Icons.info_outline,
                            label: 'Alasan Penolakan',
                            value: community.rejectionReason!,
                            valueColor: AppColors.error,
                          ),
                        const SizedBox(height: 6),
                        OutlinedButton.icon(
                          onPressed: () =>
                              context.pushNamed(AppRouter.communityVerification),
                          icon: const Icon(Icons.upload_file, size: 16),
                          label: Text(
                            community.isVerified
                                ? 'Lihat / Perbarui Dokumen'
                                : 'Unggah / Perbaiki Dokumen Legalitas',
                            style: const TextStyle(fontSize: 12),
                          ),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 38),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSizes.md),
              ],

              // Pengaturan Akun & Keamanan
              Card(
                elevation: 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                ),
                child: Column(
                  children: [
                    // Ganti Kata Sandi
                    ListTile(
                      leading: const Icon(Icons.lock_reset, color: AppColors.primary),
                      title: const Text('Ganti Kata Sandi'),
                      subtitle: const Text(
                        'Perbarui password login akun Anda',
                        style: TextStyle(fontSize: 12),
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => _showChangePasswordDialog(context),
                    ),
                    const Divider(height: 1),

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
                        Icons.shield_outlined,
                        color: AppColors.primary,
                      ),
                      title: const Text('Keamanan & Privasi Data'),
                      subtitle: const Text(
                        'Dilindungi enkripsi Supabase Row Level Security',
                        style: TextStyle(fontSize: 12),
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        context.showSnackBar('Aplikasi dilindungi enkripsi JWT & Supabase RLS.');
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
      ),
    );
  }

  /// Dialog Modal untuk Mengedit Profil Pengguna
  void _showEditProfileDialog(BuildContext context, dynamic user) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: user?.fullName ?? '');
    final phoneController = TextEditingController(text: user?.phoneNumber ?? '');
    final addressController = TextEditingController(text: user?.address ?? '');

    showDialog(
      context: context,
      builder: (dialogCtx) {
        bool isLoading = false;
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Row(
                children: [
                  Icon(Icons.person_pin, color: AppColors.primary),
                  SizedBox(width: 8),
                  Text('Edit Profil Anda', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Nama Lengkap
                      TextFormField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          labelText: 'Nama Lengkap',
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return 'Nama lengkap tidak boleh kosong';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),

                      // Nomor Telepon
                      TextFormField(
                        controller: phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          labelText: 'Nomor Telepon / WhatsApp',
                          prefixIcon: Icon(Icons.phone_outlined),
                          hintText: '081234567890',
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Alamat
                      TextFormField(
                        controller: addressController,
                        maxLines: 2,
                        decoration: const InputDecoration(
                          labelText: 'Alamat Domisili / Kantor',
                          prefixIcon: Icon(Icons.location_on_outlined),
                          hintText: 'Jl. Contoh No. 123, Kota',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isLoading ? null : () => Navigator.pop(dialogCtx),
                  child: const Text('Batal'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: isLoading
                      ? null
                      : () async {
                          if (!formKey.currentState!.validate()) return;
                          setDialogState(() => isLoading = true);

                          final success = await ref
                              .read(authNotifierProvider.notifier)
                              .updateProfile(
                                fullName: nameController.text,
                                phoneNumber: phoneController.text,
                                address: addressController.text,
                              );

                          if (context.mounted) {
                            Navigator.pop(dialogCtx);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  success
                                      ? 'Profil berhasil diperbarui!'
                                      : 'Gagal memperbarui profil.',
                                ),
                                backgroundColor:
                                    success ? AppColors.success : AppColors.error,
                              ),
                            );
                          }
                        },
                  child: isLoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Simpan Perubahan'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  /// Dialog Modal untuk Mengganti Kata Sandi
  void _showChangePasswordDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    bool obscureNew = true;
    bool obscureConfirm = true;

    showDialog(
      context: context,
      builder: (dialogCtx) {
        bool isLoading = false;
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Row(
                children: [
                  Icon(Icons.lock_reset, color: AppColors.primary),
                  SizedBox(width: 8),
                  Text('Ganti Kata Sandi', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: newPasswordController,
                        obscureText: obscureNew,
                        decoration: InputDecoration(
                          labelText: 'Kata Sandi Baru',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(obscureNew ? Icons.visibility_off : Icons.visibility),
                            onPressed: () => setDialogState(() => obscureNew = !obscureNew),
                          ),
                        ),
                        validator: (val) {
                          if (val == null || val.length < 6) {
                            return 'Kata sandi minimal 6 karakter';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: confirmPasswordController,
                        obscureText: obscureConfirm,
                        decoration: InputDecoration(
                          labelText: 'Ulangi Kata Sandi Baru',
                          prefixIcon: const Icon(Icons.lock_clock_outlined),
                          suffixIcon: IconButton(
                            icon: Icon(obscureConfirm ? Icons.visibility_off : Icons.visibility),
                            onPressed: () => setDialogState(() => obscureConfirm = !obscureConfirm),
                          ),
                        ),
                        validator: (val) {
                          if (val != newPasswordController.text) {
                            return 'Konfirmasi kata sandi tidak cocok';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isLoading ? null : () => Navigator.pop(dialogCtx),
                  child: const Text('Batal'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: isLoading
                      ? null
                      : () async {
                          if (!formKey.currentState!.validate()) return;
                          setDialogState(() => isLoading = true);

                          final success = await ref
                              .read(authNotifierProvider.notifier)
                              .changePassword(newPasswordController.text);

                          if (context.mounted) {
                            Navigator.pop(dialogCtx);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  success
                                      ? 'Kata sandi berhasil diganti!'
                                      : 'Gagal mengganti kata sandi.',
                                ),
                                backgroundColor:
                                    success ? AppColors.success : AppColors.error,
                              ),
                            );
                          }
                        },
                  child: isLoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Perbarui Sandi'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData? icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoRow({
    this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 18, color: Colors.grey.shade600),
            const SizedBox(width: 8),
          ],
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey.shade600,
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
