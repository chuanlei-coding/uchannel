import React, { useEffect, useRef } from 'react';
import { View, Text, StyleSheet, Animated, TouchableOpacity, Dimensions } from 'react-native';
import { useNavigation } from '@react-navigation/native';
import { Colors } from '../../theme';
import { Spacing, BorderRadius } from '../../theme';

const { width, height } = Dimensions.get('window');

/**
 * 启动页 - 柔和版
 */
const SplashScreen: React.FC = () => {
  const navigation = useNavigation();
  const fadeAnim = useRef(new Animated.Value(0)).current;
  const scaleAnim = useRef(new Animated.Value(0.8)).current;

  useEffect(() => {
    // 启动动画
    Animated.parallel([
      Animated.timing(fadeAnim, {
        toValue: 1,
        duration: 900,
        useNativeDriver: true,
      }),
      Animated.timing(scaleAnim, {
        toValue: 1,
        duration: 900,
        useNativeDriver: true,
      }),
    ]).start();

    // 3秒后自动跳转
    const timer = setTimeout(() => {
      navigation.navigate('Main' as never);
    }, 3000);

    return () => clearTimeout(timer);
  }, []);

  const handleEnterSpace = () => {
    navigation.navigate('Main' as never);
  };

  return (
    <View style={styles.container}>
      {/* 背景装饰 */}
      <View style={styles.backgroundDecoration1} />
      <View style={styles.backgroundDecoration2} />

      {/* 主内容 */}
      <Animated.View
        style={[
          styles.content,
          {
            opacity: fadeAnim,
            transform: [{ scale: scaleAnim }],
          },
        ]}
      >
        {/* Logo */}
        <View style={styles.logoContainer}>
          <View style={styles.leafShape} />
          <View style={styles.arcShape} />
        </View>

        {/* 标题 */}
        <Text style={styles.title}>Vita</Text>

        {/* 中文格言 */}
        <Text style={styles.chineseMotto}>在微小中，见终生</Text>

        {/* 英文格言 */}
        <Text style={styles.englishMotto}>Life unfolds in minutiae</Text>
      </Animated.View>

      {/* 底部区域 */}
      <View style={styles.bottomSection}>
        {/* 进入空间按钮 */}
        <TouchableOpacity style={styles.enterButton} onPress={handleEnterSpace}>
          <Text style={styles.enterButtonText}>进入空间</Text>
        </TouchableOpacity>
        <Text style={styles.enterButtonSubtext}>Enter Space</Text>

        {/* Android Edition 标签 */}
        <View style={styles.editionContainer}>
          <View style={styles.editionLine} />
          <Text style={styles.editionText}>Android Edition</Text>
          <View style={styles.editionLine} />
        </View>
      </View>

      {/* 底部指示器 */}
      <View style={styles.bottomIndicator} />
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: Colors.creamBg,
  },
  backgroundDecoration1: {
    position: 'absolute',
    top: -height * 0.05,
    right: -width * 0.1,
    width: width * 0.6,
    height: height * 0.4,
    borderRadius: width * 0.3,
    backgroundColor: Colors.brandSage + '0D', // 5% opacity
  },
  backgroundDecoration2: {
    position: 'absolute',
    bottom: -height * 0.05,
    left: -width * 0.1,
    width: width * 0.5,
    height: height * 0.4,
    borderRadius: width * 0.25,
    backgroundColor: Colors.brandTeal + '0D', // 5% opacity
  },
  content: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    paddingHorizontal: Spacing.xl,
  },
  logoContainer: {
    width: 120,
    height: 120,
    marginBottom: Spacing.xxl,
  },
  leafShape: {
    position: 'absolute',
    left: 4,
    bottom: 4,
    width: 78,
    height: 78,
    backgroundColor: Colors.brandSage,
    borderTopLeftRadius: 62,
    borderBottomRightRadius: 62,
    transform: [{ rotate: '-15deg' }],
    shadowColor: Colors.brandSage,
    shadowOffset: { width: 0, height: 4 },
    shadowOpacity: 0.2,
    shadowRadius: 10,
    elevation: 4,
  },
  arcShape: {
    position: 'absolute',
    right: 4,
    top: 4,
    width: 86,
    height: 86,
    borderRadius: 43,
    borderTopWidth: 8,
    borderRightWidth: 8,
    borderColor: Colors.brandTeal + '99', // 60% opacity
    transform: [{ rotate: '45deg' }],
  },
  title: {
    fontSize: 60,
    fontWeight: '300',
    letterSpacing: -1.5,
    color: Colors.darkGrey,
  },
  chineseMotto: {
    fontSize: 24,
    fontWeight: '400',
    letterSpacing: 4.8,
    color: Colors.darkGrey + 'CC', // 80% opacity
    marginTop: Spacing.lg,
  },
  englishMotto: {
    fontSize: 10,
    fontWeight: '500',
    letterSpacing: 4,
    color: Colors.darkGrey + '4D', // 30% opacity
    marginTop: Spacing.md,
  },
  bottomSection: {
    alignItems: 'center',
    paddingBottom: Spacing.xxxl,
  },
  enterButton: {
    paddingHorizontal: 40,
    paddingVertical: 14,
    backgroundColor: Colors.buttonSage,
    borderRadius: BorderRadius.full,
    shadowColor: Colors.brandSage,
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.2,
    shadowRadius: 4,
    elevation: 2,
  },
  enterButtonText: {
    fontSize: 16,
    fontWeight: '500',
    letterSpacing: 3.2,
    color: Colors.white,
  },
  enterButtonSubtext: {
    fontSize: 9,
    fontWeight: '700',
    letterSpacing: 1.8,
    color: Colors.darkGrey + '66', // 40% opacity
    marginTop: Spacing.md,
  },
  editionContainer: {
    flexDirection: 'row',
    alignItems: 'center',
    marginTop: Spacing.xxl + Spacing.md,
  },
  editionLine: {
    width: 24,
    height: 1,
    backgroundColor: Colors.darkGrey + '1A', // 10% opacity
  },
  editionText: {
    fontSize: 10,
    fontWeight: '500',
    letterSpacing: 3,
    color: Colors.darkGrey + '4D', // 30% opacity
    marginHorizontal: Spacing.md,
  },
  bottomIndicator: {
    width: 128,
    height: 4,
    backgroundColor: Colors.darkGrey + '1A', // 10% opacity
    borderRadius: 2,
    alignSelf: 'center',
    marginBottom: Spacing.md,
  },
});

export default SplashScreen;
