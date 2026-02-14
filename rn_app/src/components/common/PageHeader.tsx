import React from 'react';
import { View, Text, TouchableOpacity, StyleSheet } from 'react-native';
import { useNavigation } from '@react-navigation/native';
import Icon from 'react-native-vector-icons/MaterialIcons';
import { Colors } from '../../theme';
import { Spacing, BorderRadius } from '../../theme';

interface PageHeaderProps {
  title: string;
  showBackButton?: boolean;
  onBackPress?: () => void;
  rightAction?: React.ReactNode;
  subtitle?: string;
}

/**
 * 页面头部组件
 */
const PageHeader: React.FC<PageHeaderProps> = ({
  title,
  showBackButton = false,
  onBackPress,
  rightAction,
  subtitle,
}) => {
  const navigation = useNavigation();

  const handleBackPress = () => {
    if (onBackPress) {
      onBackPress();
    } else {
      navigation.goBack();
    }
  };

  return (
    <View style={styles.container}>
      <View style={styles.leftSection}>
        {showBackButton && (
          <TouchableOpacity
            style={styles.backButton}
            onPress={handleBackPress}
            activeOpacity={0.7}
          >
            <Icon name="arrow-back-ios" size={20} color={Colors.darkGrey} />
          </TouchableOpacity>
        )}
      </View>

      <View style={styles.centerSection}>
        <Text style={styles.title}>{title}</Text>
        {subtitle && <Text style={styles.subtitle}>{subtitle}</Text>}
      </View>

      <View style={styles.rightSection}>{rightAction}</View>
    </View>
  );
};

/**
 * 简化版页面头部
 */
export const SimplePageHeader: React.FC<{ title: string }> = ({ title }) => (
  <PageHeader title={title} />
);

const styles = StyleSheet.create({
  container: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingHorizontal: Spacing.md,
    paddingVertical: Spacing.md,
    backgroundColor: Colors.creamBg,
  },
  leftSection: {
    width: 44,
    justifyContent: 'center',
  },
  centerSection: {
    flex: 1,
    alignItems: 'center',
  },
  rightSection: {
    width: 44,
    alignItems: 'flex-end',
    justifyContent: 'center',
  },
  backButton: {
    width: 40,
    height: 40,
    borderRadius: BorderRadius.full,
    backgroundColor: Colors.white,
    justifyContent: 'center',
    alignItems: 'center',
  },
  title: {
    fontSize: 18,
    fontWeight: '600',
    color: Colors.darkGrey,
  },
  subtitle: {
    fontSize: 12,
    color: Colors.softGrey,
    marginTop: 2,
  },
});

export default PageHeader;
