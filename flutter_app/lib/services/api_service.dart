import 'package:dio/dio.dart';
import '../models/message.dart';
import '../models/task.dart';

/// API 服务
class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'http://192.168.1.46:8080/api',
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
    headers: {
      'Content-Type': 'application/json',
    },
    validateStatus: (status) {
      return status != null && status < 500;
    },
  ));

  String? _conversationId;

  // ==================== 聊天相关 ====================

  /// 获取当前会话ID
  String? get conversationId => _conversationId;

  /// 发送消息
  Future<Message?> sendMessage(String content) async {
    try {
      final response = await _dio.post('/chat/send', data: {
        'message': content,
        'conversationId': _conversationId,
      });

      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'];
        _conversationId = data['conversationId'];

        return Message(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          content: data['response'] ?? '',
          sender: MessageSender.assistant,
          timestamp: DateTime.now(),
        );
      }
    } catch (e) {
      // Error logged silently, consider adding proper logging
    }
    return null;
  }

  /// 获取历史消息
  Future<List<Message>> getHistory() async {
    if (_conversationId == null) return [];

    try {
      final response = await _dio.get('/chat/history/$_conversationId');

      if (response.statusCode == 200 && response.data['success'] == true) {
        final messages = response.data['messages'] as List;
        return messages.map((m) => Message.fromJson(m)).toList();
      }
    } catch (e) {
      // Error logged silently, consider adding proper logging
    }
    return [];
  }

  /// 健康检查
  Future<bool> healthCheck() async {
    try {
      final response = await _dio.get('/chat/health');
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // ==================== 任务相关 ====================

  /// 创建任务
  Future<Task?> createTask(Task task) async {
    try {
      final response = await _dio.post(
        '/tasks',
        data: task.toCreateRequest(),
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return Task.fromJson(response.data['task']);
      }
    } catch (e) {
      // Error logged silently, consider adding proper logging
    }
    return null;
  }

  /// 获取所有任务
  Future<List<Task>> getAllTasks() async {
    try {
      final response = await _dio.get('/tasks');

      if (response.statusCode == 200 && response.data['success'] == true) {
        final tasks = response.data['tasks'] as List;
        return tasks.map((t) => Task.fromJson(t)).toList();
      }
    } catch (e) {
      // Error logged silently, consider adding proper logging
    }
    return [];
  }

  /// 获取指定日期的任务
  Future<List<Task>> getTasksByDate(String date) async {
    try {
      final response = await _dio.get('/tasks/date/$date');

      if (response.statusCode == 200 && response.data['success'] == true) {
        final tasks = response.data['tasks'] as List;
        return tasks.map((t) => Task.fromJson(t)).toList();
      }
    } catch (e) {
      // Error logged silently, consider adding proper logging
    }
    return [];
  }

  /// 获取待处理任务
  Future<List<Task>> getPendingTasks() async {
    try {
      final response = await _dio.get('/tasks/pending');

      if (response.statusCode == 200 && response.data['success'] == true) {
        final tasks = response.data['tasks'] as List;
        return tasks.map((t) => Task.fromJson(t)).toList();
      }
    } catch (e) {
      // Error logged silently, consider adding proper logging
    }
    return [];
  }

  /// 获取已完成任务
  Future<List<Task>> getCompletedTasks() async {
    try {
      final response = await _dio.get('/tasks/completed');

      if (response.statusCode == 200 && response.data['success'] == true) {
        final tasks = response.data['tasks'] as List;
        return tasks.map((t) => Task.fromJson(t)).toList();
      }
    } catch (e) {
      // Error logged silently, consider adding proper logging
    }
    return [];
  }

  /// 根据ID获取任务
  Future<Task?> getTaskById(int id) async {
    try {
      final response = await _dio.get('/tasks/$id');

      if (response.statusCode == 200 && response.data['success'] == true) {
        return Task.fromJson(response.data['task']);
      }
    } catch (e) {
      // Error logged silently, consider adding proper logging
    }
    return null;
  }

  /// 更新任务
  Future<Task?> updateTask(int id, Task task) async {
    try {
      final response = await _dio.put(
        '/tasks/$id',
        data: task.toUpdateRequest(),
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return Task.fromJson(response.data['task']);
      }
    } catch (e) {
      // Error logged silently, consider adding proper logging
    }
    return null;
  }

  /// 完成任务
  Future<bool> completeTask(int id) async {
    try {
      final response = await _dio.post('/tasks/$id/complete');
      return response.statusCode == 200 && response.data['success'] == true;
    } catch (e) {
      return false;
    }
  }

  /// 取消任务
  Future<bool> cancelTask(int id) async {
    try {
      final response = await _dio.post('/tasks/$id/cancel');
      return response.statusCode == 200 && response.data['success'] == true;
    } catch (e) {
      return false;
    }
  }

  /// 删除任务
  Future<bool> deleteTask(int id) async {
    try {
      final response = await _dio.delete('/tasks/$id');
      return response.statusCode == 200 && response.data['success'] == true;
    } catch (e) {
      return false;
    }
  }

  /// AI智能拆解任务
  Future<List<Task>> breakdownTask(String title, {String? description}) async {
    try {
      final response = await _dio.post(
        '/tasks/breakdown',
        data: {
          'title': title,
          if (description != null) 'description': description,
        },
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final subTasks = response.data['subTasks'] as List;
        return subTasks.map((t) => Task.fromJson(t)).toList();
      }
    } catch (e) {
      // Error logged silently, consider adding proper logging
    }
    return [];
  }

  // ==================== 统计相关 ====================

  /// 统计数据概览
  Future<Map<String, dynamic>?> getOverviewStats() async {
    try {
      final response = await _dio.get('/stats/overview');

      if (response.statusCode == 200 && response.data['success'] == true) {
        return response.data['stats'] as Map<String, dynamic>;
      }
    } catch (e) {
      // Error logged silently, consider adding proper logging
    }
    return null;
  }

  /// 本周统计数据
  Future<Map<String, dynamic>?> getWeeklyStats() async {
    try {
      final response = await _dio.get('/stats/weekly');

      if (response.statusCode == 200 && response.data['success'] == true) {
        return {
          'weeklyTotal': response.data['weeklyTotal'],
          'weeklyCompleted': response.data['weeklyCompleted'],
          'completionRate': response.data['completionRate'],
          'weeklyData': response.data['weeklyData'],
        };
      }
    } catch (e) {
      // Error logged silently, consider adding proper logging
    }
    return null;
  }

  /// 分类统计数据
  Future<List<Map<String, dynamic>>> getCategoryStats() async {
    try {
      final response = await _dio.get('/stats/category');

      if (response.statusCode == 200 && response.data['success'] == true) {
        final categories = response.data['categories'] as List;
        return categories.map((c) => Map<String, dynamic>.from(c)).toList();
      }
    } catch (e) {
      // Error logged silently, consider adding proper logging
    }
    return [];
  }

  /// 优先级统计数据
  Future<List<Map<String, dynamic>>> getPriorityStats() async {
    try {
      final response = await _dio.get('/stats/priority');

      if (response.statusCode == 200 && response.data['success'] == true) {
        final priorities = response.data['priorities'] as List;
        return priorities.map((p) => Map<String, dynamic>.from(p)).toList();
      }
    } catch (e) {
      // Error logged silently, consider adding proper logging
    }
    return [];
  }

  /// 热力图数据
  Future<List<Map<String, dynamic>>> getHeatmapData({int days = 28}) async {
    try {
      final response = await _dio.get(
        '/stats/heatmap',
        queryParameters: {'days': days},
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'] as List;
        return data.map((d) => Map<String, dynamic>.from(d)).toList();
      }
    } catch (e) {
      // Error logged silently, consider adding proper logging
    }
    return [];
  }

  /// 专注时长统计
  Future<Map<String, dynamic>?> getFocusTimeStats({int days = 7}) async {
    try {
      final response = await _dio.get(
        '/stats/focus-time',
        queryParameters: {'days': days},
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return response.data['focusTime'] as Map<String, dynamic>;
      }
    } catch (e) {
      // Error logged silently, consider adding proper logging
    }
    return null;
  }
}
