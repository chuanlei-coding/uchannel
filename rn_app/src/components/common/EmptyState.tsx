import React from 'react';
import { View, Text, StyleSheet } from 'react-native';
import Icon from 'react-native-vector-icons/MaterialIcons';
import { Colors } from '../../theme';
import { Spacing, BorderRadius } from '../../theme';
import PrimaryButton from './PrimaryButton';

type EmptyStateType =
  | 'chat'
  | 'schedule'
  | 'stats'
  | 'search'
  | 'error'
  | 'network';

interface EmptyStateProps {
  type?: EmptyStateType;
  title?: string;
  message?: string;
  icon?: string;
  actionLabel?: string;
  onAction?: () => void;
}

/**
 * 空状态组件
 */
const EmptyState: React.FC<EmptyStateProps> = ({
  type = 'schedule',
  title,
  message,
  icon,
  actionLabel,
  onAction,
}) => {
  const getDefaultContent = (): { icon: string; title: string; message: string } => {
    switch (type) {
      case 'chat':
        return {
          icon: 'chat-bubble-outline',
          title: '开始对话',
          message: '向 Vita AI 助手提问，获取智能建议',
        };
      case 'schedule':
        return {
          icon: 'event-note',
          title: '暂无日程',
          message: '点击下方按钮添加你的第一个任务',
        };
      case 'stats':
        return {
          icon: 'bar-chart',
          title: '暂无统计数据',
          message: '完成任务后将显示你的统计信息',
        };
      case 'search':
        return {
          icon: 'search',
          title: '未找到结果',
          message: '尝试使用不同的关键词搜索',
        };
      case 'error':
        return {
          icon: 'error-outline',
          title: '出错了',
          message: '请稍后重试',
        };
      case 'network':
        return {
          icon: 'wifi-off',
          title: '网络连接失败',
          message: '请检查你的网络设置',
        };
    }
  };

  const defaultContent = getDefaultContent();
  const displayIcon = icon || defaultContent.icon;
  const displayTitle = title || defaultContent.title;
  const displayMessage = message || defaultContent.message;

  return (
    <View style={styles.container}>
      <View style={styles.iconContainer}>
        <Icon name={displayIcon} size={48} color={Colors.softGrey} />
      </View>
      <Text style={styles.title}>{displayTitle}</Text>
      <Text style={styles.message}>{displayMessage}</Text>
      {actionLabel && onAction && (
        <View style={styles.actionContainer}>
          <PrimaryButton
            text={actionLabel}
            onPress={onAction}
            variant="filled"
            size="medium"
          />
        </View>
      )}
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
    padding: Spacing.xl,
  },
  iconContainer: {
    width: 80,
    height: 80,
    borderRadius: BorderRadius.full,
    backgroundColor: Colors.softSage,
    alignItems: 'center',
    justifyContent: 'center',
    marginBottom: Spacing.lg,
  },
  title: {
    fontSize: 18,
    fontWeight: '600',
    color: Colors.darkGrey,
    marginBottom: Spacing.sm,
  },
  message: {
    fontSize: 14,
    color: Colors.softGrey,
    textAlign: 'center',
    lineHeight: 20,
  },
  actionContainer: {
    marginTop: Spacing.lg,
  },
});

export default EmptyState;
