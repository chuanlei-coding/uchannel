import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/colors.dart';

/// 启动页 - 柔和版
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

    // 3秒后跳转到聊天页
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
      backgroundColor: AppColors.creamBg,
      body: SafeArea(
        child: Stack(
          children: [
            // 背景装饰 - 径向渐变（中心）
            Positioned.fill(
              child: IgnorePointer(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: const Alignment(0.0, 0.0),
                      radius: 1.4,
                      colors: [
                        AppColors.brandSage.withValues(alpha: 0.12),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.7],
                    ),
                  ),
                ),
              ),
            ),

            // 背景装饰 - 模糊圆形
            Positioned(
              top: -MediaQuery.of(context).size.height * 0.05,
              right: -MediaQuery.of(context).size.width * 0.1,
              child: ClipOval(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.6,
                    height: MediaQuery.of(context).size.height * 0.4,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.brandSage.withValues(alpha: 0.05),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: -MediaQuery.of(context).size.height * 0.05,
              left: -MediaQuery.of(context).size.width * 0.1,
              child: ClipOval(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.5,
                    height: MediaQuery.of(context).size.height * 0.4,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.brandTeal.withValues(alpha: 0.05),
                    ),
                  ),
                ),
              ),
            ),

            // 主内容区域
            Column(
              children: [
                // 主内容 - 居中
                Expanded(
                  child: Center(
                    child: AnimatedBuilder(
                      animation: _controller,
                      builder: (context, child) {
                        return Opacity(
                          opacity: _fadeAnimation.value,
                          child: Transform.scale(
                            scale: _scaleAnimation.value,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 32),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Logo
                                  _buildOrganicLogo(),
                                  const SizedBox(height: 48),

                                  // 标题
                                  Text(
                                    'Vita',
                                    style: GoogleFonts.newsreader(
                                      fontSize: 60,
                                      fontWeight: FontWeight.w300,
                                      letterSpacing: -1.5,
                                      color: AppColors.darkGrey,
                                    ),
                                  ),
                                  const SizedBox(height: 24),

                                  // 中文格言
                                  Text(
                                    '在微小中，见终生',
                                    style: GoogleFonts.notoSerifSc(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w400,
                                      letterSpacing: 4.8, // 0.2em = 24 * 0.2 = 4.8px
                                      color: AppColors.darkGrey.withValues(alpha: 0.8),
                                    ),
                                  ),
                                  const SizedBox(height: 12),

                                  // 英文格言
                                  Text(
                                    'Life unfolds in minutiae',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w500,
                                      letterSpacing: 4.0, // 0.4em ≈ 4px for 10px
                                      color: AppColors.darkGrey.withValues(alpha: 0.3),
                                      fontFamily: '-apple-system',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),

                // 底部区域
                Padding(
                  padding: const EdgeInsets.only(bottom: 48),
                  child: Column(
                    children: [
                      // 进入空间按钮
                      GestureDetector(
                        onTap: () => context.go('/chat'),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 40,
                                vertical: 14,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.buttonSage,
                                borderRadius: BorderRadius.circular(999),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.brandSage.withValues(alpha: 0.2),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Text(
                                '进入空间',
                                style: GoogleFonts.notoSerifSc(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 3.2,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Enter Space',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.8,
                                color: AppColors.darkGrey.withValues(alpha: 0.4),
                                fontFamily: '-apple-system',
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 56),

                      // iOS Edition 标签
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 24,
                            height: 1,
                            color: AppColors.darkGrey.withValues(alpha: 0.1),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              'iOS Edition',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 3.0, // 0.3em ≈ 3px for 10px
                                color: AppColors.darkGrey.withValues(alpha: 0.3),
                                fontFamily: '-apple-system',
                              ),
                            ),
                          ),
                          Container(
                            width: 24,
                            height: 1,
                            color: AppColors.darkGrey.withValues(alpha: 0.1),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // 底部指示器
                Container(
                  height: 32,
                  alignment: Alignment.bottomCenter,
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Container(
                    width: 128,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.darkGrey.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrganicLogo() {
    return SizedBox(
      width: 120,
      height: 120,
      child: Stack(
        children: [
          // 叶子形状
          Positioned(
            left: 4,
            bottom: 4,
            child: Transform.rotate(
              angle: -0.26, // -15 degrees
              child: Container(
                width: 78,
                height: 78,
                decoration: BoxDecoration(
                  color: AppColors.brandSage,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(62),
                    topRight: Radius.circular(0),
                    bottomLeft: Radius.circular(0),
                    bottomRight: Radius.circular(62),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.brandSage.withValues(alpha: 0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // 弧形
          Positioned(
            right: 4,
            top: 4,
            child: Transform.rotate(
              angle: 0.785, // 45 degrees
              child: Container(
                width: 86,
                height: 86,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border(
                    top: BorderSide(
                      color: AppColors.brandTeal.withValues(alpha: 0.6),
                      width: 8,
                    ),
                    right: BorderSide(
                      color: AppColors.brandTeal.withValues(alpha: 0.6),
                      width: 8,
                    ),
                    bottom: BorderSide.none,
                    left: BorderSide.none,
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
