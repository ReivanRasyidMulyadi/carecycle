import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/admin/presentation/screens/admin_analytics_screen.dart';
import '../../features/admin/presentation/screens/admin_items_screen.dart';
import '../../features/admin/presentation/screens/admin_users_screen.dart';
import '../../features/admin/presentation/screens/admin_verification_screen.dart';
import '../../features/auth/presentation/screens/community_verification_screen.dart';
import '../../features/auth/presentation/screens/home_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/profile_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/campaigns/presentation/screens/campaign_screen.dart';
import '../../features/items/presentation/screens/catalog_screen.dart';
import '../../features/items/presentation/screens/item_detail_screen.dart';
import '../../features/items/presentation/screens/item_upload_screen.dart';
import '../../features/items/presentation/screens/my_items_screen.dart';
import '../../features/requests/presentation/screens/community_requests_screen.dart';
import '../../features/requests/presentation/screens/donor_requests_screen.dart';
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
  static const String itemDetail = 'itemDetail';
  static const String upload = 'upload';
  static const String myItems = 'myItems';
  static const String request = 'request';
  static const String donorRequests = 'donorRequests';
  static const String communityRequests = 'communityRequests';
  static const String campaign = 'campaign';
  static const String profile = 'profile';
  static const String settings = 'settings';
  static const String communityVerification = 'communityVerification';
  static const String adminVerification = 'adminVerification';
  static const String adminUsers = 'adminUsers';
  static const String adminAnalytics = 'adminAnalytics';
  static const String adminItems = 'adminItems';

  // Path Route
  static const String splashPath = '/';
  static const String loginPath = '/login';
  static const String registerPath = '/register';
  static const String homePath = '/home';
  static const String catalogPath = '/catalog';
  static const String itemDetailPath = '/items/:id';
  static const String uploadPath = '/upload';
  static const String myItemsPath = '/my-items';
  static const String requestPath = '/request';
  static const String donorRequestsPath = '/requests/donor';
  static const String communityRequestsPath = '/community/requests';
  static const String campaignPath = '/campaign';
  static const String profilePath = '/profile';
  static const String settingsPath = '/settings';
  static const String communityVerificationPath = '/community/verification';
  static const String adminVerificationPath = '/admin/verification';
  static const String adminUsersPath = '/admin/users';
  static const String adminAnalyticsPath = '/admin/analytics';
  static const String adminItemsPath = '/admin/items';

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
        builder: (context, state) => const CatalogScreen(),
      ),
      GoRoute(
        path: itemDetailPath,
        name: itemDetail,
        builder: (context, state) => ItemDetailScreen(
          itemId: state.pathParameters['id']!,
        ),
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
        builder: (context, state) => const CatalogScreen(),
      ),
      GoRoute(
        path: donorRequestsPath,
        name: donorRequests,
        builder: (context, state) => const DonorRequestsScreen(),
      ),
      GoRoute(
        path: communityRequestsPath,
        name: communityRequests,
        builder: (context, state) => const CommunityRequestsScreen(),
      ),
      GoRoute(
        path: campaignPath,
        name: campaign,
        builder: (context, state) => const CampaignScreen(),
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
      GoRoute(
        path: adminUsersPath,
        name: adminUsers,
        builder: (context, state) => const AdminUsersScreen(),
      ),
      GoRoute(
        path: adminAnalyticsPath,
        name: adminAnalytics,
        builder: (context, state) => const AdminAnalyticsScreen(),
      ),
      GoRoute(
        path: adminItemsPath,
        name: adminItems,
        builder: (context, state) => const AdminItemsScreen(),
      ),
    ],
  );

  /// Auth guard - pengalihan otomatis berdasarkan status login dan peran
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

    // Guard khusus admin: hanya role 'admin' yang boleh akses rute admin dan permintaan donasi masuk
    final isAdminOnlyRoute = state.matchedLocation.startsWith('/admin') ||
        state.matchedLocation == donorRequestsPath;

    if (isAdminOnlyRoute) {
      final userRole = HiveService.getUserRole();
      if (userRole != 'admin') return homePath;
    }

    return null;
  }
}
