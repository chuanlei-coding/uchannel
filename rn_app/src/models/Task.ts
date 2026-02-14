/**
 * 任务标签类型
 */
export enum TaskTag {
  highPriority = 'highPriority',
  meditation = 'meditation',
  work = 'work',
  social = 'social',
  review = 'review',
}

/**
 * 任务状态
 */
export enum TaskStatus {
  pending = 'pending',
  completed = 'completed',
  cancelled = 'cancelled',
}

/**
 * 任务优先级
 */
export enum TaskPriority {
  urgent = 'urgent',
  important = 'important',
  normal = 'normal',
}

/**
 * 任务标签文本映射
 */
export const TaskTagText: Record<TaskTag, string> = {
  [TaskTag.highPriority]: '高优先级',
  [TaskTag.meditation]: '冥想',
  [TaskTag.work]: '工作',
  [TaskTag.social]: '社交',
  [TaskTag.review]: '回顾',
};

/**
 * 任务状态文本映射
 */
export const TaskStatusText: Record<TaskStatus, string> = {
  [TaskStatus.pending]: '待处理',
  [TaskStatus.completed]: '已完成',
  [TaskStatus.cancelled]: '已取消',
};

/**
 * 任务优先级文本映射
 */
export const TaskPriorityText: Record<TaskPriority, string> = {
  [TaskPriority.urgent]: '紧急',
  [TaskPriority.important]: '重要',
  [TaskPriority.normal]: '普通',
};

/**
 * 从字符串值获取任务标签
 */
export function getTaskTagFromValue(value?: string): TaskTag | undefined {
  if (!value) return undefined;
  const tag = Object.values(TaskTag).find((t) => t === value);
  return tag;
}

/**
 * 从字符串值获取任务状态
 */
export function getTaskStatusFromValue(value: string): TaskStatus {
  const status = Object.values(TaskStatus).find((s) => s === value);
  return status || TaskStatus.pending;
}

/**
 * 从字符串值获取任务优先级
 */
export function getTaskPriorityFromValue(value: string): TaskPriority {
  switch (value) {
    case '紧急':
      return TaskPriority.urgent;
    case '重要':
      return TaskPriority.important;
    default:
      return TaskPriority.normal;
  }
}

/**
 * 任务模型
 */
export interface Task {
  id?: number;
  category: string;
  title: string;
  description?: string;
  startTime: string;
  endTime: string;
  taskDate: string; // 格式：yyyy-MM-dd
  priority: TaskPriority;
  status: TaskStatus;
  iconName: string;
  categoryColor: string;
  tag?: TaskTag;
  aiBreakdownEnabled: boolean;
  createdAt?: string;
  completedAt?: string;
}

/**
 * 从JSON创建任务
 */
export function taskFromJson(json: Record<string, any>): Task {
  return {
    id: json.id,
    category: json.category ?? '',
    title: json.title ?? '',
    description: json.description,
    startTime: json.start_time ?? json.startTime ?? '',
    endTime: json.end_time ?? json.endTime ?? '',
    taskDate: json.task_date ?? json.taskDate ?? '',
    priority: getTaskPriorityFromValue(json.priority ?? '普通'),
    status: getTaskStatusFromValue(json.status ?? 'pending'),
    iconName: json.icon_name ?? json.iconName ?? 'event',
    categoryColor: json.category_color ?? json.categoryColor ?? '#9DC695',
    tag: getTaskTagFromValue(json.tag),
    aiBreakdownEnabled: json.ai_breakdown_enabled ?? json.aiBreakdownEnabled ?? false,
    createdAt: json.created_at ?? json.createdAt,
    completedAt: json.completed_at ?? json.completedAt,
  };
}

/**
 * 任务转换为JSON（创建请求）
 */
export function taskToCreateRequest(task: Task): Record<string, any> {
  return {
    category: task.category,
    title: task.title,
    ...(task.description && task.description.length > 0 ? { description: task.description } : {}),
    start_time: task.startTime,
    end_time: task.endTime,
    task_date: task.taskDate,
    priority: TaskPriorityText[task.priority],
    icon_name: task.iconName,
    category_color: task.categoryColor,
    ...(task.tag ? { tag: task.tag } : {}),
    ai_breakdown_enabled: task.aiBreakdownEnabled,
  };
}

/**
 * 任务转换为JSON（更新请求）
 */
export function taskToUpdateRequest(task: Task): Record<string, any> {
  return taskToCreateRequest(task);
}

/**
 * 创建任务的默认值
 */
export function createDefaultTask(date: string): Partial<Task> {
  return {
    category: '',
    title: '',
    startTime: '09:00',
    endTime: '10:00',
    taskDate: date,
    priority: TaskPriority.normal,
    status: TaskStatus.pending,
    iconName: 'event',
    categoryColor: '#9DC695',
    aiBreakdownEnabled: false,
  };
}
