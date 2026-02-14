import React, { useState } from 'react';
import {
  View,
  Text,
  StyleSheet,
  ScrollView,
  TouchableOpacity,
  TextInput,
} from 'react-native';
import { useNavigation, useRoute } from '@react-navigation/native';
import Icon from 'react-native-vector-icons/MaterialIcons';
import { Colors } from '../../theme';
import { Spacing, BorderRadius } from '../../theme';
import { Task } from '../../models/Task';

interface SubTask {
  id: string;
  title: string;
  completed: boolean;
}

interface TaskDetailProps {
  route: {
    params: {
      task: Task;
    };
  };
}

/**
 * 日程详情页面
 */
const TaskDetailScreen: React.FC<TaskDetailProps> = ({ route }) => {
  const navigation = useNavigation();
  const { task } = route.params;

  const [subTasks, setSubTasks] = useState<SubTask[]>([
    { id: '1', title: '准备演示文稿 (PPT/Keynote)', completed: false },
    { id: '2', title: '确认视觉细节 (色彩/排版)', completed: false },
    { id: '3', title: '整理会议纪要模板', completed: false },
  ]);
  const [notes, setNotes] = useState('');

  const completedCount = subTasks.filter((t) => t.completed).length;
  const progress = subTasks.length > 0 ? Math.round((completedCount / subTasks.length) * 100) : 0;

  const toggleSubTask = (id: string) => {
    setSubTasks((prev) =>
      prev.map((t) => (t.id === id ? { ...t, completed: !t.completed } : t))
    );
  };

  const formatTime = () => {
    return `${task.startTime} - ${task.endTime}`;
  };

  return (
    <View style={styles.container}>
      {/* 背景装饰 */}
      <View style={styles.backgroundDecoration1} />
      <View style={styles.backgroundDecoration2} />

      {/* 头部 */}
      <View style={styles.header}>
        <TouchableOpacity
          style={styles.backButton}
          onPress={() => navigation.goBack()}
        >
          <Icon name="chevron-left" size={20} color={Colors.brandSage} />
          <Text style={styles.backText}>Back</Text>
        </TouchableOpacity>

        <View style={styles.headerContent}>
          <Text style={styles.title}>{task.title}</Text>
          <View style={styles.timeRow}>
            <Icon name="schedule" size={14} color={Colors.brandSage} />
            <Text style={styles.timeText}>{formatTime()}</Text>
          </View>
        </View>

        <TouchableOpacity style={styles.editButton}>
          <Icon name="edit-note" size={22} color={Colors.darkGrey + '99'} />
        </TouchableOpacity>
      </View>

      <ScrollView style={styles.scrollView} contentContainerStyle={styles.scrollContent}>
        {/* AI Decomposed Tasks */}
        <View style={styles.section}>
          <View style={styles.sectionHeader}>
            <Text style={styles.sectionTitle}>AI Decomposed Tasks</Text>
            <View style={styles.stepsBadge}>
              <Text style={styles.stepsText}>{subTasks.length} Steps</Text>
            </View>
          </View>

          <View style={styles.subTaskList}>
            {subTasks.map((subTask) => (
              <TouchableOpacity
                key={subTask.id}
                style={styles.subTaskItem}
                onPress={() => toggleSubTask(subTask.id)}
                activeOpacity={0.7}
              >
                <View
                  style={[
                    styles.checkbox,
                    subTask.completed && styles.checkboxCompleted,
                  ]}
                >
                  {subTask.completed && (
                    <Icon name="check" size={14} color={Colors.brandSage} />
                  )}
                </View>
                <Text
                  style={[
                    styles.subTaskText,
                    subTask.completed && styles.subTaskTextCompleted,
                  ]}
                >
                  {subTask.title}
                </Text>
              </TouchableOpacity>
            ))}
          </View>

          <TouchableOpacity style={styles.aiBreakdownButton}>
            <Icon name="auto-awesome" size={18} color={Colors.brandSage} />
            <Text style={styles.aiBreakdownText}>AI 进一步分解</Text>
          </TouchableOpacity>
        </View>

        {/* Progress Insights */}
        <View style={styles.insightsCard}>
          <View style={styles.insightsHeader}>
            <View style={styles.insightsIcon}>
              <Icon name="lightbulb" size={20} color={Colors.softGold} />
            </View>
            <Text style={styles.insightsTitle}>Progress Insights</Text>
          </View>

          <View style={styles.progressHeader}>
            <Text style={styles.progressPercent}>{progress}%</Text>
            <Text style={styles.progressLabel}>Completion</Text>
          </View>

          <View style={styles.progressBar}>
            <View style={[styles.progressFill, { width: `${progress}%` }]} />
          </View>

          {/* AI Suggestion */}
          <View style={styles.suggestionCard}>
            <Text style={styles.suggestionText}>
              "建议优先处理『确认视觉细节』，此项工作通常耗时较长。完成该项后，演示文稿的整合将变得更为顺畅。"
            </Text>
            <View style={styles.suggestionFooter}>
              <Icon name="smart-toy" size={12} color={Colors.brandSage + '99'} />
              <Text style={styles.suggestionLabel}>Vita AI Suggestion</Text>
            </View>
          </View>

          {/* Personal Notes */}
          <View style={styles.notesCard}>
            <TextInput
              style={styles.notesInput}
              placeholder="点击此处记录心得、摘要或重要备注..."
              placeholderTextColor={Colors.darkGrey + '30'}
              value={notes}
              onChangeText={setNotes}
              multiline
              numberOfLines={3}
              textAlignVertical="top"
            />
            <View style={styles.notesFooter}>
              <Icon name="edit-square" size={12} color={Colors.darkGrey + '30'} />
              <Text style={styles.notesLabel}>Personal Notes</Text>
            </View>
          </View>
        </View>
      </ScrollView>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: Colors.creamBg,
  },
  backgroundDecoration1: {
    position: 'absolute',
    top: -80,
    left: -80,
    width: 200,
    height: 200,
    borderRadius: 100,
    backgroundColor: Colors.brandSage + '0D',
  },
  backgroundDecoration2: {
    position: 'absolute',
    bottom: 100,
    right: -60,
    width: 150,
    height: 150,
    borderRadius: 75,
    backgroundColor: Colors.softGold + '0D',
  },
  header: {
    paddingHorizontal: Spacing.lg,
    paddingTop: 60,
    paddingBottom: Spacing.lg,
    backgroundColor: Colors.creamBg + 'E6',
  },
  backButton: {
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: Spacing.sm,
  },
  backText: {
    fontSize: 12,
    fontWeight: '700',
    letterSpacing: 2,
    color: Colors.brandSage,
    marginLeft: 2,
  },
  headerContent: {
    flex: 1,
  },
  title: {
    fontSize: 28,
    fontWeight: '500',
    color: Colors.darkGrey,
    lineHeight: 34,
  },
  timeRow: {
    flexDirection: 'row',
    alignItems: 'center',
    marginTop: Spacing.xs,
  },
  timeText: {
    fontSize: 14,
    fontWeight: '500',
    color: Colors.darkGrey + '80',
    fontStyle: 'italic',
    letterSpacing: 1,
    marginLeft: Spacing.xs,
  },
  editButton: {
    position: 'absolute',
    right: Spacing.lg,
    top: 80,
    width: 44,
    height: 44,
    borderRadius: BorderRadius.full,
    backgroundColor: Colors.white,
    alignItems: 'center',
    justifyContent: 'center',
    borderWidth: 1,
    borderColor: Colors.darkGrey + '0D',
  },
  scrollView: {
    flex: 1,
  },
  scrollContent: {
    paddingHorizontal: Spacing.lg,
    paddingBottom: 100,
  },
  section: {
    marginBottom: Spacing.xl,
  },
  sectionHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: Spacing.md,
    paddingHorizontal: Spacing.xs,
  },
  sectionTitle: {
    fontSize: 11,
    fontWeight: '700',
    letterSpacing: 3,
    color: Colors.darkGrey + '40',
    textTransform: 'uppercase',
  },
  stepsBadge: {
    backgroundColor: Colors.brandSage + '1A',
    paddingHorizontal: Spacing.sm,
    paddingVertical: 2,
    borderRadius: BorderRadius.full,
  },
  stepsText: {
    fontSize: 10,
    fontWeight: '700',
    color: Colors.brandSage,
  },
  subTaskList: {},
  subTaskItem: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingVertical: Spacing.md,
    borderBottomWidth: 1,
    borderBottomColor: Colors.darkGrey + '0D',
  },
  checkbox: {
    width: 24,
    height: 24,
    borderRadius: BorderRadius.full,
    borderWidth: 1.5,
    borderColor: Colors.brandSage + '4D',
    backgroundColor: Colors.white,
    alignItems: 'center',
    justifyContent: 'center',
    marginRight: Spacing.md,
  },
  checkboxCompleted: {
    backgroundColor: Colors.brandSage + '1A',
    borderColor: Colors.brandSage,
  },
  subTaskText: {
    flex: 1,
    fontSize: 15,
    color: Colors.darkGrey + 'CC',
  },
  subTaskTextCompleted: {
    textDecorationLine: 'line-through',
    color: Colors.darkGrey + '80',
  },
  aiBreakdownButton: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    marginTop: Spacing.xl,
    paddingVertical: Spacing.md,
    borderRadius: BorderRadius.xl,
    backgroundColor: Colors.brandSage + '1A',
    borderWidth: 1,
    borderColor: Colors.brandSage + '33',
  },
  aiBreakdownText: {
    fontSize: 14,
    fontWeight: '700',
    letterSpacing: 2,
    color: Colors.brandSage,
    marginLeft: Spacing.sm,
  },
  insightsCard: {
    backgroundColor: Colors.white,
    borderRadius: 40,
    padding: Spacing.xl,
    borderWidth: 1,
    borderColor: Colors.brandSage + '0D',
  },
  insightsHeader: {
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: Spacing.lg,
  },
  insightsIcon: {
    width: 40,
    height: 40,
    borderRadius: BorderRadius.full,
    backgroundColor: Colors.softGold + '1A',
    alignItems: 'center',
    justifyContent: 'center',
    marginRight: Spacing.md,
  },
  insightsTitle: {
    fontSize: 18,
    fontWeight: '500',
    fontStyle: 'italic',
    color: Colors.darkGrey,
  },
  progressHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'flex-end',
    marginBottom: Spacing.sm,
    paddingHorizontal: Spacing.xs,
  },
  progressPercent: {
    fontSize: 30,
    fontWeight: '500',
    fontStyle: 'italic',
    color: Colors.brandSage,
  },
  progressLabel: {
    fontSize: 11,
    fontWeight: '700',
    letterSpacing: 3,
    color: Colors.darkGrey + '30',
    textTransform: 'uppercase',
  },
  progressBar: {
    height: 6,
    backgroundColor: Colors.darkGrey + '0D',
    borderRadius: BorderRadius.full,
    marginBottom: Spacing.xl,
    overflow: 'hidden',
  },
  progressFill: {
    height: '100%',
    backgroundColor: Colors.brandSage,
    borderRadius: BorderRadius.full,
  },
  suggestionCard: {
    backgroundColor: Colors.creamBg + '80',
    borderRadius: BorderRadius.xl,
    padding: Spacing.md,
    borderWidth: 1,
    borderColor: Colors.darkGrey + '0D',
    marginBottom: Spacing.md,
  },
  suggestionText: {
    fontSize: 14,
    lineHeight: 22,
    fontStyle: 'italic',
    color: Colors.darkGrey + 'B3',
  },
  suggestionFooter: {
    flexDirection: 'row',
    alignItems: 'center',
    marginTop: Spacing.sm,
  },
  suggestionLabel: {
    fontSize: 10,
    fontWeight: '700',
    letterSpacing: 2,
    color: Colors.brandSage + '99',
    textTransform: 'uppercase',
    marginLeft: Spacing.xs,
  },
  notesCard: {
    backgroundColor: Colors.creamBg + '4D',
    borderRadius: BorderRadius.xl,
    padding: Spacing.md,
    borderWidth: 1,
    borderColor: Colors.darkGrey + '14',
    borderStyle: 'dashed',
  },
  notesInput: {
    fontSize: 14,
    fontStyle: 'italic',
    color: Colors.darkGrey + '99',
    minHeight: 60,
  },
  notesFooter: {
    flexDirection: 'row',
    alignItems: 'center',
    marginTop: Spacing.sm,
  },
  notesLabel: {
    fontSize: 10,
    fontWeight: '700',
    letterSpacing: 2,
    color: Colors.darkGrey + '30',
    textTransform: 'uppercase',
    marginLeft: Spacing.xs,
  },
});

export default TaskDetailScreen;
