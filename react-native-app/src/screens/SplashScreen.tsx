import React, {useEffect} from 'react';
import {
  View,
  Text,
  StyleSheet,
  TouchableOpacity,
  Animated,
} from 'react-native';
import {useNavigation} from '@react-navigation/native';
import {Colors} from '../utils/colors';

const SplashScreen = () => {
  const navigation = useNavigation();
  const fadeAnim = new Animated.Value(0);

  useEffect(() => {
    Animated.timing(fadeAnim, {
      toValue: 1,
      duration: 1000,
      useNativeDriver: true,
    }).start();

    // 3秒后自动跳转
    const timer = setTimeout(() => {
      navigation.navigate('Main' as never);
    }, 3000);

    return () => clearTimeout(timer);
  }, [fadeAnim, navigation]);

  const handleEnter = () => {
    navigation.navigate('Main' as never);
  };

  return (
    <View style={styles.container}>
      <Animated.View style={[styles.content, {opacity: fadeAnim}]}>
        {/* Vita Logo */}
        <View style={styles.logoContainer}>
          <View style={styles.leafShape} />
          <View style={styles.arcShape} />
        </View>

        {/* Title */}
        <Text style={styles.title}>Vita</Text>

        {/* Subtitle */}
        <View style={styles.subtitleContainer}>
          <Text style={styles.subtitle}>岁序更替，步履轻盈</Text>
          <Text style={styles.subtitleEn}>
            Seasons change, steps stay light
          </Text>
        </View>
      </Animated.View>

      {/* Footer */}
      <View style={styles.footer}>
        <TouchableOpacity
          style={styles.enterButton}
          onPress={handleEnter}
          activeOpacity={0.8}>
          <Text style={styles.enterIcon}>↓</Text>
        </TouchableOpacity>
        <Text style={styles.enterText}>Enter Space</Text>

        <View style={styles.taglineContainer}>
          <View style={styles.dot} />
          <Text style={styles.tagline}>IN MINUTIAE, LIFE UNFOLDS</Text>
          <View style={styles.dot} />
        </View>
        <Text style={styles.copyright}>© 2024 Vita Studio</Text>
      </View>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: Colors.charcoal,
    justifyContent: 'space-between',
    alignItems: 'center',
    paddingVertical: 40,
  },
  content: {
    alignItems: 'center',
    marginTop: 80,
  },
  logoContainer: {
    width: 140,
    height: 140,
    marginBottom: 48,
    position: 'relative',
  },
  leafShape: {
    position: 'absolute',
    width: 90,
    height: 90,
    backgroundColor: Colors.brandSage,
    borderRadius: 80,
    bottom: 5,
    left: 5,
    transform: [{rotate: '-15deg'}],
    opacity: 0.9,
  },
  arcShape: {
    position: 'absolute',
    width: 100,
    height: 100,
    borderWidth: 10,
    borderColor: Colors.brandTeal,
    borderBottomColor: 'transparent',
    borderLeftColor: 'transparent',
    borderRadius: 50,
    top: 5,
    right: 5,
    transform: [{rotate: '45deg'}],
    opacity: 0.7,
  },
  title: {
    fontSize: 60,
    color: Colors.textPrimary,
    fontFamily: 'serif',
    letterSpacing: 0.02,
  },
  subtitleContainer: {
    alignItems: 'center',
    marginTop: 16,
    opacity: 0.9,
  },
  subtitle: {
    fontSize: 20,
    color: Colors.brandSage,
    fontStyle: 'italic',
  },
  subtitleEn: {
    fontSize: 10,
    color: Colors.textWhite40,
    letterSpacing: 0.03,
    marginTop: 8,
  },
  footer: {
    alignItems: 'center',
    paddingBottom: 40,
  },
  enterButton: {
    width: 56,
    height: 56,
    borderRadius: 28,
    backgroundColor: Colors.glassGrey,
    borderWidth: 1,
    borderColor: Colors.textWhite20,
    justifyContent: 'center',
    alignItems: 'center',
    marginBottom: 16,
  },
  enterIcon: {
    fontSize: 24,
    color: Colors.brandSage,
  },
  enterText: {
    fontSize: 12,
    color: Colors.textWhite40,
    letterSpacing: 0.02,
    marginBottom: 40,
    textTransform: 'uppercase',
  },
  taglineContainer: {
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: 8,
  },
  dot: {
    width: 4,
    height: 4,
    borderRadius: 2,
    backgroundColor: Colors.brandSage,
    opacity: 0.4,
    marginHorizontal: 12,
  },
  tagline: {
    fontSize: 11,
    color: Colors.textWhite30,
    letterSpacing: 0.1,
  },
  copyright: {
    fontSize: 10,
    color: Colors.textWhite20,
  },
});

export default SplashScreen;
