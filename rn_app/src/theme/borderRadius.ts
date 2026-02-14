/**
 * 应用圆角常量
 * 统一管理应用中的圆角半径，保持一致性
 */
export const BorderRadius = {
  xs: 4,
  sm: 8,
  md: 12,
  lg: 16,
  xl: 24,
  xxl: 32,
  xxxl: 40,
  full: 999,
} as const;

/**
 * 根据用途命名的圆角
 */
export const BorderRadiusValues = {
  button: BorderRadius.full,
  card: BorderRadius.lg,
  modal: BorderRadius.xxl,
  input: BorderRadius.full,
  iconButton: BorderRadius.lg,
  tag: BorderRadius.sm,
  avatar: BorderRadius.full,
} as const;

export default BorderRadius;
