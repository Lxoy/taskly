import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_colors.dart';

class AppTheme {
  static ThemeData light = ThemeData(
    useMaterial3: true,

    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
    ),

    scaffoldBackgroundColor:
        AppColors.background,

    cardTheme: const CardThemeData(
      elevation: 0,
    ),
  );
}