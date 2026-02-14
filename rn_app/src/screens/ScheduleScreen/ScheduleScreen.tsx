import React, { useEffect, useState, useCallback } from 'react';
import {
  View,
  Text,
  FlatList,
  StyleSheet,
  RefreshControl,
  TouchableOpacity,
} from 'react-native';
import Icon from 'react-native-vector-icons/MaterialIcons';
import { useNavigation, useFocusEffect } from '@react-navigation/native';
import { useTaskStore } from '../../stores';
import { TaskCard } from '../../components';
import { Task, TaskStatus } from '../../models/Task';
import { Colors } from '../../theme';
import { Spacing, BorderRadius } from '../../theme';

type FilterType = 'all' | 'pending' | 'completed';

/**
 * 日程页面
 */
const ScheduleScreen: React.FC = () => {
  const navigation = useNavigation();
  const [activeFilter, setActiveFilter] = useState<FilterType>('all');
  const [refreshing, setRefreshing] = useState(false);

  const {
    tasks,
    isLoading,
    loadTasksByDate,
    completeTask,
    selectedDate,
    setSelectedDate,
  } = useTaskStore();

  useFocusEffect(
    useCallback(() => {
      const today = new Date().toISOString().split('T')[0];
      loadTasksByDate(today);
    }, [])
  );

  const onRefresh = async () => {
    setRefreshing(true);
    await loadTasksByDate(selectedDate);
    setRefreshing(false);
  };

  const getFilteredTasks = (): Task[] => {
    switch (activeFilter) {
      case 'pending':
        return tasks.filter((t) => t.status === TaskStatus.pending);
      case 'completed':
        return tasks.filter((t) => t.status === TaskStatus.completed);
      default:
        return tasks;
    }
  };

  const handleCompleteTask = async (taskId: number) => {
    await completeTask(taskId);
  };

  const handleAddTask = () => {
    navigation.navigate('AddTodo' as never);
  };

  const formatDate = () => {
    const date = new Date(selectedDate);
    const weekdays = ['周日', '周一', '周二', '周三', '周四', '周五', '周六'];
    return `${date.getMonth() + 1}月${date.getDate()}日 ${weekdays[date.getDay()]}`;
  };

  const renderTask = ({ item }: { item: Task }) => (
    <TaskCard
      task={item}
      onComplete={() => item.id && handleCompleteTask(item.id)}
      onTap={() => navigation.navigate('TaskDetail' as never, { task: item } as never)}
    />
  );

  const filters: { key: FilterType; label: string }[] = [
    { key: 'all', label: '全部' },
    { key: 'pending', label: '待办' },
    { key: 'completed', label: '已完成' },
  ];

  const filteredTasks = getFilteredTasks();

  return (
    <View style={styles.container}>
      {/* 背景装饰 */}
      <View style={styles.backgroundDecoration} />

      {/* 头部 */}
      <View style={styles.header}>
        <View>
          <Text style={styles.headerTitle}>日程安排</Text>
          <Text style={styles.headerDate}>{formatDate()}</Text>
        </View>
        <TouchableOpacity style={styles.calendarButton}>
          <Icon name="calendar-today" size={24} color={Colors.brandSage} />
        </TouchableOpacity>
      </View>

      {/* 筛选标签 */}
      <View style={styles.filterContainer}>
        {filters.map((filter) => (
          <TouchableOpacity
            key={filter.key}
            style={[
              styles.filterTab,
              activeFilter === filter.key && styles.filterTabActive,
            ]}
            onPress={() => setActiveFilter(filter.key)}
          >
            <Text
              style={[
                styles.filterText,
                activeFilter === filter.key && styles.filterTextActive,
              ]}
            >
              {filter.label}
            </Text>
          </TouchableOpacity>
        ))}
      </View>

      {/* 任务统计 */}
      <View style={styles.statsContainer}>
        <View style={styles.statItem}>
          <Text style={styles.statNumber}>{tasks.length}</Text>
          <Text style={styles.statLabel}>总任务</Text>
        </View>
        <View style={styles.statDivider} />
        <View style={styles.statItem}>
          <Text style={[styles.statNumber, { color: Colors.brandSage }]}>
            {tasks.filter((t) => t.status === TaskStatus.completed).length}
          </Text>
          <Text style={styles.statLabel}>已完成</Text>
        </View>
        <View style={styles.statDivider} />
        <View style={styles.statItem}>
          <Text style={[styles.statNumber, { color: Colors.terracotta }]}>
            {tasks.filter((t) => t.status === TaskStatus.pending).length}
          </Text>
          <Text style={styles.statLabel}>待办</Text>
        </View>
      </View>

      {/* 任务列表 */}
      <FlatList
        data={filteredTasks}
        renderItem={renderTask}
        keyExtractor={(item) => item.id?.toString() || item.title}
        contentContainerStyle={styles.taskList}
        refreshControl={
          <RefreshControl
            refreshing={refreshing}
            onRefresh={onRefresh}
            colors={[Colors.brandSage]}
          />
        }
        ListEmptyComponent={
          <View style={styles.emptyContainer}>
            <Icon name="event-note" size={64} color={Colors.softGrey + '4D'} />
            <Text style={styles.emptyText}>暂无日程安排</Text>
            <Text style={styles.emptySubtext}>点击下方按钮添加任务</Text>
          </View>
        }
      />

      {/* 添加按钮 */}
      <TouchableOpacity style={styles.fab} onPress={handleAddTask}>
        <Icon name="add" size={28} color={Colors.white} />
      </TouchableOpacity>
    </View>
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
    right: -100,
    width: 250,
    height: 250,
    borderRadius: 125,
    backgroundColor: Colors.brandSage + '0D',
  },
  header: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    paddingHorizontal: Spacing.lg,
    paddingVertical: Spacing.md,
    paddingTop: Spacing.xl,
  },
  headerTitle: {
    fontSize: 28,
    fontWeight: '600',
    color: Colors.darkGrey,
  },
  headerDate: {
    fontSize: 14,
    color: Colors.softGrey,
    marginTop: Spacing.xs,
  },
  calendarButton: {
    width: 44,
    height: 44,
    borderRadius: BorderRadius.full,
    backgroundColor: Colors.softSage,
    alignItems: 'center',
    justifyContent: 'center',
  },
  filterContainer: {
    flexDirection: 'row',
    paddingHorizontal: Spacing.lg,
    marginBottom: Spacing.md,
  },
  filterTab: {
    paddingHorizontal: Spacing.md,
    paddingVertical: Spacing.sm,
    marginRight: Spacing.sm,
    borderRadius: BorderRadius.full,
    backgroundColor: Colors.white,
  },
  filterTabActive: {
    backgroundColor: Colors.brandSage,
  },
  filterText: {
    fontSize: 14,
    color: Colors.softGrey,
  },
  filterTextActive: {
    color: Colors.white,
    fontWeight: '500',
  },
  statsContainer: {
    flexDirection: 'row',
    marginHorizontal: Spacing.lg,
    marginBottom: Spacing.md,
    paddingVertical: Spacing.md,
    paddingHorizontal: Spacing.lg,
    backgroundColor: Colors.white,
    borderRadius: BorderRadius.lg,
  },
  statItem: {
    flex: 1,
    alignItems: 'center',
  },
  statNumber: {
    fontSize: 24,
    fontWeight: '600',
    color: Colors.darkGrey,
  },
  statLabel: {
    fontSize: 12,
    color: Colors.softGrey,
    marginTop: Spacing.xs,
  },
  statDivider: {
    width: 1,
    backgroundColor: Colors.borderLight,
    marginVertical: Spacing.sm,
  },
  taskList: {
    paddingHorizontal: Spacing.lg,
    paddingBottom: 100,
  },
  emptyContainer: {
    alignItems: 'center',
    paddingTop: 60,
  },
  emptyText: {
    fontSize: 18,
    fontWeight: '500',
    color: Colors.darkGrey,
    marginTop: Spacing.md,
  },
  emptySubtext: {
    fontSize: 14,
    color: Colors.softGrey,
    marginTop: Spacing.xs,
  },
  fab: {
    position: 'absolute',
    right: Spacing.lg,
    bottom: Spacing.xxl,
    width: 56,
    height: 56,
    borderRadius: 28,
    backgroundColor: Colors.brandSage,
    alignItems: 'center',
    justifyContent: 'center',
    shadowColor: Colors.brandSage,
    shadowOffset: { width: 0, height: 4 },
    shadowOpacity: 0.3,
    shadowRadius: 8,
    elevation: 6,
  },
});

export default ScheduleScreen;
