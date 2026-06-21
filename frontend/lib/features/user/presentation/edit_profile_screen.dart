import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/di/injection.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_text_styles.dart';
import 'package:frontend/core/theme/app_spacing.dart';
import 'package:frontend/core/theme/app_radius.dart';
import 'package:frontend/data/models/user_models.dart';
import 'package:frontend/features/user/bloc/user_bloc.dart';

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<UserBloc>()..add(const UserFetchRequested()),
      child: const _EditProfileView(),
    );
  }
}

class _EditProfileView extends StatefulWidget {
  const _EditProfileView();

  @override
  State<_EditProfileView> createState() => _EditProfileViewState();
}

class _EditProfileViewState extends State<_EditProfileView> {
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl  = TextEditingController();
  final _usernameCtrl  = TextEditingController();
  final _emailCtrl     = TextEditingController();
  final _phoneCtrl     = TextEditingController();

  bool _populated = false;

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _usernameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  void _populate(GetUserDto user) {
    if (_populated) return;
    _firstNameCtrl.text = user.firstName ?? '';
    _lastNameCtrl.text  = user.lastName  ?? '';
    _usernameCtrl.text  = user.username  ?? '';
    _emailCtrl.text     = user.email     ?? '';
    _phoneCtrl.text     = user.phoneNumber ?? '';
    _populated = true;
  }

  void _onSave() {
    context.read<UserBloc>().add(
          UserUpdateRequested(
            UpdateUserRequest(
              firstName:   _firstNameCtrl.text.trim().isEmpty ? null : _firstNameCtrl.text.trim(),
              lastName:    _lastNameCtrl.text.trim().isEmpty  ? null : _lastNameCtrl.text.trim(),
              username:    _usernameCtrl.text.trim().isEmpty  ? null : _usernameCtrl.text.trim(),
              email:       _emailCtrl.text.trim().isEmpty     ? null : _emailCtrl.text.trim(),
              phoneNumber: _phoneCtrl.text.trim().isEmpty     ? null : _phoneCtrl.text.trim(),
            ),
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<UserBloc, UserState>(
      listener: (context, state) {
        if (state is UserLoaded)   _populate(state.user);
        if (state is UserUpdated)  _populate(state.user);

        if (state is UserUpdated) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Profile updated!'),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.sm)),
            ),
          );
          Navigator.pop(context);
        }
        if (state is UserError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.danger,
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.sm)),
            ),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is UserLoading;

        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: Column(
              children: [
                // Top bar
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                      AppSpacing.md, AppSpacing.md, AppSpacing.md, 0),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 40, height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius:
                                BorderRadius.circular(AppRadius.sm),
                            border: Border.all(
                                color: const Color(0xFFE5E7EB)),
                          ),
                          child: const Icon(
                              Icons.arrow_back_ios_new_rounded,
                              size: 16,
                              color: AppColors.textPrimary),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Text('Edit Profile',
                          style: AppTextStyles.subtitle
                              .copyWith(color: AppColors.textPrimary)),
                    ],
                  ),
                ),

                // Content
                Expanded(
                  child: state is UserInitial || state is UserLoading && !_populated
                      ? const Center(
                          child: CircularProgressIndicator(
                              color: AppColors.primary))
                      : SingleChildScrollView(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: AppSpacing.lg),

                              // Avatar
                              Center(
                                child: Container(
                                  width: 72, height: 72,
                                  decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    borderRadius: BorderRadius.circular(
                                        AppRadius.lg),
                                  ),
                                  child: Center(
                                    child: Text(
                                      _initials(),
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 24,
                                          fontWeight: FontWeight.w700),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: AppSpacing.xxl),

                              _buildField('First Name',   _firstNameCtrl, Icons.person_outline_rounded,  hint: 'John'),
                              const SizedBox(height: AppSpacing.md),
                              _buildField('Last Name',    _lastNameCtrl,  Icons.person_outline_rounded,  hint: 'Doe'),
                              const SizedBox(height: AppSpacing.md),
                              _buildField('Username',     _usernameCtrl,  Icons.alternate_email_rounded, hint: 'johndoe'),
                              const SizedBox(height: AppSpacing.md),
                              _buildField('Email',        _emailCtrl,     Icons.mail_outline_rounded,    hint: 'john@example.com', keyboard: TextInputType.emailAddress),
                              const SizedBox(height: AppSpacing.md),
                              _buildField('Phone Number', _phoneCtrl,     Icons.phone_outlined,          hint: '+385 91 234 5678', keyboard: TextInputType.phone),
                              const SizedBox(height: AppSpacing.xxl),

                              // Save button
                              GestureDetector(
                                onTap: isLoading ? null : _onSave,
                                child: Container(
                                  width: double.infinity,
                                  height: 52,
                                  decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    borderRadius: BorderRadius.circular(
                                        AppRadius.md),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.primary
                                            .withOpacity(0.3),
                                        blurRadius: 12,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: isLoading
                                        ? const SizedBox(
                                            width: 22, height: 22,
                                            child:
                                                CircularProgressIndicator(
                                                    color: Colors.white,
                                                    strokeWidth: 2.5))
                                        : Text('Save Changes',
                                            style: AppTextStyles.body
                                                .copyWith(
                                                    color: Colors.white,
                                                    fontWeight:
                                                        FontWeight.w600)),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _initials() {
    final first = _firstNameCtrl.text.trim();
    final last  = _lastNameCtrl.text.trim();
    if (first.isNotEmpty && last.isNotEmpty) {
      return '${first[0]}${last[0]}'.toUpperCase();
    }
    final user = _usernameCtrl.text.trim();
    if (user.isNotEmpty) return user[0].toUpperCase();
    return '?';
  }

  Widget _buildField(
    String label,
    TextEditingController ctrl,
    IconData icon, {
    String hint = '',
    TextInputType keyboard = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: AppTextStyles.caption.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600)),
        const SizedBox(height: AppSpacing.sm),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: TextField(
            controller: ctrl,
            keyboardType: keyboard,
            style: AppTextStyles.body
                .copyWith(color: AppColors.textPrimary),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: AppTextStyles.body.copyWith(
                  color: AppColors.textSecondary.withOpacity(0.5)),
              prefixIcon: Icon(icon,
                  size: 18, color: AppColors.textSecondary),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md, vertical: AppSpacing.md),
            ),
          ),
        ),
      ],
    );
  }
}