import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/widgets/carecycle_bottom_nav.dart';
import '../providers/admin_provider.dart';

/// Layar Statistik & Analitik Platform untuk Administrator CareCycle
class AdminAnalyticsScreen extends ConsumerWidget {
  const AdminAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(adminStatsProvider);

    return AppScaffold(
      title: 'Statistik & Dampak Platform',
      bottomNavigationBar: const CareCycleBottomNav(currentIndex: 3),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          tooltip: 'Segarkan Data',
          onPressed: () => ref.refresh(adminStatsProvider),
        ),
      ],
      body: statsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: AppColors.error),
              const SizedBox(height: AppSizes.md),
              Text('Gagal memuat analitik: $err'),
              const SizedBox(height: AppSizes.sm),
              ElevatedButton(
                onPressed: () => ref.refresh(adminStatsProvider),
                child: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
        data: (stats) {
          final totalAccRate = stats.totalRequests > 0
              ? ((stats.approvedRequests / stats.totalRequests) * 100).toStringAsFixed(1)
              : '0.0';

          return RefreshIndicator(
            onRefresh: () async => ref.refresh(adminStatsProvider),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSizes.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Banner Dampak Lingkungan (Eco-Impact)
                  _buildEcoImpactCard(stats.estimatedWasteDivertedKg),
                  const SizedBox(height: AppSizes.md),

                  // Bagian 1: Pengguna Platform
                  const Text(
                    'Pengguna & Komunitas',
                    style: TextStyle(fontSize: AppSizes.fontMd, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: AppSizes.sm),
                  Row(
                    children: [
                      Expanded(
                        child: _buildMetricCard(
                          title: 'Total Akun',
                          value: '${stats.totalUsers}',
                          icon: Icons.people_alt_outlined,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: AppSizes.sm),
                      Expanded(
                        child: _buildMetricCard(
                          title: 'Donatur Aktif',
                          value: '${stats.totalDonors}',
                          icon: Icons.volunteer_activism_outlined,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSizes.sm),
                  Row(
                    children: [
                      Expanded(
                        child: _buildMetricCard(
                          title: 'Komunitas Terverifikasi',
                          value: '${stats.totalVerifiedCommunities}',
                          icon: Icons.verified_outlined,
                          color: AppColors.success,
                        ),
                      ),
                      const SizedBox(width: AppSizes.sm),
                      Expanded(
                        child: _buildMetricCard(
                          title: 'Menunggu Legalitas',
                          value: '${stats.totalPendingCommunities}',
                          icon: Icons.pending_actions_outlined,
                          color: AppColors.warning,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSizes.lg),

                  // Bagian 2: Barang & Donasi
                  const Text(
                    'Aktivitas Barang & Penyaluran',
                    style: TextStyle(fontSize: AppSizes.fontMd, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: AppSizes.sm),
                  Row(
                    children: [
                      Expanded(
                        child: _buildMetricCard(
                          title: 'Total Barang',
                          value: '${stats.totalItems}',
                          icon: Icons.inventory_2_outlined,
                          color: Colors.teal.shade700,
                        ),
                      ),
                      const SizedBox(width: AppSizes.sm),
                      Expanded(
                        child: _buildMetricCard(
                          title: 'Tersedia di Katalog',
                          value: '${stats.availableItems}',
                          icon: Icons.check_circle_outline,
                          color: Colors.indigo.shade600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSizes.sm),
                  Row(
                    children: [
                      Expanded(
                        child: _buildMetricCard(
                          title: 'Donasi Selesai',
                          value: '${stats.completedItems}',
                          icon: Icons.task_alt,
                          color: AppColors.success,
                        ),
                      ),
                      const SizedBox(width: AppSizes.sm),
                      Expanded(
                        child: _buildMetricCard(
                          title: 'Tingkat Acc Donasi',
                          value: '$totalAccRate%',
                          icon: Icons.analytics_outlined,
                          color: Colors.deepPurple,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSizes.lg),

                  // Bagian 3: Antrean Permohonan
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
                          const Row(
                            children: [
                              Icon(Icons.fact_check_outlined, color: AppColors.primary, size: 20),
                              SizedBox(width: 8),
                              Text(
                                'Status Permohonan Komunitas',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                            ],
                          ),
                          const Divider(height: 20),
                          _buildStatusRow('Total Pengajuan', stats.totalRequests, Colors.blueGrey),
                          const SizedBox(height: 8),
                          _buildStatusRow('Menunggu Acc Admin', stats.pendingRequests, AppColors.warning),
                          const SizedBox(height: 8),
                          _buildStatusRow('Disetujui & Diproses', stats.approvedRequests, AppColors.success),
                          const SizedBox(height: 8),
                          _buildStatusRow('Ditolak', stats.rejectedRequests, AppColors.error),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEcoImpactCard(double kgSaved) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.lg),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.eco_rounded, color: Colors.white, size: 28),
              SizedBox(width: 8),
              Text(
                'Dampak Lingkungan (Circular Economy)',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '~${kgSaved.toStringAsFixed(1)} Kg',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Estimasi timbunan sampah tekstil, perkakas & elektronik yang berhasil dicegah dari TPA berkat penyaluran donasi KindShare.',
            style: TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
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
                Text(
                  title,
                  style: const TextStyle(fontSize: 11, color: Colors.black54),
                ),
                Icon(icon, size: 18, color: color),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusRow(String label, int count, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(fontSize: 13)),
          ],
        ),
        Text(
          '$count',
          style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 14),
        ),
      ],
    );
  }
}
