import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/border_radius.dart';
import '../theme/colors.dart';
import '../theme/spacing.dart';

/// 应用输入框组件
///
/// 提供统一的输入框样式，支持多种类型和状态
class AppTextField extends StatefulWidget {
  /// 控制器
  final TextEditingController? controller;

  /// 初始值
  final String? initialValue;

  /// 提示文字
  final String? hintText;

  /// 标签文字
  final String? labelText;

  /// 错误文字
  final String? errorText;

  /// 帮助文字
  final String? helperText;

  /// 是否必填
  final bool required;

  /// 是否只读
  final bool readOnly;

  /// 是否启用
  final bool enabled;

  /// 最大行数
  final int maxLines;

  /// 最小行数
  final int? minLines;

  /// 最大长度
  final int? maxLength;

  /// 输入类型
  final TextInputType? keyboardType;

  /// 文本变化回调
  final ValueChanged<String>? onChanged;

  /// 提交回调
  final ValueChanged<String>? onSubmitted;

  /// 点击回调
  final VoidCallback? onTap;

  /// 前缀图标
  final IconData? prefixIcon;

  /// 后缀图标
  final Widget? suffixIcon;

  /// 清除按钮
  final bool showClearButton;

  /// 输入框变体
  final AppTextFieldVariant variant;

  /// 输入框尺寸
  final AppTextFieldSize size;

  /// 文字对齐
  final TextAlign textAlign;

  /// 输入格式
  final List<TextInputFormatter>? inputFormatters;

  /// 焦点节点
  final FocusNode? focusNode;

  const AppTextField({
    super.key,
    this.controller,
    this.initialValue,
    this.hintText,
    this.labelText,
    this.errorText,
    this.helperText,
    this.required = false,
    this.readOnly = false,
    this.enabled = true,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.keyboardType,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.prefixIcon,
    this.suffixIcon,
    this.showClearButton = false,
    this.variant = AppTextFieldVariant.outlined,
    this.size = AppTextFieldSize.medium,
    this.textAlign = TextAlign.start,
    this.inputFormatters,
    this.focusNode,
  });

  /// 多行输入框
  factory AppTextField.multiline({
    Key? key,
    TextEditingController? controller,
    String? initialValue,
    String? hintText,
    String? labelText,
    int maxLines = 5,
    int? minLines,
    ValueChanged<String>? onChanged,
  }) {
    return AppTextField(
      key: key,
      controller: controller,
      initialValue: initialValue,
      hintText: hintText,
      labelText: labelText,
      maxLines: maxLines,
      minLines: minLines,
      onChanged: onChanged,
    );
  }

