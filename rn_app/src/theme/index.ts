export { Colors, default as colors } from './colors';
export { Spacing, SpacingStyles, default as spacing } from './spacing';
export { BorderRadius, BorderRadiusValues, default as borderRadius } from './borderRadius';
export { Shadows, ShadowStyles, default as shadows } from './shadows';
export { Animations, Easing, default as animations } from './animations';

// Re-export all
export default {
  Colors: require('./colors').Colors,
  Spacing: require('./spacing').Spacing,
  BorderRadius: require('./borderRadius').BorderRadius,
  Shadows: require('./shadows').Shadows,
  Animations: require('./animations').Animations,
};
