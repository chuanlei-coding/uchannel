import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/task.dart';
import '../services/api_service.dart';
import '../theme/colors.dart';
import '../widgets/bottom_nav.dart';
import '../widgets/page_background.dart';
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
  final ApiService _apiService = ApiService();
  final List<Task> _tasks = [];
  List<Task> _filteredTasks = [];
  bool _isLoading = true;
  String? _errorMessage;
  String _searchQuery = '';
  String _statusFilter = 'all'; // 'all', 'pending', 'completed', 'cancelled'
  bool _isSearchVisible = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final tasks = await _apiService.getAllTasks();
      if (mounted) {
        setState(() {
          _tasks.clear();
          _tasks.addAll(tasks);
          _applyFilters();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = '加载任务失败: $e';
          _isLoading = false;
        });
      }
    }
  }

  void _applyFilters() {
    _filteredTasks = _tasks.where((task) {
      // Status filter
      if (_statusFilter != 'all') {
        if (_statusFilter == 'pending' && task.status != TaskStatus.pending) return false;
        if (_statusFilter == 'completed' && task.status != TaskStatus.completed) return false;
        if (_statusFilter == 'cancelled' && task.status != TaskStatus.cancelled) return false;
      }
      // Search filter
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        return task.title.toLowerCase().contains(query) ||
            (task.description?.toLowerCase().contains(query) ?? false) ||
            task.category.toLowerCase().contains(query);
      }
      return true;
    }).toList();
  }

  Future<void> _completeTask(int? taskId) async {
    if (taskId == null) return;
    try {
      await _apiService.completeTask(taskId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('任务已完成')),
        );
        _loadTasks();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('完成失败: $e')),
        );
      }
    }
  }

  Future<void> _cancelTask(int? taskId) async {
    if (taskId == null) return;
    try {
      await _apiService.cancelTask(taskId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('任务已取消')),
        );
        _loadTasks();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('取消失败: $e')),
        );
      }
    }
  }

  Future<void> _deleteTask(int? taskId) async {
    if (taskId == null) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: const Text('确定要删除这个任务吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('删除'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _apiService.deleteTask(taskId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('任务已删除')),
          );
          _loadTasks();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('删除失败: $e')),
          );
        }
      }
    }
  }

  void _showTaskOptions(Task task) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              task.title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: AppColors.darkGrey,
              ),
            ),
            const SizedBox(height: 16),
            if (task.status == TaskStatus.pending) ...[
              ListTile(
                leading: const Icon(Icons.check_circle, color: AppColors.brandSage),
                title: const Text('标记完成'),
                onTap: () {
                  Navigator.pop(context);
                  _completeTask(task.id);
                },
              ),
              ListTile(
                leading: const Icon(Icons.cancel, color: AppColors.terracotta),
                title: const Text('取消任务'),
                onTap: () {
                  Navigator.pop(context);
                  _cancelTask(task.id);
                },
              ),
            ],
            ListTile(
              leading: const Icon(Icons.edit, color: AppColors.brandTeal),
              title: const Text('编辑任务'),
              onTap: () async {
                Navigator.pop(context);
                final result = await context.push<bool>('/add-todo?taskId=${task.id}');
                if (result == true && mounted) {
                  _loadTasks();
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('删除任务'),
              onTap: () {
                Navigator.pop(context);
                _deleteTask(task.id);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
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

                // 筛选栏
                _buildFilterBar(),

                // 标签页
                _buildTabs(),

                // 内容区域
                Expanded(
                  child: _buildContent(),
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
    return PageBackground.leftAligned();
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
                onPressed: _loadTasks,
                icon: const Icon(
                  Icons.refresh,
                  color: AppColors.darkGrey,
                ),
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    _isSearchVisible = !_isSearchVisible;
                    if (!_isSearchVisible) {
                      _searchQuery = '';
                      _searchController.clear();
                      _applyFilters();
                    }
                  });
                },
                icon: Icon(
                  _isSearchVisible ? Icons.close : Icons.search,
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

  Widget _buildFilterBar() {
    if (!_isSearchVisible) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Column(
        children: [
          // Search field
          TextField(
            controller: _searchController,
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
                _applyFilters();
              });
            },
            decoration: InputDecoration(
              hintText: '搜索任务...',
              hintStyle: TextStyle(color: AppColors.softGrey),
              prefixIcon: const Icon(Icons.search, color: AppColors.softGrey),
              filled: true,
              fillColor: AppColors.softIvory,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
          const SizedBox(height: 8),
          // Status filters
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('全部', 'all'),
                const SizedBox(width: 8),
                _buildFilterChip('待处理', 'pending'),
                const SizedBox(width: 8),
                _buildFilterChip('已完成', 'completed'),
                const SizedBox(width: 8),
                _buildFilterChip('已取消', 'cancelled'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _statusFilter == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _statusFilter = value;
          _applyFilters();
        });
      },
      selectedColor: AppColors.brandSage.withValues(alpha: 0.2),
      checkmarkColor: AppColors.brandSage,
      backgroundColor: AppColors.softIvory,
      labelStyle: TextStyle(
        color: isSelected ? AppColors.brandSage : AppColors.softGrey,
        fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: isSelected ? AppColors.brandSage : Colors.transparent,
        ),
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

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppColors.brandSage,
        ),
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
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.darkGrey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadTasks,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.brandSage,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('重试'),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 日期区域
          _buildDateSection(),

          // 任务列表
          if (_filteredTasks.isEmpty) ...[
            const SizedBox(height: 48),
            Center(
              child: Column(
                children: [
                  Icon(
                    Icons.event_available,
                    size: 64,
                    color: AppColors.brandSage.withValues(alpha: 0.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _searchQuery.isNotEmpty || _statusFilter != 'all'
                        ? '没有找到匹配的任务'
                        : '今天还没有任务',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.darkGrey.withValues(alpha: 0.5),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _searchQuery.isNotEmpty || _statusFilter != 'all'
                        ? '尝试调整筛选条件'
                        : '点击右下角按钮添加新任务',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.darkGrey.withValues(alpha: 0.3),
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            ..._filteredTasks.map((task) => GestureDetector(
              onTap: () async {
                final result = await context.push<bool>('/add-todo?taskId=${task.id}');
                if (result == true && mounted) {
                  _loadTasks();
                }
              },
              onLongPress: () => _showTaskOptions(task),
              child: TaskCard(task: task),
            )),
          ],

          const SizedBox(height: 80),
        ],
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
      onTap: () async {
        // 等待添加任务页面返回，如果返回 true 则刷新任务列表
        final result = await context.push<bool>('/add-todo');
        if (result == true && mounted) {
          _loadTasks();
        }
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
    return BottomNav.defaultNav(currentRoute: '/schedule');
  }
}
