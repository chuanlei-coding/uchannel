import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/animations.dart';

/// 支持侧滑返回的页面包装组件
///
/// 提供 iOS 风格的侧滑返回手势，带视觉反馈和弹簧动画
/// 使用 AnimatedBuilder 优化性能，支持流畅的拖动交互
/// 小红书风格的视觉反馈：轻微缩放和阴影效果
class SwipeablePage extends StatefulWidget {
  final Widget child;
  final bool canPop;

  const SwipeablePage({
    super.key,
    required this.child,
    this.canPop = true,
  });

  @override
  State<SwipeablePage> createState() => _SwipeablePageState();
}

class _SwipeablePageState extends State<SwipeablePage>
    with SingleTickerProviderStateMixin {
  double _dragOffset = 0.0;
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppAnimations.swipeBackDuration,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: AppAnimations.swipeBackCurve,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    if (!widget.canPop || !context.canPop()) return;

    final screenWidth = MediaQuery.of(context).size.width;
    final delta = details.primaryDelta ?? 0;

    // 只允许从左向右滑动（返回手势）
    if (delta > 0) {
      setState(() {
        _dragOffset = (_dragOffset + delta).clamp(0.0, screenWidth);
      });
    } else if (_dragOffset > 0 && delta < 0) {
      // 允许向右滑动时回退
      setState(() {
        _dragOffset = (_dragOffset + delta).clamp(0.0, screenWidth);
      });
    }
  }

  void _handleDragEnd(DragEndDetails details) {
    if (!widget.canPop || !context.canPop()) {
      _resetDragOffset();
      return;
    }

    final screenWidth = MediaQuery.of(context).size.width;
    final threshold = screenWidth * AppAnimations.swipeThreshold;
    final velocity = details.primaryVelocity ?? 0;

    // 如果滑动超过阈值或速度足够快，则返回
    if (_dragOffset > threshold || velocity > AppAnimations.swipeVelocityThreshold) {
      _completeSwipeBack();
    } else {
      // 否则回弹
      _cancelSwipeBack();
    }
  }

  /// 完成侧滑返回
  void _completeSwipeBack() {
    _controller.forward().then((_) {
      if (mounted && context.canPop()) {
        context.pop();
      }
    });
  }

  /// 取消侧滑返回，回弹到原位
  void _cancelSwipeBack() {
    _controller.reverse();
    setState(() {
      _dragOffset = 0.0;
    });
  }

  /// 重置拖动偏移
  void _resetDragOffset() {
    setState(() {
      _dragOffset = 0.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return PopScope(
      canPop: widget.canPop,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && widget.canPop && context.canPop()) {
          context.pop();
        }
      },
      child: GestureDetector(
        onHorizontalDragUpdate: _handleDragUpdate,
        onHorizontalDragEnd: _handleDragEnd,
        child: AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            // 使用动画值平滑过渡拖动偏移
            final offset = _dragOffset * (1 - _animation.value);
            // 根据偏移量计算进度
            final progress = (offset / screenWidth).clamp(0.0, 1.0);

            // 极轻微缩放效果
            final scale = 1.0 - progress * 0.02;

            // 透明度渐变（更微妙）
            final opacity = 1.0 - progress * 0.1;

            return Transform.translate(
              offset: Offset(offset, 0),
              child: Transform.scale(
                scale: scale,
                alignment: Alignment.centerRight,
                child: Opacity(
                  opacity: opacity.clamp(0.9, 1.0),
                  child: widget.child,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
