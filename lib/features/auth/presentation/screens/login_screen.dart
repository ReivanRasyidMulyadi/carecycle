import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/widgets/app_button.dart';
import '../providers/auth_provider.dart';

/// Layar Masuk (Login) CareCycle
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await ref.read(authNotifierProvider.notifier).signIn(
          email: _emailController.text,
          password: _passwordController.text,
        );

    if (mounted) {
      if (success) {
        context.goNamed(AppRouter.home);
      } else {
        final error = ref.read(authNotifierProvider).errorMessage;
        if (error != null) {
          context.showSnackBar(error, isError: true);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.lg),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 84,
                      height: 84,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.15),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.asset(
                          'assets/images/logo.png',
                          width: 84,
                          height: 84,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSizes.sm),
                  const Text(
                    AppStrings.appName,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: AppSizes.fontXxl,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: AppSizes.xs),
                  const Text(
                    AppStrings.appTagline,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: AppSizes.fontSm,
                      color: AppColors.textSecondaryLight,
                    ),
                  ),
                  const SizedBox(height: AppSizes.xl),

                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    autofillHints: const [AutofillHints.email],
                    autocorrect: false,
                    decoration: const InputDecoration(
                      labelText: AppStrings.email,
                      prefixIcon: Icon(Icons.email_outlined),
                      hintText: 'nama@email.com',
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Email wajib diisi';
                      }
                      if (!value.trim().isValidEmail) {
                        return 'Format email tidak valid';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSizes.md),

                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    textInputAction: TextInputAction.done,
                    autofillHints: const [AutofillHints.password],
                    onFieldSubmitted: (_) => _handleLogin(),
                    decoration: InputDecoration(
                      labelText: AppStrings.password,
                      prefixIcon: const Icon(Icons.lock_outlined),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Kata sandi wajib diisi';
                      }
                      if (value.length < 6) {
                        return 'Kata sandi minimal 6 karakter';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSizes.lg),

                  AppButton(
                    label: AppStrings.login,
                    isLoading: authState.isLoading,
                    onPressed: _handleLogin,
                  ),
                  const SizedBox(height: AppSizes.lg),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        AppStrings.noAccount,
                        style: TextStyle(color: AppColors.textSecondaryLight),
                      ),
                      TextButton(
                        onPressed: () {
                          context.pushNamed(AppRouter.register);
                        },
                        child: const Text(
                          AppStrings.register,
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSizes.sm),
                  const Divider(color: Colors.black12),
                  const SizedBox(height: AppSizes.sm),

                  // Demo Akses Cepat (Sesuai carecycle-prototype.html)
                  Container(
                    padding: const EdgeInsets.all(AppSizes.md),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'DEMO AKSES CEPAT',
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.8,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: AppSizes.sm),
                        _buildQuickDemoButton(
                          title: '👤 Masuk sebagai Donatur',
                          email: 'donatur@carecycle.id',
                          bgColor: const Color(0xFFECFDF5),
                          borderColor: const Color(0xFFA7F3D0),
                          textColor: AppColors.primary,
                        ),
                        const SizedBox(height: 8),
                        _buildQuickDemoButton(
                          title: '🏢 Masuk sebagai Komunitas',
                          email: 'komunitas@carecycle.id',
                          bgColor: const Color(0xFFEFF6FF),
                          borderColor: const Color(0xFFBFDBFE),
                          textColor: const Color(0xFF2563EB),
                        ),
                        const SizedBox(height: 8),
                        _buildQuickDemoButton(
                          title: '🛡️ Masuk sebagai Admin',
                          email: 'admin@carecycle.id',
                          bgColor: const Color(0xFFFAF5FF),
                          borderColor: const Color(0xFFE9D5FF),
                          textColor: const Color(0xFF7C3AED),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSizes.md),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickDemoButton({
    required String title,
    required String email,
    required Color bgColor,
    required Color borderColor,
    required Color textColor,
  }) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          backgroundColor: bgColor,
          side: BorderSide(color: borderColor),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          ),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        ),
        onPressed: () {
          setState(() {
            _emailController.text = email;
            _passwordController.text = 'secret123';
          });
          _handleLogin();
        },
        child: Text(
          title,
          style: TextStyle(
            color: textColor,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
