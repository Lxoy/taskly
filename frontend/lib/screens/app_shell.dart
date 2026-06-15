import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/di/injection.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_spacing.dart';
import 'package:frontend/features/categories/bloc/category_bloc.dart';
import 'package:frontend/features/home/presentation/home_screen.dart';
import 'package:frontend/features/calendar/presentation/calendar_screen.dart';
import 'package:frontend/features/statistics/presentation/statistics_screen.dart';
import 'package:frontend/features/profile/presentation/profile_screen.dart';
import 'package:frontend/features/entry/presentation/add_entry_sheet.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CategoryBloc>(
      create: (_) => sl<CategoryBloc>()..add(const CategoriesFetchRequested()),
      child: _AppShellContent(),
    );
  }
}

class _AppShellContent extends StatefulWidget {
  @override
  State<_AppShellContent> createState() => _AppShellContentState();
}

class _AppShellContentState extends State<_AppShellContent> {
  int _currentIndex = 0;

  static const List<Widget> _pages = [
    HomeScreen(),
    CalendarScreen(),
    StatisticsScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      floatingActionButton: FloatingActionButton(
        onPressed: () => showAddEntrySheet(context),
        backgroundColor: AppColors.primary,
        elevation: 2,
        shape: const CircleBorder(),
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _BottomNavBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
      ),
    );
  }
}

class _BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _BottomNavBar({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      color: AppColors.surface,
      elevation: 8,
      shadowColor: Colors.black12,
      shape: const CircularNotchedRectangle(),
      notchMargin: 8,
      child: SizedBox(
        height: 60,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _NavItem(icon: Icons.home_outlined,           activeIcon: Icons.home_rounded,            label: 'Home',    index: 0, currentIndex: currentIndex, onTap: onTap),
            _NavItem(icon: Icons.calendar_today_outlined, activeIcon: Icons.calendar_today_rounded,  label: 'Calendar',   index: 1, currentIndex: currentIndex, onTap: onTap),
            const SizedBox(width: 56), // FAB space
            _NavItem(icon: Icons.bar_chart_outlined,      activeIcon: Icons.bar_chart_rounded,       label: 'Statistics', index: 2, currentIndex: currentIndex, onTap: onTap),
            _NavItem(icon: Icons.person_outline_rounded,  activeIcon: Icons.person_rounded,          label: 'Profile',     index: 3, currentIndex: currentIndex, onTap: onTap),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final int index;
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.index,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = index == currentIndex;
    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 64,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isActive ? activeIcon : icon,
              color: isActive ? AppColors.primary : AppColors.textSecondary,
              size: 24,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                color: isActive ? AppColors.primary : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}