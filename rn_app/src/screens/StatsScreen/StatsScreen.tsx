import React, { useEffect, useState } from 'react';
import { View, Text, ScrollView, StyleSheet, Dimensions } from 'react-native';
import { statsApi, OverviewStats, WeeklyStats, HeatmapData } from '../../services/api';
import { LoadingIndicator } from '../../components';
import { Colors } from '../../theme';
import { Spacing, BorderRadius, Shadows } from '../../theme';

const { width } = Dimensions.get('window');

/**
 * 简单的柱状图组件
 */
const SimpleBarChart: React.FC<{ data: number[] }> = ({ data }) => {
  const maxValue = Math.max(...data, 1);
  const barWidth = (width - 80) / data.length - 4;

  return (
    <View style={styles.chartContainer}>
      <View style={styles.chartBars}>
        {data.map((value, index) => (
          <View key={index} style={styles.barWrapper}>
            <View
              style={[
                styles.bar,
                {
                  height: (value / maxValue) * 100,
                  width: barWidth,
                },
              ]}
            />
            <Text style={styles.barLabel}>{['一', '二', '三', '四', '五', '六', '日'][index]}</Text>
          </View>
        ))}
      </View>
    </View>
  );
};

/**
 * 统计页面
 */
const StatsScreen: React.FC = () => {
  const [isLoading, setIsLoading] = useState(true);
  const [overview, setOverview] = useState<OverviewStats | null>(null);
  const [weekly, setWeekly] = useState<WeeklyStats | null>(null);
  const [heatmap, setHeatmap] = useState<HeatmapData[]>([]);

  useEffect(() => {
    loadStats();
  }, []);

  const loadStats = async () => {
    setIsLoading(true);
    try {
      const [overviewData, weeklyData, heatmapData] = await Promise.all([
        statsApi.getOverviewStats(),
        statsApi.getWeeklyStats(),
        statsApi.getHeatmapData(28),
      ]);

      if (overviewData) setOverview(overviewData);
      if (weeklyData) setWeekly(weeklyData);
      if (heatmapData.length > 0) setHeatmap(heatmapData);
    } catch (error) {
      console.error('Failed to load stats:', error);
    } finally {
      setIsLoading(false);
    }
  };

  const getCompletionRate = () => {
    if (!overview) return 0;
    return Math.round(overview.completionRate * 100);
  };

  const getHeatmapColor = (level: number): string => {
    switch (level) {
      case 0:
        return Colors.heatmapLight;
      case 1:
        return Colors.heatmap1;
      case 2:
        return Colors.heatmap2;
      case 3:
        return Colors.heatmap3;
      default:
        return Colors.heatmap4;
    }
  };

  // Mock data for weekly chart
  const weeklyChartData = weekly?.weeklyData?.map(d => d.completed) || [2, 3, 1, 4, 2, 3, 1];

  if (isLoading) {
    return <LoadingIndicator fullScreen message="加载统计数据..." />;
  }

  return (
    <View style={styles.container}>
      {/* 背景装饰 */}
      <View style={styles.backgroundDecoration} />

      {/* 头部 */}
      <View style={styles.header}>
        <Text style={styles.headerTitle}>数据洞察</Text>
        <Text style={styles.headerSubtitle}>了解你的效率模式</Text>
      </View>

      <ScrollView style={styles.scrollView}>
        {/* 概览卡片 */}
        <View style={styles.overviewSection}>
          <View style={[styles.overviewCard, Shadows.cardMd]}>
            <Text style={styles.overviewTitle}>总完成率</Text>
            <Text style={styles.overviewValue}>{getCompletionRate()}%</Text>
            <View style={styles.progressBar}>
              <View
                style={[
                  styles.progressFill,
                  { width: `${getCompletionRate()}%` },
                ]}
              />
            </View>
          </View>

          <View style={styles.statsRow}>
            <View style={[styles.statCard, Shadows.cardSm]}>
              <Text style={styles.statValue}>{overview?.totalTasks || 0}</Text>
              <Text style={styles.statLabel}>总任务</Text>
            </View>
            <View style={[styles.statCard, Shadows.cardSm]}>
              <Text style={[styles.statValue, { color: Colors.brandSage }]}>
                {overview?.completedTasks || 0}
              </Text>
              <Text style={styles.statLabel}>已完成</Text>
            </View>
            <View style={[styles.statCard, Shadows.cardSm]}>
              <Text style={[styles.statValue, { color: Colors.terracotta }]}>
                {overview?.pendingTasks || 0}
              </Text>
              <Text style={styles.statLabel}>待办</Text>
            </View>
          </View>
        </View>

        {/* 本周趋势 */}
        <View style={styles.section}>
          <Text style={styles.sectionTitle}>本周趋势</Text>
          <View style={[styles.chartCard, Shadows.cardSm]}>
            <SimpleBarChart data={weeklyChartData} />
          </View>
        </View>

        {/* 活动热力图 */}
        {heatmap.length > 0 && (
          <View style={styles.section}>
            <Text style={styles.sectionTitle}>活动热力图</Text>
            <View style={[styles.heatmapCard, Shadows.cardSm]}>
              <View style={styles.heatmapGrid}>
                {heatmap.slice(0, 28).map((item, index) => (
                  <View
                    key={index}
                    style={[
                      styles.heatmapCell,
                      { backgroundColor: getHeatmapColor(item.level) },
                    ]}
                  />
                ))}
              </View>
              <View style={styles.heatmapLegend}>
                <Text style={styles.legendText}>少</Text>
                {[0, 1, 2, 3, 4].map((level) => (
                  <View
                    key={level}
                    style={[
                      styles.legendCell,
                      { backgroundColor: getHeatmapColor(level) },
                    ]}
                  />
                ))}
                <Text style={styles.legendText}>多</Text>
              </View>
            </View>
          </View>
        )}

        {/* 周报摘要 */}
        <View style={styles.section}>
          <Text style={styles.sectionTitle}>本周摘要</Text>
          <View style={[styles.summaryCard, Shadows.cardSm]}>
            <View style={styles.summaryRow}>
              <View style={styles.summaryItem}>
                <Text style={styles.summaryLabel}>本周完成</Text>
                <Text style={styles.summaryValue}>
                  {weekly?.weeklyCompleted || 0} 任务
                </Text>
              </View>
              <View style={styles.summaryDivider} />
              <View style={styles.summaryItem}>
                <Text style={styles.summaryLabel}>完成率</Text>
                <Text style={styles.summaryValue}>
                  {weekly?.completionRate
                    ? Math.round(weekly.completionRate * 100)
                    : 0}
                  %
                </Text>
              </View>
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
  backgroundDecoration: {
    position: 'absolute',
    top: -100,
    right: -80,
    width: 220,
    height: 220,
    borderRadius: 110,
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
  overviewSection: {
    paddingHorizontal: Spacing.lg,
    marginBottom: Spacing.lg,
  },
  overviewCard: {
    backgroundColor: Colors.white,
    borderRadius: BorderRadius.xl,
    padding: Spacing.lg,
    marginBottom: Spacing.md,
  },
  overviewTitle: {
    fontSize: 14,
    color: Colors.softGrey,
    marginBottom: Spacing.sm,
  },
  overviewValue: {
    fontSize: 48,
    fontWeight: '600',
    color: Colors.brandSage,
    marginBottom: Spacing.md,
  },
  progressBar: {
    height: 8,
    backgroundColor: Colors.softSage,
    borderRadius: 4,
    overflow: 'hidden',
  },
  progressFill: {
    height: '100%',
    backgroundColor: Colors.brandSage,
    borderRadius: 4,
  },
  statsRow: {
    flexDirection: 'row',
    gap: Spacing.sm,
  },
  statCard: {
    flex: 1,
    backgroundColor: Colors.white,
    borderRadius: BorderRadius.lg,
    padding: Spacing.md,
    alignItems: 'center',
  },
  statValue: {
    fontSize: 24,
    fontWeight: '600',
    color: Colors.darkGrey,
  },
  statLabel: {
    fontSize: 12,
    color: Colors.softGrey,
    marginTop: Spacing.xs,
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
  chartCard: {
    backgroundColor: Colors.white,
    borderRadius: BorderRadius.xl,
    padding: Spacing.md,
    alignItems: 'center',
  },
  chartContainer: {
    width: '100%',
    height: 150,
  },
  chartBars: {
    flex: 1,
    flexDirection: 'row',
    alignItems: 'flex-end',
    justifyContent: 'space-around',
    paddingHorizontal: Spacing.sm,
  },
  barWrapper: {
    alignItems: 'center',
  },
  bar: {
    backgroundColor: Colors.brandSage,
    borderRadius: 4,
    minHeight: 4,
  },
  barLabel: {
    fontSize: 10,
    color: Colors.softGrey,
    marginTop: Spacing.xs,
  },
  heatmapCard: {
    backgroundColor: Colors.white,
    borderRadius: BorderRadius.xl,
    padding: Spacing.lg,
  },
  heatmapGrid: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    gap: 4,
    justifyContent: 'center',
  },
  heatmapCell: {
    width: (width - 80) / 7 - 4,
    height: (width - 80) / 7 - 4,
    borderRadius: 4,
  },
  heatmapLegend: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'flex-end',
    marginTop: Spacing.md,
    gap: 4,
  },
  legendText: {
    fontSize: 11,
    color: Colors.softGrey,
    marginHorizontal: Spacing.xs,
  },
  legendCell: {
    width: 12,
    height: 12,
    borderRadius: 2,
  },
  summaryCard: {
    backgroundColor: Colors.white,
    borderRadius: BorderRadius.xl,
    padding: Spacing.lg,
  },
  summaryRow: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  summaryItem: {
    flex: 1,
    alignItems: 'center',
  },
  summaryLabel: {
    fontSize: 13,
    color: Colors.softGrey,
    marginBottom: Spacing.xs,
  },
  summaryValue: {
    fontSize: 20,
    fontWeight: '600',
    color: Colors.darkGrey,
  },
  summaryDivider: {
    width: 1,
    height: 40,
    backgroundColor: Colors.borderLight,
  },
});

export default StatsScreen;
