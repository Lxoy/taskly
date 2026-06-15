import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_text_styles.dart';
import 'package:frontend/core/theme/app_spacing.dart';
import 'package:frontend/core/theme/app_radius.dart';
import 'package:frontend/features/auth/bloc/auth_bloc.dart';
import 'app_shell.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController     = TextEditingController();
  final _emailController    = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController  = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirm  = true;
  bool _acceptTerms     = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _onRegisterPressed() {
    final username = _nameController.text.trim();
    final email    = _emailController.text.trim();
    final password = _passwordController.text;
    final confirm  = _confirmController.text;

    if (username.isEmpty || email.isEmpty || password.isEmpty) return;
    if (password != confirm) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Lozinke se ne podudaraju.'),
          backgroundColor: AppColors.warning,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.sm)),
          margin: const EdgeInsets.fromLTRB(AppSpacing.md, 0, AppSpacing.md, AppSpacing.md),
        ),
      );
      return;
    }
    if (!_acceptTerms) return;

    context.read<AuthBloc>().add(
          RegisterSubmitted(email: email, username: username, password: password),
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
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.sm)),
              margin: const EdgeInsets.fromLTRB(AppSpacing.md, 0, AppSpacing.md, AppSpacing.md),
            ),
          );
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                // ── Top bar ─────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.md, AppSpacing.md, 0),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 42, height: 42,
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(AppRadius.sm),
                            border: Border.all(color: const Color(0xFFE5E7EB)),
                          ),
                          child: Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary, size: 18),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Text('Novi račun', style: AppTextStyles.subtitle.copyWith(color: AppColors.textPrimary)),
                    ],
                  ),
                ),

                // ── Avatar icon ─────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 96, height: 96,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primary.withOpacity(0.08),
                        ),
                      ),
                      Container(
                        width: 72, height: 72,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primary.withOpacity(0.12),
                        ),
                      ),
                      Container(
                        width: 56, height: 56,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.3),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.person_add_alt_1_rounded, color: Colors.white, size: 26),
                      ),
                    ],
                  ),
                ),

                // ── Form ────────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(child: Text('Kreiraj račun', style: AppTextStyles.title.copyWith(color: AppColors.textPrimary))),
                      const SizedBox(height: AppSpacing.xs),
                      Center(child: Text('Počni pratiti svoje obveze danas', style: AppTextStyles.body.copyWith(color: AppColors.textSecondary))),
                      const SizedBox(height: AppSpacing.xl),

                      _buildLabel('Ime i prezime'),
                      const SizedBox(height: AppSpacing.sm),
                      _buildTextField(controller: _nameController, hint: 'Lovro Babić', icon: Icons.person_outline_rounded),
                      const SizedBox(height: AppSpacing.md),

                      _buildLabel('Email adresa'),
                      const SizedBox(height: AppSpacing.sm),
                      _buildTextField(controller: _emailController, hint: 'ime@primjer.com', icon: Icons.mail_outline_rounded, keyboardType: TextInputType.emailAddress),
                      const SizedBox(height: AppSpacing.md),

                      _buildLabel('Lozinka'),
                      const SizedBox(height: AppSpacing.sm),
                      _buildTextField(
                        controller: _passwordController,
                        hint: 'Min. 8 znakova',
                        icon: Icons.lock_outline_rounded,
                        obscure: _obscurePassword,
                        suffixIcon: GestureDetector(
                          onTap: () => setState(() => _obscurePassword = !_obscurePassword),
                          child: Icon(_obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: AppColors.textSecondary, size: 20),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      _buildPasswordStrength(),
                      const SizedBox(height: AppSpacing.md),

                      _buildLabel('Potvrdi lozinku'),
                      const SizedBox(height: AppSpacing.sm),
                      _buildTextField(
                        controller: _confirmController,
                        hint: 'Ponovi lozinku',
                        icon: Icons.lock_outline_rounded,
                        obscure: _obscureConfirm,
                        suffixIcon: GestureDetector(
                          onTap: () => setState(() => _obscureConfirm = !_obscureConfirm),
                          child: Icon(_obscureConfirm ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: AppColors.textSecondary, size: 20),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),

                      // Terms checkbox
                      GestureDetector(
                        onTap: () => setState(() => _acceptTerms = !_acceptTerms),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              width: 22, height: 22,
                              decoration: BoxDecoration(
                                color: _acceptTerms ? AppColors.primary : Colors.transparent,
                                borderRadius: BorderRadius.circular(AppRadius.sm / 2),
                                border: Border.all(
                                  color: _acceptTerms ? AppColors.primary : const Color(0xFFD1D5DB),
                                  width: 1.5,
                                ),
                              ),
                              child: _acceptTerms ? const Icon(Icons.check_rounded, color: Colors.white, size: 14) : null,
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: RichText(
                                text: TextSpan(
                                  style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary, height: 1.5),
                                  children: [
                                    const TextSpan(text: 'Prihvaćam '),
                                    TextSpan(text: 'Uvjete korištenja', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w500)),
                                    const TextSpan(text: ' i '),
                                    TextSpan(text: 'Politiku privatnosti', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w500)),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),

                      // Register button
                      BlocBuilder<AuthBloc, AuthState>(
                        builder: (context, state) {
                          final isLoading = state is AuthLoading;
                          return GestureDetector(
                            onTap: isLoading ? null : _onRegisterPressed,
                            child: _PrimaryButton(label: 'Registriraj se', isLoading: isLoading),
                          );
                        },
                      ),
                      const SizedBox(height: AppSpacing.xl),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Već imaš račun? ', style: AppTextStyles.body.copyWith(color: AppColors.textSecondary)),
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Text('Prijavi se', style: AppTextStyles.body.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600)),
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

  Widget _buildPasswordStrength() {
    return Row(
      children: List.generate(4, (i) => Expanded(
        child: Container(
          margin: EdgeInsets.only(right: i < 3 ? 4 : 0),
          height: 3,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color: i == 0 ? AppColors.primary : const Color(0xFFE5E7EB),
          ),
        ),
      )),
    );
  }

  Widget _buildLabel(String text) => Text(
        text,
        style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary, fontWeight: FontWeight.w500),
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
}

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
            ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
            : Text(label, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600, letterSpacing: 0.2)),
      ),
    );
  }
}