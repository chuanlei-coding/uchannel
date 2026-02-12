import 'package:flutter/material.dart';
import '../theme/border_radius.dart';
import '../theme/colors.dart';
import '../theme/opacity.dart';
import '../theme/shadows.dart';
import '../theme/spacing.dart';
import 'loading_indicator.dart';

/// 主要按钮组件
///
/// 提供统一的按钮样式，支持多种状态和变体
class PrimaryButton extends StatelessWidget {
  /// 按钮文字
  final String text;

  /// 点击回调
  final VoidCallback? onPressed;

  /// 是否正在加载
  final bool isLoading;

  /// 是否禁用
  final bool isDisabled;

  /// 按钮宽度
  final double? width;

  /// 按钮高度
  final double? height;

  /// 背景颜色
  final Color? backgroundColor;

  /// 文字颜色
  final Color? textColor;

  /// 按钮变体
  final PrimaryButtonVariant variant;

  /// 按钮尺寸
  final PrimaryButtonSize size;

  /// 图标
  final IconData? icon;

  /// 图标位置
  final PrimaryButtonIconPosition iconPosition;

  const PrimaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isDisabled = false,
    this.width,
    this.height,
    this.backgroundColor,
    this.textColor,
    this.variant = PrimaryButtonVariant.filled,
    this.size = PrimaryButtonSize.medium,
    this.icon,
    this.iconPosition = PrimaryButtonIconPosition.left,
  });

  /// 大尺寸按钮
  factory PrimaryButton.large({
    Key? key,
    required String text,
    VoidCallback? onPressed,
    bool isLoading = false,
    Color? backgroundColor,
  }) {
    return PrimaryButton(
      key: key,
      text: text,
      onPressed: onPressed,
      isLoading: isLoading,
      size: PrimaryButtonSize.large,
      backgroundColor: backgroundColor,
    );
  }

  /// 小尺寸按钮
  factory PrimaryButton.small({
    Key? key,
    required String text,
    VoidCallback? onPressed,
    bool isLoading = false,
  }) {
    return PrimaryButton(
      key: key,
      text: text,
      onPressed: onPressed,
      isLoading: isLoading,
      size: PrimaryButtonSize.small,
    );
  }

  /// 描边样式按钮
  factory PrimaryButton.outlined({
    Key? key,
    required String text,
    VoidCallback? onPressed,
    bool isLoading = false,
  }) {
    return PrimaryButton(
      key: key,
      text: text,
      onPressed: onPressed,
      isLoading: isLoading,
      variant: PrimaryButtonVariant.outlined,
    );
  }

  /// 文字样式按钮
  factory PrimaryButton.text({
    Key? key,
    required String text,
    VoidCallback? onPressed,
    Color? textColor,
  }) {
    return PrimaryButton(
      key: key,
      text: text,
      onPressed: onPressed,
      variant: PrimaryButtonVariant.text,
      textColor: textColor,
    );
  }

  /// 带图标的按钮
  factory PrimaryButton.withIcon({
    Key? key,
    required String text,
    required IconData icon,
    VoidCallback? onPressed,
    bool isLoading = false,
    PrimaryButtonIconPosition iconPosition = PrimaryButtonIconPosition.left,
  }) {
    return PrimaryButton(
      key: key,
      text: text,
      icon: icon,
      onPressed: onPressed,
      isLoading: isLoading,
      iconPosition: iconPosition,
    );
  }

  bool get _isEnabled => !isDisabled && !isLoading;

  @override
  Widget build(BuildContext context) {
    final effectiveBackgroundColor = _getBackgroundColor();
    final effectiveTextColor = _getTextColor();

    final buttonChild = _buildContent(effectiveTextColor);

    final buttonStyle = _getButtonStyle(effectiveBackgroundColor);

    final button = GestureDetector(
      onTap: _isEnabled ? onPressed : null,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 150),
        opacity: _isEnabled ? 1.0 : AppOpacity.disabled,
        child: Container(
          width: width,
          height: height ?? _getHeight(),
          decoration: buttonStyle,
          child: buttonChild,
        ),
      ),
    );

    if (variant == PrimaryButtonVariant.text) {
      return button;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      decoration: BoxDecoration(
        borderRadius: _getBorderRadius(),
        boxShadow: variant == PrimaryButtonVariant.filled && _isEnabled
            ? AppShadows.button
            : AppShadows.none,
      ),
      child: button,
    );
  }

  BoxDecoration _getButtonStyle(Color backgroundColor) {
    final borderRadius = _getBorderRadius();

    switch (variant) {
      case PrimaryButtonVariant.filled:
        return BoxDecoration(
          color: backgroundColor,
          borderRadius: borderRadius,
        );
      case PrimaryButtonVariant.outlined:
        return BoxDecoration(
          color: Colors.transparent,
          border: Border.all(color: backgroundColor),
          borderRadius: borderRadius,
        );
      case PrimaryButtonVariant.text:
        return const BoxDecoration(color: Colors.transparent);
    }
  }

  Widget _buildContent(Color textColor) {
    final contentChildren = <Widget>[];

    // 添加加载指示器或图标
    if (isLoading) {
      contentChildren.add(
        ButtonLoadingIndicator(
          size: _getIconSize(),
          color: textColor,
        ),
      );
    } else if (icon != null) {
      contentChildren.add(Icon(icon, size: _getIconSize(), color: textColor));
    }

    // 添加文字
    if (isLoading && icon == null) {
      // 仅加载时不显示文字
    } else {
      contentChildren.add(
        Text(
          text,
          style: _getTextStyle(textColor),
        ),
      );
    }

    // 根据图标位置排列
    List<Widget> arrangedChildren;
    if (iconPosition == PrimaryButtonIconPosition.right && !isLoading) {
      arrangedChildren = contentChildren.reversed.toList();
    } else {
      arrangedChildren = contentChildren;
    }

    // 添加间距
    if ((icon != null || isLoading) && text.isNotEmpty && !isLoading) {
      final spacedChildren = <Widget>[];
      for (int i = 0; i < arrangedChildren.length; i++) {
        spacedChildren.add(arrangedChildren[i]);
        if (i < arrangedChildren.length - 1) {
          spacedChildren.add(SizedBox(width: _getIconTextSpacing()));
        }
      }
      arrangedChildren = spacedChildren;
    }

    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: arrangedChildren,
      ),
    );
  }

  Color _getBackgroundColor() {
    if (backgroundColor != null) return backgroundColor!;

    switch (variant) {
      case PrimaryButtonVariant.filled:
        return AppColors.brandSage;
      case PrimaryButtonVariant.outlined:
      case PrimaryButtonVariant.text:
        return AppColors.brandSage;
    }
  }

  Color _getTextColor() {
    if (textColor != null) return textColor!;

    switch (variant) {
      case PrimaryButtonVariant.filled:
        return Colors.white;
      case PrimaryButtonVariant.outlined:
      case PrimaryButtonVariant.text:
        return AppColors.brandSage;
    }
  }

  double _getHeight() {
    switch (size) {
      case PrimaryButtonSize.small:
        return 40;
      case PrimaryButtonSize.medium:
        return 48;
      case PrimaryButtonSize.large:
        return 56;
    }
  }

  BorderRadius _getBorderRadius() {
    switch (size) {
      case PrimaryButtonSize.small:
      case PrimaryButtonSize.medium:
        return AppBorderRadius.allFull;
      case PrimaryButtonSize.large:
        return AppBorderRadius.allXL;
    }
  }

  double _getIconSize() {
    switch (size) {
      case PrimaryButtonSize.small:
        return 16;
      case PrimaryButtonSize.medium:
        return 18;
      case PrimaryButtonSize.large:
        return 20;
    }
  }

  double _getIconTextSpacing() {
    return Spacing.sm;
  }

  TextStyle _getTextStyle(Color color) {
    return TextStyle(
      color: color,
      fontSize: _getFontSize(),
      fontWeight: _getFontWeight(),
      letterSpacing: _getLetterSpacing(),
    );
  }

  double _getFontSize() {
    switch (size) {
      case PrimaryButtonSize.small:
        return 14;
      case PrimaryButtonSize.medium:
        return 16;
      case PrimaryButtonSize.large:
        return 18;
    }
  }

  FontWeight _getFontWeight() {
    switch (variant) {
      case PrimaryButtonVariant.filled:
      case PrimaryButtonVariant.outlined:
        return FontWeight.w600;
      case PrimaryButtonVariant.text:
        return FontWeight.w500;
    }
  }

  double _getLetterSpacing() {
    switch (variant) {
      case PrimaryButtonVariant.filled:
        return 2.0;
      case PrimaryButtonVariant.outlined:
      case PrimaryButtonVariant.text:
        return 0.5;
    }
  }
}

