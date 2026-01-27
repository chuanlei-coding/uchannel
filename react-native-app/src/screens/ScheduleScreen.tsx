import React, {useState} from 'react';
import {
  View,
  Text,
  StyleSheet,
  ScrollView,
  TouchableOpacity,
  StatusBar,
} from 'react-native';
import {Colors} from '../utils/colors';
import {useNavigation} from '@react-navigation/native';
import type {NativeStackNavigationProp} from '@react-navigation/native-stack';
import type {RootStackParamList} from '../navigation/AppNavigator';

type NavigationProp = NativeStackNavigationProp<RootStackParamList>;

interface ScheduleItem {
  id: string;
  category: string;
  categoryColor: 'sage' | 'teal' | 'muted';
  title: string;
  description?: string;
  time: string;
  icon: string;
  priority?: string;
  dimmed?: boolean;
}

const ScheduleScreen = () => {
  const navigation = useNavigation<NavigationProp>();
  const [selectedTab, setSelectedTab] = useState(0);
  const tabs = ['日', '周', '月', '年', '生涯'];

  const scheduleItems: ScheduleItem[] = [
    {
      id: '1',
      category: '晨间冥想',
      categoryColor: 'sage',
      title: '内观与呼吸练习',
      time: '07:00 - 07:30',
      icon: '🧘',
    },
    {
      id: '2',
      category: '深度工作',
      categoryColor: 'teal',
      title: 'Vita 界面设计迭代',
      description: '完善 Android 端的 Material 3 适配方案，优化排版视觉节奏。',
      time: '09:00 - 11:30',
      icon: '✨',
      priority: '高优先级',
    },
    {
      id: '3',
      category: '社交',
      categoryColor: 'muted',
      title: '与团队午餐',
      time: '12:00 - 13:30',
      icon: '🍽️',
      dimmed: true,
    },
    {
      id: '4',
      category: '晚间回顾',
      categoryColor: 'sage',
      title: '每日复盘与明日规划',
      time: '21:30 - 22:00',
      icon: '📝',
    },
  ];

  const getCurrentDate = () => {
    const date = new Date();
    const month = date.getMonth() + 1;
    const day = date.getDate();
    return `${month}月${day}日`;
  };

  const getWeekday = () => {
    const weekdays = ['星期日', '星期一', '星期二', '星期三', '星期四', '星期五', '星期六'];
    return weekdays[new Date().getDay()];
  };

  const getCategoryColor = (color: 'sage' | 'teal' | 'muted') => {
    switch (color) {
      case 'sage':
        return Colors.brandSage;
      case 'teal':
        return Colors.brandTeal;
      case 'muted':
        return Colors.onSurfaceVariant;
    }
  };

  return (
    <View style={styles.container}>
      <StatusBar barStyle="light-content" backgroundColor={Colors.charcoal} />
      
      {/* Header */}
      <View style={styles.header}>
        <View style={styles.headerTop}>
          <Text style={styles.vitaLogo}>Vita</Text>
          <View style={styles.headerActions}>
            <TouchableOpacity style={styles.iconButton}>
              <Text style={styles.iconText}>🔍</Text>
            </TouchableOpacity>
            <View style={styles.avatar}>
              <Text style={styles.avatarIcon}>👤</Text>
            </View>
          </View>
        </View>

        {/* Tabs */}
        <View style={styles.tabsContainer}>
          <ScrollView horizontal showsHorizontalScrollIndicator={false}>
            {tabs.map((tab, index) => (
              <TouchableOpacity
                key={tab}
                style={styles.tab}
                onPress={() => setSelectedTab(index)}>
                <Text
                  style={[
                    styles.tabText,
                    selectedTab === index && styles.tabTextActive,
                  ]}>
                  {tab}
                </Text>
                {selectedTab === index && <View style={styles.tabIndicator} />}
              </TouchableOpacity>
            ))}
          </ScrollView>
        </View>
      </View>

      {/* Main Content */}
      <ScrollView style={styles.scrollView} contentContainerStyle={styles.content}>
        {/* Date Display */}
        <View style={styles.dateSection}>
          <Text style={styles.dateText}>{getCurrentDate()}</Text>
          <Text style={styles.weekdayText}>{getWeekday()} · 岁序更替，步履轻盈</Text>
        </View>

        {/* Schedule Items */}
        {scheduleItems.map(item => (
          <View
            key={item.id}
            style={[
              styles.scheduleCard,
              item.dimmed && styles.scheduleCardDimmed,
            ]}>
            <View style={styles.cardHeader}>
              <View style={styles.cardTitleSection}>
                <Text
                  style={[
                    styles.categoryLabel,
                    {color: getCategoryColor(item.categoryColor)},
                  ]}>
                  {item.category}
                </Text>
                <Text
                  style={[
                    styles.cardTitle,
                    item.dimmed && styles.cardTitleDimmed,
                  ]}>
                  {item.title}
                </Text>
              </View>
              <Text
                style={[
                  styles.cardIcon,
                  item.dimmed && styles.cardIconDimmed,
                ]}>
                {item.icon}
              </Text>
            </View>

            {item.description && (
              <Text style={styles.cardDescription} numberOfLines={2}>
                {item.description}
              </Text>
            )}

            <View style={styles.cardFooter}>
              <View style={styles.timeContainer}>
                <Text style={styles.clockIcon}>🕐</Text>
                <Text
                  style={[
                    styles.timeText,
                    item.dimmed && styles.timeTextDimmed,
                  ]}>
                  {item.time}
                </Text>
              </View>
              {item.priority && (
                <View style={styles.priorityTag}>
                  <Text style={styles.priorityText}>{item.priority}</Text>
                </View>
              )}
            </View>
          </View>
        ))}
      </ScrollView>

      {/* Floating Add Button */}
      <TouchableOpacity style={styles.fab}>
        <Text style={styles.fabIcon}>+</Text>
      </TouchableOpacity>

      {/* Bottom Navigation */}
      <View style={styles.bottomNav}>
        <View style={styles.navItem}>
          <Text style={styles.navIconActive}>📅</Text>
          <Text style={styles.navTextActive}>日程</Text>
        </View>
        <TouchableOpacity style={styles.navItem}>
          <Text style={styles.navIcon}>📊</Text>
          <Text style={styles.navText}>洞察</Text>
        </TouchableOpacity>
        <TouchableOpacity
          style={styles.navItem}
          onPress={() => navigation.navigate('Main')}>
          <Text style={styles.navIcon}>🤖</Text>
          <Text style={styles.navText}>AI 助手</Text>
        </TouchableOpacity>
        <TouchableOpacity style={styles.navItem} onPress={() => navigation.navigate('Settings')}>
          <Text style={styles.navIcon}>⚙️</Text>
          <Text style={styles.navText}>设置</Text>
        </TouchableOpacity>
      </View>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: Colors.charcoal,
  },
  header: {
    backgroundColor: Colors.charcoal,
    paddingTop: 12,
    zIndex: 20,
  },
  headerTop: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    paddingHorizontal: 24,
    marginBottom: 16,
  },
  vitaLogo: {
    fontSize: 24,
    fontStyle: 'italic',
    color: Colors.brandSage,
    fontWeight: '500',
  },
  headerActions: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 16,
  },
  iconButton: {
    padding: 4,
  },
  iconText: {
    fontSize: 20,
  },
  avatar: {
    width: 32,
    height: 32,
    borderRadius: 16,
    backgroundColor: 'rgba(90,138,131,0.2)',
    borderWidth: 1,
    borderColor: 'rgba(90,138,131,0.3)',
    justifyContent: 'center',
    alignItems: 'center',
  },
  avatarIcon: {
    fontSize: 18,
    opacity: 0.8,
  },
  tabsContainer: {
    borderBottomWidth: 1,
    borderBottomColor: Colors.textWhite05,
  },
  tab: {
    paddingHorizontal: 16,
    paddingVertical: 12,
    position: 'relative',
  },
  tabText: {
    fontSize: 14,
    fontWeight: '500',
    color: Colors.onSurfaceVariant,
  },
  tabTextActive: {
    color: Colors.brandSage,
  },
  tabIndicator: {
    position: 'absolute',
    bottom: 0,
    left: 8,
    right: 8,
    height: 3,
    backgroundColor: Colors.brandSage,
    borderTopLeftRadius: 3,
    borderTopRightRadius: 3,
  },
  scrollView: {
    flex: 1,
  },
  content: {
    paddingHorizontal: 16,
    paddingTop: 24,
    paddingBottom: 140,
  },
  dateSection: {
    paddingHorizontal: 8,
    marginBottom: 24,
  },
  dateText: {
    fontSize: 32,
    fontWeight: '300',
    color: Colors.onSurface,
  },
  weekdayText: {
    fontSize: 14,
    color: Colors.onSurfaceVariant,
    marginTop: 4,
  },
  scheduleCard: {
    backgroundColor: Colors.surfaceContainer,
    padding: 24,
    borderRadius: 24,
    marginBottom: 16,
    borderWidth: 1,
    borderColor: Colors.textWhite05,
  },
  scheduleCardDimmed: {
    backgroundColor: 'rgba(29,33,31,0.6)',
  },
  cardHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'flex-start',
  },
  cardTitleSection: {
    flex: 1,
    marginRight: 16,
  },
  categoryLabel: {
    fontSize: 10,
    fontWeight: '500',
    textTransform: 'uppercase',
    letterSpacing: 1.5,
    marginBottom: 4,
  },
  cardTitle: {
    fontSize: 20,
    fontWeight: '400',
    color: Colors.onSurface,
  },
  cardTitleDimmed: {
    color: 'rgba(225,227,223,0.8)',
  },
  cardIcon: {
    fontSize: 24,
  },
  cardIconDimmed: {
    opacity: 0.5,
  },
  cardDescription: {
    fontSize: 14,
    color: Colors.onSurfaceVariant,
    lineHeight: 20,
    marginTop: 16,
  },
  cardFooter: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginTop: 16,
  },
  timeContainer: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  clockIcon: {
    fontSize: 14,
    marginRight: 8,
  },
  timeText: {
    fontSize: 14,
    color: Colors.onSurfaceVariant,
  },
  timeTextDimmed: {
    color: 'rgba(191,201,194,0.7)',
  },
  priorityTag: {
    paddingHorizontal: 12,
    paddingVertical: 4,
    backgroundColor: 'rgba(157,198,149,0.1)',
    borderRadius: 12,
    borderWidth: 1,
    borderColor: 'rgba(157,198,149,0.2)',
  },
  priorityText: {
    fontSize: 11,
    color: Colors.brandSage,
  },
  fab: {
    position: 'absolute',
    bottom: 88,
    right: 24,
    width: 56,
    height: 56,
    borderRadius: 24,
    backgroundColor: Colors.brandSage,
    justifyContent: 'center',
    alignItems: 'center',
    elevation: 8,
    shadowColor: '#000',
    shadowOffset: {width: 0, height: 4},
    shadowOpacity: 0.3,
    shadowRadius: 8,
    zIndex: 30,
  },
  fabIcon: {
    fontSize: 32,
    color: Colors.charcoal,
    fontWeight: 'bold',
    marginTop: -2,
  },
  bottomNav: {
    height: 64,
    backgroundColor: Colors.surfaceContainer,
    borderTopWidth: 1,
    borderTopColor: Colors.textWhite05,
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-around',
    paddingHorizontal: 16,
  },
  navItem: {
    alignItems: 'center',
    justifyContent: 'center',
    paddingVertical: 8,
  },
  navIcon: {
    fontSize: 24,
    opacity: 0.6,
  },
  navIconActive: {
    fontSize: 24,
  },
  navText: {
    fontSize: 10,
    color: Colors.onSurfaceVariant,
    marginTop: 4,
  },
  navTextActive: {
    fontSize: 10,
    color: Colors.brandSage,
    marginTop: 4,
  },
});

export default ScheduleScreen;
