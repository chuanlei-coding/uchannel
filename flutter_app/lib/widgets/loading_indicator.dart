import 'package:flutter/material.dart';
import '../theme/colors.dart';

/// 加载指示器组件
///
/// 提供统一的加载状态显示
class LoadingIndicator extends StatelessWidget {
  /// 加载提示文字
  final String? message;

  /// 背景遮罩颜色
  final Color? barrierColor;

  /// 指示器大小
  final double? size;

  /// 是否显示背景遮罩
  final bool showBarrier;

  const LoadingIndicator({
    super.key,
    this.message,
    this.barrierColor,
    this.size,
    this.showBarrier = true,
  });

  /// 小尺寸加载指示器
  factory LoadingIndicator.small({Key? key, String? message}) {
    return LoadingIndicator(
      key: key,
      message: message,
      size: 24,
      showBarrier: false,
    );
  }

  /// 大尺寸加载指示器（全屏）
  factory LoadingIndicator.fullScreen({
    Key? key,
    String? message,
    Color? barrierColor,
  }) {
    return LoadingIndicator(
      key: key,
      message: message,
      barrierColor: barrierColor,
      size: 40,
      showBarrier: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: CircularProgressIndicator(
            strokeWidth: size != null && size! < 30 ? 2 : 3,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.brandSage),
          ),
        ),
        if (message != null) ...[
          const SizedBox(height: 16),
          Text(
            message!,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.softGrey,
            ),
          ),
        ],
      ],
    );

    if (showBarrier) {
      return Container(
        color: barrierColor ?? AppColors.creamBg.withValues(alpha: 0.8),
        child: Center(child: content),
      );
    }

    return content;
  }
}

/// 带加载状态的包装器
///
/// 当 loading 为 true 时显示加载指示器，否则显示子组件
class LoadingBuilder extends StatelessWidget {
  /// 是否正在加载
  final bool loading;

  /// 加载提示文字
  final String? loadingMessage;

  /// 子组件
  final Widget child;

  /// 是否使用全屏遮罩
  final bool fullScreen;

  const LoadingBuilder({
    super.key,
    required this.loading,
    required this.child,
    this.loadingMessage,
    this.fullScreen = false,
  });

  @override
  Widget build(BuildContext context) {
    if (!loading) return child;

    if (fullScreen) {
      return LoadingIndicator.fullScreen(message: loadingMessage);
    }

    return LoadingIndicator.small(message: loadingMessage);
  }
}

/// 按钮加载状态包装器
///
/// 用于在按钮上显示加载状态
class ButtonLoadingIndicator extends StatelessWidget {
  /// 加载指示器大小
  final double size;

  /// 加载指示器颜色
  final Color? color;

  const ButtonLoadingIndicator({
    super.key,
    this.size = 16,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        valueColor: AlwaysStoppedAnimation<Color>(
          color ?? AppColors.creamBg,
        ),
      ),
    );
  }
}

/// 骨架屏加载指示器
///
/// 用于内容加载时的占位显示
class SkeletonIndicator extends StatelessWidget {
  /// 占位符宽度
  final double? width;

  /// 占位符高度
  final double? height;

  /// 占位符圆角
  final BorderRadius? borderRadius;

  const SkeletonIndicator({
    super.key,
    this.width,
    this.height,
    this.borderRadius,
  });

  /// 圆形骨架屏
  factory SkeletonIndicator.circle({
    Key? key,
    double size = 40,
  }) {
    return SkeletonIndicator(
      key: key,
      width: size,
      height: size,
      borderRadius: BorderRadius.circular(size / 2),
    );
  }

  /// 文本行骨架屏
  factory SkeletonIndicator.line({
    Key? key,
    double? width,
    double height = 12,
  }) {
    return SkeletonIndicator(
      key: key,
      width: width,
      height: height,
      borderRadius: BorderRadius.circular(4),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _ShkeletonLoading(
      width: width,
      height: height,
      borderRadius: borderRadius ?? BorderRadius.circular(8),
    );
  }
}

class _ShkeletonLoading extends StatefulWidget {
  final double? width;
  final double? height;
  final BorderRadius borderRadius;

  const _ShkeletonLoading({
    this.width,
    this.height,
    required this.borderRadius,
  });

  @override
  State<_ShkeletonLoading> createState() => _ShkeletonLoadingState();
}

class _ShkeletonLoadingState extends State<_ShkeletonLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    _animation = Tween<double>(begin: -2, end: 2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius,
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                AppColors.borderLight,
                AppColors.borderLight.withValues(alpha: 0.3),
                AppColors.borderLight,
              ],
              stops: [
                _animation.value - 1,
                _animation.value,
                _animation.value + 1,
              ].map((e) => e.clamp(0.0, 1.0)).toList(),
            ),
          ),
        );
      },
    );
  }
}
