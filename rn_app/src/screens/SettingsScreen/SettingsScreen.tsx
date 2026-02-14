import React from 'react';
import { View, Text, ScrollView, StyleSheet, Alert } from 'react-native';
import { useSettingsStore } from '../../stores';
import { SettingTile, SettingSection } from '../../components/settings';
import { Colors } from '../../theme';
import { Spacing } from '../../theme';

/**
 * 设置页面
 */
const SettingsScreen: React.FC = () => {
  const {
    isDarkMode,
    notificationsEnabled,
    reminderTime,
    fontSize,
    useHapticFeedback,
    aiSuggestionsEnabled,
    autoBreakdownEnabled,
    analyticsEnabled,
    toggleDarkMode,
    toggleNotifications,
    setReminderTime,
    setFontSize,
    toggleHapticFeedback,
    toggleAiSuggestions,
    toggleAutoBreakdown,
    toggleAnalytics,
  } = useSettingsStore();

  const showFontSizeOptions = () => {
    Alert.alert(
      '字体大小',
      '请选择字体大小',
      [
        { text: '小', onPress: () => setFontSize('small') },
        { text: '中', onPress: () => setFontSize('medium') },
        { text: '大', onPress: () => setFontSize('large') },
        { text: '取消', style: 'cancel' },
      ],
      { cancelable: true }
    );
  };

  const showReminderOptions = () => {
    Alert.alert(
      '提醒时间',
      '请选择提前提醒时间',
      [
        { text: '5分钟', onPress: () => setReminderTime(5) },
        { text: '15分钟', onPress: () => setReminderTime(15) },
        { text: '30分钟', onPress: () => setReminderTime(30) },
        { text: '1小时', onPress: () => setReminderTime(60) },
        { text: '取消', style: 'cancel' },
      ],
      { cancelable: true }
    );
  };

  const getFontSizeLabel = () => {
    switch (fontSize) {
      case 'small':
        return '小';
      case 'medium':
        return '中';
      case 'large':
        return '大';
    }
  };

  const getReminderLabel = () => {
    if (reminderTime >= 60) {
      return `${reminderTime / 60}小时`;
    }
    return `${reminderTime}分钟`;
  };

  return (
    <View style={styles.container}>
      {/* 背景装饰 */}
      <View style={styles.backgroundDecoration} />

      {/* 头部 */}
      <View style={styles.header}>
        <Text style={styles.headerTitle}>设置</Text>
      </View>

      <ScrollView style={styles.scrollView}>
        {/* 外观设置 */}
        <SettingSection title="外观">
          <SettingTile
            icon="dark-mode"
            title="深色模式"
            subtitle="切换深色/浅色主题"
            hasSwitch
            switchValue={isDarkMode}
            onSwitchChange={toggleDarkMode}
          />
          <SettingTile
            icon="text-fields"
            title="字体大小"
            value={getFontSizeLabel()}
            onPress={showFontSizeOptions}
          />
        </SettingSection>

        {/* 通知设置 */}
        <SettingSection title="通知">
          <SettingTile
            icon="notifications"
            title="推送通知"
            subtitle="接收任务提醒"
            hasSwitch
            switchValue={notificationsEnabled}
            onSwitchChange={toggleNotifications}
          />
          <SettingTile
            icon="schedule"
            title="提醒时间"
            subtitle="提前提醒"
            value={getReminderLabel()}
            onPress={showReminderOptions}
          />
        </SettingSection>

        {/* AI 设置 */}
        <SettingSection title="AI 功能">
          <SettingTile
            icon="lightbulb"
            title="智能建议"
            subtitle="AI 自动提供任务建议"
            hasSwitch
            switchValue={aiSuggestionsEnabled}
            onSwitchChange={toggleAiSuggestions}
          />
          <SettingTile
            icon="auto-awesome"
            title="自动拆解"
            subtitle="自动将复杂任务拆解为子任务"
            hasSwitch
            switchValue={autoBreakdownEnabled}
            onSwitchChange={toggleAutoBreakdown}
          />
        </SettingSection>

        {/* 其他设置 */}
        <SettingSection title="其他">
          <SettingTile
            icon="vibration"
            title="触感反馈"
            subtitle="操作时提供震动反馈"
            hasSwitch
            switchValue={useHapticFeedback}
            onSwitchChange={toggleHapticFeedback}
          />
          <SettingTile
            icon="analytics"
            title="使用分析"
            subtitle="帮助我们改进产品"
            hasSwitch
            switchValue={analyticsEnabled}
            onSwitchChange={toggleAnalytics}
          />
        </SettingSection>

        {/* 关于 */}
        <SettingSection title="关于">
          <SettingTile
            icon="info"
            title="版本"
            value="1.0.0"
            showArrow={false}
          />
          <SettingTile
            icon="description"
            title="隐私政策"
            onPress={() => {}}
          />
          <SettingTile
            icon="gavel"
            title="服务条款"
            onPress={() => {}}
          />
        </SettingSection>

        {/* 底部信息 */}
        <View style={styles.footer}>
          <Text style={styles.footerText}>UChannel Vita</Text>
          <Text style={styles.footerSubtext}>Android Edition</Text>
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
    top: -50,
    left: -50,
    width: 200,
    height: 200,
    borderRadius: 100,
    backgroundColor: Colors.brandTeal + '0D',
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
  scrollView: {
    flex: 1,
  },
  footer: {
    alignItems: 'center',
    paddingVertical: Spacing.xxl,
  },
  footerText: {
    fontSize: 14,
    fontWeight: '500',
    color: Colors.darkGrey,
  },
  footerSubtext: {
    fontSize: 12,
    color: Colors.softGrey,
    marginTop: Spacing.xs,
  },
});

export default SettingsScreen;
