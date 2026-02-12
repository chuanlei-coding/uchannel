import 'package:flutter/material.dart';

/// 应用阴影常量
///
/// 统一管理应用中的阴影样式，保持一致性
class AppShadows {
  AppShadows._();

  /// 默认卡片阴影 - 轻微
  static const List<BoxShadow> cardSm = [
    BoxShadow(
      color: Color(0x08000000), // black.withValues(alpha: 0.03)
      blurRadius: 4,
      offset: Offset(0, 2),
    ),
  ];

  /// 默认卡片阴影 - 中等
  static const List<BoxShadow> cardMd = [
    BoxShadow(
      color: Color(0x0A000000), // black.withValues(alpha: 0.04)
      blurRadius: 8,
      offset: Offset(0, 4),
    ),
  ];

  /// 默认卡片阴影 - 明显
  static const List<BoxShadow> cardLg = [
    BoxShadow(
      color: Color(0x14000000), // black.withValues(alpha: 0.08)
      blurRadius: 20,
      offset: Offset(0, 8),
    ),
  ];

  /// 按钮阴影
  static const List<BoxShadow> button = [
    BoxShadow(
      color: Color(0x08000000), // black.withValues(alpha: 0.03)
      blurRadius: 4,
      offset: Offset(0, 2),
    ),
  ];

  /// 浮动按钮阴影
  static const List<BoxShadow> fab = [
    BoxShadow(
      color: Color(0x33000000), // black.withValues(alpha: 0.2)
      blurRadius: 8,
      offset: Offset(0, 4),
    ),
  ];

  /// 无阴影
  static const List<BoxShadow> none = [];
}