/// 按钮变体
enum PrimaryButtonVariant {
  filled,
  outlined,
  text,
}

/// 按钮尺寸
enum PrimaryButtonSize {
  small,
  medium,
  large,
}

/// 图标位置
enum PrimaryButtonIconPosition {
  left,
  right,
}

/// 浮动操作按钮 (FAB)
class FloatingActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;
  final Color? backgroundColor;
  final Color? iconColor;
  final double size;

  const FloatingActionButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.tooltip,
    this.backgroundColor,
    this.iconColor,
    this.size = 56,
  });

  @override
  Widget build(BuildContext context) {
    Widget button = GestureDetector(
      onTap: onPressed,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: backgroundColor ?? AppColors.brandSage,
          borderRadius: BorderRadius.circular(size * 0.3),
          boxShadow: AppShadows.fab,
        ),
        child: Icon(
          icon,
          color: iconColor ?? AppColors.darkGrey,
          size: size * 0.4,
        ),
      ),
    );

    if (tooltip != null) {
      button = Tooltip(message: tooltip!, child: button);
    }

    return button;
  }
}

/// 图标按钮
class IconButtonWidget extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final String? tooltip;
  final Color? backgroundColor;
  final Color? iconColor;
  final double size;
  final bool bordered;

  const IconButtonWidget({
    super.key,
    required this.icon,
    this.onTap,
    this.tooltip,
    this.backgroundColor,
    this.iconColor,
    this.size = 40,
    this.bordered = true,
  });

  @override
  Widget build(BuildContext context) {
    Widget button = GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: backgroundColor ?? Colors.white,
          border: bordered
              ? Border.all(
                  color: AppColors.borderLight,
                  width: 1,
                )
              : null,
          boxShadow: bordered ? AppShadows.button : AppShadows.none,
        ),
        child: Icon(
          icon,
          size: size * 0.45,
          color: iconColor ?? AppColors.softGrey,
        ),
      ),
    );

    if (tooltip != null) {
      button = Tooltip(message: tooltip!, child: button);
    }

    return button;
  }
}
