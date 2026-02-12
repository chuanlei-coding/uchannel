import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/colors.dart';
import '../widgets/bottom_nav.dart';
import '../widgets/page_header.dart';
import '../widgets/setting_tile.dart';
import '../services/settings_service.dart';

/// 设置页面
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  void initState() {
    super.initState();
    // 初始化设置服务
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SettingsService>().init();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.creamBg,
      body: SafeArea(
        child: Consumer<SettingsService>(
          builder: (context, settings, child) {
            return Column(
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
                        _buildProfileSection(settings),

                        const SizedBox(height: 32),

                        // 视觉风格
                        SettingSection(
                          title: '视觉风格',
                          items: [
                            SettingTile.toggle(
                              icon: Icons.dark_mode_outlined,
                              title: '暗色模式',
                              value: settings.darkMode,
                              onToggle: (value) {
                                settings.setDarkMode(value);
                              },
                            ),
                            SettingTile.normal(
                              icon: Icons.palette_outlined,
                              title: '主题配色',
                              subtitle: settings.themeColor,
                              valueColor: SettingsService.themeColorMap[settings.themeColor],
                              onTap: () => _showThemeColorDialog(context, settings),
                            ),
                            SettingTile.normal(
                              icon: Icons.text_fields,
                              title: '字体偏好',
                              subtitle: SettingsService.fontSizeDisplayNames[settings.fontSize] ?? '中',
                              showBorder: false,
                              onTap: () => _showFontSizeDialog(context, settings),
                            ),
                          ],
                        ),

                        const SizedBox(height: 32),

                        // 智能偏好
                        SettingSection(
                          title: '智能偏好',
                          items: [
                            SettingTile.normal(
                              icon: Icons.auto_awesome_outlined,
                              title: 'AI 助手灵敏度',
                              subtitle: SettingsService.aiSensitivityDisplayNames[settings.aiSensitivity] ?? '沉浸式',
                              onTap: () => _showAiSensitivityDialog(context, settings),
                            ),
                            SettingTile.normal(
                              icon: Icons.notifications_active_outlined,
                              title: '通知频率',
                              subtitle: SettingsService.notificationFrequencyDisplayNames[settings.notificationFrequency] ?? '仅重要事项',
                              showBorder: false,
                              onTap: () => _showNotificationFrequencyDialog(context, settings),
                            ),
                          ],
                        ),

                        const SizedBox(height: 32),

                        // 账号与数据
                        SettingSection(
                          title: '账号与数据',
                          items: [
                            SettingTile.normal(
                              icon: Icons.cloud_sync_outlined,
                              title: '云同步状态',
                              subtitle: '已更新',
                              valueColor: AppColors.brandSage,
                              onTap: () => _showSyncDialog(context),
                            ),
                            SettingTile.danger(
                              icon: Icons.logout,
                              title: '退出登录',
                              onTap: () => _showLogoutDialog(context),
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
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return PageHeader.centered(
      title: '个性化设置',
      showBack: true,
    );
  }

  Widget _buildProfileSection(SettingsService settings) {
    return Column(
      children: [
        const SizedBox(height: 24),

        // 头像
        Stack(
          children: [
            GestureDetector(
              onTap: () => _showEditNameDialog(context, settings),
              child: Container(
                width: 96,
                height: 96,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.brandSage.withValues(alpha: 0.3),
                    width: 2,
                  ),
                  color: AppColors.softGrey.withValues(alpha: 0.5),
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
                  child: Center(
                    child: Text(
                      settings.userName.isNotEmpty ? settings.userName[0].toUpperCase() : 'V',
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        fontStyle: FontStyle.italic,
                        color: AppColors.creamBg,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: GestureDetector(
                onTap: () => _showEditNameDialog(context, settings),
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: AppColors.brandSage,
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
                    color: AppColors.creamBg,
                  ),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // 用户名（可点击编辑）
        GestureDetector(
          onTap: () => _showEditNameDialog(context, settings),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                settings.userName,
                style: const TextStyle(
                  fontSize: 26,
                  fontStyle: FontStyle.italic,
                  color: AppColors.darkGrey,
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.edit,
                size: 16,
                color: AppColors.brandSage.withValues(alpha: 0.5),
              ),
            ],
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
    return BottomNav.defaultNav(currentRoute: '/settings');
  }

  // ==================== 选择对话框 ====================

  /// 主题颜色选择对话框
  void _showThemeColorDialog(BuildContext context, SettingsService settings) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('选择主题配色'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: SettingsService.themeColorOptions.map((color) {
            final isSelected = settings.themeColor == color;
            final colorValue = SettingsService.themeColorMap[color];
            return ListTile(
              leading: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: colorValue,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
                ),
              ),
              title: Text(color),
              trailing: isSelected ? const Icon(Icons.check, color: AppColors.brandSage) : null,
              onTap: () {
                settings.setThemeColor(color);
                Navigator.pop(context);
                _showApplyThemeDialog(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  /// 字体大小选择对话框
  void _showFontSizeDialog(BuildContext context, SettingsService settings) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('选择字体大小'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: SettingsService.fontSizeOptions.map((size) {
            final isSelected = settings.fontSize == size;
            final displayName = SettingsService.fontSizeDisplayNames[size] ?? size;
            return ListTile(
              title: Text(displayName),
              trailing: isSelected ? const Icon(Icons.check, color: AppColors.brandSage) : null,
              onTap: () {
                settings.setFontSize(size);
                Navigator.pop(context);
                _showApplyRestartHint(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  /// AI 灵敏度选择对话框
  void _showAiSensitivityDialog(BuildContext context, SettingsService settings) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('AI 助手灵敏度'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: SettingsService.aiSensitivityOptions.map((level) {
            final isSelected = settings.aiSensitivity == level;
            final displayName = SettingsService.aiSensitivityDisplayNames[level] ?? level;
            return ListTile(
              title: Text(displayName),
              trailing: isSelected ? const Icon(Icons.check, color: AppColors.brandSage) : null,
              onTap: () {
                settings.setAiSensitivity(level);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('AI 助手灵敏度已设置为：$displayName'),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  /// 通知频率选择对话框
  void _showNotificationFrequencyDialog(BuildContext context, SettingsService settings) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('通知频率'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: SettingsService.notificationFrequencyOptions.map((freq) {
            final isSelected = settings.notificationFrequency == freq;
            final displayName = SettingsService.notificationFrequencyDisplayNames[freq] ?? freq;
            return ListTile(
              title: Text(displayName),
              trailing: isSelected ? const Icon(Icons.check, color: AppColors.brandSage) : null,
              onTap: () {
                settings.setNotificationFrequency(freq);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('通知频率已设置为：$displayName'),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  /// 编辑用户名对话框
  void _showEditNameDialog(BuildContext context, SettingsService settings) {
    final controller = TextEditingController(text: settings.userName);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('编辑昵称'),
        content: TextField(
          controller: controller,
          maxLength: 20,
          decoration: const InputDecoration(
            hintText: '请输入昵称',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                settings.setUserName(controller.text.trim());
              }
              Navigator.pop(context);
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }

  /// 云同步对话框
  void _showSyncDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('云同步'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: AppColors.brandSage),
            SizedBox(height: 16),
            Text('正在同步数据...'),
          ],
        ),
      ),
    );

    // 模拟同步
    Future.delayed(const Duration(seconds: 2), () {
      if (!context.mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('数据同步完成'),
          duration: Duration(seconds: 2),
        ),
      );
    });
  }

  /// 退出登录对话框
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('退出登录'),
        content: const Text('确定要退出登录吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // 这里可以添加退出登录逻辑
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('已退出登录'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.danger),
            child: const Text('退出'),
          ),
        ],
      ),
    );
  }

  /// 主题应用提示
  void _showApplyThemeDialog(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('主题配色已更新，重启应用后完全生效'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  /// 重启提示
  void _showApplyRestartHint(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('字体大小已更新，重启应用后完全生效'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}
