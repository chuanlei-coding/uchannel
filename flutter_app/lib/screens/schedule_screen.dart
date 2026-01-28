import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/task.dart';
import '../theme/colors.dart';
import '../widgets/task_card.dart';

/// 日程页面
class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _tabs = ['日', '周', '月', '年', '生涯'];
  final List<Task> _tasks = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _loadTasks();
  }

  void _loadTasks() {
    setState(() {
      _tasks.addAll([
        Task(
          id: '1',
          category: '晨间冥想',
          title: '内观与呼吸练习',
          time: '07:00 - 07:30',
          iconName: 'meditation',
          categoryColor: '#9DC695',
        ),
        Task(
          id: '2',
          category: '深度工作',
          title: 'Vita 界面设计迭代',
          time: '09:00 - 11:30',
          description: '完善 Android 端的 Material 3 适配方案，优化排版视觉节奏。',
          tag: TaskTag.highPriority,
          iconName: 'auto_awesome',
          categoryColor: '#5A8A83',
        ),
        Task(
          id: '3',
          category: '社交',
          title: '与团队午餐',
          time: '12:00 - 13:30',
          iconName: 'silverware-fork-knife',
          categoryColor: '#BFC9C2',
        ),
        Task(
          id: '4',
          category: '晚间回顾',
          title: '每日复盘与明日规划',
          time: '21:30 - 22:00',
          iconName: 'note-edit-outline',
          categoryColor: '#9DC695',
        ),
      ]);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.creamBg,
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

                // 标签页
                _buildTabs(),

                // 内容区域
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 日期区域
                        _buildDateSection(),

                        // 任务列表
                        ..._tasks.map((task) => TaskCard(task: task)),

                        const SizedBox(height: 80),
                      ],
                    ),
                  ),
                ),

                // 底部导航
                _buildBottomNav(),
              ],
            ),
          ),

          // 悬浮添加按钮
          Positioned(
            bottom: 100,
            right: 24,
            child: _buildFloatingButton(),
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
            height: MediaQuery.of(context).size.height * 0.4,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.brandSage.withValues(alpha: 0.05),
            ),
          ),
        ),
        Positioned(
          bottom: MediaQuery.of(context).size.height * 0.1,
          left: -MediaQuery.of(context).size.width * 0.1,
          child: Container(
            width: MediaQuery.of(context).size.width * 0.4,
            height: MediaQuery.of(context).size.height * 0.3,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.brandTeal.withValues(alpha: 0.05),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Vita',
            style: TextStyle(
              fontSize: 24,
              fontStyle: FontStyle.italic,
              color: AppColors.brandSage,
            ),
          ),
          Row(
            children: [
              IconButton(
                onPressed: () {},
                icon: const Icon(
                  Icons.search,
                  color: AppColors.darkGrey,
                ),
              ),
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.brandTeal.withValues(alpha: 0.2),
                  border: Border.all(
                    color: AppColors.brandTeal.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: const Icon(
                  Icons.person,
                  size: 18,
                  color: AppColors.brandSage,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppColors.darkGrey.withValues(alpha: 0.05),
            width: 1,
          ),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: AppColors.brandSage,
        unselectedLabelColor: AppColors.softGrey,
        labelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        indicatorColor: AppColors.brandSage,
        indicatorWeight: 3,
        tabs: _tabs.map((tab) => Tab(text: tab)).toList(),
      ),
    );
  }

  Widget _buildDateSection() {
    final now = DateTime.now();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${now.month}月${now.day}日',
            style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w300,
              color: AppColors.darkGrey,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '星期${_getWeekday(now.weekday)} · 岁序更替，步履轻盈',
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.softGrey,
            ),
          ),
        ],
      ),
    );
  }

  String _getWeekday(int weekday) {
    const weekdays = ['一', '二', '三', '四', '五', '六', '日'];
    return weekdays[weekday - 1];
  }

  Widget _buildFloatingButton() {
    return GestureDetector(
      onTap: () {
        context.push('/add-todo');
      },
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: AppColors.brandSage,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(
          Icons.add,
          size: 30,
          color: AppColors.darkGrey,
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      height: 64,
      decoration: BoxDecoration(
        color: AppColors.softIvory,
        border: Border(
          top: BorderSide(
            color: AppColors.darkGrey.withValues(alpha: 0.05),
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(Icons.calendar_today, '日程', true, () {}),
          _buildNavItem(Icons.show_chart, '洞察', false, () {}),
          _buildNavItem(Icons.smart_toy_outlined, 'AI 助手', false, () {
            context.go('/chat');
          }),
          _buildNavItem(Icons.settings_outlined, '设置', false, () {
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
            size: 24,
            color: isActive ? AppColors.brandSage : AppColors.softGrey,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: isActive ? AppColors.brandSage : AppColors.softGrey,
            ),
          ),
        ],
      ),
    );
  }
}
