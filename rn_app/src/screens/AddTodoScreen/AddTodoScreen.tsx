import React, { useState } from 'react';
import {
  View,
  Text,
  TextInput,
  TouchableOpacity,
  ScrollView,
  StyleSheet,
  Alert,
  KeyboardAvoidingView,
  Platform,
} from 'react-native';
import Icon from 'react-native-vector-icons/MaterialIcons';
import { useNavigation } from '@react-navigation/native';
import { useTaskStore } from '../../stores';
import { PrioritySelector, PrimaryButton, PageHeader } from '../../components';
import { Task, TaskPriority, createDefaultTask } from '../../models/Task';
import { Colors } from '../../theme';
import { Spacing, BorderRadius, Shadows } from '../../theme';

/**
 * 添加待办页面
 */
const AddTodoScreen: React.FC = () => {
  const navigation = useNavigation();
  const { createTask, isLoading } = useTaskStore();

  const today = new Date().toISOString().split('T')[0];
  const defaultTask = createDefaultTask(today);

  const [title, setTitle] = useState('');
  const [description, setDescription] = useState('');
  const [category, setCategory] = useState('');
  const [startTime, setStartTime] = useState(defaultTask.startTime || '09:00');
  const [endTime, setEndTime] = useState(defaultTask.endTime || '10:00');
  const [priority, setPriority] = useState<TaskPriority>(TaskPriority.normal);
  const [aiBreakdown, setAiBreakdown] = useState(false);

  const handleSave = async () => {
    if (!title.trim()) {
      Alert.alert('提示', '请输入任务标题');
      return;
    }

    const task: Task = {
      category: category || '未分类',
      title: title.trim(),
      description: description.trim() || undefined,
      startTime,
      endTime,
      taskDate: today,
      priority,
      status: defaultTask.status!,
      iconName: 'event',
      categoryColor: Colors.brandSage,
      aiBreakdownEnabled: aiBreakdown,
    };

    const result = await createTask(task);

    if (result) {
      Alert.alert('成功', '任务已创建', [
        {
          text: '确定',
          onPress: () => navigation.goBack(),
        },
      ]);
    } else {
      Alert.alert('错误', '创建任务失败，请重试');
    }
  };

  const showTimePicker = (type: 'start' | 'end') => {
    // 简单的时间选择对话框
    Alert.alert(
      `选择${type === 'start' ? '开始' : '结束'}时间`,
      '请选择时间',
      [
        { text: '09:00', onPress: () => type === 'start' ? setStartTime('09:00') : setEndTime('09:00') },
        { text: '10:00', onPress: () => type === 'start' ? setStartTime('10:00') : setEndTime('10:00') },
        { text: '11:00', onPress: () => type === 'start' ? setStartTime('11:00') : setEndTime('11:00') },
        { text: '14:00', onPress: () => type === 'start' ? setStartTime('14:00') : setEndTime('14:00') },
        { text: '15:00', onPress: () => type === 'start' ? setStartTime('15:00') : setEndTime('15:00') },
        { text: '16:00', onPress: () => type === 'start' ? setStartTime('16:00') : setEndTime('16:00') },
        { text: '取消', style: 'cancel' },
      ],
      { cancelable: true }
    );
  };

  return (
    <KeyboardAvoidingView
      style={styles.container}
      behavior={Platform.OS === 'ios' ? 'padding' : 'height'}
    >
      {/* 背景装饰 */}
      <View style={styles.backgroundDecoration} />

      {/* 头部 */}
      <PageHeader
        title="新建任务"
        showBackButton
      />

      <ScrollView style={styles.scrollView}>
        {/* 任务标题 */}
        <View style={styles.section}>
          <Text style={styles.label}>任务标题</Text>
          <TextInput
            style={styles.input}
            placeholder="输入任务标题"
            placeholderTextColor={Colors.softGrey}
            value={title}
            onChangeText={setTitle}
          />
        </View>

        {/* 任务描述 */}
        <View style={styles.section}>
          <Text style={styles.label}>任务描述</Text>
          <TextInput
            style={[styles.input, styles.textArea]}
            placeholder="添加任务描述（可选）"
            placeholderTextColor={Colors.softGrey}
            value={description}
            onChangeText={setDescription}
            multiline
            numberOfLines={3}
          />
        </View>

        {/* 分类 */}
        <View style={styles.section}>
          <Text style={styles.label}>分类</Text>
          <TextInput
            style={styles.input}
            placeholder="例如：工作、学习、生活"
            placeholderTextColor={Colors.softGrey}
            value={category}
            onChangeText={setCategory}
          />
        </View>

        {/* 时间 */}
        <View style={styles.section}>
          <Text style={styles.label}>时间</Text>
          <View style={styles.timeRow}>
            <TouchableOpacity
              style={styles.timeButton}
              onPress={() => showTimePicker('start')}
            >
              <Icon name="schedule" size={20} color={Colors.brandSage} />
              <Text style={styles.timeText}>{startTime}</Text>
            </TouchableOpacity>
            <Text style={styles.timeSeparator}>至</Text>
            <TouchableOpacity
              style={styles.timeButton}
              onPress={() => showTimePicker('end')}
            >
              <Icon name="schedule" size={20} color={Colors.brandSage} />
              <Text style={styles.timeText}>{endTime}</Text>
            </TouchableOpacity>
          </View>
        </View>

        {/* 优先级 */}
        <View style={styles.section}>
          <Text style={styles.label}>优先级</Text>
          <PrioritySelector
            value={priority}
            onChange={setPriority}
          />
        </View>

        {/* AI 拆解 */}
        <View style={styles.section}>
          <TouchableOpacity
            style={styles.aiOption}
            onPress={() => setAiBreakdown(!aiBreakdown)}
          >
            <View style={styles.aiOptionLeft}>
              <Icon name="auto-awesome" size={20} color={Colors.brandSage} />
              <View style={styles.aiOptionText}>
                <Text style={styles.aiOptionTitle}>AI 智能拆解</Text>
                <Text style={styles.aiOptionDescription}>
                  让 AI 帮你把任务拆解成子任务
                </Text>
              </View>
            </View>
            <View
              style={[
                styles.checkbox,
                aiBreakdown && styles.checkboxActive,
              ]}
            >
              {aiBreakdown && (
                <Icon name="check" size={16} color={Colors.white} />
              )}
            </View>
          </TouchableOpacity>
        </View>
      </ScrollView>

      {/* 底部按钮 */}
      <View style={styles.footer}>
        <PrimaryButton
          text="保存任务"
          onPress={handleSave}
          isLoading={isLoading}
          width={undefined}
        />
      </View>
    </KeyboardAvoidingView>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: Colors.creamBg,
  },
  backgroundDecoration: {
    position: 'absolute',
    top: -100,
    left: -80,
    width: 200,
    height: 200,
    borderRadius: 100,
    backgroundColor: Colors.terracotta + '0D',
  },
  scrollView: {
    flex: 1,
    paddingHorizontal: Spacing.lg,
  },
  section: {
    marginBottom: Spacing.lg,
  },
  label: {
    fontSize: 14,
    fontWeight: '500',
    color: Colors.darkGrey,
    marginBottom: Spacing.sm,
  },
  input: {
    backgroundColor: Colors.white,
    borderRadius: BorderRadius.lg,
    paddingHorizontal: Spacing.md,
    paddingVertical: Spacing.md,
    fontSize: 15,
    color: Colors.darkGrey,
    ...Shadows.cardSm,
  },
  textArea: {
    height: 100,
    textAlignVertical: 'top',
  },
  timeRow: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  timeButton: {
    flex: 1,
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: Colors.white,
    borderRadius: BorderRadius.lg,
    paddingHorizontal: Spacing.md,
    paddingVertical: Spacing.md,
    ...Shadows.cardSm,
  },
  timeText: {
    fontSize: 15,
    color: Colors.darkGrey,
    marginLeft: Spacing.sm,
  },
  timeSeparator: {
    marginHorizontal: Spacing.md,
    color: Colors.softGrey,
  },
  aiOption: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    backgroundColor: Colors.white,
    borderRadius: BorderRadius.lg,
    padding: Spacing.md,
    ...Shadows.cardSm,
  },
  aiOptionLeft: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  aiOptionText: {
    marginLeft: Spacing.sm,
  },
  aiOptionTitle: {
    fontSize: 15,
    fontWeight: '500',
    color: Colors.darkGrey,
  },
  aiOptionDescription: {
    fontSize: 12,
    color: Colors.softGrey,
    marginTop: 2,
  },
  checkbox: {
    width: 24,
    height: 24,
    borderRadius: BorderRadius.full,
    borderWidth: 2,
    borderColor: Colors.borderLight,
    alignItems: 'center',
    justifyContent: 'center',
  },
  checkboxActive: {
    backgroundColor: Colors.brandSage,
    borderColor: Colors.brandSage,
  },
  footer: {
    padding: Spacing.lg,
    paddingBottom: Spacing.xl,
  },
});

export default AddTodoScreen;
