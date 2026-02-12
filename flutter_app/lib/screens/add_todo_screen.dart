import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/task.dart';
import '../services/api_service.dart';
import '../theme/colors.dart';

/// 添加新待办事项页面
class AddTodoScreen extends StatefulWidget {
  const AddTodoScreen({super.key});

  @override
  State<AddTodoScreen> createState() => _AddTodoScreenState();
}

class _AddTodoScreenState extends State<AddTodoScreen> {
  final TextEditingController _taskController = TextEditingController(text: '准备下周的会议');
  final FocusNode _taskFocusNode = FocusNode();
  final ApiService _apiService = ApiService();

  bool _aiBreakdownEnabled = true;
  String _selectedPriority = '重要';
  String _selectedCategory = '深度工作';
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = const TimeOfDay(hour: 14, minute: 0);
  bool _isLoading = false;
  String? _errorMessage;

  static const List<String> _priorities = ['普通', '重要', '紧急'];
  static const List<Map<String, String>> _categories = [
    {'name': '晨间冥想', 'icon': 'meditation', 'color': '#9DC695'},
    {'name': '深度工作', 'icon': 'auto_awesome', 'color': '#5A8A83'},
    {'name': '社交', 'icon': 'silverware-fork-knife', 'color': '#BFC9C2'},
    {'name': '晚间回顾', 'icon': 'note-edit-outline', 'color': '#D48C70'},
  ];

  @override
  void dispose() {
    _taskController.dispose();
    _taskFocusNode.dispose();
    super.dispose();
  }

