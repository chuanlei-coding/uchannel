import React, { useRef, useState } from 'react';
import {
  View,
  Modal,
  Image,
  TouchableOpacity,
  StyleSheet,
  Animated,
  Dimensions,
  StatusBar,
} from 'react-native';
import Icon from 'react-native-vector-icons/MaterialIcons';
import { Colors } from '../../theme';
import { Spacing } from '../../theme';

const { width: SCREEN_WIDTH, height: SCREEN_HEIGHT } = Dimensions.get('window');

interface ImagePreviewProps {
  visible: boolean;
  imageUri: string;
  onClose: () => void;
}

/**
 * 图片预览组件
 * 支持双击放大/缩小，点击背景关闭
 */
const ImagePreview: React.FC<ImagePreviewProps> = ({ visible, imageUri, onClose }) => {
  const [scale, setScale] = useState(1);
  const scaleAnim = useRef(new Animated.Value(1)).current;
  const opacityAnim = useRef(new Animated.Value(0)).current;

  // 显示时的动画
  React.useEffect(() => {
    if (visible) {
      Animated.parallel([
        Animated.timing(opacityAnim, {
          toValue: 1,
          duration: 200,
          useNativeDriver: true,
        }),
        Animated.spring(scaleAnim, {
          toValue: 1,
          friction: 8,
          tension: 40,
          useNativeDriver: true,
        }),
      ]).start();
    } else {
      opacityAnim.setValue(0);
      scaleAnim.setValue(0.8);
      setScale(1);
    }
  }, [visible, opacityAnim, scaleAnim]);

  // 双击切换缩放
  const handleDoubleTap = () => {
    const newScale = scale === 1 ? 2.5 : 1;
    setScale(newScale);
    Animated.spring(scaleAnim, {
      toValue: newScale,
      friction: 8,
      tension: 40,
      useNativeDriver: true,
    }).start();
  };

  // 单击关闭（仅在原始大小时）
  const handleTap = () => {
    if (scale === 1) {
      handleClose();
    }
  };

  // 关闭预览
  const handleClose = () => {
    Animated.timing(opacityAnim, {
      toValue: 0,
      duration: 150,
      useNativeDriver: true,
    }).start(() => {
      onClose();
    });
  };

  return (
    <Modal
      visible={visible}
      transparent
      animationType="none"
      statusBarTranslucent
      onRequestClose={handleClose}
    >
      <StatusBar barStyle="light-content" backgroundColor="rgba(0,0,0,0.95)" />
      <Animated.View style={[styles.container, { opacity: opacityAnim }]}>
        {/* 背景遮罩 */}
        <TouchableOpacity
          style={styles.background}
          activeOpacity={1}
          onPress={handleTap}
        />

        {/* 关闭按钮 */}
        <TouchableOpacity style={styles.closeButton} onPress={handleClose}>
          <Icon name="close" size={28} color={Colors.white} />
        </TouchableOpacity>

        {/* 图片 */}
        <Animated.View style={[styles.imageContainer, { transform: [{ scale: scaleAnim }] }]}>
          <TouchableOpacity
            activeOpacity={1}
            onPress={handleTap}
            onLongPress={handleDoubleTap}
          >
            <Image
              source={{ uri: imageUri }}
              style={styles.image}
              resizeMode="contain"
            />
          </TouchableOpacity>
        </Animated.View>

        {/* 提示文字 */}
        <Animated.View style={[styles.hint, { opacity: opacityAnim }]}>
          <Icon name="touch-app" size={16} color={Colors.white + '80'} />
          <Animated.Text style={styles.hintText}>
            长按图片可放大查看
          </Animated.Text>
        </Animated.View>
      </Animated.View>
    </Modal>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: 'rgba(0,0,0,0.95)',
    justifyContent: 'center',
    alignItems: 'center',
  },
  background: {
    ...StyleSheet.absoluteFillObject,
  },
  closeButton: {
    position: 'absolute',
    top: Spacing.xxl + Spacing.md,
    right: Spacing.lg,
    width: 44,
    height: 44,
    borderRadius: 22,
    backgroundColor: 'rgba(255,255,255,0.15)',
    justifyContent: 'center',
    alignItems: 'center',
    zIndex: 10,
  },
  imageContainer: {
    width: SCREEN_WIDTH,
    height: SCREEN_HEIGHT,
    justifyContent: 'center',
    alignItems: 'center',
  },
  image: {
    width: SCREEN_WIDTH,
    height: SCREEN_HEIGHT * 0.8,
  },
  hint: {
    position: 'absolute',
    bottom: Spacing.xxl + Spacing.lg,
    flexDirection: 'row',
    alignItems: 'center',
    gap: Spacing.xs,
  },
  hintText: {
    fontSize: 13,
    color: Colors.white + '80',
  },
});

export default ImagePreview;
