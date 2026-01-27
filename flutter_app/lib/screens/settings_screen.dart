import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/colors.dart';

/// 设置页面
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _darkMode = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: Stack(
        children: [
          // 背景装饰
          _buildBackgroundDecorations(),

          // 主内容
          SafeArea(
            child: Column(
              children: [
                // 头部
                _buildHeader(),

                // 内容区域
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        // 用户资料区
                        _buildProfileSection(),

                        const SizedBox(height: 32),

                        // 视觉风格
                        _buildSection(
                          '视觉风格',
                          [
                            _buildSettingItem(
                              icon: Icons.dark_mode_outlined,
                              title: '暗色模式',
                              isToggle: true,
                              toggleValue: _darkMode,
                              onToggle: (value) {
                                setState(() {
                                  _darkMode = value;
                                });
                              },
                            ),
                            _buildSettingItem(
                              icon: Icons.palette_outlined,
                              title: '主题配色',
                              value: 'Sage & Slate',
                            ),
                            _buildSettingItem(
                              icon: Icons.text_fields,
                              title: '字体偏好',
                              showBorder: false,
                            ),
                          ],
                        ),

                        const SizedBox(height: 32),

                        // 智能偏好
                        _buildSection(
                          '智能偏好',
                          [
                            _buildSettingItem(
                              icon: Icons.auto_awesome_outlined,
                              title: 'AI 助手灵敏度',
                              value: '沉浸式',
                            ),
                            _buildSettingItem(
                              icon: Icons.notifications_active_outlined,
                              title: '通知频率',
                              value: '仅重要事项',
                              showBorder: false,
                            ),
                          ],
                        ),

                        const SizedBox(height: 32),

                        // 账号与数据
                        _buildSection(
                          '账号与数据',
                          [
                            _buildSettingItem(
                              icon: Icons.cloud_sync_outlined,
                              title: '云同步状态',
                              value: '已更新',
                              valueColor: AppColors.primary,
                            ),
                            _buildSettingItem(
                              icon: Icons.logout,
                              title: '退出登录',
                              showArrow: false,
                              showBorder: false,
                              isDanger: true,
                            ),
                          ],
                        ),

                        const SizedBox(height: 48),

                        // 底部格言
                        _buildFooter(),

                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),

                // 底部导航
                _buildBottomNav(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackgroundDecorations() {
    return Stack(
      children: [
        Positioned(
          top: -MediaQuery.of(context).size.height * 0.1,
          left: -MediaQuery.of(context).size.width * 0.1,
          child: Container(
            width: MediaQuery.of(context).size.width * 0.5,
            height: MediaQuery.of(context).size.height * 0.5,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.brandSage.withValues(alpha: 0.1),
            ),
          ),
        ),
        Positioned(
          bottom: -MediaQuery.of(context).size.height * 0.1,
          right: -MediaQuery.of(context).size.width * 0.1,
          child: Container(
            width: MediaQuery.of(context).size.width * 0.5,
            height: MediaQuery.of(context).size.height * 0.5,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.brandTeal.withValues(alpha: 0.1),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.go('/chat'),
            child: Row(
              children: [
                Icon(
                  Icons.chevron_left,
                  size: 28,
                  color: AppColors.brandSage,
                ),
                Text(
                  '返回',
                  style: TextStyle(
                    fontSize: 17,
                    color: AppColors.brandSage,
                  ),
                ),
              ],
            ),
          ),
          const Expanded(
            child: Text(
              '个性化设置',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w500,
                color: AppColors.onSurface,
              ),
            ),
          ),
          const SizedBox(width: 60),
        ],
      ),
    );
  }

  Widget _buildProfileSection() {
    return Column(
      children: [
        const SizedBox(height: 24),

        // 头像
        Stack(
          children: [
            Container(
              width: 96,
              height: 96,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.brandSage.withValues(alpha: 0.3),
                  width: 2,
                ),
                color: AppColors.slateGrey.withValues(alpha: 0.5),
              ),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.brandSage,
                      AppColors.brandTeal,
                    ],
                  ),
                ),
                child: const Center(
                  child: Text(
                    'V',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      fontStyle: FontStyle.italic,
                      color: AppColors.backgroundDark,
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.edit,
                  size: 14,
                  color: AppColors.backgroundDark,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // 用户名
        const Text(
          '林之境',
          style: TextStyle(
            fontSize: 26,
            fontStyle: FontStyle.italic,
            color: AppColors.onSurface,
          ),
        ),

        const SizedBox(height: 4),

        // 会员等级
        Text(
          'VITA PREMIUM EXPLORER',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            letterSpacing: 3,
            color: AppColors.brandSage.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildSection(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, bottom: 8),
          child: Text(
            title.toUpperCase(),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              letterSpacing: 2,
              color: AppColors.brandSage.withValues(alpha: 0.4),
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.charcoalDark.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.white05,
              width: 1,
            ),
          ),
          child: Column(children: items),
        ),
      ],
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    String? value,
    Color? valueColor,
    bool showArrow = true,
    bool showBorder = true,
    bool isToggle = false,
    bool toggleValue = false,
    ValueChanged<bool>? onToggle,
    bool isDanger = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: showBorder
            ? Border(
                bottom: BorderSide(
                  color: AppColors.white05,
                  width: 1,
                ),
              )
            : null,
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 22,
            color: isDanger ? AppColors.danger : AppColors.brandSage,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 17,
                color: isDanger ? AppColors.danger : AppColors.onSurface,
              ),
            ),
          ),
          if (isToggle)
            Switch(
              value: toggleValue,
              onChanged: onToggle,
            )
          else ...[
            if (value != null)
              Text(
                value,
                style: TextStyle(
                  fontSize: 15,
                  fontStyle: FontStyle.italic,
                  color: valueColor ?? AppColors.brandSage.withValues(alpha: 0.6),
                ),
              ),
            if (showArrow) ...[
              const SizedBox(width: 4),
              Icon(
                Icons.chevron_right,
                size: 20,
                color: AppColors.white20,
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        Text(
          '"在微小中，见终生"',
          style: TextStyle(
            fontSize: 14,
            fontStyle: FontStyle.italic,
            letterSpacing: 1,
            color: AppColors.brandSage.withValues(alpha: 0.4),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            3,
            (index) => Container(
              width: 4,
              height: 4,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.brandSage.withValues(alpha: 0.2),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNav() {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: AppColors.backgroundDark.withValues(alpha: 0.8),
        border: Border(
          top: BorderSide(
            color: AppColors.white05,
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(Icons.calendar_today_outlined, '日程', false, () {
            context.go('/schedule');
          }),
          _buildNavItem(Icons.show_chart, '洞察', false, () {}),
          _buildNavItem(Icons.smart_toy_outlined, 'AI 助手', false, () {
            context.go('/chat');
          }),
          _buildNavItem(Icons.settings, '设置', true, () {}),
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
            size: 24,
            color: isActive
                ? AppColors.brandSage
                : AppColors.brandSage.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: isActive
                  ? AppColors.brandSage
                  : AppColors.brandSage.withValues(alpha: 0.4),
            ),
          ),
        ],
      ),
    );
  }
}
