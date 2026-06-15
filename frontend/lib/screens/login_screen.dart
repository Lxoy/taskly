import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_text_styles.dart';
import 'package:frontend/core/theme/app_spacing.dart';
import 'package:frontend/core/theme/app_radius.dart';
import 'package:frontend/features/auth/bloc/auth_bloc.dart';
import 'register_screen.dart';
import 'app_shell.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController    = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword     = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onLoginPressed() {
    final email    = _emailController.text.trim();
    final password = _passwordController.text;
    if (email.isEmpty || password.isEmpty) return;
    context.read<AuthBloc>().add(
          LoginSubmitted(email: email, password: password),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const AppShell()),
            (route) => false,
          );
        }
        if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.danger,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              margin: const EdgeInsets.fromLTRB(
                AppSpacing.md, 0, AppSpacing.md, AppSpacing.md,
              ),
            ),
          );
        }
      },
      child: Scaffold(
        // Koristimo AppTheme.light scaffoldBackgroundColor = AppColors.background
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                // ── Hero ──────────────────────────────────────────────
                _HeroSection(),
                // ── Form ──────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg, AppSpacing.xxl, AppSpacing.lg, AppSpacing.lg,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Dobrodošao nazad', style: AppTextStyles.title.copyWith(color: AppColors.textPrimary)),
                      const SizedBox(height: AppSpacing.xs),
                      Text('Prijavi se na svoj račun', style: AppTextStyles.body.copyWith(color: AppColors.textSecondary)),
                      const SizedBox(height: AppSpacing.xl),

                      _buildLabel('Email adresa'),
                      const SizedBox(height: AppSpacing.sm),
                      _buildTextField(
                        controller: _emailController,
                        hint: 'ime@primjer.com',
                        icon: Icons.mail_outline_rounded,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: AppSpacing.md),

                      _buildLabel('Lozinka'),
                      const SizedBox(height: AppSpacing.sm),
                      _buildTextField(
                        controller: _passwordController,
                        hint: '••••••••',
                        icon: Icons.lock_outline_rounded,
                        obscure: _obscurePassword,
                        suffixIcon: GestureDetector(
                          onTap: () => setState(() => _obscurePassword = !_obscurePassword),
                          child: Icon(
                            _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                            color: AppColors.textSecondary,
                            size: 20,
                          ),
                        ),
                      ),

                      Align(
                        alignment: Alignment.centerRight,
                        child: Padding(
                          padding: const EdgeInsets.only(top: AppSpacing.sm),
                          child: Text(
                            'Zaboravljena lozinka?',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),

                      // Login button
                      BlocBuilder<AuthBloc, AuthState>(
                        builder: (context, state) {
                          final isLoading = state is AuthLoading;
                          return GestureDetector(
                            onTap: isLoading ? null : _onLoginPressed,
                            child: _PrimaryButton(label: 'Prijavi se', isLoading: isLoading),
                          );
                        },
                      ),
                      const SizedBox(height: AppSpacing.md),

                      _buildDivider(),
                      const SizedBox(height: AppSpacing.md),

                      _buildSocialButton(
                        icon: Icons.g_mobiledata_rounded,
                        label: 'Nastavi s Googleom',
                      ),
                      const SizedBox(height: AppSpacing.xl),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Nemaš račun? ", style: AppTextStyles.body.copyWith(color: AppColors.textSecondary)),
                          GestureDetector(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const RegisterScreen()),
                            ),
                            child: Text(
                              'Registriraj se',
                              style: AppTextStyles.body.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.lg),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) => Text(
        text,
        style: AppTextStyles.caption.copyWith(
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w500,
        ),
      );

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscure = false,
    TextInputType keyboardType = TextInputType.text,
    Widget? suffixIcon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        keyboardType: keyboardType,
        style: AppTextStyles.body.copyWith(color: AppColors.textPrimary),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: AppTextStyles.body.copyWith(color: AppColors.textSecondary.withOpacity(0.5)),
          prefixIcon: Icon(icon, color: AppColors.textSecondary, size: 20),
          suffixIcon: suffixIcon,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.md),
        ),
      ),
    );
  }

  Widget _buildDivider() => Row(
        children: [
          Expanded(child: Divider(color: AppColors.textSecondary.withOpacity(0.2), thickness: 1)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
            child: Text('ili', style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
          ),
          Expanded(child: Divider(color: AppColors.textSecondary.withOpacity(0.2), thickness: 1)),
        ],
      );

  Widget _buildSocialButton({required IconData icon, required String label}) {
    return Container(
      width: double.infinity,
      height: 52,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: AppColors.textSecondary, size: 26),
          const SizedBox(width: AppSpacing.sm),
          Text(label, style: AppTextStyles.body.copyWith(color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

// ── Hero section ──────────────────────────────────────────────────────────────

class _HeroSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 220,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(AppRadius.xl),
          bottomRight: Radius.circular(AppRadius.xl),
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: -20, right: -20,
            child: Container(
              width: 140, height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.07),
              ),
            ),
          ),
          Positioned(
            bottom: -30, left: -10,
            child: Container(
              width: 110, height: 110,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.05),
              ),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 64, height: 64,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
                child: const Icon(Icons.account_balance_wallet_rounded, color: Colors.white, size: 32),
              ),
              const SizedBox(height: AppSpacing.md),
              const Text('ObvezaTrack', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w700, letterSpacing: -0.3)),
              const SizedBox(height: 4),
              Text('Upravljaj svojim troškovima', style: TextStyle(color: Colors.white.withOpacity(0.65), fontSize: 13)),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Primary button ────────────────────────────────────────────────────────────

class _PrimaryButton extends StatelessWidget {
  final String label;
  final bool isLoading;

  const _PrimaryButton({required this.label, this.isLoading = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 52,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(AppRadius.md),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: isLoading
            ? const SizedBox(
                width: 22, height: 22,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
              )
            : Text(label, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600, letterSpacing: 0.2)),
      ),
    );
  }
}