import React from 'react';
import { View, Text, ScrollView, TouchableOpacity, StyleSheet, Image } from 'react-native';
import Icon from 'react-native-vector-icons/MaterialIcons';
import { Colors } from '../../theme';
import { Spacing, BorderRadius, Shadows } from '../../theme';

interface DiscoverItem {
  id: string;
  title: string;
  description: string;
  icon: string;
  color: string;
}

const discoverItems: DiscoverItem[] = [
  {
    id: '1',
    title: '冥想入门',
    description: '5分钟快速放松身心',
    icon: 'self-improvement',
    color: Colors.brandSage,
  },
  {
    id: '2',
    title: '专注技巧',
    description: '提升工作效率的秘诀',
    icon: 'psychology',
    color: Colors.brandTeal,
  },
  {
    id: '3',
    title: '时间管理',
    description: '科学规划每一天',
    icon: 'schedule',
    color: Colors.terracotta,
  },
  {
    id: '4',
    title: '健康习惯',
    description: '从小事开始改变',
    icon: 'favorite',
    color: Colors.dustyRose,
  },
];

/**
 * 发现页面
 */
const DiscoverScreen: React.FC = () => {
  const renderDiscoverItem = (item: DiscoverItem) => (
    <TouchableOpacity
      key={item.id}
      style={[styles.discoverCard, Shadows.cardSm]}
      activeOpacity={0.8}
    >
      <View style={[styles.iconContainer, { backgroundColor: item.color + '20' }]}>
        <Icon name={item.icon} size={32} color={item.color} />
      </View>
      <View style={styles.cardContent}>
        <Text style={styles.cardTitle}>{item.title}</Text>
        <Text style={styles.cardDescription}>{item.description}</Text>
      </View>
      <Icon name="chevron-right" size={20} color={Colors.softGrey} />
    </TouchableOpacity>
  );

  return (
    <View style={styles.container}>
      {/* 背景装饰 */}
      <View style={styles.backgroundDecoration1} />
      <View style={styles.backgroundDecoration2} />

      {/* 头部 */}
      <View style={styles.header}>
        <Text style={styles.headerTitle}>发现</Text>
        <Text style={styles.headerSubtitle}>探索更多可能性</Text>
      </View>

      <ScrollView style={styles.scrollView}>
        {/* 今日推荐 */}
        <View style={styles.section}>
          <Text style={styles.sectionTitle}>今日推荐</Text>
          <TouchableOpacity style={styles.featuredCard} activeOpacity={0.9}>
            <View style={styles.featuredContent}>
              <Text style={styles.featuredTitle}>21天习惯养成计划</Text>
              <Text style={styles.featuredDescription}>
                科学验证的习惯养成方法，每天一个小步骤，21天改变生活
              </Text>
              <TouchableOpacity style={styles.startButton}>
                <Text style={styles.startButtonText}>开始挑战</Text>
              </TouchableOpacity>
            </View>
          </TouchableOpacity>
        </View>

        {/* 探索分类 */}
        <View style={styles.section}>
          <Text style={styles.sectionTitle}>探索分类</Text>
          {discoverItems.map(renderDiscoverItem)}
        </View>

        {/* AI 助手推荐 */}
        <View style={styles.section}>
          <Text style={styles.sectionTitle}>AI 助手推荐</Text>
          <View style={[styles.aiCard, Shadows.cardMd]}>
            <View style={styles.aiHeader}>
              <View style={styles.aiLogo}>
                <Text style={styles.aiLogoText}>V</Text>
              </View>
              <View>
                <Text style={styles.aiName}>Vita AI</Text>
                <Text style={styles.aiStatus}>在线</Text>
              </View>
            </View>
            <Text style={styles.aiDescription}>
              "我注意到你最近经常熬夜，要不要我帮你制定一个睡眠改善计划？"
            </Text>
            <TouchableOpacity style={styles.chatButton}>
              <Icon name="chat" size={18} color={Colors.white} />
              <Text style={styles.chatButtonText}>与 Vita 对话</Text>
            </TouchableOpacity>
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
    right: -50,
    width: 200,
    height: 200,
    borderRadius: 100,
    backgroundColor: Colors.terracotta + '0D',
  },
  backgroundDecoration2: {
    position: 'absolute',
    bottom: 100,
    left: -80,
    width: 180,
    height: 180,
    borderRadius: 90,
    backgroundColor: Colors.brandSage + '0D',
  },
  header: {
    paddingHorizontal: Spacing.lg,
    paddingTop: Spacing.xl + Spacing.md,
    paddingBottom: Spacing.md,
  },
  headerTitle: {
    fontSize: 28,
    fontWeight: '600',
    color: Colors.darkGrey,
  },
  headerSubtitle: {
    fontSize: 14,
    color: Colors.softGrey,
    marginTop: Spacing.xs,
  },
  scrollView: {
    flex: 1,
  },
  section: {
    paddingHorizontal: Spacing.lg,
    marginBottom: Spacing.lg,
  },
  sectionTitle: {
    fontSize: 18,
    fontWeight: '600',
    color: Colors.darkGrey,
    marginBottom: Spacing.md,
  },
  featuredCard: {
    backgroundColor: Colors.brandSage,
    borderRadius: BorderRadius.xl,
    padding: Spacing.lg,
    overflow: 'hidden',
  },
  featuredContent: {},
  featuredTitle: {
    fontSize: 22,
    fontWeight: '600',
    color: Colors.white,
    marginBottom: Spacing.sm,
  },
  featuredDescription: {
    fontSize: 14,
    color: Colors.white + 'CC',
    lineHeight: 20,
    marginBottom: Spacing.md,
  },
  startButton: {
    backgroundColor: Colors.white,
    alignSelf: 'flex-start',
    paddingHorizontal: Spacing.md,
    paddingVertical: Spacing.sm,
    borderRadius: BorderRadius.full,
  },
  startButtonText: {
    fontSize: 14,
    fontWeight: '600',
    color: Colors.brandSage,
  },
  discoverCard: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: Colors.white,
    borderRadius: BorderRadius.lg,
    padding: Spacing.md,
    marginBottom: Spacing.sm,
  },
  iconContainer: {
    width: 56,
    height: 56,
    borderRadius: BorderRadius.lg,
    alignItems: 'center',
    justifyContent: 'center',
    marginRight: Spacing.md,
  },
  cardContent: {
    flex: 1,
  },
  cardTitle: {
    fontSize: 16,
    fontWeight: '500',
    color: Colors.darkGrey,
  },
  cardDescription: {
    fontSize: 13,
    color: Colors.softGrey,
    marginTop: 2,
  },
  aiCard: {
    backgroundColor: Colors.white,
    borderRadius: BorderRadius.xl,
    padding: Spacing.lg,
  },
  aiHeader: {
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: Spacing.md,
  },
  aiLogo: {
    width: 40,
    height: 40,
    borderRadius: BorderRadius.full,
    backgroundColor: Colors.brandSage,
    alignItems: 'center',
    justifyContent: 'center',
    marginRight: Spacing.sm,
  },
  aiLogoText: {
    color: Colors.white,
    fontWeight: '600',
    fontSize: 18,
  },
  aiName: {
    fontSize: 16,
    fontWeight: '500',
    color: Colors.darkGrey,
  },
  aiStatus: {
    fontSize: 12,
    color: Colors.brandSage,
  },
  aiDescription: {
    fontSize: 15,
    color: Colors.darkGrey,
    lineHeight: 22,
    fontStyle: 'italic',
    marginBottom: Spacing.md,
  },
  chatButton: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    backgroundColor: Colors.brandSage,
    paddingVertical: Spacing.sm,
    paddingHorizontal: Spacing.md,
    borderRadius: BorderRadius.full,
    alignSelf: 'flex-start',
  },
  chatButtonText: {
    color: Colors.white,
    fontWeight: '500',
    marginLeft: Spacing.xs,
  },
});

export default DiscoverScreen;
