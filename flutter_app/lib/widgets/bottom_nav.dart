import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/colors.dart';
import '../theme/animations.dart';

/// 导航项配置
class NavItem {
  final IconData icon;
  final String label;
  final String route;

  const NavItem({
    required this.icon,
    required this.label,
    required this.route,
  });
}

/// 底部导航栏组件
///
/// 提供统一的底部导航栏，自动根据当前路由激活对应项
/// 支持流畅的切换动画和视觉反馈
class BottomNav extends StatelessWidget {
  /// 当前激活的路由
  final String currentRoute;

  /// 导航项列表
  final List<NavItem> items;

  /// 导航栏高度
  final double height;

  const BottomNav({
    super.key,
    required this.currentRoute,
    required this.items,
    this.height = 84,
  });

  /// 默认导航项（助手、日程、发现、统计、设置）
  static const defaultItems = [
    NavItem(icon: Icons.chat_bubble, label: '助手', route: '/chat'),
    NavItem(icon: Icons.calendar_today, label: '日程', route: '/schedule'),
    NavItem(icon: Icons.explore, label: '发现', route: '/discover'),
    NavItem(icon: Icons.bar_chart, label: '统计', route: '/stats'),
    NavItem(icon: Icons.settings, label: '设置', route: '/settings'),
  ];

  /// 简化版导航项（日程、洞察、AI助手、设置）
  static const simplifiedItems = [
    NavItem(icon: Icons.calendar_today, label: '日程', route: '/schedule'),
    NavItem(icon: Icons.show_chart, label: '洞察', route: '/stats'),
    NavItem(icon: Icons.smart_toy_outlined, label: 'AI 助手', route: '/chat'),
    NavItem(icon: Icons.settings_outlined, label: '设置', route: '/settings'),
  ];

  /// 使用默认导航项的构造函数
  factory BottomNav.defaultNav({
    Key? key,
    required String currentRoute,
    double height = 84,
  }) {
    return BottomNav(
      key: key,
      currentRoute: currentRoute,
      items: defaultItems,
      height: height,
    );
  }

  /// 使用简化版导航项的构造函数
  factory BottomNav.simplifiedNav({
    Key? key,
    required String currentRoute,
    double height = 64,
  }) {
    return BottomNav(
      key: key,
      currentRoute: currentRoute,
      items: simplifiedItems,
      height: height,
    );
  }

  /// 判断路由是否匹配（支持子路由）
  bool _isRouteActive(String itemRoute) {
    return currentRoute.startsWith(itemRoute);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: AppColors.creamBg.withValues(alpha: 0.8),
        border: Border(
          top: BorderSide(
            color: AppColors.darkGrey.withValues(alpha: 0.05),
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: items.map((item) {
          final isActive = _isRouteActive(item.route);
          return _AnimatedNavItemWidget(
            icon: item.icon,
            label: item.label,
            isActive: isActive,
            onTap: () => context.go(item.route),
          );
        }).toList(),
      ),
    );
  }
}

/// 带动画的单个导航项组件
class _AnimatedNavItemWidget extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _AnimatedNavItemWidget({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  State<_AnimatedNavItemWidget> createState() => _AnimatedNavItemWidgetState();
}

class _AnimatedNavItemWidgetState extends State<_AnimatedNavItemWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _colorAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppAnimations.tabSwitchDuration,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: AppAnimations.tabIconActiveScale,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: AppAnimations.tabIconScaleCurve,
    ));

    _colorAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: AppAnimations.tabIndicatorCurve,
    ));

    if (widget.isActive) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(_AnimatedNavItemWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isActive != oldWidget.isActive) {
      if (widget.isActive) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: widget.onTap,
        splashColor: AppColors.brandSage.withValues(alpha: 0.1),
        highlightColor: AppColors.brandSage.withValues(alpha: 0.05),
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 图标带缩放动画
                ScaleTransition(
                  scale: _scaleAnimation,
                  child: Icon(
                    widget.icon,
                    size: 24,
                    color: Color.lerp(
                      AppColors.softGrey.withValues(alpha: 0.5),
                      AppColors.brandSage,
                      _colorAnimation.value,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                // 标签带颜色动画
                Text(
                  widget.label,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: widget.isActive ? FontWeight.w600 : FontWeight.w500,
                    color: Color.lerp(
                      AppColors.softGrey.withValues(alpha: 0.5),
                      AppColors.brandSage,
                      _colorAnimation.value,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
