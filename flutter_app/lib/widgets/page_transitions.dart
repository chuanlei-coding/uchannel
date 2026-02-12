import 'package:flutter/material.dart';
import '../theme/animations.dart';

/// 页面过渡动画工具类
///
/// 提供统一的页面过渡动画效果
/// 支持小红书风格、iOS 风格滑动、淡入淡出、底部滑入等多种过渡方式
class PageTransitions {
  PageTransitions._();

  /// 小红书风格页面过渡
  ///
  /// 特点：
  /// 1. 新页面带轻微缩放 + 滑动效果
  /// 2. 背景页面视差移动（慢于前景）+ 轻微缩小
  /// 3. 使用弹性曲线，动画更有活力
  /// 4. 微妙的淡入淡出效果
  static Widget xiaohongshuTransition(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    // 新页面动画：滑动 + 缩放 + 淡入
    final slideIn = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: animation,
      curve: AppAnimations.pageTransitionCurve,
    ));

    final scaleIn = Tween<double>(
      begin: AppAnimations.pageEnterScale,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: animation,
      curve: AppAnimations.pageTransitionCurve,
    ));

    final fadeIn = Tween<double>(
      begin: 0.9,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: animation,
      curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
    ));

    // 背景页面动画：视差滑动 + 缩小 + 淡出
    final parallaxSlideOut = Tween<Offset>(
      begin: Offset.zero,
      end: Offset(-AppAnimations.parallaxFactor, 0.0),
    ).animate(CurvedAnimation(
      parent: secondaryAnimation,
      curve: AppAnimations.pageTransitionCurve,
    ));

    final scaleOut = Tween<double>(
      begin: 1.0,
      end: AppAnimations.backgroundScale,
    ).animate(CurvedAnimation(
      parent: secondaryAnimation,
      curve: AppAnimations.pageTransitionCurve,
    ));

    final fadeOut = Tween<double>(
      begin: 1.0,
      end: 1.0 - AppAnimations.backgroundBlurMax,
    ).animate(CurvedAnimation(
      parent: secondaryAnimation,
      curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
    ));

    return SlideTransition(
      position: parallaxSlideOut,
      child: ScaleTransition(
        scale: scaleOut,
        child: FadeTransition(
          opacity: fadeOut,
          child: SlideTransition(
            position: slideIn,
            child: ScaleTransition(
              scale: scaleIn,
              child: FadeTransition(
                opacity: fadeIn,
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// iOS 风格滑动过渡
  ///
  /// 新页面从右侧滑入，旧页面同时向左推移并淡出
  /// 模拟 iOS 原生的导航体验
  static Widget iosSlideTransition(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    // 新页面从右侧滑入
    final slideIn = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: animation,
      curve: AppAnimations.pageTransitionCurve,
    ));

    // 旧页面向左淡出
    final fadeOut = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: secondaryAnimation,
      curve: AppAnimations.pageTransitionCurve,
    ));

    final slideOut = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(-0.3, 0.0),
    ).animate(CurvedAnimation(
      parent: secondaryAnimation,
      curve: AppAnimations.pageTransitionCurve,
    ));

    return SlideTransition(
      position: slideIn,
      child: SlideTransition(
        position: slideOut,
        child: FadeTransition(
          opacity: fadeOut,
          child: child,
        ),
      ),
    );
  }

  /// 简化的滑动过渡（仅新页面移动）
  ///
  /// 新页面从右侧滑入，旧页面保持不动
  /// 适用于需要更轻量级过渡的场景
  static Widget slideTransition(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final slideIn = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: animation,
      curve: AppAnimations.pageTransitionCurve,
    ));

    return SlideTransition(
      position: slideIn,
      child: child,
    );
  }

  /// 淡入淡出过渡
  ///
  /// 适用于首页加载、启动页等场景
  static Widget fadeTransition(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return FadeTransition(
      opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: animation,
          curve: AppAnimations.fadeTransitionCurve,
        ),
      ),
      child: child,
    );
  }

  /// 底部滑入过渡（模态框）- 轻柔风格
  ///
  /// 新页面从底部滑入，带有遮罩效果
  /// 适用于添加任务、表单等模态场景
  static Widget slideUpTransition(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    // 页面从底部滑入
    final slideUp = Tween<Offset>(
      begin: const Offset(0.0, 1.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: animation,
      curve: AppAnimations.modalTransitionCurve,
    ));

    // 极轻微缩放效果
    final scaleIn = Tween<double>(
      begin: 0.98,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: animation,
      curve: AppAnimations.modalTransitionCurve,
    ));

    // 淡入效果
    final fadeIn = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: animation,
        curve: const Interval(0.3, 1.0, curve: AppAnimations.modalTransitionCurve),
      ),
    );

    return SlideTransition(
      position: slideUp,
      child: ScaleTransition(
        scale: scaleIn,
        child: FadeTransition(
          opacity: fadeIn,
          child: child,
        ),
      ),
    );
  }

  /// 底部滑入的背景遮罩
  ///
  /// 配合 slideUpTransition 使用，为模态框添加半透明背景
  static Widget slideUpBackground(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return FadeTransition(
      opacity: Tween<double>(begin: 0.0, end: 0.5).animate(
        CurvedAnimation(
          parent: animation,
          curve: const Interval(0.0, 0.5),
        ),
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.5),
        ),
        child: child,
      ),
    );
  }

  /// 缩放淡入过渡
  ///
  /// 新页面从小到大缩放并淡入
  /// 适用于弹窗、卡片展开等场景
  static Widget scaleFadeTransition(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final scale = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(
        parent: animation,
        curve: AppAnimations.pageTransitionCurve,
      ),
    );

    final fadeIn = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: animation,
        curve: const Interval(0.0, 0.5, curve: AppAnimations.fadeTransitionCurve),
      ),
    );

    return ScaleTransition(
      scale: scale,
      child: FadeTransition(
        opacity: fadeIn,
        child: child,
      ),
    );
  }

  /// 无动画过渡
  ///
  /// 立即显示页面，无过渡效果
  /// 适用于特殊场景
  static Widget noTransition(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return child;
  }
}

