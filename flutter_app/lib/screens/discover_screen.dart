import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../widgets/bottom_nav.dart';
import '../widgets/page_background.dart';
import '../widgets/base_card.dart';

/// 发现页面
class DiscoverScreen extends StatelessWidget {
  const DiscoverScreen({super.key});

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
                _buildHeader(),

                // 内容区域
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        const SizedBox(height: 16),
                        // 摇一摇推荐卡片
                        _buildShakeCard(),
                        const SizedBox(height: 40),

                        // 规划模版
                        _buildTemplatesSection(),
                        const SizedBox(height: 40),

                        // 精选生活方式
                        _buildFeaturedSection(),
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
    return PageBackground(
      topLeft: const BackgroundCircle(
        widthFactor: 0.4,
        heightFactor: 0.4,
        color: AppColors.brandSage,
        alpha: 0.05,
      ),
      bottomRight: const BackgroundCircle(
        widthFactor: 0.4,
        heightFactor: 0.4,
        color: AppColors.softGold,
        alpha: 0.1,
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.brandSage.withValues(alpha: 0.1),
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  size: 20,
                  color: AppColors.brandSage,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                '发现',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  color: AppColors.darkGrey,
                ),
              ),
            ],
          ),
          Row(
            children: [
              Icon(Icons.search, color: AppColors.darkGrey.withValues(alpha: 0.4)),
              const SizedBox(width: 16),
              Icon(Icons.more_horiz, color: AppColors.darkGrey.withValues(alpha: 0.4)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildShakeCard() {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            AppColors.creamBg,
          ],
        ),
        borderRadius: BorderRadius.circular(40),
        border: Border.all(
          color: AppColors.brandSage.withValues(alpha: 0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.brandSage.withValues(alpha: 0.15),
            blurRadius: 50,
            offset: const Offset(0, 20),
          ),
          BoxShadow(
            color: AppColors.softGold.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.brandSage.withValues(alpha: 0.05),
            ),
            child: const Icon(
              Icons.vibration,
              size: 32,
              color: AppColors.brandSage,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            '为您推荐',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 3,
              color: AppColors.brandSage,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            '"在午后，\n来一次专注的冥想。"',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w400,
              fontStyle: FontStyle.italic,
              height: 1.5,
              color: AppColors.darkGrey,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Vita 观察到您最近压力略高，建议通过 10 分钟的静坐来恢复精力。',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.mutedGrey,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.darkGrey,
              borderRadius: BorderRadius.circular(999),
            ),
            child: const Text(
              '开始任务',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                letterSpacing: 2,
                color: AppColors.creamBg,
              ),
            ),
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.refresh,
                size: 14,
                color: AppColors.mutedGrey.withValues(alpha: 0.6),
              ),
              const SizedBox(width: 6),
              Text(
                '摇一摇换一个建议',
                style: TextStyle(
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                  letterSpacing: 2,
                  color: AppColors.mutedGrey.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTemplatesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              '规划模版',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: AppColors.darkGrey,
              ),
            ),
            Text(
              '查看全部',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 2,
                color: AppColors.brandSage,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildTemplateItem(
          icon: Icons.self_improvement,
          title: '晨间唤醒流',
          subtitle: '3 个动作 • 15 分钟',
        ),
        const SizedBox(height: 8),
        _buildTemplateItem(
          icon: Icons.menu_book,
          title: '深层阅读周期',
          subtitle: '专注模式 • 45 分钟',
        ),
        const SizedBox(height: 8),
        _buildTemplateItem(
          icon: Icons.nightlight,
          title: '睡前复盘仪式',
          subtitle: '日志记录 • 10 分钟',
        ),
      ],
    );
  }

    Widget _buildTemplateItem({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return BaseCard.rounded(
      padding: EdgeInsets.zero,
      child: CardListItem(
        icon: icon,
        title: title,
        subtitle: subtitle,
        padding: const EdgeInsets.all(20),
      ),
    );
  }

  Widget _buildFeaturedSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '精选生活方式',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: AppColors.darkGrey,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          height: 208,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(32),
            border: Border.all(
              color: AppColors.brandSage.withValues(alpha: 0.05),
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
          child: Stack(
            children: [
              // 渐变背景
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(32),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        AppColors.softAmber.withValues(alpha: 0.8),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              // 内容
              Positioned(
                bottom: 32,
                left: 32,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.brandSage,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'FEATURED',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 3,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      '"极简主义者的日程表"',
                      style: TextStyle(
                        fontSize: 24,
                        fontStyle: FontStyle.italic,
                        color: AppColors.darkGrey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '由 1,240 位 Vita 用户收藏',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.mutedGrey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

      Widget _buildBottomNav(BuildContext context) {
    return BottomNav.defaultNav(currentRoute: '/discover');
  }
}
