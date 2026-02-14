import React from 'react';
import { View, TouchableOpacity, StyleSheet, Text } from 'react-native';
import { TabActions } from '@react-navigation/native';
import type { NavigationProp } from '@react-navigation/native';
import Icon from 'react-native-vector-icons/MaterialIcons';
import { Colors } from '../../theme';
import { Spacing } from '../../theme';

/**
 * 导航项配置
 */
export interface NavItem {
  icon: string;
  label: string;
  route: string;
}

/**
 * 默认导航项
 */
export const defaultNavItems: NavItem[] = [
  { icon: 'chat-bubble', label: '助手', route: 'Chat' },
  { icon: 'calendar-today', label: '日程', route: 'Schedule' },
  { icon: 'explore', label: '发现', route: 'Discover' },
  { icon: 'bar-chart', label: '统计', route: 'Stats' },
  { icon: 'settings', label: '设置', route: 'Settings' },
];

/**
 * 简化版导航项
 */
export const simplifiedNavItems: NavItem[] = [
  { icon: 'calendar-today', label: '日程', route: 'Schedule' },
  { icon: 'show-chart', label: '洞察', route: 'Stats' },
  { icon: 'smart-toy', label: 'AI 助手', route: 'Chat' },
  { icon: 'settings', label: '设置', route: 'Settings' },
];

interface BottomNavProps {
  currentRoute: string;
  navigation: NavigationProp<ReactNavigation.RootParamList>;
  items?: NavItem[];
  height?: number;
}

/**
 * 底部导航栏组件
 */
const BottomNav: React.FC<BottomNavProps> = ({
  currentRoute,
  navigation,
  items = defaultNavItems,
  height = 84,
}) => {
  const isRouteActive = (itemRoute: string): boolean => {
    return currentRoute === itemRoute || currentRoute.startsWith(itemRoute);
  };

  const handleNavigation = (route: string) => {
    navigation.dispatch(TabActions.jumpTo(route));
  };

  return (
    <View style={[styles.container, { height }]}>
      {items.map((item) => {
        const isActive = isRouteActive(item.route);
        const color = isActive ? Colors.brandSage : Colors.softGrey;
        const fontWeight = isActive ? '600' : '500';

        return (
          <TouchableOpacity
            key={item.route}
            style={styles.navItem}
            onPress={() => handleNavigation(item.route)}
            activeOpacity={0.7}
          >
            <Icon name={item.icon} size={24} color={color} />
            <Text style={[styles.label, { color, fontWeight }]}>
              {item.label}
            </Text>
          </TouchableOpacity>
        );
      })}
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flexDirection: 'row',
    backgroundColor: Colors.creamBg,
    borderTopWidth: 0.5,
    borderTopColor: Colors.darkGrey + '0D', // 5% opacity
  },
  navItem: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    paddingVertical: Spacing.sm,
  },
  label: {
    fontSize: 10,
    marginTop: 4,
  },
});

export default BottomNav;
