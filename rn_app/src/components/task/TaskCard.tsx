import React from 'react';
import { View, Text, TouchableOpacity, StyleSheet } from 'react-native';
import Icon from 'react-native-vector-icons/MaterialIcons';
import { Task, TaskPriority, TaskStatus, TaskPriorityText, TaskTagText } from '../../models/Task';
import { Colors } from '../../theme';
import { Spacing, BorderRadius, Shadows } from '../../theme';

interface TaskCardProps {
  task: Task;
  onComplete?: () => void;
  onTap?: () => void;
  compact?: boolean;
}

/**
 * 任务卡片组件
 */
const TaskCard: React.FC<TaskCardProps> = ({
  task,
  onComplete,
  onTap,
  compact = false,
}) => {
  const getPriorityColor = (): string => {
    switch (task.priority) {
      case TaskPriority.urgent:
        return Colors.terracotta;
      case TaskPriority.important:
        return Colors.softGold;
      default:
        return Colors.brandSage;
    }
  };

  const isCompleted = task.status === TaskStatus.completed;
  const priorityColor = getPriorityColor();

  const containerStyle = [
    styles.container,
    compact ? styles.containerCompact : null,
    Shadows.cardSm,
    isCompleted && styles.containerCompleted,
  ];

  return (
    <TouchableOpacity
      style={containerStyle}
      onPress={onTap}
      activeOpacity={0.8}
      disabled={!onTap}
    >
      {/* 左侧优先级指示器 */}
      <View style={[styles.priorityIndicator, { backgroundColor: priorityColor }]} />

      {/* 完成按钮 */}
      <TouchableOpacity
        style={[
          styles.checkbox,
          { borderColor: priorityColor },
          isCompleted && { backgroundColor: priorityColor },
        ]}
        onPress={onComplete}
        activeOpacity={0.7}
      >
        {isCompleted && <Icon name="check" size={14} color={Colors.white} />}
      </TouchableOpacity>

      {/* 任务内容 */}
      <View style={styles.content}>
        <View style={styles.header}>
          <Text
            style={[styles.title, isCompleted && styles.titleCompleted]}
            numberOfLines={1}
          >
            {task.title}
          </Text>
          {task.tag && (
            <View style={[styles.tag, { backgroundColor: priorityColor + '20' }]}>
              <Text style={[styles.tagText, { color: priorityColor }]}>
                {TaskTagText[task.tag]}
              </Text>
            </View>
          )}
        </View>

        <View style={styles.details}>
          <View style={styles.timeContainer}>
            <Icon name="schedule" size={12} color={Colors.softGrey} />
            <Text style={styles.timeText}>
              {task.startTime} - {task.endTime}
            </Text>
          </View>
          <Text style={styles.categoryText}>{task.category}</Text>
        </View>
      </View>

      {/* 右侧箭头 */}
      {onTap && (
        <Icon name="chevron-right" size={20} color={Colors.softGrey} />
      )}
    </TouchableOpacity>
  );
};

const styles = StyleSheet.create({
  container: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: Colors.white,
    borderRadius: BorderRadius.lg,
    marginBottom: Spacing.sm,
    overflow: 'hidden',
  },
  containerCompact: {
    paddingVertical: Spacing.sm,
  },
  containerCompleted: {
    opacity: 0.6,
  },
  priorityIndicator: {
    width: 4,
    height: '100%',
  },
  checkbox: {
    width: 20,
    height: 20,
    borderRadius: BorderRadius.full,
    borderWidth: 2,
    marginLeft: Spacing.md,
    marginRight: Spacing.sm,
    alignItems: 'center',
    justifyContent: 'center',
  },
  content: {
    flex: 1,
    paddingVertical: Spacing.md,
    paddingHorizontal: Spacing.sm,
  },
  header: {
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: Spacing.xs,
  },
  title: {
    flex: 1,
    fontSize: 15,
    fontWeight: '500',
    color: Colors.darkGrey,
  },
  titleCompleted: {
    textDecorationLine: 'line-through',
    color: Colors.softGrey,
  },
  tag: {
    paddingHorizontal: Spacing.sm,
    paddingVertical: 2,
    borderRadius: BorderRadius.sm,
    marginLeft: Spacing.sm,
  },
  tagText: {
    fontSize: 10,
    fontWeight: '500',
  },
  details: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
  },
  timeContainer: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  timeText: {
    fontSize: 12,
    color: Colors.softGrey,
    marginLeft: 4,
  },
  categoryText: {
    fontSize: 12,
    color: Colors.softGrey,
  },
});

export default TaskCard;
