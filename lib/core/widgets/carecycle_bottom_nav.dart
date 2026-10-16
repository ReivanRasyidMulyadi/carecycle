import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../constants/app_colors.dart';
import '../router/app_router.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';

/// Bottom Navigation Bar dinamis yang menyesuaikan 100% dengan rancangan carecycle-prototype.html
class CareCycleBottomNav extends ConsumerWidget {
  final int currentIndex;

  const CareCycleBottomNav({
    super.key,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final user = authState.user;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (user?.isAdmin == true) {
      return _buildAdminNav(context, isDark);
    } else if (user?.isKomunitas == true) {
      return _buildKomunitasNav(context, isDark);
    } else {
      return _buildDonaturNav(context, isDark);
    }
  }

  /// Navigation Bar khusus Donatur (5 item dengan tombol Unggah tengah menonjol)
  Widget _buildDonaturNav(BuildContext context, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        border: Border(
          top: BorderSide(
            color: isDark ? Colors.white12 : Colors.grey.shade200,
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      height: 68,
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            _buildNavItem(
              context: context,
              index: 0,
              icon: Icons.home_rounded,
              label: 'Beranda',
              onTap: () => _navigate(context, 0, AppRouter.home),
            ),
            _buildNavItem(
              context: context,
              index: 1,
              icon: Icons.grid_view_rounded,
              label: 'Katalog',
              onTap: () => _navigate(context, 1, AppRouter.catalog),
            ),
            // Tombol Unggah Tengah yang Menonjol (Special Center FAB)
            Expanded(
              child: GestureDetector(
                onTap: () => _navigate(context, 2, AppRouter.upload),
                behavior: HitTestBehavior.opaque,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Transform.translate(
                      offset: const Offset(0, -10),
                      child: Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isDark ? AppColors.surfaceDark : Colors.white,
                            width: 3,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.35),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.add_rounded,
                          color: Colors.white,
                          size: 26,
                        ),
                      ),
                    ),
                    Transform.translate(
                      offset: const Offset(0, -8),
                      child: Text(
                        'Unggah',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.bold,
                          color: currentIndex == 2
                              ? AppColors.primary
                              : (isDark ? Colors.white70 : Colors.grey.shade600),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            _buildNavItem(
              context: context,
              index: 3,
              icon: Icons.inventory_2_rounded,
              label: 'Barang Saya',
              onTap: () => _navigate(context, 3, AppRouter.myItems),
            ),
            _buildNavItem(
              context: context,
              index: 4,
              icon: Icons.person_rounded,
              label: 'Profil',
              onTap: () => _navigate(context, 4, AppRouter.profile),
            ),
          ],
        ),
      ),
    );
  }

  /// Navigation Bar khusus Komunitas (4 item)
  Widget _buildKomunitasNav(BuildContext context, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        border: Border(
          top: BorderSide(
            color: isDark ? Colors.white12 : Colors.grey.shade200,
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      height: 64,
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            _buildNavItem(
              context: context,
              index: 0,
              icon: Icons.home_rounded,
              label: 'Beranda',
              onTap: () => _navigate(context, 0, AppRouter.home),
            ),
            _buildNavItem(
              context: context,
              index: 1,
              icon: Icons.grid_view_rounded,
              label: 'Katalog',
              onTap: () => _navigate(context, 1, AppRouter.catalog),
            ),
            _buildNavItem(
              context: context,
              index: 2,
              icon: Icons.receipt_long_rounded,
              label: 'Permintaan',
              onTap: () => _navigate(context, 2, AppRouter.communityRequests),
            ),
            _buildNavItem(
              context: context,
              index: 3,
              icon: Icons.person_rounded,
              label: 'Profil',
              onTap: () => _navigate(context, 3, AppRouter.profile),
            ),
          ],
        ),
      ),
    );
  }

  /// Navigation Bar khusus Admin (5 item)
  Widget _buildAdminNav(BuildContext context, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        border: Border(
          top: BorderSide(
            color: isDark ? Colors.white12 : Colors.grey.shade200,
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      height: 64,
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            _buildNavItem(
              context: context,
              index: 0,
              icon: Icons.home_rounded,
              label: 'Beranda',
              onTap: () => _navigate(context, 0, AppRouter.home),
            ),
            _buildNavItem(
              context: context,
              index: 1,
              icon: Icons.verified_user_rounded,
              label: 'Verifikasi',
              onTap: () => _navigate(context, 1, AppRouter.adminVerification),
            ),
            _buildNavItem(
              context: context,
              index: 2,
              icon: Icons.people_alt_rounded,
              label: 'Pengguna',
              onTap: () => _navigate(context, 2, AppRouter.adminUsers),
            ),
            _buildNavItem(
              context: context,
              index: 3,
              icon: Icons.analytics_rounded,
              label: 'Statistik',
              onTap: () => _navigate(context, 3, AppRouter.adminAnalytics),
            ),
            _buildNavItem(
              context: context,
              index: 4,
              icon: Icons.person_rounded,
              label: 'Profil',
              onTap: () => _navigate(context, 4, AppRouter.profile),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required int index,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final isSelected = currentIndex == index;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    const selectedColor = AppColors.primary;
    final unselectedColor = isDark ? Colors.white54 : Colors.grey.shade400;

    return Expanded(
      child: InkWell(
        onTap: onTap,
        splashColor: AppColors.primaryLight.withOpacity(0.1),
        highlightColor: Colors.transparent,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? selectedColor : unselectedColor,
              size: 22,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? selectedColor : unselectedColor,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  void _navigate(BuildContext context, int targetIndex, String routeName) {
    if (currentIndex == targetIndex) return;

    if (routeName == AppRouter.home) {
      context.goNamed(routeName);
    } else {
      context.pushNamed(routeName);
    }
  }
}
