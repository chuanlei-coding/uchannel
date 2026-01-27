import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/colors.dart';

/// 启动页
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _controller.forward();

    // 3秒后跳转到主页
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        context.go('/chat');
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: Stack(
        children: [
          // 背景模糊装饰
          Positioned(
            top: -100,
            left: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.brandSage.withValues(alpha: 0.1),
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            right: -50,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.brandTeal.withValues(alpha: 0.1),
              ),
            ),
          ),

          // 主内容
          Center(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Opacity(
                  opacity: _fadeAnimation.value,
                  child: Transform.scale(
                    scale: _scaleAnimation.value,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Logo
                        _buildLogo(),
                        const SizedBox(height: 24),

                        // 标题
                        Text(
                          'Vita',
                          style: TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.w300,
                            fontStyle: FontStyle.italic,
                            color: AppColors.brandSage,
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(height: 8),

                        // 副标题
                        Text(
                          '在微小中，见终生',
                          style: TextStyle(
                            fontSize: 14,
                            fontStyle: FontStyle.italic,
                            color: AppColors.brandSage.withValues(alpha: 0.6),
                            letterSpacing: 4,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // 底部版本号
          Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Text(
                'Version 1.0.0',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.white20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogo() {
    return SizedBox(
      width: 80,
      height: 80,
      child: Stack(
        children: [
          // 背景形状
          Positioned.fill(
            child: Transform.rotate(
              angle: -0.26, // -15 degrees
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.brandSage.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(32),
                    topRight: Radius.circular(0),
                    bottomLeft: Radius.circular(0),
                    bottomRight: Radius.circular(32),
                  ),
                ),
              ),
            ),
          ),
          // 圆环
          Positioned.fill(
            child: Transform.scale(
              scale: 1.1,
              child: Transform.rotate(
                angle: 0.785, // 45 degrees
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border(
                      top: BorderSide(
                        color: AppColors.brandTeal.withValues(alpha: 0.6),
                        width: 2,
                      ),
                      right: BorderSide(
                        color: AppColors.brandTeal.withValues(alpha: 0.6),
                        width: 2,
                      ),
                      bottom: BorderSide.none,
                      left: BorderSide.none,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
