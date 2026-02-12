import 'package:flutter/material.dart';
import '../theme/border_radius.dart';
import '../theme/colors.dart';
import '../theme/spacing.dart';

/// 优先级选择器组件
///
/// 用于选择任务的优先级
class PrioritySelector extends StatelessWidget {
  /// 当前选中的优先级
  final String selectedPriority;

  /// 优先级选项
  final List<String> priorities;

  /// 选择回调
  final ValueChanged<String>? onPriorityChanged;

  /// 是否紧凑模式
  final bool isCompact;

  const PrioritySelector({
    super.key,
    required this.selectedPriority,
    this.priorities = const ['普通', '重要', '紧急'],
    this.onPriorityChanged,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: priorities.map((priority) {
        final isSelected = selectedPriority == priority;
        return Expanded(
          child: GestureDetector(
            onTap: () => onPriorityChanged?.call(priority),
            child: _PriorityButton(
              label: priority,
              isSelected: isSelected,
              isCompact: isCompact,
            ),
          ),
        );
      }).toList(),
    );
  }
}

/// 优先级按钮组件
class _PriorityButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final bool isCompact;

  const _PriorityButton({
    required this.label,
    required this.isSelected,
    required this.isCompact,
  });

  Color _getBackgroundColor() {
    switch (label) {
      case '紧急':
        return isSelected
            ? AppColors.danger
            : AppColors.danger.withValues(alpha: 0.1);
      case '重要':
        return isSelected
            ? AppColors.terracotta
            : AppColors.terracotta.withValues(alpha: 0.1);
      default:
        return isSelected
            ? AppColors.brandSage
            : AppColors.brandSage.withValues(alpha: 0.1);
    }
  }

  Color _getTextColor() {
    return isSelected ? Colors.white : _getPriorityColor();
  }

  Color _getPriorityColor() {
    switch (label) {
      case '紧急':
        return AppColors.danger;
      case '重要':
        return AppColors.terracotta;
      default:
        return AppColors.brandSage;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      margin: EdgeInsets.only(
        right: isCompact ? Spacing.sm : Spacing.md,
      ),
      padding: EdgeInsets.symmetric(
        vertical: isCompact ? 8 : 12,
        horizontal: isCompact ? 12 : Spacing.md,
      ),
      decoration: BoxDecoration(
        color: _getBackgroundColor(),
        borderRadius: isCompact ? AppBorderRadius.allSM : AppBorderRadius.allLG,
        border: Border.all(
          color: _getPriorityColor().withValues(alpha: isSelected ? 0.0 : 0.3),
          width: 1,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: isCompact ? 12 : 14,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          color: _getTextColor(),
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

/// 垂直优先级选择器
class VerticalPrioritySelector extends StatelessWidget {
  final String selectedPriority;
  final List<String> priorities;
  final ValueChanged<String>? onPriorityChanged;

  const VerticalPrioritySelector({
    super.key,
    required this.selectedPriority,
    this.priorities = const ['普通', '重要', '紧急'],
    this.onPriorityChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: priorities.map((priority) {
        final isSelected = selectedPriority == priority;
        return Padding(
          padding: const EdgeInsets.only(bottom: Spacing.sm),
          child: GestureDetector(
            onTap: () => onPriorityChanged?.call(priority),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: Spacing.md,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: isSelected
                    ? _getPriorityColor(priority)
                    : _getPriorityColor(priority).withValues(alpha: 0.1),
                borderRadius: AppBorderRadius.allLG,
                border: Border.all(
                  color: _getPriorityColor(priority).withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected
                          ? Colors.white
                          : _getPriorityColor(priority).withValues(alpha: 0.3),
                    ),
                    child: isSelected
                        ? Icon(
                            Icons.check,
                            size: 10,
                            color: _getPriorityColor(priority),
                          )
                        : null,
                  ),
                  const SizedBox(width: Spacing.sm),
                  Text(
                    priority,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: isSelected ? Colors.white : _getPriorityColor(priority),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case '紧急':
        return AppColors.danger;
      case '重要':
        return AppColors.terracotta;
      default:
        return AppColors.brandSage;
    }
  }
}
