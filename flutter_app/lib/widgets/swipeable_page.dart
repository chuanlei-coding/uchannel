import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// 支持侧滑返回的页面包装组件
/// 提供 iOS 风格的侧滑返回手势，带视觉反馈
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
      duration: const Duration(milliseconds: 200),
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
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
      setState(() {
        _dragOffset = 0.0;
      });
      return;
    }

    final screenWidth = MediaQuery.of(context).size.width;
    final threshold = screenWidth * 0.3; // 30% 的屏幕宽度作为阈值
    final velocity = details.primaryVelocity ?? 0;

    // 如果滑动超过阈值或速度足够快，则返回
    if (_dragOffset > threshold || velocity > 500) {
      _controller.forward().then((_) {
        if (mounted && context.canPop()) {
          context.pop();
        }
      });
    } else {
      // 否则回弹
      _controller.reverse();
      setState(() {
        _dragOffset = 0.0;
      });
    }
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
            final offset = _dragOffset * (1 - _animation.value);
            final opacity = 1.0 - (offset / screenWidth) * 0.3;
            
            return Transform.translate(
              offset: Offset(offset, 0),
              child: Opacity(
                opacity: opacity.clamp(0.7, 1.0),
                child: widget.child,
              ),
            );
          },
        ),
      ),
    );
  }
}
