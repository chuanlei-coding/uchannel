/**
 * 动画配置常量
 */
export const Animations = {
  // 页面过渡动画
  pageTransition: {
    duration: 250,
  },

  // 模态框过渡动画
  modalTransition: {
    duration: 300,
  },

  // 侧滑阈值 (屏幕宽度的百分比)
  swipeThreshold: 0.25,

  // 弹簧动画配置
  spring: {
    damping: 20,
    stiffness: 100,
    mass: 1,
  },

  // 淡入动画
  fadeIn: {
    duration: 200,
  },

  // 缩放动画
  scale: {
    duration: 150,
  },
} as const;

/**
 * 缓动函数
 */
export const Easing = {
  easeOut: [0.33, 1, 0.68, 1],
  easeInOut: [0.65, 0, 0.35, 1],
  easeIn: [0.55, 0.055, 0.675, 0.19],
} as const;

export default Animations;
