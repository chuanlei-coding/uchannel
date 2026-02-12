/// 任务标签类型
enum TaskTag {
  highPriority,
  meditation,
  work,
  social,
  review,
}

/// 任务状态
enum TaskStatus {
  pending,
  completed,
  cancelled,
}

/// 任务优先级
enum TaskPriority {
  urgent,
  important,
  normal,
}

/// 任务扩展，添加标签文本
extension TaskTagExtension on TaskTag {
  String get text {
    switch (this) {
      case TaskTag.highPriority:
        return '高优先级';
      case TaskTag.meditation:
        return '冥想';
      case TaskTag.work:
        return '工作';
      case TaskTag.social:
        return '社交';
      case TaskTag.review:
        return '回顾';
    }
  }

  String get value {
    switch (this) {
      case TaskTag.highPriority:
        return 'highPriority';
      case TaskTag.meditation:
        return 'meditation';
      case TaskTag.work:
        return 'work';
      case TaskTag.social:
        return 'social';
      case TaskTag.review:
        return 'review';
    }
  }

  static TaskTag? fromValue(String? value) {
    if (value == null) return null;
    switch (value) {
      case 'highPriority':
        return TaskTag.highPriority;
      case 'meditation':
        return TaskTag.meditation;
      case 'work':
        return TaskTag.work;
      case 'social':
        return TaskTag.social;
      case 'review':
        return TaskTag.review;
      default:
        return null;
    }
  }
}

/// 任务状态扩展
extension TaskStatusExtension on TaskStatus {
  String get value {
    switch (this) {
      case TaskStatus.pending:
        return 'pending';
      case TaskStatus.completed:
        return 'completed';
      case TaskStatus.cancelled:
        return 'cancelled';
    }
  }

  String get text {
    switch (this) {
      case TaskStatus.pending:
        return '待处理';
      case TaskStatus.completed:
        return '已完成';
      case TaskStatus.cancelled:
        return '已取消';
    }
  }

  static TaskStatus fromValue(String value) {
    switch (value) {
      case 'pending':
        return TaskStatus.pending;
      case 'completed':
        return TaskStatus.completed;
      case 'cancelled':
        return TaskStatus.cancelled;
      default:
        return TaskStatus.pending;
    }
  }
}

/// 任务优先级扩展
extension TaskPriorityExtension on TaskPriority {
  String get value {
    switch (this) {
      case TaskPriority.urgent:
        return '紧急';
      case TaskPriority.important:
        return '重要';
      case TaskPriority.normal:
        return '普通';
    }
  }

  String get text {
    switch (this) {
      case TaskPriority.urgent:
        return '紧急';
      case TaskPriority.important:
        return '重要';
      case TaskPriority.normal:
        return '普通';
    }
  }

  static TaskPriority fromValue(String value) {
    switch (value) {
      case '紧急':
        return TaskPriority.urgent;
      case '重要':
        return TaskPriority.important;
      case '普通':
      default:
        return TaskPriority.normal;
    }
  }
}

/// 任务模型
class Task {
  final int? id;
  final String category;
  final String title;
  final String? description;
  final String startTime;
  final String endTime;
  final String taskDate; // 格式：yyyy-MM-dd
  final TaskPriority priority;
  final TaskStatus status;
  final String iconName;
  final String categoryColor;
  final TaskTag? tag;
  final bool aiBreakdownEnabled;
  final DateTime? createdAt;
  final DateTime? completedAt;

  Task({
    this.id,
    required this.category,
    required this.title,
    this.description,
    required this.startTime,
    required this.endTime,
    required this.taskDate,
    this.priority = TaskPriority.normal,
    this.status = TaskStatus.pending,
    required this.iconName,
    this.categoryColor = '#9DC695',
    this.tag,
    this.aiBreakdownEnabled = false,
    this.createdAt,
    this.completedAt,
  });

  /// 从JSON创建任务
  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] as int?,
      category: json['category'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      startTime: json['startTime'] as String? ?? '',
      endTime: json['endTime'] as String? ?? '',
      taskDate: json['taskDate'] as String? ?? '',
      priority: TaskPriorityExtension.fromValue(json['priority'] as String? ?? '普通'),
      status: TaskStatusExtension.fromValue(json['status'] as String? ?? 'pending'),
      iconName: json['iconName'] as String? ?? 'event',
      categoryColor: json['categoryColor'] as String? ?? '#9DC695',
      tag: TaskTagExtension.fromValue(json['tag'] as String?),
      aiBreakdownEnabled: json['aiBreakdownEnabled'] as bool? ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'])
          : null,
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'category': category,
      'title': title,
      if (description != null) 'description': description,
      'startTime': startTime,
      'endTime': endTime,
      'taskDate': taskDate,
      'priority': priority.value,
      'status': status.value,
      'iconName': iconName,
      'categoryColor': categoryColor,
      if (tag != null) 'tag': tag!.value,
      'aiBreakdownEnabled': aiBreakdownEnabled,
    };
  }

  /// 创建任务的请求体
  Map<String, dynamic> toCreateRequest() {
    return {
      'category': category,
      'title': title,
      if (description != null && description!.isNotEmpty) 'description': description,
      'startTime': startTime,
      'endTime': endTime,
      'taskDate': taskDate,
      'priority': priority.value,
      'iconName': iconName,
      'categoryColor': categoryColor,
      if (tag != null) 'tag': tag!.value,
      'aiBreakdownEnabled': aiBreakdownEnabled,
    };
  }

  /// 更新任务的请求体
  Map<String, dynamic> toUpdateRequest() {
    return toCreateRequest();
  }

  /// 创建副本
  Task copyWith({
    int? id,
    String? category,
    String? title,
    String? description,
    String? startTime,
    String? endTime,
    String? taskDate,
    TaskPriority? priority,
    TaskStatus? status,
    String? iconName,
    String? categoryColor,
    TaskTag? tag,
    bool? aiBreakdownEnabled,
    DateTime? createdAt,
    DateTime? completedAt,
  }) {
    return Task(
      id: id ?? this.id,
      category: category ?? this.category,
      title: title ?? this.title,
      description: description ?? this.description,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      taskDate: taskDate ?? this.taskDate,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      iconName: iconName ?? this.iconName,
      categoryColor: categoryColor ?? this.categoryColor,
      tag: tag ?? this.tag,
      aiBreakdownEnabled: aiBreakdownEnabled ?? this.aiBreakdownEnabled,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  /// 是否待处理
  bool get isPending => status == TaskStatus.pending;

  /// 是否已完成
  bool get isCompleted => status == TaskStatus.completed;

  /// 是否已取消
  bool get isCancelled => status == TaskStatus.cancelled;

  /// 获取标签文本
  String get tagText => tag?.text ?? '';

  /// 兼容旧代码的时间属性
  String get time => '$startTime-$endTime';
}