  Future<void> _selectDateTime() async {
    final DateTime? pickedDate = await showDatePicker(
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
    if (pickedDate != null) {
      setState(() => _selectedDate = pickedDate);
    }

    if (!mounted) return;
    final TimeOfDay? pickedTime = await showTimePicker(
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
    if (pickedTime != null && mounted) {
      setState(() => _selectedTime = pickedTime);
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diffDays = DateTime(date.year, date.month, date.day)
        .difference(DateTime(now.year, now.month, now.day))
        .inDays;

    if (diffDays == 0) return '今天';
    if (diffDays == 1) return '明天';
    return '${date.month}月${date.day}日';
  }

  String _formatTime(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  TimeOfDay _addMinutes(TimeOfDay time, int minutes) {
    final totalMinutes = time.hour * 60 + time.minute + minutes;
    return TimeOfDay(hour: (totalMinutes ~/ 60) % 24, minute: totalMinutes % 60);
  }

  Future<void> _handleAddTask() async {
    if (_taskController.text.trim().isEmpty) {
      setState(() => _errorMessage = '请输入任务内容');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final categoryConfig = _categories.firstWhere(
        (c) => c['name'] == _selectedCategory,
        orElse: () => _categories[1],
      );

      final endTime = _addMinutes(_selectedTime, 60);

      final task = Task(
        category: _selectedCategory,
        title: _taskController.text.trim(),
        startTime: _formatTime(_selectedTime),
        endTime: _formatTime(endTime),
        taskDate: '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}',
        priority: TaskPriorityExtension.fromValue(_selectedPriority),
        iconName: categoryConfig['icon']!,
        categoryColor: categoryConfig['color']!,
        aiBreakdownEnabled: _aiBreakdownEnabled,
      );

      if (_aiBreakdownEnabled) {
        final subTasks = await _apiService.breakdownTask(
          task.title,
          description: task.description,
        );

        if (subTasks.isNotEmpty) {
          await _apiService.createTask(task);
          for (final subTask in subTasks) {
            await _apiService.createTask(subTask.copyWith(
              taskDate: task.taskDate,
              startTime: task.startTime,
              endTime: task.endTime,
            ));
          }
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('任务已创建并智能拆解'),
                backgroundColor: AppColors.brandSage,
              ),
            );
          }
        } else {
          await _apiService.createTask(task);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('任务已创建'),
                backgroundColor: AppColors.brandSage,
              ),
            );
          }
        }
      } else {
        final createdTask = await _apiService.createTask(task);
        if (createdTask != null && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('任务已创建'),
              backgroundColor: AppColors.brandSage,
            ),
          );
        } else if (mounted) {
          setState(() => _errorMessage = '创建任务失败，请稍后重试');
          return;
        }
      }

      if (mounted) context.pop(true);
    } catch (e) {
      if (mounted) setState(() => _errorMessage = '创建任务失败: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: AppColors.warmCream,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: AppColors.vitaBlack.withValues(alpha: 0.6)),
          onPressed: () => context.pop(),
        ),
        title: Text(
          '新待办事项',
          style: GoogleFonts.newsreader(
            fontSize: 20,
            fontStyle: FontStyle.italic,
            color: AppColors.vitaBlack,
          ),
        ),
        centerTitle: true,
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      _buildTaskInput(),
                      const SizedBox(height: 24),
                      _buildAIBreakdown(),
                      if (_errorMessage != null) ...[
                        const SizedBox(height: 16),
                        _buildErrorMessage(),
                      ],
                      const SizedBox(height: 32),
                      _buildDateTimeSection(),
                      const SizedBox(height: 24),
                      _buildPrioritySection(),
                      const SizedBox(height: 24),
                      _buildCategorySection(),
                      const SizedBox(height: 100), // 底部按钮空间
                    ],
                  ),
                ),
              ),
              _buildAddButton(bottomPadding),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTaskInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _taskController,
          focusNode: _taskFocusNode,
          autofocus: true,
          keyboardType: TextInputType.text,
          textInputAction: TextInputAction.done,
          style: const TextStyle(
            fontSize: 24,
            color: AppColors.vitaBlack,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText: '输入你的目标或任务',
            hintStyle: TextStyle(
              color: AppColors.vitaBlack.withValues(alpha: 0.25),
              fontSize: 24,
              fontWeight: FontWeight.w500,
            ),
            border: InputBorder.none,
            contentPadding: EdgeInsets.zero,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          height: 1,
          color: AppColors.vitaBlack.withValues(alpha: 0.08),
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
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.auto_awesome, color: AppColors.brandSage, size: 24),
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
                    fontSize: 11,
                    color: AppColors.vitaBlack.withValues(alpha: 0.4),
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => setState(() => _aiBreakdownEnabled = !_aiBreakdownEnabled),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 44,
              height: 26,
              decoration: BoxDecoration(
                color: _aiBreakdownEnabled
                    ? AppColors.brandSage
                    : AppColors.vitaBlack.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Padding(
                padding: const EdgeInsets.all(2),
                child: AnimatedAlign(
                  duration: const Duration(milliseconds: 200),
                  alignment: _aiBreakdownEnabled
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    width: 22,
                    height: 22,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
                      ],
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

  Widget _buildErrorMessage() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, size: 18, color: Colors.red.shade400),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _errorMessage!,
              style: TextStyle(fontSize: 13, color: Colors.red.shade400),
            ),
          ),
          GestureDetector(
            onTap: () => setState(() => _errorMessage = null),
            child: Icon(Icons.close, size: 16, color: Colors.red.shade300),
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
            Icon(Icons.calendar_today, size: 20, color: AppColors.vitaBlack.withValues(alpha: 0.3)),
            const SizedBox(width: 12),
            const Text('日期与时间', style: TextStyle(fontSize: 14, color: AppColors.darkGrey)),
          ],
        ),
        GestureDetector(
          onTap: _selectDateTime,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.sand.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${_formatDate(_selectedDate)}, ${_formatTime(_selectedTime)}',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.vitaBlack.withValues(alpha: 0.7),
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
            Icon(Icons.priority_high, size: 20, color: AppColors.vitaBlack.withValues(alpha: 0.3)),
            const SizedBox(width: 12),
            const Text('重要度', style: TextStyle(fontSize: 14, color: AppColors.darkGrey)),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: _priorities.map((priority) {
            final isSelected = _selectedPriority == priority;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(left: priority != _priorities.first ? 8 : 0),
                child: GestureDetector(
                  onTap: () => setState(() => _selectedPriority = priority),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.brandSage.withValues(alpha: 0.15)
                          : AppColors.sand.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.brandSage.withValues(alpha: 0.4)
                            : Colors.transparent,
                      ),
                    ),
                    child: Text(
                      priority,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                        color: isSelected
                            ? AppColors.brandSage
                            : AppColors.vitaBlack.withValues(alpha: 0.5),
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildCategorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.grid_view, size: 20, color: AppColors.vitaBlack.withValues(alpha: 0.3)),
            const SizedBox(width: 12),
            const Text('分类', style: TextStyle(fontSize: 14, color: AppColors.darkGrey)),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: _categories.map((category) {
            final isSelected = _selectedCategory == category['name'];
            final color = Color(int.parse(category['color']!.substring(1), radix: 16) + 0xFF000000);
            return GestureDetector(
              onTap: () => setState(() => _selectedCategory = category['name']!),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? color.withValues(alpha: 0.15) : AppColors.sand.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? color.withValues(alpha: 0.4) : Colors.transparent,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      category['name']!,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                        color: isSelected ? color : AppColors.vitaBlack.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildAddButton(double bottomPadding) {
    return Container(
      padding: EdgeInsets.only(left: 24, right: 24, top: 16, bottom: bottomPadding + 16),
      decoration: BoxDecoration(
        color: AppColors.warmCream,
        border: Border(
          top: BorderSide(color: AppColors.vitaBlack.withValues(alpha: 0.05)),
        ),
      ),
      child: GestureDetector(
        onTap: _isLoading ? null : _handleAddTask,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: _isLoading ? AppColors.brandSage.withValues(alpha: 0.6) : AppColors.brandSage,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.brandSage.withValues(alpha: 0.25),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: _isLoading
              ? const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                    SizedBox(width: 12),
                    Text('创建中...', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(_aiBreakdownEnabled ? Icons.auto_awesome : Icons.add, color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      _aiBreakdownEnabled ? '添加并拆解' : '添加任务',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