  /// 搜索框
  factory AppTextField.search({
    Key? key,
    TextEditingController? controller,
    String? hintText,
    ValueChanged<String>? onChanged,
    VoidCallback? onClear,
  }) {
    return AppTextField(
      key: key,
      controller: controller,
      hintText: hintText ?? '搜索...',
      prefixIcon: Icons.search,
      showClearButton: true,
      onChanged: onChanged,
      suffixIcon: onClear != null ? _ClearButton(onTap: onClear) : null,
    );
  }

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _focusNode = widget.focusNode ?? FocusNode();
    if (widget.initialValue != null) {
      _controller.text = widget.initialValue!;
      _hasText = widget.initialValue!.isNotEmpty;
    }
    _controller.addListener(_onTextChanged);
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    _controller.removeListener(_onTextChanged);
    _focusNode.removeListener(_onFocusChanged);
    super.dispose();
  }

  void _onTextChanged() {
    setState(() {
      _hasText = _controller.text.isNotEmpty;
    });
    widget.onChanged?.call(_controller.text);
  }

  void _onFocusChanged() {
    setState(() {});
  }

  void _clearText() {
    _controller.clear();
    widget.onChanged?.call('');
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      focusNode: _focusNode,
      readOnly: widget.readOnly,
      enabled: widget.enabled,
      maxLines: widget.maxLines,
      minLines: widget.minLines,
      maxLength: widget.maxLength,
      keyboardType: widget.keyboardType,
      textAlign: widget.textAlign,
      inputFormatters: widget.inputFormatters,
      textInputAction: widget.onSubmitted != null
          ? TextInputAction.done
          : TextInputAction.next,
      onSubmitted: widget.onSubmitted,
      onTap: widget.onTap,
      style: _getTextStyle(),
      decoration: _getDecoration(),
      cursorColor: AppColors.brandSage,
    );
  }

  TextStyle _getTextStyle() {
    switch (widget.size) {
      case AppTextFieldSize.small:
        return const TextStyle(
          fontSize: 14,
          color: AppColors.darkGrey,
        );
      case AppTextFieldSize.medium:
        return const TextStyle(
          fontSize: 16,
          color: AppColors.darkGrey,
        );
      case AppTextFieldSize.large:
        return const TextStyle(
          fontSize: 18,
          color: AppColors.darkGrey,
        );
    }
  }

  InputDecoration _getDecoration() {
    final hasFocus = _focusNode.hasFocus;

    return InputDecoration(
      hintText: widget.hintText,
      labelText: _buildLabelText(),
      labelStyle: TextStyle(
        color: hasFocus ? AppColors.brandSage : AppColors.softGrey,
      ),
      errorText: widget.errorText,
      helperText: widget.helperText,
      prefixIcon: widget.prefixIcon != null
          ? Icon(
              widget.prefixIcon,
              color: hasFocus ? AppColors.brandSage : AppColors.softGrey,
            )
          : null,
      suffixIcon: _buildSuffixIcon(),
      filled: widget.variant == AppTextFieldVariant.filled,
      contentPadding: _getContentPadding(),
      border: _getInputBorder(),
      enabledBorder: _getInputBorder(),
      focusedBorder: _getFocusedInputBorder(),
      errorBorder: _getErrorInputBorder(),
      focusedErrorBorder: _getErrorInputBorder(),
      disabledBorder: _getDisabledInputBorder(),
      counterText: '', // 隐藏字数统计
    );
  }

  String? _buildLabelText() {
    if (widget.labelText == null) return null;
    if (widget.required) {
      return '${widget.labelText} *';
    }
    return widget.labelText;
  }

  Widget? _buildSuffixIcon() {
    if (widget.suffixIcon != null) {
      return widget.suffixIcon;
    }

    if (widget.showClearButton && _hasText) {
      return _ClearButton(onTap: _clearText);
    }

    return null;
  }

  EdgeInsets _getContentPadding() {
    switch (widget.size) {
      case AppTextFieldSize.small:
        return const EdgeInsets.symmetric(
          horizontal: Spacing.md,
          vertical: Spacing.sm,
        );
      case AppTextFieldSize.medium:
        return const EdgeInsets.symmetric(
          horizontal: Spacing.lg,
          vertical: Spacing.md,
        );
      case AppTextFieldSize.large:
        return const EdgeInsets.symmetric(
          horizontal: Spacing.lg,
          vertical: Spacing.lg,
        );
    }
  }

  InputBorder _getInputBorder() {
    return OutlineInputBorder(
      borderRadius: _getBorderRadius(),
      borderSide: const BorderSide(
        color: AppColors.borderLight,
        width: 1,
      ),
    );
  }

  InputBorder _getFocusedInputBorder() {
    return OutlineInputBorder(
      borderRadius: _getBorderRadius(),
      borderSide: const BorderSide(
        color: AppColors.brandSage,
        width: 1.5,
      ),
    );
  }

  InputBorder _getErrorInputBorder() {
    return OutlineInputBorder(
      borderRadius: _getBorderRadius(),
      borderSide: const BorderSide(
        color: AppColors.danger,
        width: 1,
      ),
    );
  }

  InputBorder _getDisabledInputBorder() {
    return OutlineInputBorder(
      borderRadius: _getBorderRadius(),
      borderSide: BorderSide(
        color: AppColors.borderLight.withValues(alpha: 0.5),
        width: 1,
      ),
    );
  }

  BorderRadius _getBorderRadius() {
    switch (widget.variant) {
      case AppTextFieldVariant.outlined:
      case AppTextFieldVariant.filled:
        switch (widget.size) {
          case AppTextFieldSize.small:
          case AppTextFieldSize.medium:
            return AppBorderRadius.allLG;
          case AppTextFieldSize.large:
            return AppBorderRadius.allXL;
        }
    }
  }
}

/// 输入框变体
enum AppTextFieldVariant {
  outlined,
  filled,
}

/// 输入框尺寸
enum AppTextFieldSize {
  small,
  medium,
  large,
}

/// 清除按钮
class _ClearButton extends StatelessWidget {
  final VoidCallback onTap;

  const _ClearButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.clear, size: 18),
      color: AppColors.softGrey,
      onPressed: onTap,
      splashRadius: 16,
    );
  }
}

/// 只读输入框（用于显示数据并允许点击选择）
class ReadOnlyTextField extends StatelessWidget {
  final String? value;
  final String? hintText;
  final String? labelText;
  final IconData? prefixIcon;
  final VoidCallback? onTap;
  final Widget? suffix;

  const ReadOnlyTextField({
    super.key,
    this.value,
    this.hintText,
    this.labelText,
    this.prefixIcon,
    this.onTap,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      initialValue: value,
      hintText: hintText,
      labelText: labelText,
      prefixIcon: prefixIcon,
      readOnly: true,
      onTap: onTap,
      suffixIcon: suffix ??
          (onTap != null
              ? const Icon(
                  Icons.chevron_right,
                  size: 20,
                  color: AppColors.softGrey,
                )
              : null),
    );
  }
}

/// 文本区域输入框
class AppTextArea extends StatelessWidget {
  final TextEditingController? controller;
  final String? initialValue;
  final String? hintText;
  final String? labelText;
  final int maxLines;
  final int? minLines;
  final ValueChanged<String>? onChanged;
  final String? errorText;

  const AppTextArea({
    super.key,
    this.controller,
    this.initialValue,
    this.hintText,
    this.labelText,
    this.maxLines = 5,
    this.minLines,
    this.onChanged,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      controller: controller,
      initialValue: initialValue,
      hintText: hintText,
      labelText: labelText,
      maxLines: maxLines,
      minLines: minLines,
      onChanged: onChanged,
      errorText: errorText,
    );
  }
}
