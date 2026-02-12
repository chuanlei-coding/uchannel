import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../theme/colors.dart';
import '../theme/opacity.dart';
import '../widgets/bottom_nav.dart';
import '../widgets/page_background.dart';
import '../widgets/base_card.dart';

/// 统计页面
class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  String? _errorMessage;

  // 统计数据
  Map<String, dynamic>? _overviewStats;
  Map<String, dynamic>? _weeklyStats;
  List<Map<String, dynamic>> _categoryStats = [];
  List<Map<String, dynamic>> _priorityStats = [];
  List<Map<String, dynamic>> _heatmapData = [];

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final results = await Future.wait([
        _apiService.getOverviewStats(),
        _apiService.getWeeklyStats(),
        _apiService.getCategoryStats(),
        _apiService.getPriorityStats(),
        _apiService.getHeatmapData(days: 28),
      ]);

      if (mounted) {
        setState(() {
          _overviewStats = results[0] as Map<String, dynamic>?;
          _weeklyStats = results[1] as Map<String, dynamic>?;
          _categoryStats = results[2] as List<Map<String, dynamic>>;
          _priorityStats = results[3] as List<Map<String, dynamic>>;
          _heatmapData = results[4] as List<Map<String, dynamic>>;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = '加载统计数据失败: $e';
          _isLoading = false;
        });
      }
    }
  }

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
                  child: _buildContent(),
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

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.brandSage),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: AppColors.brandSage.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: const TextStyle(fontSize: 14, color: AppColors.darkGrey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadStats,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.brandSage,
                foregroundColor: Colors.white,
              ),
              child: const Text('重试'),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const SizedBox(height: 16),
          // 统计卡片
          _buildStatsCards(),
          const SizedBox(height: 24),

          // 分类统计
          if (_categoryStats.isNotEmpty) _buildCategoryStats(),
          if (_categoryStats.isNotEmpty) const SizedBox(height: 24),

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
    );
  }

  Widget _buildBackgroundDecorations(BuildContext context) {
    return PageBackground(
      topLeft: const BackgroundCircle(
        widthFactor: 0.6,
        heightFactor: 0.6,
        color: AppColors.sageGreen,
        alpha: 0.1,
      ),
      bottomRight: const BackgroundCircle(
        widthFactor: 0.5,
        heightFactor: 0.5,
        color: AppColors.softTerracotta,
        alpha: 0.05,
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: _loadStats,
            icon: const Icon(Icons.refresh, color: AppColors.sageGreen),
          ),
          const Text(
            '数据洞察',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: AppColors.darkGrey,
            ),
          ),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              border: Border.all(color: AppColors.borderLight, width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
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
    final completedTasks = _overviewStats?['completedTasks'] ?? 0;
    final totalTasks = _overviewStats?['totalTasks'] ?? 1;
    final completionRate = totalTasks > 0
        ? ((completedTasks / totalTasks) * 100).toStringAsFixed(0)
        : '0';

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            label: '本周任务',
            value: (_weeklyStats?['weeklyCompleted'] ?? 0).toString(),
            unit: '/ ${_weeklyStats?['weeklyTotal'] ?? 0} 完成',
            color: AppColors.sageGreen,
            trend: '+${(_weeklyStats?['completionRate'] ?? 0).toStringAsFixed(0)}%',
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            label: '完成目标',
            value: completionRate,
            unit: '%',
            color: AppColors.softTerracotta,
            trend: '$completedTasks 个',
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
    return BaseCard(
      padding: const EdgeInsets.all(20),
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
                  color: AppColors.darkGrey,
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
              Icon(icon ?? Icons.trending_up, size: 12, color: color),
              const SizedBox(width: 4),
              Text(
                '较上周 $trend',
                style: TextStyle(fontSize: 10, color: color),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryStats() {
    return BaseCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '分类统计',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: AppColors.darkGrey,
            ),
          ),
          const SizedBox(height: 16),
          ..._categoryStats.map((stat) {
            final name = stat['name'] as String;
            final count = stat['count'] as int;
            final color = Color(
              int.parse((stat['color'] as String).substring(1), radix: 16) +
                  0xFF000000,
            );
            final maxCount = _categoryStats
                    .map((s) => s['count'] as int)
                    .reduce((a, b) => a > b ? a : b) ??
                1;
            final width = count / maxCount;

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.darkGrey,
                        ),
                      ),
                      Text(
                        '$count',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.darkGrey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: width,
                      backgroundColor: AppColors.sand.withValues(alpha: 0.3),
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                      minHeight: 6,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildTrendChart() {
    return BaseCard(
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
                      color: AppColors.darkGrey,
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
                        '已完成',
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
                        '总任务',
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
    return BaseCard(
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
                  color: AppColors.darkGrey,
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
              // 尝试从真实数据获取强度
              int intensityLevel = 0;
              if (_heatmapData.isNotEmpty && index < _heatmapData.length) {
                final completedCount =
                    _heatmapData[index]['completedCount'] as int? ?? 0;
                intensityLevel = (completedCount.clamp(0, 10) / 2).floor();
              } else {
                intensityLevel = index % 5;
              }

              final intensity = intensityLevel / 4.0;
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
        color: AppColorsSecondary.aiInsightBg,
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
    return BottomNav.defaultNav(currentRoute: '/stats');
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
