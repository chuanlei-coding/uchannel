import { StyleSheet, Platform } from 'react-native';

/**
 * 应用阴影常量
 * 统一管理应用中的阴影样式，保持一致性
 */
export const Shadows = {
  /// 默认卡片阴影 - 轻微
  cardSm: {
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.03,
    shadowRadius: 4,
    elevation: 2,
  },

  /// 默认卡片阴影 - 中等
  cardMd: {
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 4 },
    shadowOpacity: 0.04,
    shadowRadius: 8,
    elevation: 4,
  },

  /// 默认卡片阴影 - 明显
  cardLg: {
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 8 },
    shadowOpacity: 0.08,
    shadowRadius: 20,
    elevation: 8,
  },

  /// 按钮阴影
  button: {
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.03,
    shadowRadius: 4,
    elevation: 2,
  },

  /// 浮动按钮阴影
  fab: {
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 4 },
    shadowOpacity: 0.2,
    shadowRadius: 8,
    elevation: 6,
  },

  /// 无阴影
  none: {},
} as const;

/**
 * 阴影样式
 */
export const ShadowStyles = StyleSheet.create({
  cardSm: Shadows.cardSm,
  cardMd: Shadows.cardMd,
  cardLg: Shadows.cardLg,
  button: Shadows.button,
  fab: Shadows.fab,
  none: Shadows.none,
});

export default Shadows;
