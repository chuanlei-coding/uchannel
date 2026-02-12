import 'package:flutter/material.dart';
import '../theme/border_radius.dart';
import '../theme/colors.dart';
import '../theme/spacing.dart';

/// 日期时间选择器组件
class DateTimeSelector extends StatelessWidget {
  final DateTime selectedDate;
  final TimeOfDay selectedTime;
  final ValueChanged<DateTime>? onDateChanged;
  final ValueChanged<TimeOfDay>? onTimeChanged;
  final bool isCompact;

  const DateTimeSelector({
    super.key,
    required this.selectedDate,
    required this.selectedTime,
    this.onDateChanged,
    this.onTimeChanged,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _DateButton(
            date: selectedDate,
            onTap: () => _selectDate(context),
            isCompact: isCompact,
          ),
        ),
        const SizedBox(width: Spacing.sm),
        Expanded(
          child: _TimeButton(
            time: selectedTime,
            onTap: () => _selectTime(context),
            isCompact: isCompact,
          ),
        ),
      ],
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return _DatePickerTheme(child: child!);
      },
    );
    if (pickedDate != null) {
      onDateChanged?.call(pickedDate);
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: selectedTime,
      builder: (context, child) {
        return _TimePickerTheme(child: child!);
      },
    );
    if (pickedTime != null) {
      onTimeChanged?.call(pickedTime);
    }
  }
}

/// 日期选择按钮
class _DateButton extends StatelessWidget {
  final DateTime date;
  final VoidCallback onTap;
  final bool isCompact;

  const _DateButton({
    required this.date,
    required this.onTap,
    required this.isCompact,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: isCompact ? 10 : 14,
          horizontal: Spacing.md,
        ),
        decoration: BoxDecoration(
          color: AppColors.creamBg,
          borderRadius: AppBorderRadius.allLG,
          border: Border.all(
            color: AppColors.brandSage.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.calendar_today_outlined,
              size: isCompact ? 16 : 18,
              color: AppColors.brandSage,
            ),
            const SizedBox(width: Spacing.sm),
            Text(
              _formatDate(date),
              style: TextStyle(
                fontSize: isCompact ? 14 : 16,
                fontWeight: FontWeight.w500,
                color: AppColors.darkGrey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final targetDate = DateTime(date.year, date.month, date.day);
    final diffDays = targetDate.difference(today).inDays;

    if (diffDays == 0) return '今天';
    if (diffDays == 1) return '明天';
    return '${date.month}月${date.day}日';
  }
}

/// 时间选择按钮
class _TimeButton extends StatelessWidget {
  final TimeOfDay time;
  final VoidCallback onTap;
  final bool isCompact;

  const _TimeButton({
    required this.time,
    required this.onTap,
    required this.isCompact,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: isCompact ? 10 : 14,
          horizontal: Spacing.md,
        ),
        decoration: BoxDecoration(
          color: AppColors.creamBg,
          borderRadius: AppBorderRadius.allLG,
          border: Border.all(
            color: AppColors.brandSage.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.access_time,
              size: isCompact ? 16 : 18,
              color: AppColors.brandSage,
            ),
            const SizedBox(width: Spacing.sm),
            Text(
              _formatTime(time),
              style: TextStyle(
                fontSize: isCompact ? 14 : 16,
                fontWeight: FontWeight.w500,
                color: AppColors.darkGrey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}

/// 日期选择器主题包装器
class _DatePickerTheme extends StatelessWidget {
  final Widget child;

  const _DatePickerTheme({required this.child});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        colorScheme: const ColorScheme.light(
          primary: AppColors.brandSage,
          onPrimary: Colors.white,
          surface: AppColors.creamBg,
          onSurface: AppColors.darkGrey,
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: AppColors.brandSage,
          ),
        ),
      ),
      child: child,
    );
  }
}

/// 时间选择器主题包装器
class _TimePickerTheme extends StatelessWidget {
  final Widget child;

  const _TimePickerTheme({required this.child});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        colorScheme: const ColorScheme.light(
          primary: AppColors.brandSage,
          onPrimary: Colors.white,
          surface: AppColors.creamBg,
          onSurface: AppColors.darkGrey,
        ),
      ),
      child: child,
    );
  }
}

/// 仅日期选择器
class DateSelector extends StatelessWidget {
  final DateTime selectedDate;
  final ValueChanged<DateTime>? onDateChanged;
  final String? label;
  final bool isExpanded;

  const DateSelector({
    super.key,
    required this.selectedDate,
    this.onDateChanged,
    this.label,
    this.isExpanded = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _selectDate(context),
      child: Container(
        width: isExpanded ? double.infinity : null,
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.md,
          vertical: 14,
        ),
        decoration: BoxDecoration(
          color: AppColors.creamBg,
          borderRadius: AppBorderRadius.allLG,
          border: Border.all(
            color: AppColors.brandSage.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (label != null) ...[
              Text(
                label!,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.softGrey,
                ),
              ),
              const SizedBox(width: Spacing.sm),
            ],
            Icon(
              Icons.calendar_today_outlined,
              size: 18,
              color: AppColors.brandSage,
            ),
            const SizedBox(width: Spacing.sm),
            Text(
              _formatDate(selectedDate),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.darkGrey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return _DatePickerTheme(child: child!);
      },
    );
    if (pickedDate != null) {
      onDateChanged?.call(pickedDate);
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final targetDate = DateTime(date.year, date.month, date.day);
    final diffDays = targetDate.difference(today).inDays;

    if (diffDays == 0) return '今天';
    if (diffDays == 1) return '明天';
    return '${date.month}月${date.day}日';
  }
}
