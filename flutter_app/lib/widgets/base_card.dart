import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/border_radius.dart';
import '../theme/shadows.dart';
import '../theme/spacing.dart';

/// 基础卡片组件
///
/// 提供统一的卡片样式，支持多种预设和自定义配置
class BaseCard extends StatelessWidget {
  /// 卡片内容
  final Widget child;

  /// 内边距
  final EdgeInsetsGeometry? padding;

  /// 外边距
  final EdgeInsetsGeometry? margin;

  /// 圆角半径
  final double? borderRadius;

  /// 背景颜色
  final Color? backgroundColor;

  /// 是否显示边框
  final bool showBorder;

  /// 边框颜色
  final Color? borderColor;

  /// 边框宽度
  final double borderWidth;

  /// 阴影样式
  final List<BoxShadow>? shadows;

  /// 点击回调
  final VoidCallback? onTap;

  /// 卡片宽度
  final double? width;

  /// 卡片高度
  final double? height;

  const BaseCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius,
    this.backgroundColor,
    this.showBorder = true,
    this.borderColor,
    this.borderWidth = 1,
    this.shadows,
    this.onTap,
    this.width,
    this.height,
  });

  /// 默认样式 - 白色背景，带边框和轻微阴影
  factory BaseCard.defaultStyle({
    Key? key,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    VoidCallback? onTap,
    double? width,
    double? height,
    required Widget child,
  }) {
    return BaseCard(
      key: key,
      padding: padding,
      margin: margin,
      onTap: onTap,
      width: width,
      height: height,
      child: child,
    );
  }

  /// 紧凑样式 - 较小的内边距
  factory BaseCard.compact({
    Key? key,
    EdgeInsetsGeometry? margin,
    VoidCallback? onTap,
    required Widget child,
  }) {
    return BaseCard(
      key: key,
      padding: const EdgeInsets.all(16),
      margin: margin,
      onTap: onTap,
      child: child,
    );
  }

  /// 无边框样式 - 仅阴影，无边框
  factory BaseCard.noBorder({
    Key? key,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    VoidCallback? onTap,
    required Widget child,
  }) {
    return BaseCard(
      key: key,
      padding: padding,
      margin: margin,
      showBorder: false,
      onTap: onTap,
      child: child,
    );
  }

  /// 大圆角样式 - 24px 圆角
  factory BaseCard.rounded({
    Key? key,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    VoidCallback? onTap,
    required Widget child,
  }) {
    return BaseCard(
      key: key,
      padding: padding,
      margin: margin,
      borderRadius: 24,
      onTap: onTap,
      child: child,
    );
  }

  /// 柔和背景样式 - 使用奶油色背景
  factory BaseCard.soft({
    Key? key,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    VoidCallback? onTap,
    required Widget child,
  }) {
    return BaseCard(
      key: key,
      padding: padding,
      margin: margin,
      backgroundColor: AppColors.creamBg,
      showBorder: false,
      shadows: AppShadows.none,
      onTap: onTap,
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final content = Container(
      width: width,
      height: height,
      margin: margin,
      padding: padding ?? Spacing.allLG,
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white,
        borderRadius: BorderRadius.circular(borderRadius ?? AppBorderRadius.lg),
        border: showBorder
            ? Border.all(
                color: borderColor ?? AppColors.borderLight,
                width: borderWidth,
              )
            : null,
        boxShadow: shadows ?? AppShadows.cardSm,
      ),
      child: child,
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(borderRadius ?? AppBorderRadius.lg),
        child: content,
      );
    }

    return content;
  }
}

/// 卡片列表项 - 带图标、标题、副标题和箭头
class CardListItem extends StatelessWidget {
  final IconData? icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? iconColor;
  final Color? iconBackgroundColor;
  final EdgeInsetsGeometry? padding;
  final bool showArrow;

  const CardListItem({
    super.key,
    this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.iconColor,
    this.iconBackgroundColor,
    this.padding,
    this.showArrow = true,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppBorderRadius.card,
      child: Padding(
        padding: padding ?? const EdgeInsets.all(20),
        child: Row(
          children: [
            if (icon != null) ...[
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: iconBackgroundColor ?? AppColors.creamBg,
                  borderRadius: AppBorderRadius.card,
                  border: Border.all(
                    color: AppColors.brandSage.withValues(alpha: 0.1),
                    width: 1,
                  ),
                ),
                child: Icon(icon, color: iconColor ?? AppColors.brandSage),
              ),
              const SizedBox(width: 16),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppColors.darkGrey,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.mutedGrey,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null) trailing!,
            if (showArrow && trailing == null)
              Icon(
                Icons.chevron_right,
                color: AppColors.mutedGrey.withValues(alpha: 0.3),
              ),
          ],
        ),
      ),
    );
  }
}
