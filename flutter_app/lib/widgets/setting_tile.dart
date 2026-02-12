import 'package:flutter/material.dart';
import '../theme/colors.dart';

/// 设置项组件
///
/// 支持多种样式：普通项、带开关项、带值项、危险操作项等
class SettingTile extends StatelessWidget {
  /// 图标
  final IconData icon;

  /// 标题
  final String title;

  /// 副标题/值
  final String? subtitle;

  /// 值的颜色
  final Color? valueColor;

  /// 是否显示右侧箭头
  final bool showArrow;

  /// 是否显示底部边框
  final bool showBorder;

  /// 是否为开关样式
  final bool isToggle;

  /// 开关状态值
  final bool toggleValue;

  /// 开关状态变化回调
  final ValueChanged<bool>? onToggle;

  /// 是否为危险操作（红色）
  final bool isDanger;

  /// 点击回调
  final VoidCallback? onTap;

  const SettingTile({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.valueColor,
    this.showArrow = true,
    this.showBorder = true,
    this.isToggle = false,
    this.toggleValue = false,
    this.onToggle,
    this.isDanger = false,
    this.onTap,
  });

  /// 普通设置项
  factory SettingTile.normal({
    Key? key,
    required IconData icon,
    required String title,
    String? subtitle,
    Color? valueColor,
    bool showArrow = true,
    bool showBorder = true,
    VoidCallback? onTap,
  }) {
    return SettingTile(
      key: key,
      icon: icon,
      title: title,
      subtitle: subtitle,
      valueColor: valueColor,
      showArrow: showArrow,
      showBorder: showBorder,
      onTap: onTap,
    );
  }

  /// 开关设置项
  factory SettingTile.toggle({
    Key? key,
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onToggle,
    bool showBorder = true,
  }) {
    return SettingTile(
      key: key,
      icon: icon,
      title: title,
      isToggle: true,
      toggleValue: value,
      onToggle: onToggle,
      showBorder: showBorder,
    );
  }

  /// 危险操作项（红色）
  factory SettingTile.danger({
    Key? key,
    required IconData icon,
    required String title,
    bool showBorder = true,
    VoidCallback? onTap,
  }) {
    return SettingTile(
      key: key,
      icon: icon,
      title: title,
      showArrow: false,
      showBorder: showBorder,
      isDanger: true,
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    final content = Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: showBorder
            ? Border(
                bottom: BorderSide(
                  color: AppColors.darkGrey.withValues(alpha: 0.05),
                  width: 1,
                ),
              )
            : null,
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 22,
            color: isDanger ? AppColors.danger : AppColors.brandSage,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 17,
                color: isDanger ? AppColors.danger : AppColors.darkGrey,
              ),
            ),
          ),
          if (isToggle)
            Switch(
              value: toggleValue,
              onChanged: onToggle,
            )
          else ...[
            if (subtitle != null)
              Text(
                subtitle!,
                style: TextStyle(
                  fontSize: 15,
                  fontStyle: FontStyle.italic,
                  color: valueColor ?? AppColors.brandSage.withValues(alpha: 0.6),
                ),
              ),
            if (showArrow) ...[
              const SizedBox(width: 4),
              Icon(
                Icons.chevron_right,
                size: 20,
                color: AppColors.darkGrey.withValues(alpha: 0.2),
              ),
            ],
          ],
        ],
      ),
    );

    if (onTap != null && !isToggle) {
      return GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: content,
      );
    }

    return content;
  }
}

/// 设置分组组件
///
/// 用于将多个设置项分组显示
class SettingSection extends StatelessWidget {
  /// 分组标题
  final String title;

  /// 设置项列表
  final List<Widget> items;

  const SettingSection({
    super.key,
    required this.title,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, bottom: 8),
          child: Text(
            title.toUpperCase(),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              letterSpacing: 2,
              color: AppColors.brandSage.withValues(alpha: 0.4),
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.darkGrey.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.darkGrey.withValues(alpha: 0.05),
              width: 1,
            ),
          ),
          child: Column(children: items),
        ),
      ],
    );
  }
}
