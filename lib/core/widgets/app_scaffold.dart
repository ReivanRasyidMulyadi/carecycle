import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../constants/app_colors.dart';
import '../constants/app_strings.dart';
import '../providers/app_providers.dart';

/// Scaffold wrapper dengan indikator status offline
class AppScaffold extends ConsumerWidget {
  final String? title;
  final Widget? titleWidget;
  final Widget body;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;
  final List<Widget>? actions;
  final bool showOfflineBanner;

  const AppScaffold({
    super.key,
    this.title,
    this.titleWidget,
    required this.body,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.actions,
    this.showOfflineBanner = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectivityAsync = ref.watch(connectivityProvider);

    return Scaffold(
      appBar: (title != null || titleWidget != null)
          ? AppBar(
              title: titleWidget ?? Text(title!),
              actions: actions,
            )
          : null,
      body: Column(
        children: [
          if (showOfflineBanner)
            connectivityAsync.when(
              data: (results) {
                if (results.contains(ConnectivityResult.none)) {
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    color: AppColors.warning,
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.wifi_off, size: 16, color: Colors.white),
                        SizedBox(width: 8),
                        Text(
                          AppStrings.offline,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),
          Expanded(child: body),
        ],
      ),
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
    );
  }
}
