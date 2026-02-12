import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/colors.dart';

/// 页面头部组件
///
/// 提供统一的页面头部样式，支持返回按钮、标题和右侧操作
class PageHeader extends StatelessWidget {
  /// 标题
  final String title;

  /// 副标题
  final String? subtitle;

  /// 是否显示返回按钮
  final bool showBack;

  /// 返回按钮回调
  final VoidCallback? onBack;

  /// 返回按钮图标
  final IconData? backIcon;

  /// 右侧操作组件
  final List<Widget>? actions;

  /// 头部内边距
  final EdgeInsetsGeometry? padding;

  /// 标题样式
  final TextStyle? titleStyle;

  /// 副标题样式
  final TextStyle? subtitleStyle;

  /// 背景颜色
  final Color? backgroundColor;

  /// 是否居中显示标题
  final bool centerTitle;

  const PageHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.showBack = true,
    this.onBack,
    this.backIcon,
    this.actions,
    this.padding,
    this.titleStyle,
    this.subtitleStyle,
    this.backgroundColor,
    this.centerTitle = false,
  });

  /// 简单样式 - 只有标题和返回按钮
  factory PageHeader.simple({
    Key? key,
    required String title,
    bool showBack = true,
    VoidCallback? onBack,
    List<Widget>? actions,
  }) {
    return PageHeader(
      key: key,
      title: title,
      showBack: showBack,
      onBack: onBack,
      actions: actions,
    );
  }

  /// 居中标题样式
  factory PageHeader.centered({
    Key? key,
    required String title,
    String? subtitle,
    bool showBack = true,
    VoidCallback? onBack,
    List<Widget>? actions,
  }) {
    return PageHeader(
      key: key,
      title: title,
      subtitle: subtitle,
      showBack: showBack,
      onBack: onBack,
      actions: actions,
      centerTitle: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasBack = showBack && (Navigator.canPop(context) || onBack != null);

    return Container(
      color: backgroundColor,
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // 返回按钮
          if (hasBack)
            _BackButton(
              icon: backIcon,
              onTap: onBack ?? () => context.pop(),
            )
          else
            const SizedBox(width: 40),

          // 标题区域
          if (!centerTitle) ...[
            const SizedBox(width: 8),
            Expanded(
              child: _buildTitle(),
            ),
          ] else ...[
            Expanded(
              child: Center(
                child: _buildTitle(),
              ),
            ),
          ],

          // 右侧操作区
          if (actions != null && actions!.isNotEmpty) ...[
            ...actions!,
          ] else if (!centerTitle) ...[
            const SizedBox(width: 40),
          ] else ...[
            const SizedBox(width: 40),
          ],
        ],
      ),
    );
  }

  Widget _buildTitle() {
    return Column(
      crossAxisAlignment: centerTitle ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: titleStyle ??
              const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w500,
                color: AppColors.darkGrey,
              ),
        ),
        if (subtitle != null)
          Text(
            subtitle!,
            style: subtitleStyle ??
                const TextStyle(
                  fontSize: 12,
                  color: AppColors.softGrey,
                ),
          ),
      ],
    );
  }
}

/// 返回按钮组件
class _BackButton extends StatelessWidget {
  final IconData? icon;
  final VoidCallback onTap;

  const _BackButton({
    this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(
            icon ?? Icons.chevron_left,
            size: 28,
            color: AppColors.brandSage,
          ),
          Text(
            '返回',
            style: TextStyle(
              fontSize: 17,
              color: AppColors.brandSage,
            ),
          ),
        ],
      ),
    );
  }
}

/// 图标按钮 - 用于头部右侧操作
class HeaderIconButton extends StatelessWidget {
  final IconData icon;
  final String? tooltip;
  final VoidCallback? onTap;
  final Color? color;
  final double size;

  const HeaderIconButton({
    super.key,
    required this.icon,
    this.tooltip,
    this.onTap,
    this.color,
    this.size = 40,
  });

  @override
  Widget build(BuildContext context) {
    Widget button = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        border: Border.all(
          color: AppColors.borderLight,
          width: 1,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Icon(
        icon,
        size: 18,
        color: color ?? AppColors.softGrey,
      ),
    );

    if (tooltip != null) {
      button = Tooltip(
        message: tooltip!,
        child: button,
      );
    }

    if (onTap != null) {
      button = GestureDetector(
        onTap: onTap,
        child: button,
      );
    }

    return button;
  }
}

/// 简单头部组件 - 用于不需要返回按钮的页面
class SimpleHeader extends StatelessWidget {
  final String title;
  final Widget? leading;
  final List<Widget>? actions;
  final EdgeInsetsGeometry? padding;

  const SimpleHeader({
    super.key,
    required this.title,
    this.leading,
    this.actions,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (leading != null) leading! else const SizedBox(),
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: AppColors.darkGrey,
            ),
          ),
          if (actions != null && actions!.isNotEmpty)
            Row(children: actions!)
          else
            const SizedBox(width: 40),
        ],
      ),
    );
  }
}
