/// 任务标签类型
enum TaskTag {
  highPriority,
  meditation,
  work,
  social,
  review,
}

/// 任务模型
class Task {
  final String id;
  final String category;
  final String title;
  final String time;
  final String? description;
  final TaskTag? tag;
  final String iconName;
  final String categoryColor;

  Task({
    required this.id,
    required this.category,
    required this.title,
    required this.time,
    this.description,
    this.tag,
    required this.iconName,
    this.categoryColor = '#9DC695',
  });

  String get tagText {
    switch (tag) {
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
      default:
        return '';
    }
  }
}
