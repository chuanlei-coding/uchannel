import { StyleSheet } from 'react-native';

/**
 * 应用间距常量
 * 统一管理应用中的间距值，保持一致性
 */
export const Spacing = {
  xs: 4,
  sm: 8,
  md: 16,
  lg: 24,
  xl: 32,
  xxl: 48,
  xxxl: 64,
} as const;

/**
 * EdgeInsets 预设样式
 */
export const SpacingStyles = StyleSheet.create({
  allXS: { padding: Spacing.xs },
  allSM: { padding: Spacing.sm },
  allMD: { padding: Spacing.md },
  allLG: { padding: Spacing.lg },
  allXL: { padding: Spacing.xl },

  horizontalMD: { paddingHorizontal: Spacing.md },
  horizontalLG: { paddingHorizontal: Spacing.lg },
  verticalMD: { paddingVertical: Spacing.md },
  verticalLG: { paddingVertical: Spacing.lg },

  onlyTopMD: { paddingTop: Spacing.md },
  onlyBottomMD: { paddingBottom: Spacing.md },

  // Margin presets
  marginBottomSM: { marginBottom: Spacing.sm },
  marginBottomMD: { marginBottom: Spacing.md },
  marginBottomLG: { marginBottom: Spacing.lg },
  marginTopMD: { marginTop: Spacing.md },
  marginTopLG: { marginTop: Spacing.lg },
});

export default Spacing;
