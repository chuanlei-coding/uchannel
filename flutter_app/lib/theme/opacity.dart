import 'package:flutter/material.dart';
import 'colors.dart';

/// 应用透明度常量
///
/// 统一管理应用中的透明度值，保持一致性
class AppOpacity {
  AppOpacity._();

  // 透明度值 (0.0 - 1.0)
  static const double invisible = 0.0;
  static const double ultraLow = 0.03;
  static const double veryLow = 0.05;
  static const double low = 0.1;
  static const double mediumLow = 0.2;
  static const double medium = 0.3;
  static const double mediumHigh = 0.4;
  static const double high = 0.5;
  static const double veryHigh = 0.6;
  static const double ultraHigh = 0.8;
  static const double visible = 1.0;

  // 常用透明度组合
  /// 背景遮罩透明度
  static const double barrier = 0.8;

  /// 禁用状态透明度
  static const double disabled = 0.5;

  /// 阴影透明度
  static const double shadow = 0.08;

  /// 边框透明度
  static const double border = 0.1;

  /// 覆盖层透明度
  static const double overlay = 0.05;
}

/// 颜色透明度扩展
extension ColorOpacityExtension on Color {
  /// 常用透明度快捷方法
  Color withUltraLowOpacity() => withValues(alpha: AppOpacity.veryLow);
  Color withVeryLowOpacity() => withValues(alpha: AppOpacity.veryLow);
  Color withLowOpacity() => withValues(alpha: AppOpacity.low);
  Color withMediumOpacity() => withValues(alpha: AppOpacity.medium);
  Color withHighOpacity() => withValues(alpha: AppOpacity.high);
  Color withDisabledOpacity() => withValues(alpha: AppOpacity.disabled);
  Color withBarrierOpacity() => withValues(alpha: AppOpacity.barrier);
}

/// 预定义的带透明度颜色
class AppColorsAlpha {
  AppColorsAlpha._();

  /// 品牌色的透明度变体
  static Color brandSage(double opacity) => AppColors.brandSage.withValues(alpha: opacity);
  static Color brandTeal(double opacity) => AppColors.brandTeal.withValues(alpha: opacity);
  static Color terracotta(double opacity) => AppColors.terracotta.withValues(alpha: opacity);
  static Color softGold(double opacity) => AppColors.softGold.withValues(alpha: opacity);

  /// 常用透明度预设
  static const brandSageUltraLow = Color(0x0D9DC695); // ultraLow
  static const brandSageVeryLow = Color(0x149DC695); // veryLow
  static const brandSageLow = Color(0x1A9DC695); // low
  static const brandSageMedium = Color(0x4D9DC695); // medium
  static const brandSageHigh = Color(0x809DC695); // high

  /// 背景色透明度变体
  static Color creamBg(double opacity) => AppColors.creamBg.withValues(alpha: opacity);
  static const creamBgBarrier = Color(0xCCFDFBF7); // 0.8

  /// 黑色透明度变体
  static Color black(double opacity) => Colors.black.withValues(alpha: opacity);
  static const blackUltraLow = Color(0x08000000); // 0.03
  static const blackVeryLow = Color(0x0A000000); // 0.04
  static const blackLow = Color(0x1A000000); // 0.1
  static const blackMedium = Color(0x33000000); // 0.2
  static const blackHigh = Color(0x80000000); // 0.5
}

/// AI 洞察卡片背景色
/// @see stats_screen.dart:455
class AppColorsSecondary {
  AppColorsSecondary._();

  /// AI 洞察卡片背景色
  static const Color aiInsightBg = Color(0xFFF1F4EE);
}
