import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/di/injection.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_text_styles.dart';
import 'package:frontend/core/theme/app_spacing.dart';
import 'package:frontend/core/theme/app_radius.dart';
import 'package:frontend/core/utils/icon_registry.dart';
import 'package:frontend/data/models/category_models.dart';
import 'package:frontend/data/models/home_models.dart';
import 'package:frontend/features/categories/bloc/category_bloc.dart';
import 'package:frontend/features/home/bloc/home_bloc.dart';
import 'package:frontend/features/home/presentation/home_skeleton.dart';
import 'package:frontend/features/entry/presentation/entry_details_sheet.dart';
import 'package:frontend/features/user/bloc/user_bloc.dart';
import 'package:frontend/core/utils/entry_refresh_bus.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final HomeBloc _homeBloc;
  late final CategoryBloc _categoryBloc;
  late final UserBloc _userBloc;

  @override
  void initState() {
    super.initState();
    _homeBloc = sl<HomeBloc>()..add(const HomeFetchRequested());
    _categoryBloc = sl<CategoryBloc>()..add(const CategoriesFetchRequested());
    _userBloc = sl<UserBloc>()..add(const UserFetchRequested());
    entryRefreshBus.addListener(_refreshHome);
  }

  @override
  void dispose() {
    entryRefreshBus.removeListener(_refreshHome);
    _homeBloc.close();
    _categoryBloc.close();
    _userBloc.close();
    super.dispose();
  }

  void _refreshHome() {
    _homeBloc.add(const HomeFetchRequested());
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _homeBloc),
        BlocProvider.value(value: _categoryBloc),
        BlocProvider.value(value: _userBloc),
      ],
      child: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          return switch (state) {
            HomeLoading() || HomeInitial() => const HomeSkeletonScreen(),
            HomeLoaded(:final data) => _HomeBody(data: data),
            HomeError(:final message) => _HomeErrorView(
                message: message,
                onRetry: _refreshHome,
              ),
            _ => const HomeSkeletonScreen(),
          };
        },
      ),
    );
  }
}

// ── Body ──────────────────────────────────────────────────────────────────────

class _HomeBody extends StatelessWidget {
  final HomeData data;
  const _HomeBody({required this.data});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () async {
          context.read<HomeBloc>().add(const HomeFetchRequested());
          await Future<void>.delayed(const Duration(milliseconds: 300));
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
          SliverToBoxAdapter(child: _HomeHeader(data: data)),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.lg,
                AppSpacing.md,
                AppSpacing.sm,
              ),
              child: Text(
                'THIS MONTH',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.8,
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(child: _MonthSummaryRow(data: data)),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.lg,
                AppSpacing.md,
                AppSpacing.sm,
              ),
              child: Text(
                'UPCOMING',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.8,
                ),
              ),
            ),
          ),

          data.scheduleEntries.isEmpty
              ? SliverToBoxAdapter(child: _EmptyObligations())
              : SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final entry = data.scheduleEntries[index];
                      final isLast = index == data.scheduleEntries.length - 1;

                      return _ObligationItem(
                        entry: entry,
                        isLast: isLast,
                      );
                    },
                    childCount: data.scheduleEntries.length,
                  ),
                ),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }
}

// ── Header ────────────────────────────────────────────────────────────────────

class _HomeHeader extends StatelessWidget {
  final HomeData data;
  const _HomeHeader({required this.data});

  String _getGreetingName(UserState state) {
    if (state is UserLoaded) {
      final firstName = state.user.firstName?.trim();
      if (firstName != null && firstName.isNotEmpty) return firstName;

      final username = state.user.username?.trim();
      if (username != null && username.isNotEmpty) return username;
    }

    if (state is UserUpdated) {
      final firstName = state.user.firstName?.trim();
      if (firstName != null && firstName.isNotEmpty) return firstName;

      final username = state.user.username?.trim();
      if (username != null && username.isNotEmpty) return username;
    }

    return 'User';
  }

  String _getInitials(UserState state) {
    if (state is UserLoaded) {
      return _initialsFromUser(state.user.firstName, state.user.lastName, state.user.username);
    }

    if (state is UserUpdated) {
      return _initialsFromUser(state.user.firstName, state.user.lastName, state.user.username);
    }

    return 'U';
  }

