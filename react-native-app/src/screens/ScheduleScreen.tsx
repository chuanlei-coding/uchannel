import React, {useState, useEffect} from 'react';
import {
  View,
  Text,
  StyleSheet,
  ScrollView,
  TouchableOpacity,
  Animated,
} from 'react-native';
import {Colors} from '../utils/colors';
import {Task} from '../models/Task';
import TaskItem from '../components/TaskItem';

const ScheduleScreen = () => {
  const [selectedTab, setSelectedTab] = useState(0);
  const [tasks, setTasks] = useState<Task[]>([]);
  const indicatorPosition = new Animated.Value(0);

  useEffect(() => {
    // 加载示例任务
    setTasks([
      {
        id: '1',
        title: '品牌视觉方案终审',
        description: '"岁序更替,步履轻盈"概念校对',
        time: '14:00 - 15:30',
        tags: ['WORK', 'VITA AI'],
        isCompleted: false,
      },
      {
        id: '2',
        title: '午后冥想与拉伸',
        description: '在微小中,见终生',
        time: '16:00 - 16:30',
        tags: [],
        isCompleted: false,
      },
      {
        id: '3',
        title: '早间AI资讯汇总',
        time: '09:00 - 10:00',
        tags: [],
        isCompleted: true,
      },
    ]);
  }, []);

  const handleTabPress = (index: number) => {
    setSelectedTab(index);
    Animated.timing(indicatorPosition, {
      toValue: index * 80,
      duration: 200,
      useNativeDriver: true,
    }).start();
  };

  const handleTaskToggle = (taskId: string) => {
    setTasks(prev =>
      prev.map(task =>
        task.id === taskId ? {...task, isCompleted: !task.isCompleted} : task,
      ),
    );
  };

  const completedCount = tasks.filter(t => t.isCompleted).length;
  const totalCount = tasks.length;
  const progress = totalCount > 0 ? (completedCount / totalCount) * 100 : 0;

  const getCurrentDate = () => {
    const date = new Date();
    const month = date.getMonth() + 1;
    const day = date.getDate();
    const weekdays = ['周日', '周一', '周二', '周三', '周四', '周五', '周六'];
    const weekday = weekdays[date.getDay()];
    return `${month}月${day}日, ${weekday}`;
  };

  return (
    <View style={styles.container}>
      <ScrollView style={styles.scrollView} contentContainerStyle={styles.content}>
        {/* Header */}
        <View style={styles.header}>
          <View style={styles.dateContainer}>
            <Text style={styles.todayLabel}>TODAY</Text>
            <Text style={styles.dateText}>{getCurrentDate()}</Text>
          </View>
          <View style={styles.headerRight}>
            <TouchableOpacity style={styles.headerButton}>
              <Text style={styles.searchIcon}>🔍</Text>
            </TouchableOpacity>
            <View style={styles.avatar} />
          </View>
        </View>

        {/* Tabs */}
        <View style={styles.tabsContainer}>
          <TouchableOpacity
            style={styles.tab}
            onPress={() => handleTabPress(0)}>
            <Text
              style={[
                styles.tabText,
                selectedTab === 0 && styles.tabTextActive,
              ]}>
              日程
            </Text>
          </TouchableOpacity>
          <TouchableOpacity
            style={styles.tab}
            onPress={() => handleTabPress(1)}>
            <Text
              style={[
                styles.tabText,
                selectedTab === 1 && styles.tabTextActive,
              ]}>
              专注
            </Text>
          </TouchableOpacity>
          <TouchableOpacity
            style={styles.tab}
            onPress={() => handleTabPress(2)}>
            <Text
              style={[
                styles.tabText,
                selectedTab === 2 && styles.tabTextActive,
              ]}>
              反思
            </Text>
          </TouchableOpacity>
        </View>

        {/* Tab Indicator */}
        <Animated.View
          style={[
            styles.indicator,
            {
              transform: [{translateX: indicatorPosition}],
            },
          ]}
        />

        {/* Daily Flow Card */}
        <View style={styles.dailyFlowCard}>
          <Text style={styles.dailyFlowLabel}>DAILY FLOW</Text>
          <Text style={styles.progressText}>
            今日进度 : 已完成 {Math.round(progress)}%
          </Text>
          <View style={styles.progressContainer}>
            <View style={styles.progressBarBackground}>
              <View
                style={[
                  styles.progressBarFill,
                  {width: `${progress}%`},
                ]}
              />
            </View>
            <Text style={styles.taskCount}>
              {completedCount}/{totalCount}
            </Text>
          </View>
        </View>

        {/* Upcoming Focus */}
        <Text style={styles.sectionLabel}>UPCOMING FOCUS</Text>

        {/* Tasks */}
        {tasks.map(task => (
          <TaskItem
            key={task.id}
            task={task}
            onToggle={() => handleTaskToggle(task.id)}
          />
        ))}
      </ScrollView>

      {/* Bottom Navigation */}
      <View style={styles.bottomNav}>
        <View style={styles.navItem}>
          <Text style={styles.navIcon}>📅</Text>
          <Text style={styles.navText}>SCHEDULE</Text>
        </View>
        <TouchableOpacity style={styles.addButton}>
          <Text style={styles.addButtonText}>+</Text>
        </TouchableOpacity>
        <View style={styles.navItem}>
          <Text style={styles.navIcon}>📊</Text>
          <Text style={styles.navText}>INSIGHTS</Text>
        </View>
      </View>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: Colors.charcoal,
  },
  scrollView: {
    flex: 1,
  },
  content: {
    paddingBottom: 100,
  },
  header: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    paddingHorizontal: 16,
    paddingVertical: 16,
  },
  dateContainer: {
    flex: 1,
  },
  todayLabel: {
    fontSize: 11,
    color: Colors.textWhite40,
    letterSpacing: 0.05,
    textTransform: 'uppercase',
  },
  dateText: {
    fontSize: 24,
    color: Colors.textPrimary,
    fontWeight: 'bold',
    marginTop: 4,
  },
  headerRight: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  headerButton: {
    width: 40,
    height: 40,
    justifyContent: 'center',
    alignItems: 'center',
  },
  searchIcon: {
    fontSize: 20,
    color: Colors.textPrimary,
  },
  avatar: {
    width: 32,
    height: 32,
    borderRadius: 16,
    backgroundColor: Colors.brandTeal,
    marginLeft: 8,
  },
  tabsContainer: {
    flexDirection: 'row',
    paddingHorizontal: 16,
    marginTop: 24,
  },
  tab: {
    paddingRight: 24,
    paddingBottom: 8,
  },
  tabText: {
    fontSize: 16,
    color: Colors.textWhite60,
  },
  tabTextActive: {
    color: Colors.brandSage,
    fontWeight: 'bold',
  },
  indicator: {
    width: 40,
    height: 3,
    backgroundColor: Colors.brandSage,
    marginLeft: 16,
    borderRadius: 1.5,
  },
  dailyFlowCard: {
    backgroundColor: Colors.inputBarDarkGreen,
    marginHorizontal: 16,
    marginTop: 8,
    marginBottom: 16,
    padding: 20,
    borderRadius: 16,
  },
  dailyFlowLabel: {
    fontSize: 11,
    color: Colors.textWhite40,
    letterSpacing: 0.05,
    textTransform: 'uppercase',
  },
  progressText: {
    fontSize: 18,
    color: Colors.textPrimary,
    fontWeight: 'bold',
    marginTop: 12,
  },
  progressContainer: {
    flexDirection: 'row',
    alignItems: 'center',
    marginTop: 12,
  },
  progressBarBackground: {
    flex: 1,
    height: 8,
    backgroundColor: Colors.brandTeal,
    borderRadius: 4,
    overflow: 'hidden',
  },
  progressBarFill: {
    height: '100%',
    backgroundColor: Colors.brandSage,
    borderRadius: 4,
  },
  taskCount: {
    fontSize: 14,
    color: Colors.textWhite60,
    marginLeft: 12,
  },
  sectionLabel: {
    fontSize: 11,
    color: Colors.textWhite40,
    letterSpacing: 0.05,
    textTransform: 'uppercase',
    marginHorizontal: 16,
    marginTop: 8,
    marginBottom: 8,
  },
  bottomNav: {
    position: 'absolute',
    bottom: 0,
    left: 0,
    right: 0,
    flexDirection: 'row',
    justifyContent: 'space-around',
    alignItems: 'center',
    backgroundColor: Colors.darkSage,
    paddingTop: 16,
    paddingBottom: 20,
    borderTopWidth: 1,
    borderTopColor: Colors.borderLight,
  },
  navItem: {
    flex: 1,
    alignItems: 'center',
  },
  navIcon: {
    fontSize: 24,
    color: Colors.brandSage,
  },
  navText: {
    fontSize: 10,
    color: Colors.brandSage,
    marginTop: 4,
    textTransform: 'uppercase',
  },
  addButton: {
    width: 56,
    height: 56,
    borderRadius: 28,
    backgroundColor: Colors.brandSage,
    justifyContent: 'center',
    alignItems: 'center',
    elevation: 8,
  },
  addButtonText: {
    fontSize: 32,
    color: Colors.charcoal,
    fontWeight: 'bold',
  },
});

export default ScheduleScreen;
