import 'package:flutter/animation.dart';

/// 统一动画配置
///
/// 定义应用中所有动画的时长、曲线等常量
/// 确保整个应用的动画体验一致
class AppAnimations {
  AppAnimations._();

  // ========== 时长常量 ==========

  /// 快速过渡 - 用于简单状态变化
  static const Duration transitionQuick = Duration(milliseconds: 200);

  /// 正常过渡 - 用于页面切换
  static const Duration transitionNormal = Duration(milliseconds: 350);

  /// 慢速过渡 - 用于模态框、重要动画
  static const Duration transitionSlow = Duration(milliseconds: 400);

  // ========== 曲线常量 ==========

  /// 标准缓出曲线 - 用于大多数进入动画
  static const Curve easeOut = Curves.easeOutCubic;

  /// 标准缓入缓出曲线 - 用于往返动画
  static const Curve easeInOut = Curves.easeInOutCubic;

  /// 弹性曲线 - 用于强调反馈
  static const Curve spring = Curves.elasticOut;

  /// 平滑曲线 - 用于拖动跟随
  static const Curve smooth = Curves.easeOutExpo;

  /// 小红书风格曲线 - 带轻微过冲的缓出曲线
  /// 让动画更有活力和弹性感
  static const Curve xiaohongshuCurve = Curves.easeOutBack;

  /// 自定义弹性曲线 - 更自然的弹簧效果
  static const Curve bouncyOut = _BouncyOutCurve();

  // ========== 页面过渡配置（轻柔风格）==========

  /// 页面过渡时长 - 300ms 适中流畅
  static const Duration pageTransition = Duration(milliseconds: 300);

  /// 页面过渡曲线 - 柔和的缓出，无过冲
  static const Curve pageTransitionCurve = Curves.easeOutCubic;

  /// 页面进入缩放比例 - 极轻微，几乎无感
  static const double pageEnterScale = 0.98;

  /// 背景页面视差系数 - 背景移动慢于前景（更小）
  static const double parallaxFactor = 0.2;

  /// 背景页面缩放比例 - 极轻微缩小
  static const double backgroundScale = 0.97;

  /// 背景页面模糊最大值
  static const double backgroundBlurMax = 0.05;

  // ========== 模态框过渡配置 ==========

  /// 模态框过渡时长
  static const Duration modalTransition = Duration(milliseconds: 350);

  /// 模态框过渡曲线 - 柔和
  static const Curve modalTransitionCurve = Curves.easeOutCubic;

  /// 淡入淡出过渡时长
  static const Duration fadeTransition = Duration(milliseconds: 250);

  /// 淡入淡出过渡曲线
  static const Curve fadeTransitionCurve = Curves.easeOut;

  // ========== 手势导航配置 ==========

  /// 手势返回动画时长
  static const Duration swipeBackDuration = Duration(milliseconds: 250);

  /// 手势返回动画曲线 - 柔和
  static const Curve swipeBackCurve = Curves.easeOutCubic;

  /// 触发返回的拖动阈值（屏幕宽度的百分比）
  static const double swipeThreshold = 0.3;

  /// 触发返回的最小速度 (px/s)
  static const double swipeVelocityThreshold = 500.0;

  // ========== 底部导航配置 ==========

  /// Tab 切换动画时长
  static const Duration tabSwitchDuration = Duration(milliseconds: 250);

  /// Tab 图标缩放动画曲线
  static const Curve tabIconScaleCurve = Curves.easeOutBack;

  /// Tab 指示器动画曲线
  static const Curve tabIndicatorCurve = Curves.easeOutCubic;

  /// 激活状态图标缩放比例
  static const double tabIconActiveScale = 1.15;
}

/// 自定义弹性曲线
///
/// 提供更自然的弹簧效果，类似小红书的动画风格
class _BouncyOutCurve extends Curve {
  const _BouncyOutCurve();

  @override
  double transform(double t) {
    // 使用四次多项式创建自然的弹性效果
    // 先快速到达目标，然后轻微过冲，最后回到目标
    final t2 = t * t;
    final t3 = t2 * t;
    return 1.0 - 0.5 * (1.0 - t) * (1.0 - t3 * t);
  }
}

