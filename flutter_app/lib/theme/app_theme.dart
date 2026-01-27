import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'colors.dart';

/// Vita 应用主题配置
class AppTheme {
  AppTheme._();

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.backgroundDark,
      primaryColor: AppColors.primary,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        secondary: AppColors.brandSage,
        tertiary: AppColors.brandTeal,
        surface: AppColors.surfaceContainer,
        onSurface: AppColors.onSurface,
        onSurfaceVariant: AppColors.onSurfaceVariant,
      ),
      // fontFamily: 'Newsreader', // 需要添加字体文件
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w300,
          color: AppColors.onSurface,
        ),
        displayMedium: TextStyle(
          fontSize: 26,
          fontStyle: FontStyle.italic,
          color: AppColors.onSurface,
        ),
        headlineLarge: TextStyle(
          fontSize: 24,
          fontStyle: FontStyle.italic,
          color: AppColors.brandSage,
        ),
        headlineMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
        titleLarge: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w500,
          color: AppColors.onSurface,
        ),
        titleMedium: TextStyle(
          fontSize: 15,
          color: AppColors.white80,
        ),
        bodyLarge: TextStyle(
          fontSize: 17,
          color: AppColors.onSurface,
        ),
        bodyMedium: TextStyle(
          fontSize: 15,
          color: AppColors.white80,
        ),
        bodySmall: TextStyle(
          fontSize: 14,
          color: AppColors.onSurfaceVariant,
        ),
        labelLarge: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          letterSpacing: 2,
          color: AppColors.white40,
        ),
        labelSmall: TextStyle(
          fontSize: 10,
          color: AppColors.white40,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surfaceContainer,
        selectedItemColor: AppColors.brandSage,
        unselectedItemColor: AppColors.white40,
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: true,
        showUnselectedLabels: true,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.all(Colors.white),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primary;
          }
          return AppColors.white20;
        }),
      ),
    );
  }
}
