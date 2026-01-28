import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:ui' as ui;
import '../theme/colors.dart';

/// 统计页面
class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.creamBg,
      body: Stack(
        children: [
          // 背景装饰
          _buildBackgroundDecorations(context),

          // 主内容
          SafeArea(
            child: Column(
              children: [
                // 头部
                _buildHeader(context),

                // 内容区域
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        const SizedBox(height: 16),
                        // 统计卡片
                        _buildStatsCards(),
                        const SizedBox(height: 24),

                        // 成长趋势图表
                        _buildTrendChart(),
                        const SizedBox(height: 24),

                        // 生命进度热力图
                        _buildHeatmap(),
                        const SizedBox(height: 24),

                        // AI 洞察
                        _buildAIInsight(),
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),

                // 底部导航
                _buildBottomNav(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackgroundDecorations(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: -MediaQuery.of(context).size.height * 0.05,
          left: -MediaQuery.of(context).size.width * 0.1,
          child: Container(
            width: MediaQuery.of(context).size.width * 0.6,
            height: MediaQuery.of(context).size.height * 0.6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.sageGreen.withValues(alpha: 0.1),
            ),
          ),
        ),
        Positioned(
          bottom: MediaQuery.of(context).size.height * 0.15,
          right: -MediaQuery.of(context).size.width * 0.1,
          child: Container(
            width: MediaQuery.of(context).size.width * 0.5,
            height: MediaQuery.of(context).size.height * 0.5,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.softTerracotta.withValues(alpha: 0.05),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              border: Border.all(
                color: AppColors.borderLight,
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              Icons.arrow_back_ios_new,
              size: 18,
              color: AppColors.sageGreen,
            ),
          ),
          const Text(
            '数据洞察',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: Color(0xFF2D2A26),
            ),
          ),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              border: Border.all(
                color: AppColors.borderLight,
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              Icons.calendar_today,
              size: 18,
              color: AppColors.sageGreen,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCards() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            label: '专注时长',
            value: '24.5',
            unit: 'hrs',
            color: AppColors.sageGreen,
            trend: '+12%',
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            label: '完成目标',
            value: '42',
            unit: 'tasks',
            color: AppColors.softTerracotta,
            trend: '88%',
            icon: Icons.verified,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String label,
    required String value,
    required String unit,
    required Color color,
    required String trend,
    IconData? icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.borderLight,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 2,
              color: color,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w300,
                  fontStyle: FontStyle.italic,
                  color: Color(0xFF2D2A26),
                ),
              ),
              const SizedBox(width: 4),
              Text(
                unit,
                style: TextStyle(
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                  color: AppColors.warmGrey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                icon ?? Icons.trending_up,
                size: 12,
                color: color,
              ),
              const SizedBox(width: 4),
              Text(
                '较上周增加 $trend',
                style: TextStyle(
                  fontSize: 10,
                  color: color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTrendChart() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.borderLight,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '成长趋势',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF2D2A26),
                    ),
                  ),
                  Text(
                    'Daily Rhythm',
                    style: TextStyle(
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                      color: AppColors.warmGrey,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.sageGreen,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '深度专注',
                        style: TextStyle(
                          fontSize: 10,
                          color: AppColors.warmGrey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.softTerracotta,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '常规计划',
                        style: TextStyle(
                          fontSize: 10,
                          color: AppColors.warmGrey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 32),
          SizedBox(
            height: 180,
            child: CustomPaint(
              painter: TrendChartPainter(),
              size: const Size(double.infinity, 180),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
                .map((day) => Text(
                      day,
                      style: TextStyle(
                        fontSize: 10,
                        color: AppColors.warmGrey.withValues(alpha: 0.6),
                      ),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeatmap() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.borderLight,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              const Text(
                '生命进度',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF2D2A26),
                ),
              ),
              Text(
                '过去 4 周',
                style: TextStyle(
                  fontSize: 10,
                  color: AppColors.warmGrey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              crossAxisSpacing: 6,
              mainAxisSpacing: 6,
            ),
            itemCount: 28,
            itemBuilder: (context, index) {
              final intensity = (index % 5) / 4.0;
              Color color;
              if (intensity < 0.2) {
                color = AppColors.heatmapLight;
              } else if (intensity < 0.4) {
                color = AppColors.heatmap1;
              } else if (intensity < 0.6) {
                color = AppColors.heatmap2;
              } else if (intensity < 0.8) {
                color = AppColors.heatmap3;
              } else {
                color = AppColors.heatmap4;
              }
              return Container(
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(2),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                '少',
                style: TextStyle(
                  fontSize: 8,
                  color: AppColors.warmGrey,
                ),
              ),
              const SizedBox(width: 8),
              ...List.generate(5, (index) {
                final colors = [
                  AppColors.heatmapLight,
                  AppColors.heatmap1,
                  AppColors.heatmap2,
                  AppColors.heatmap3,
                  AppColors.heatmap4,
                ];
                return Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    color: colors[index],
                    borderRadius: BorderRadius.circular(1),
                  ),
                );
              }),
              const SizedBox(width: 8),
              Text(
                '多',
                style: TextStyle(
                  fontSize: 8,
                  color: AppColors.warmGrey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAIInsight() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F4EE),
        borderRadius: BorderRadius.circular(16),
        border: Border(
          left: BorderSide(
            color: AppColors.sageGreen,
            width: 4,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '"在这个充满暖意的周间，你的生活节奏正如清晨的微光。保持这份内心的充盈，在静谧中继续前行。"',
            style: TextStyle(
              fontSize: 14,
              fontStyle: FontStyle.italic,
              height: 1.6,
              color: AppColors.sageGreen,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'VITA AI INSIGHT',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              letterSpacing: 3,
              color: AppColors.warmGrey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return Container(
      height: 96,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: AppColors.borderLight,
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(Icons.auto_awesome, '助手', false, () {
            context.go('/chat');
          }),
          _buildNavItem(Icons.calendar_month, '日程', false, () {
            context.go('/schedule');
          }),
          _buildNavItem(Icons.explore, '发现', false, () {
            context.go('/discover');
          }),
          _buildNavItem(Icons.analytics, '统计', true, () {}),
          _buildNavItem(Icons.settings, '设置', false, () {
            context.go('/settings');
          }),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    IconData icon,
    String label,
    bool isActive,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 26,
            color: isActive
                ? AppColors.sageGreen
                : AppColors.warmGrey.withValues(alpha: 0.6),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
              color: isActive
                  ? AppColors.sageGreen
                  : AppColors.warmGrey.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}

/// 趋势图表绘制器
class TrendChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    // 绘制网格线
    final gridPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = Colors.black.withValues(alpha: 0.05);

    for (double y = 30; y <= 150; y += 40) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        gridPaint,
      );
    }

    // 绘制虚线（常规计划）
    paint.color = AppColors.softTerracotta;
    paint.strokeWidth = 2.5;
    final dashPath = Path()
      ..moveTo(0, 120)
      ..quadraticBezierTo(50, 130, 100, 90)
      ..quadraticBezierTo(150, 50, 200, 80)
      ..quadraticBezierTo(250, 110, 300, 60);
    canvas.drawPath(dashPath, paint);

    // 绘制实线（深度专注）
    paint.color = AppColors.sageGreen;
    paint.strokeWidth = 2.5;
    final solidPath = Path()
      ..moveTo(0, 110)
      ..quadraticBezierTo(40, 100, 80, 120)
      ..quadraticBezierTo(120, 140, 160, 60)
      ..quadraticBezierTo(200, -20, 240, 40)
      ..quadraticBezierTo(280, 100, 300, 20);
    canvas.drawPath(solidPath, paint);

    // 绘制关键点
    final circlePaint = Paint()
      ..style = PaintingStyle.fill
      ..color = AppColors.sageGreen;
    final strokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = Colors.white;

    canvas.drawCircle(const Offset(160, 60), 4, circlePaint);
    canvas.drawCircle(const Offset(160, 60), 4, strokePaint);
    canvas.drawCircle(const Offset(300, 20), 4, circlePaint);
    canvas.drawCircle(const Offset(300, 20), 4, strokePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
