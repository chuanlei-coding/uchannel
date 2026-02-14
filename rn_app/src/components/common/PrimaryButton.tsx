import React from 'react';
import {
  View,
  Text,
  TouchableOpacity,
  StyleSheet,
  ActivityIndicator,
} from 'react-native';
import Icon from 'react-native-vector-icons/MaterialIcons';
import { Colors } from '../../theme';
import { Spacing, BorderRadius, Shadows } from '../../theme';

/**
 * 按钮变体
 */
export type ButtonVariant = 'filled' | 'outlined' | 'text';

/**
 * 按钮尺寸
 */
export type ButtonSize = 'small' | 'medium' | 'large';

/**
 * 图标位置
 */
export type IconPosition = 'left' | 'right';

interface PrimaryButtonProps {
  text: string;
  onPress?: () => void;
  isLoading?: boolean;
  isDisabled?: boolean;
  width?: number;
  height?: number;
  backgroundColor?: string;
  textColor?: string;
  variant?: ButtonVariant;
  size?: ButtonSize;
  icon?: string;
  iconPosition?: IconPosition;
}

/**
 * 主要按钮组件
 */
const PrimaryButton: React.FC<PrimaryButtonProps> = ({
  text,
  onPress,
  isLoading = false,
  isDisabled = false,
  width,
  height,
  backgroundColor,
  textColor,
  variant = 'filled',
  size = 'medium',
  icon,
  iconPosition = 'left',
}) => {
  const isEnabled = !isDisabled && !isLoading;

  const getBackgroundColor = (): string => {
    if (backgroundColor) return backgroundColor;
    return variant === 'filled' ? Colors.brandSage : 'transparent';
  };

  const getTextColor = (): string => {
    if (textColor) return textColor;
    return variant === 'filled' ? Colors.white : Colors.brandSage;
  };

  const getHeight = (): number => {
    if (height) return height;
    switch (size) {
      case 'small':
        return 40;
      case 'medium':
        return 48;
      case 'large':
        return 56;
    }
  };

  const getFontSize = (): number => {
    switch (size) {
      case 'small':
        return 14;
      case 'medium':
        return 16;
      case 'large':
        return 18;
    }
  };

  const getIconSize = (): number => {
    switch (size) {
      case 'small':
        return 16;
      case 'medium':
        return 18;
      case 'large':
        return 20;
    }
  };

  const getBorderRadius = (): number => {
    return size === 'large' ? BorderRadius.xl : BorderRadius.full;
  };

  const buttonStyle = [
    styles.button,
    {
      width,
      height: getHeight(),
      backgroundColor: variant === 'filled' ? getBackgroundColor() : 'transparent',
      borderRadius: getBorderRadius(),
      borderWidth: variant === 'outlined' ? 1 : 0,
      borderColor: variant === 'outlined' ? Colors.brandSage : 'transparent',
    },
    variant === 'filled' && isEnabled && Shadows.button,
  ];

  const contentChildren: React.ReactNode[] = [];

  if (isLoading) {
    contentChildren.push(
      <ActivityIndicator
        key="loader"
        size="small"
        color={getTextColor()}
        style={styles.loader}
      />
    );
  } else if (icon) {
    contentChildren.push(
      <Icon
        key="icon"
        name={icon}
        size={getIconSize()}
        color={getTextColor()}
        style={styles.icon}
      />
    );
  }

  if (!isLoading || icon) {
    contentChildren.push(
      <Text
        key="text"
        style={[
          styles.text,
          {
            color: getTextColor(),
            fontSize: getFontSize(),
            letterSpacing: variant === 'filled' ? 2 : 0.5,
          },
        ]}
      >
        {text}
      </Text>
    );
  }

  const arrangedChildren =
    iconPosition === 'right' && !isLoading
      ? contentChildren.reverse()
      : contentChildren;

  return (
    <TouchableOpacity
      onPress={isEnabled ? onPress : undefined}
      disabled={!isEnabled}
      activeOpacity={0.8}
      style={{ opacity: isEnabled ? 1 : 0.5 }}
    >
      <View style={buttonStyle}>{arrangedChildren}</View>
    </TouchableOpacity>
  );
};

const styles = StyleSheet.create({
  button: {
    flexDirection: 'row',
    justifyContent: 'center',
    alignItems: 'center',
    paddingHorizontal: Spacing.lg,
  },
  text: {
    fontWeight: '600',
  },
  icon: {
    marginRight: Spacing.sm,
  },
  loader: {
    marginRight: Spacing.sm,
  },
});

export default PrimaryButton;
