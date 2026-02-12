import 'package:flutter/material.dart';
import '../theme/colors.dart';

/// 空状态组件
///
/// 用于显示列表或页面为空时的友好提示
class EmptyState extends StatelessWidget {
  /// 图标
  final IconData? icon;

  /// 自定义图标组件
  final Widget? customIcon;

  /// 标题
  final String title;

  /// 描述文字
  final String? message;

  /// 操作按钮文字
  final String? actionLabel;

  /// 操作按钮回调
  final VoidCallback? onAction;

  /// 空状态大小
  final EmptyStateSize size;

  const EmptyState({
    super.key,
    this.icon,
    this.customIcon,
    required this.title,
    this.message,
    this.actionLabel,
    this.onAction,
    this.size = EmptyStateSize.medium,
  });

  /// 聊天空状态
  factory EmptyState.chat({Key? key, VoidCallback? onStart}) {
    return EmptyState(
      key: key,
      icon: Icons.chat_bubble_outline,
      title: '开始与 Vita 对话',
      message: '发送消息，让 AI 助手帮助你规划每一天',
      actionLabel: '开始对话',
      onAction: onStart,
    );
  }

  /// 日程空状态
  factory EmptyState.schedule({Key? key, VoidCallback? onAdd}) {
    return EmptyState(
      key: key,
      icon: Icons.event_available,
      title: '今天暂无安排',
      message: '点击下方按钮添加新的待办事项',
      actionLabel: '添加待办',
      onAction: onAdd,
    );
  }

  /// 统计空状态
  factory EmptyState.stats({Key? key}) {
    return EmptyState(
      key: key,
      icon: Icons.bar_chart,
      title: '暂无数据',
      message: '完成一些任务后，这里将显示你的统计数据',
    );
  }

  /// 搜索空状态
  factory EmptyState.search({Key? key, String? query}) {
    return EmptyState(
      key: key,
      icon: Icons.search_off,
      title: '未找到结果',
      message: query != null ? '没有找到与 "$query" 相关的内容' : null,
    );
  }

  /// 错误空状态
  factory EmptyState.error({
    Key? key,
    String message = '加载失败，请稍后重试',
    VoidCallback? onRetry,
  }) {
    return EmptyState(
      key: key,
      icon: Icons.error_outline,
      title: '出错了',
      message: message,
      actionLabel: '重试',
      onAction: onRetry,
    );
  }

  /// 网络错误空状态
  factory EmptyState.network({Key? key, VoidCallback? onRetry}) {
    return EmptyState(
      key: key,
      icon: Icons.wifi_off,
      title: '网络连接失败',
      message: '请检查网络设置后重试',
      actionLabel: '重试',
      onAction: onRetry,
    );
  }

  @override
  Widget build(BuildContext context) {
    final iconSize = _getIconSize();
    final spacing = _getSpacing();

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 图标
            _buildIcon(iconSize),
            SizedBox(height: spacing),

            // 标题
            Text(
              title,
              style: TextStyle(
                fontSize: _getTitleFontSize(),
                fontWeight: FontWeight.w500,
                color: AppColors.darkGrey,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: spacing * 0.5),

            // 描述
            if (message != null) ...[
              Text(
                message!,
                style: TextStyle(
                  fontSize: _getMessageFontSize(),
                  color: AppColors.softGrey,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: spacing),
            ],

            // 操作按钮
            if (actionLabel != null && onAction != null) ...[
              _buildActionButton(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildIcon(double size) {
    if (customIcon != null) {
      return customIcon!;
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.brandSage.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        size: size * 0.5,
        color: AppColors.brandSage,
      ),
    );
  }

  Widget _buildActionButton() {
    return ElevatedButton(
      onPressed: onAction,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.brandSage,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(999),
        ),
        elevation: 0,
      ),
      child: Text(
        actionLabel!,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  double _getIconSize() {
    switch (size) {
      case EmptyStateSize.small:
        return 56;
      case EmptyStateSize.medium:
        return 80;
      case EmptyStateSize.large:
        return 120;
    }
  }

  double _getSpacing() {
    switch (size) {
      case EmptyStateSize.small:
        return 16;
      case EmptyStateSize.medium:
        return 24;
      case EmptyStateSize.large:
        return 32;
    }
  }

  double _getTitleFontSize() {
    switch (size) {
      case EmptyStateSize.small:
        return 14;
      case EmptyStateSize.medium:
        return 18;
      case EmptyStateSize.large:
        return 24;
    }
  }

  double _getMessageFontSize() {
    switch (size) {
      case EmptyStateSize.small:
        return 12;
      case EmptyStateSize.medium:
        return 14;
      case EmptyStateSize.large:
        return 16;
    }
  }
}

/// 空状态尺寸
enum EmptyStateSize {
  small,
  medium,
  large,
}

/// 空状态列表项
///
/// 用于列表为空时显示的简化版空状态
class EmptyStateListItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  const EmptyStateListItem({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(
            icon,
            size: 48,
            color: AppColors.softGrey.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.darkGrey,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 8),
            Text(
              subtitle!,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.softGrey,
              ),
            ),
          ],
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 24),
            TextButton(
              onPressed: onAction,
              child: Text(actionLabel!),
            ),
          ],
        ],
      ),
    );
  }
}
