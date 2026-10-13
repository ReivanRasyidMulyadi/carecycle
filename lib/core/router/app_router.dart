import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/admin/presentation/screens/admin_verification_screen.dart';
import '../../features/auth/presentation/screens/community_verification_screen.dart';
import '../../features/auth/presentation/screens/home_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/profile_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/items/presentation/screens/item_upload_screen.dart';
import '../../features/items/presentation/screens/my_items_screen.dart';
import '../services/hive_service.dart';

/// Konfigurasi rute aplikasi CareCycle
class AppRouter {
  AppRouter._();

  // Nama Route
  static const String splash = 'splash';
  static const String login = 'login';
  static const String register = 'register';
  static const String home = 'home';
  static const String catalog = 'catalog';
  static const String upload = 'upload';
  static const String myItems = 'myItems';
  static const String request = 'request';
  static const String campaign = 'campaign';
  static const String profile = 'profile';
  static const String settings = 'settings';
  static const String communityVerification = 'communityVerification';
  static const String adminVerification = 'adminVerification';

  // Path Route
  static const String splashPath = '/';
  static const String loginPath = '/login';
  static const String registerPath = '/register';
  static const String homePath = '/home';
  static const String catalogPath = '/catalog';
  static const String uploadPath = '/upload';
  static const String myItemsPath = '/my-items';
  static const String requestPath = '/request';
  static const String campaignPath = '/campaign';
  static const String profilePath = '/profile';
  static const String settingsPath = '/settings';
  static const String communityVerificationPath = '/community/verification';
  static const String adminVerificationPath = '/admin/verification';

  static final GoRouter router = GoRouter(
    initialLocation: splashPath,
    debugLogDiagnostics: false,
    redirect: _guard,
    routes: [
      GoRoute(
        path: splashPath,
        name: splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: loginPath,
        name: login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: registerPath,
        name: register,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: homePath,
        name: home,
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: catalogPath,
        name: catalog,
        builder: (context, state) => const _PlaceholderScreen(title: 'Katalog Barang'),
      ),
      GoRoute(
        path: uploadPath,
        name: upload,
        builder: (context, state) => const ItemUploadScreen(),
      ),
      GoRoute(
        path: myItemsPath,
        name: myItems,
        builder: (context, state) => const MyItemsScreen(),
      ),
      GoRoute(
        path: requestPath,
        name: request,
        builder: (context, state) => const _PlaceholderScreen(title: 'Ajukan Permintaan Barang'),
      ),
      GoRoute(
        path: campaignPath,
        name: campaign,
        builder: (context, state) => const _PlaceholderScreen(title: 'Open Campaign'),
      ),
      GoRoute(
        path: profilePath,
        name: profile,
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: communityVerificationPath,
        name: communityVerification,
        builder: (context, state) => const CommunityVerificationScreen(),
      ),
      GoRoute(
        path: adminVerificationPath,
        name: adminVerification,
        builder: (context, state) => const AdminVerificationScreen(),
      ),
    ],
  );

  /// Auth guard - pengalihan otomatis berdasarkan status login
  static String? _guard(BuildContext context, GoRouterState state) {
    final isLoggedIn = HiveService.isLoggedIn();
    final isSplash = state.matchedLocation == splashPath;
    final isAuthRoute = state.matchedLocation == loginPath ||
        state.matchedLocation == registerPath;

    // Biarkan layar splash menangani transisi awalnya
    if (isSplash) return null;

    // Jika belum login dan mengakses halaman selain login/register
    if (!isLoggedIn && !isAuthRoute) return loginPath;

    // Jika sudah login namun masih berada di halaman login/register
    if (isLoggedIn && isAuthRoute) return homePath;

    return null;
  }
}

/// Widget placeholder untuk fitur di fase berikutnya
class _PlaceholderScreen extends StatelessWidget {
  final String title;

  const _PlaceholderScreen({required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.construction,
              size: 64,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Akan diimplementasikan pada fase berikutnya.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.6),
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
