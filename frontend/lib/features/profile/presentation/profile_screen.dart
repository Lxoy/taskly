import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_text_styles.dart';
import 'package:frontend/core/theme/app_spacing.dart';
import 'package:frontend/core/theme/app_radius.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/features/categories/bloc/category_bloc.dart';
import 'package:frontend/features/categories/presentation/categories_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // ── Header ──────────────────────────────────────────────
              Container(
                width: double.infinity,
                color: AppColors.surface,
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Row(
                  children: [
                    Container(
                      width: 56, height: 56,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                      ),
                      child: const Center(
                        child: Text('LB',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w700)),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Lovro Babić',
                            style: AppTextStyles.subtitle
                                .copyWith(color: AppColors.textPrimary)),
                        Text('lovro@example.com',
                            style: AppTextStyles.caption
                                .copyWith(color: AppColors.textSecondary)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // ── Settings group ───────────────────────────────────────
              _SectionHeader('Customisation'),
              _SettingsRow(
                icon: Icons.category_outlined,
                iconColor: AppColors.primary,
                label: 'Categories',
                subtitle: 'Manage activity categories',
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const CategoriesScreen()),
                  );
                  if (context.mounted) {
                    context.read<CategoryBloc>().add(const CategoriesFetchRequested());
                  }
                },
              ),
              const SizedBox(height: AppSpacing.lg),

              _SectionHeader('Account'),
              _SettingsRow(
                icon: Icons.person_outline_rounded,
                iconColor: const Color(0xFF3B82F6),
                label: 'Edit Profile',
                subtitle: 'Change your name and email',
                onTap: () {},
              ),
              _SettingsRow(
                icon: Icons.lock_outline_rounded,
                iconColor: const Color(0xFFF59E0B),
                label: 'Change Password',
                subtitle: 'Update your password',
                onTap: () {},
                isLast: true,
              ),
              const SizedBox(height: AppSpacing.lg),

              _SectionHeader('General'),
              _SettingsRow(
                icon: Icons.notifications_outlined,
                iconColor: const Color(0xFF8B5CF6),
                label: 'Notifications',
                subtitle: 'Manage reminders',
                onTap: () {},
              ),
              _SettingsRow(
                icon: Icons.logout_rounded,
                iconColor: AppColors.danger,
                label: 'Log Out',
                onTap: () {},
                isLast: true,
                showChevron: false,
              ),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.md, 0, AppSpacing.md, AppSpacing.sm),
      child: Text(
        title.toUpperCase(),
        style: AppTextStyles.caption.copyWith(
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String? subtitle;
  final VoidCallback onTap;
  final bool isLast;
  final bool showChevron;

  const _SettingsRow({
    required this.icon,
    required this.iconColor,
    required this.label,
    this.subtitle,
    required this.onTap,
    this.isLast = false,
    this.showChevron = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.fromLTRB(
            AppSpacing.md, 0, AppSpacing.md, isLast ? 0 : 1),
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md, vertical: AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(
            top: isLast == false
                ? Radius.zero
                : Radius.zero,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Icon(icon, color: iconColor, size: 18),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: AppTextStyles.body
                          .copyWith(color: AppColors.textPrimary,
                          fontWeight: FontWeight.w500)),
                  if (subtitle != null)
                    Text(subtitle!,
                        style: AppTextStyles.caption
                            .copyWith(color: AppColors.textSecondary)),
                ],
              ),
            ),
            if (showChevron)
              Icon(Icons.chevron_right_rounded,
                  size: 20, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}