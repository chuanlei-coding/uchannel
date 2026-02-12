import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'colors.dart';

/// Vita 应用主题配置 - 柔和版
class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.creamBg,
      primaryColor: AppColors.brandSage,
      colorScheme: const ColorScheme.light(
        primary: AppColors.brandSage,
        secondary: AppColors.terracotta,
        tertiary: AppColors.softGold,
        surface: AppColors.softIvory,
        onSurface: AppColors.darkGrey,
        onSurfaceVariant: AppColors.softGrey,
      ),
      // fontFamily: 'Newsreader', // 需要添加字体文件
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 48,
          fontWeight: FontWeight.w300,
          color: AppColors.darkGrey,
        ),
        displayMedium: TextStyle(
          fontSize: 26,
          fontStyle: FontStyle.italic,
          color: AppColors.darkGrey,
        ),
        headlineLarge: TextStyle(
          fontSize: 24,
          fontStyle: FontStyle.italic,
          color: AppColors.brandSage,
        ),
        headlineMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w500,
          color: AppColors.darkGrey,
        ),
        titleLarge: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w500,
          color: AppColors.darkGrey,
        ),
        titleMedium: TextStyle(
          fontSize: 15,
          color: AppColors.darkGrey,
        ),
        bodyLarge: TextStyle(
          fontSize: 17,
          color: AppColors.darkGrey,
        ),
        bodyMedium: TextStyle(
          fontSize: 15,
          color: AppColors.darkGrey,
        ),
        bodySmall: TextStyle(
          fontSize: 14,
          color: AppColors.softGrey,
        ),
        labelLarge: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          letterSpacing: 2,
          color: AppColors.softGrey,
        ),
        labelSmall: TextStyle(
          fontSize: 10,
          color: AppColors.softGrey,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.creamBg,
        selectedItemColor: AppColors.brandSage,
        unselectedItemColor: AppColors.softGrey,
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: true,
        showUnselectedLabels: true,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.all(Colors.white),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.brandSage;
          }
          return AppColors.softGrey.withValues(alpha: 0.3);
        }),
      ),
      cardTheme: CardThemeData(
        color: AppColors.softIvory,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: AppColors.borderLight,
            width: 1,
          ),
        ),
      ),
    );
  }

  /// 暗色主题
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF1A1A1A),
      primaryColor: AppColors.brandSage,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.brandSage,
        secondary: AppColors.terracotta,
        tertiary: AppColors.softGold,
        surface: Color(0xFF2A2A2A),
        onSurface: Color(0xFFE0E0E0),
        onSurfaceVariant: Color(0xFFB0B0B0),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 48,
          fontWeight: FontWeight.w300,
          color: Color(0xFFE0E0E0),
        ),
        displayMedium: TextStyle(
          fontSize: 26,
          fontStyle: FontStyle.italic,
          color: Color(0xFFE0E0E0),
        ),
        headlineLarge: TextStyle(
          fontSize: 24,
          fontStyle: FontStyle.italic,
          color: AppColors.brandSage,
        ),
        headlineMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w500,
          color: Color(0xFFE0E0E0),
        ),
        titleLarge: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w500,
          color: Color(0xFFE0E0E0),
        ),
        titleMedium: TextStyle(
          fontSize: 15,
          color: Color(0xFFE0E0E0),
        ),
        bodyLarge: TextStyle(
          fontSize: 17,
          color: Color(0xFFE0E0E0),
        ),
        bodyMedium: TextStyle(
          fontSize: 15,
          color: Color(0xFFE0E0E0),
        ),
        bodySmall: TextStyle(
          fontSize: 14,
          color: Color(0xFFB0B0B0),
        ),
        labelLarge: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          letterSpacing: 2,
          color: Color(0xFFB0B0B0),
        ),
        labelSmall: TextStyle(
          fontSize: 10,
          color: Color(0xFFB0B0B0),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xFF1A1A1A),
        selectedItemColor: AppColors.brandSage,
        unselectedItemColor: Color(0xFFB0B0B0),
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: true,
        showUnselectedLabels: true,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.all(Colors.white),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.brandSage;
          }
          return Colors.grey.withValues(alpha: 0.3);
        }),
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFF2A2A2A),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: Colors.white.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
      ),
    );
  }
}