  String _initialsFromUser(String? firstName, String? lastName, String? username) {
    final first = firstName?.trim();
    final last = lastName?.trim();
    final user = username?.trim();

    if (first != null && first.isNotEmpty && last != null && last.isNotEmpty) {
      return '${first[0]}${last[0]}'.toUpperCase();
    }

    if (first != null && first.isNotEmpty) {
      return first[0].toUpperCase();
    }

    if (user != null && user.isNotEmpty) {
      return user[0].toUpperCase();
    }

    return 'U';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.md,
            AppSpacing.md,
            AppSpacing.xl,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BlocBuilder<UserBloc, UserState>(
                builder: (context, userState) {
                  final name = _getGreetingName(userState);
                  final initials = _getInitials(userState);

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hello,',
                            style: AppTextStyles.body.copyWith(
                              color: Colors.white.withOpacity(0.7),
                            ),
                          ),
                          Row(
                            children: [
                              Text(
                                name,
                                style: AppTextStyles.subtitle.copyWith(
                                  color: Colors.white,
                                  fontSize: 20,
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Text(
                                '👋',
                                style: TextStyle(fontSize: 18),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                        ),
                        child: Center(
                          child: Text(
                            initials,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: AppSpacing.lg),

              Text(
                '${data.totalMoneySpentThisMonth.toStringAsFixed(2)} €',
                style: AppTextStyles.amount.copyWith(color: Colors.white),
              ),

              const SizedBox(height: 4),

              Text(
                'Total spending — ${data.month} ${data.year}',
                style: AppTextStyles.caption.copyWith(
                  color: Colors.white.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Month summary ─────────────────────────────────────────────────────────────

class _MonthSummaryRow extends StatelessWidget {
  final HomeData data;
  const _MonthSummaryRow({required this.data});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Row(
        children: [
          Expanded(
            child: _SummaryCard(
              label: 'Completed',
              value: '${data.totalEntriesFinishedThisMonth}',
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: _SummaryCard(
              label: 'Due soon',
              value: '${data.totalEntriesScheduledForThisMonth}',
              valueColor: AppColors.warning,
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _SummaryCard({
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            value,
            style: AppTextStyles.subtitle.copyWith(
              color: valueColor ?? AppColors.textPrimary,
              fontSize: 22,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Obligation item ───────────────────────────────────────────────────────────

class _ObligationItem extends StatelessWidget {
  final HomeScheduleEntry entry;
  final bool isLast;

  const _ObligationItem({
    required this.entry,
    this.isLast = false,
  });

  Color get _daysColor {
    if (entry.daysUntilDue <= 3) return AppColors.danger;
    if (entry.daysUntilDue <= 7) return AppColors.warning;
    return AppColors.textSecondary;
  }

  String get _daysLabel {
    if (entry.daysUntilDue == 0) return 'today';
    if (entry.daysUntilDue == 1) return 'tomorrow';
    return 'za ${entry.daysUntilDue} dana';
  }

  String get _dueDateLabel {
    final d = entry.dueDate;
    if (d == null) return '';
    return '${d.day}. ${d.month}.';
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CategoryBloc, CategoryState>(
      builder: (context, categoryState) {
        final category = _findCategory(categoryState, entry.categoryId);
        final iconColor = category != null
            ? _hexToColor(category.color)
            : AppColors.primary;
        final iconData = category != null
            ? IconRegistry.get(category.icon)
            : Icons.receipt_long_rounded;

        return GestureDetector(
          onTap: () => showOccurrenceDetailsSheet(
            context,
            entryId: entry.entryId,
            anomalyId: entry.anomalyId,
            occurrenceDate: entry.dueDate ?? DateTime.now(),
            onChanged: () {
              context.read<HomeBloc>().add(const HomeFetchRequested());
            },
          ),
          child: Container(
            margin: EdgeInsets.fromLTRB(
              AppSpacing.md,
              0,
              AppSpacing.md,
              isLast ? 0 : AppSpacing.sm,
            ),
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.md),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Icon(iconData, color: iconColor, size: 22),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.title,
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          if (_dueDateLabel.isNotEmpty)
                            Text(
                              _dueDateLabel,
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 1,
                            ),
                            decoration: BoxDecoration(
                              color: _daysColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              _daysLabel,
                              style: AppTextStyles.caption.copyWith(
                                color: _daysColor,
                                fontWeight: FontWeight.w600,
                                fontSize: 10,
                              ),
                            ),
                          ),
                          if (category != null) ...[
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                category.name,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.textSecondary,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                Text(
                  entry.amount != null
                      ? '${entry.amount!.toStringAsFixed(2)} €'
                      : '—',
                  style: AppTextStyles.body.copyWith(
                    color: entry.daysUntilDue <= 3 && entry.amount != null
                        ? AppColors.danger
                        : AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

Category? _findCategory(CategoryState state, int? categoryId) {
  if (categoryId == null) return null;

  final categories = switch (state) {
    CategoryLoaded(:final categories) => categories,
    CategoryMutating(:final categories) => categories,
    CategoryError(:final categories) => categories,
    _ => <Category>[],
  };

  for (final category in categories) {
    if (category.id == categoryId) return category;
  }

  return null;
}

Color _hexToColor(String hex) {
  final normalized = hex.replaceAll('#', '');
  return Color(int.parse('FF$normalized', radix: 16));
}

// ── Empty state ───────────────────────────────────────────────────────────────

class _EmptyObligations extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.xl,
        horizontal: AppSpacing.md,
      ),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.check_circle_outline_rounded,
              size: 48,
              color: AppColors.textSecondary.withOpacity(0.3),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'No upcoming activities',
              style: AppTextStyles.body.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Error view ────────────────────────────────────────────────────────────────

class _HomeErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _HomeErrorView({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.wifi_off_rounded,
                size: 56,
                color: AppColors.textSecondary.withOpacity(0.4),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                message,
                textAlign: TextAlign.center,
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              GestureDetector(
                onTap: onRetry,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Text(
                    'Pokušaj ponovno',
                    style: AppTextStyles.body.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}