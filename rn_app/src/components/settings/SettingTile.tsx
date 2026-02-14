import React from 'react';
import { View, Text, TouchableOpacity, Switch, StyleSheet } from 'react-native';
import Icon from 'react-native-vector-icons/MaterialIcons';
import { Colors } from '../../theme';
import { Spacing, BorderRadius } from '../../theme';

interface SettingTileProps {
  icon?: string;
  title: string;
  subtitle?: string;
  value?: string;
  hasSwitch?: boolean;
  switchValue?: boolean;
  onSwitchChange?: (value: boolean) => void;
  onPress?: () => void;
  showArrow?: boolean;
}

/**
 * 设置项组件
 */
const SettingTile: React.FC<SettingTileProps> = ({
  icon,
  title,
  subtitle,
  value,
  hasSwitch = false,
  switchValue = false,
  onSwitchChange,
  onPress,
  showArrow = true,
}) => {
  const content = (
    <View style={styles.container}>
      {icon && (
        <View style={styles.iconContainer}>
          <Icon name={icon} size={20} color={Colors.brandSage} />
        </View>
      )}

      <View style={styles.textContainer}>
        <Text style={styles.title}>{title}</Text>
        {subtitle && <Text style={styles.subtitle}>{subtitle}</Text>}
      </View>

      {hasSwitch ? (
        <Switch
          value={switchValue}
          onValueChange={onSwitchChange}
          trackColor={{ false: Colors.borderLight, true: Colors.brandSage }}
          thumbColor={Colors.white}
        />
      ) : (
        <View style={styles.rightSection}>
          {value && <Text style={styles.value}>{value}</Text>}
          {showArrow && onPress && (
            <Icon name="chevron-right" size={20} color={Colors.softGrey} />
          )}
        </View>
      )}
    </View>
  );

  if (onPress && !hasSwitch) {
    return (
      <TouchableOpacity onPress={onPress} activeOpacity={0.7}>
        {content}
      </TouchableOpacity>
    );
  }

  return content;
};

interface SettingSectionProps {
  title?: string;
  children: React.ReactNode;
}

/**
 * 设置分组组件
 */
export const SettingSection: React.FC<SettingSectionProps> = ({
  title,
  children,
}) => {
  return (
    <View style={styles.section}>
      {title && <Text style={styles.sectionTitle}>{title}</Text>}
      <View style={styles.sectionContent}>{children}</View>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: Colors.white,
    paddingVertical: Spacing.md,
    paddingHorizontal: Spacing.md,
    borderBottomWidth: 0.5,
    borderBottomColor: Colors.borderLight,
  },
  iconContainer: {
    width: 32,
    height: 32,
    borderRadius: BorderRadius.sm,
    backgroundColor: Colors.softSage,
    alignItems: 'center',
    justifyContent: 'center',
    marginRight: Spacing.md,
  },
  textContainer: {
    flex: 1,
  },
  title: {
    fontSize: 15,
    fontWeight: '500',
    color: Colors.darkGrey,
  },
  subtitle: {
    fontSize: 12,
    color: Colors.softGrey,
    marginTop: 2,
  },
  rightSection: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  value: {
    fontSize: 14,
    color: Colors.softGrey,
    marginRight: Spacing.xs,
  },
  section: {
    marginBottom: Spacing.lg,
  },
  sectionTitle: {
    fontSize: 13,
    fontWeight: '600',
    color: Colors.softGrey,
    marginBottom: Spacing.sm,
    marginLeft: Spacing.md,
    textTransform: 'uppercase',
  },
  sectionContent: {
    borderRadius: BorderRadius.lg,
    overflow: 'hidden',
  },
});

export default SettingTile;
