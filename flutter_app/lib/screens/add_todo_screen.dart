import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/colors.dart';

/// 添加新待办事项页面
class AddTodoScreen extends StatefulWidget {
  const AddTodoScreen({super.key});

  @override
  State<AddTodoScreen> createState() => _AddTodoScreenState();
}

class _AddTodoScreenState extends State<AddTodoScreen> {
  final TextEditingController _taskController = TextEditingController(text: '准备下周的会议');
  bool _aiBreakdownEnabled = true;
  String _selectedPriority = '重要'; // 普通、重要、紧急
  final String _selectedCategory = '工作';
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = const TimeOfDay(hour: 14, minute: 0);

  @override
  void dispose() {
    _taskController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.brandSage,
              onPrimary: Colors.white,
              surface: AppColors.creamBg,
              onSurface: AppColors.darkGrey,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.brandSage,
              onPrimary: Colors.white,
              surface: AppColors.creamBg,
              onSurface: AppColors.darkGrey,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    if (date.year == now.year && date.month == now.month && date.day == now.day) {
      return '今天';
    } else if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day + 1) {
      return '明天';
    } else {
      return '${date.month}月${date.day}日';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // 背景装饰
          _buildBackgroundDecorations(),

          // 模糊遮罩层
          Positioned.fill(
            child: GestureDetector(
              onTap: () => context.pop(),
              child: Container(
                color: AppColors.vitaBlack.withValues(alpha: 0.2),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    color: Colors.transparent,
                  ),
                ),
              ),
            ),
          ),

          // 模态容器
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: GestureDetector(
              onTap: () {}, // 阻止点击穿透
              child: Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.9,
                ),
                decoration: BoxDecoration(
                  color: AppColors.warmCream,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 20,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 拖拽指示器
                    Container(
                      margin: const EdgeInsets.only(top: 16, bottom: 24),
                      width: 48,
                      height: 6,
                      decoration: BoxDecoration(
                        color: AppColors.vitaBlack.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),

                    // 内容区域
                    Flexible(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 头部
                            _buildHeader(),

                            const SizedBox(height: 32),

                            // 任务输入
                            _buildTaskInput(),

                            const SizedBox(height: 32),

                            // AI 智能拆解
                            _buildAIBreakdown(),

                            const SizedBox(height: 24),

                            // 日期与时间
                            _buildDateTimeSection(),

                            const SizedBox(height: 24),

                            // 重要度
                            _buildPrioritySection(),

                            const SizedBox(height: 24),

                            // 分类
                            _buildCategorySection(),

                            const SizedBox(height: 48),

                            // 添加按钮
                            _buildAddButton(),

                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 底部导航
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _buildBottomNav(context),
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
              color: AppColors.brandSage.withValues(alpha: 0.05),
            ),
          ),
        ),
        Positioned(
          bottom: MediaQuery.of(context).size.height * 0.1,
          right: -MediaQuery.of(context).size.width * 0.1,
          child: Container(
            width: MediaQuery.of(context).size.width * 0.4,
            height: MediaQuery.of(context).size.height * 0.4,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.softGold.withValues(alpha: 0.05),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '新待办事项',
          style: GoogleFonts.newsreader(
            fontSize: 24,
            fontStyle: FontStyle.italic,
            color: AppColors.vitaBlack,
          ),
        ),
        GestureDetector(
          onTap: () => context.pop(),
          child: Icon(
            Icons.close,
            color: AppColors.vitaBlack.withValues(alpha: 0.4),
            size: 24,
          ),
        ),
      ],
    );
  }

  Widget _buildTaskInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _taskController,
          autofocus: true,
          style: const TextStyle(
            fontSize: 20,
            color: AppColors.vitaBlack,
            fontFamily: '-apple-system',
          ),
          decoration: InputDecoration(
            hintText: '输入你的目标或任务',
            hintStyle: TextStyle(
              color: AppColors.vitaBlack.withValues(alpha: 0.2),
              fontSize: 20,
            ),
            border: InputBorder.none,
            contentPadding: EdgeInsets.zero,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          height: 1,
          color: AppColors.vitaBlack.withValues(alpha: 0.05),
        ),
      ],
    );
  }

  Widget _buildAIBreakdown() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.vitaBlack.withValues(alpha: 0.05),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.auto_awesome,
            color: AppColors.brandSage,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
              child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'AI 智能拆解',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.vitaBlack,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '自动分析并拆分复杂任务',
                  style: TextStyle(
                    fontSize: 10,
                    color: AppColors.vitaBlack.withValues(alpha: 0.4),
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              setState(() {
                _aiBreakdownEnabled = !_aiBreakdownEnabled;
              });
            },
            child: Container(
              width: 40,
              height: 20,
              decoration: BoxDecoration(
                color: _aiBreakdownEnabled
                    ? AppColors.brandSage
                    : AppColors.vitaBlack.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Stack(
                children: [
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    left: _aiBreakdownEnabled ? 20 : 2,
                    top: 2,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 2,
                            offset: Offset(0, 1),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateTimeSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(
              Icons.calendar_today,
              size: 20,
              color: AppColors.vitaBlack.withValues(alpha: 0.3),
            ),
            const SizedBox(width: 12),
            Text(
              '日期与时间',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.vitaBlack.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
        GestureDetector(
          onTap: () async {
            await _selectDate();
            await _selectTime();
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.sand.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: AppColors.vitaBlack.withValues(alpha: 0.05),
                width: 1,
              ),
            ),
            child: Text(
              '${_formatDate(_selectedDate)}, ${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.vitaBlack.withValues(alpha: 0.6),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPrioritySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.priority_high,
              size: 20,
              color: AppColors.vitaBlack.withValues(alpha: 0.3),
            ),
            const SizedBox(width: 12),
            Text(
              '重要度',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.vitaBlack.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildPriorityButton('普通', '普通'),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildPriorityButton('重要', '重要'),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildPriorityButton('紧急', '紧急'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPriorityButton(String label, String value) {
    final isSelected = _selectedPriority == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPriority = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.brandSage.withValues(alpha: 0.2)
              : AppColors.sand.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppColors.brandSage.withValues(alpha: 0.3)
                : Colors.transparent,
            width: 1,
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
            color: isSelected
                ? AppColors.brandSage
                : AppColors.vitaBlack.withValues(alpha: 0.5),
          ),
        ),
      ),
    );
  }

  Widget _buildCategorySection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(
              Icons.grid_view,
              size: 20,
              color: AppColors.vitaBlack.withValues(alpha: 0.3),
            ),
            const SizedBox(width: 12),
            Text(
              '分类',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.vitaBlack.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
        GestureDetector(
          onTap: () {
            // TODO: 打开分类选择器
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.sand.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: AppColors.vitaBlack.withValues(alpha: 0.05),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.brandSage,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  _selectedCategory,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.vitaBlack.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAddButton() {
    return GestureDetector(
      onTap: () {
        // TODO: 保存任务并拆解
        context.pop();
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.brandSage,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.brandSage.withValues(alpha: 0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.auto_awesome,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            const Text(
              '添加并拆解',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).padding.bottom + 8,
        top: 12,
      ),
      decoration: BoxDecoration(
        color: AppColors.warmCream.withValues(alpha: 0.9),
        border: Border(
          top: BorderSide(
            color: AppColors.vitaBlack.withValues(alpha: 0.05),
            width: 1,
          ),
        ),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(Icons.smart_toy, '助手', false, () {
              context.go('/chat');
            }),
            _buildNavItem(Icons.calendar_today, '日程', true, () {
              context.go('/schedule');
            }),
            _buildNavItem(Icons.explore, '发现', false, () {
              context.go('/discover');
            }),
            _buildNavItem(Icons.bar_chart, '统计', false, () {
              context.go('/stats');
            }),
            _buildNavItem(Icons.settings, '设置', false, () {
              context.go('/settings');
            }),
          ],
        ),
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
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 26,
            color: isActive
                ? AppColors.brandSage
                : AppColors.vitaBlack.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
              color: isActive
                  ? AppColors.brandSage
                  : AppColors.vitaBlack.withValues(alpha: 0.3),
            ),
          ),
        ],
      ),
    );
  }
}