/// 页面过渡类型枚举
enum PageTransitionType {
  /// 小红书风格（推荐）
  xiaohongshu,

  /// iOS 风格滑动
  iosSlide,

  /// 简单滑动
  slide,

  /// 淡入淡出
  fade,

  /// 底部滑入
  slideUp,

  /// 缩放淡入
  scaleFade,

  /// 无动画
  none,
}

/// 页面过渡配置
class PageTransitionConfig {
  /// 过渡类型
  final PageTransitionType type;

  /// 过渡时长
  final Duration duration;

  /// 反向过渡时长
  final Duration? reverseDuration;

  const PageTransitionConfig({
    required this.type,
    this.duration = AppAnimations.pageTransition,
    this.reverseDuration,
  });

  /// 获取过渡构建器
  Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)
      get transitionsBuilder {
    switch (type) {
      case PageTransitionType.xiaohongshu:
        return PageTransitions.xiaohongshuTransition;
      case PageTransitionType.iosSlide:
        return PageTransitions.iosSlideTransition;
      case PageTransitionType.slide:
        return PageTransitions.slideTransition;
      case PageTransitionType.fade:
        return PageTransitions.fadeTransition;
      case PageTransitionType.slideUp:
        return PageTransitions.slideUpTransition;
      case PageTransitionType.scaleFade:
        return PageTransitions.scaleFadeTransition;
      case PageTransitionType.none:
        return PageTransitions.noTransition;
    }
  }

  /// 小红书风格配置（推荐）
  static const PageTransitionConfig xiaohongshu = PageTransitionConfig(
    type: PageTransitionType.xiaohongshu,
    duration: AppAnimations.pageTransition,
  );

  /// iOS 风格滑动配置
  static const PageTransitionConfig iosSlide = PageTransitionConfig(
    type: PageTransitionType.iosSlide,
    duration: AppAnimations.pageTransition,
  );

  /// 淡入淡出配置
  static const PageTransitionConfig fade = PageTransitionConfig(
    type: PageTransitionType.fade,
    duration: AppAnimations.fadeTransition,
  );

  /// 模态框配置
  static const PageTransitionConfig modal = PageTransitionConfig(
    type: PageTransitionType.slideUp,
    duration: AppAnimations.modalTransition,
  );
}
