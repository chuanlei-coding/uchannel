/**
 * 语音录制按钮组件
 *
 * 实现微信风格的"按住说话"功能：
 * - 长按开始录音
 * - 松开发送
 * - 上滑取消
 * - 实时音量波形显示
 */

import React, { useState, useRef, useEffect, useCallback } from 'react';
import {
  View,
  Text,
  StyleSheet,
  TouchableOpacity,
  Animated,
  Dimensions,
  PanResponder,
  Vibration,
  Platform,
} from 'react-native';
import Icon from 'react-native-vector-icons/MaterialIcons';
import { Colors } from '../../theme';
import { Spacing, BorderRadius } from '../../theme';
import * as AudioService from '../../services/audioService';
import type { RecordBackType } from '../../services/audioService';

const { width: SCREEN_WIDTH } = Dimensions.get('window');
const CANCEL_THRESHOLD = -80; // 上滑取消的阈值（像素）

// 录音状态
type RecordState = 'idle' | 'recording' | 'canceling';

interface VoiceRecordButtonProps {
  onRecordComplete: (uri: string, duration: number) => void;
  onRecordStart?: () => void;
  onRecordCancel?: () => void;
  disabled?: boolean;
  maxDuration?: number; // 最大录音时长（秒）
  minDuration?: number; // 最小录音时长（秒）
}

const VoiceRecordButton: React.FC<VoiceRecordButtonProps> = ({
  onRecordComplete,
  onRecordStart,
  onRecordCancel,
  disabled = false,
  maxDuration = 60,
  minDuration = 1,
}) => {
  const [recordState, setRecordState] = useState<RecordState>('idle');
  const [recordDuration, setRecordDuration] = useState(0);
  const [currentMetering, setCurrentMetering] = useState(0);

  // 动画
  const pulseAnim = useRef(new Animated.Value(1)).current;
  const meteringAnims = useRef([
    new Animated.Value(0.3),
    new Animated.Value(0.5),
    new Animated.Value(0.7),
    new Animated.Value(0.9),
    new Animated.Value(0.6),
    new Animated.Value(0.4),
    new Animated.Value(0.8),
    new Animated.Value(0.5),
  ]).current;

  // 手势状态
  const panY = useRef(0);
  const isLongPressTriggered = useRef(false);
  const recordStartTime = useRef(0);

  // 最大录音时长定时器
  const maxDurationTimer = useRef<ReturnType<typeof setTimeout> | null>(null);

  // 录音脉冲动画
  useEffect(() => {
    if (recordState === 'recording') {
      const pulse = Animated.loop(
        Animated.sequence([
          Animated.timing(pulseAnim, {
            toValue: 1.1,
            duration: 500,
            useNativeDriver: true,
          }),
          Animated.timing(pulseAnim, {
            toValue: 1,
            duration: 500,
            useNativeDriver: true,
          }),
        ])
      );
      pulse.start();
      return () => pulse.stop();
    } else {
      pulseAnim.setValue(1);
    }
  }, [recordState, pulseAnim]);

  // 音量波形动画
  useEffect(() => {
    if (recordState === 'recording') {
      const animations = meteringAnims.map((anim, index) => {
        // 基于当前音量计算目标值
        const baseValue = 0.3 + (currentMetering / 100) * 0.7;
        const targetValue = baseValue * (0.6 + Math.random() * 0.8);
        return Animated.timing(anim, {
          toValue: targetValue,
          duration: 100 + index * 20,
          useNativeDriver: true,
        });
      });

      Animated.parallel(animations).start();
    }
  }, [recordState, currentMetering, meteringAnims]);

  // 清理定时器
  const clearMaxDurationTimer = useCallback(() => {
    if (maxDurationTimer.current) {
      clearTimeout(maxDurationTimer.current);
      maxDurationTimer.current = null;
    }
  }, []);

  // 开始录音
  const startRecording = useCallback(async () => {
    if (disabled) return;

    const hasPermission = await AudioService.ensureRecordingPermission();
    if (!hasPermission) return;

    try {
      // 添加录音进度监听
      AudioService.addRecordingListener((event: RecordBackType) => {
        setRecordDuration(event.currentPosition / 1000);
        // 音量表计（-160 到 0，转换为 0-100）
        if (event.currentMetering !== undefined) {
          // currentMetering 范围大约 -160 到 0，转换为 0-100
          const metering = Math.max(0, Math.min(100, (event.currentMetering + 160) / 1.6));
          setCurrentMetering(metering);
        }
      });

      const uri = await AudioService.startRecording();
      if (!uri) {
        AudioService.removeRecordingListener();
        return;
      }

      recordStartTime.current = Date.now();
      setRecordState('recording');
      setRecordDuration(0);

      // 通知父组件录音开始
      onRecordStart?.();

      // 震动反馈
      if (Platform.OS === 'android') {
        Vibration.vibrate(30);
      } else {
        // iOS 使用更轻的震动
        Vibration.vibrate(10);
      }

      // 设置最大录音时长定时器
      maxDurationTimer.current = setTimeout(() => {
        stopRecording(true);
      }, maxDuration * 1000);

    } catch (error) {
      console.error('Start recording error:', error);
      AudioService.removeRecordingListener();
      setRecordState('idle');
    }
  }, [disabled, maxDuration, onRecordStart]);

  // 停止录音
  const stopRecording = useCallback(async (forceSend = false) => {
    clearMaxDurationTimer();

    if (recordState !== 'recording') return;

    try {
      const uri = await AudioService.stopRecording();
      AudioService.removeRecordingListener();

      const duration = recordDuration;
      setRecordState('idle');
      setRecordDuration(0);
      setCurrentMetering(0);

      // 检查是否取消
      if (recordState === 'canceling' && !forceSend) {
        onRecordCancel?.();
        return;
      }

      // 检查最小时长
      if (duration < minDuration) {
        onRecordCancel?.();
        return;
      }

      if (uri) {
        onRecordComplete(uri, Math.round(duration));
      }
    } catch (error) {
      console.error('Stop recording error:', error);
      AudioService.removeRecordingListener();
      setRecordState('idle');
    }
  }, [recordState, recordDuration, minDuration, clearMaxDurationTimer, onRecordComplete, onRecordCancel]);

  // 取消录音
  const cancelRecording = useCallback(async () => {
    if (recordState !== 'recording') return;

    setRecordState('canceling');
    clearMaxDurationTimer();

    try {
      await AudioService.stopRecording();
      AudioService.removeRecordingListener();
    } catch (_) {}

    setRecordState('idle');
    setRecordDuration(0);
    setCurrentMetering(0);
    onRecordCancel?.();
  }, [recordState, clearMaxDurationTimer, onRecordCancel]);

  // 手势处理
  const panResponder = useRef(
    PanResponder.create({
      onStartShouldSetPanResponder: () => true,
      onMoveShouldSetPanResponder: () => true,
      onPanResponderGrant: () => {
        isLongPressTriggered.current = false;
        panY.current = 0;
        // 延迟触发长按（模拟 onLongPress）
        setTimeout(() => {
          if (!isLongPressTriggered.current) {
            isLongPressTriggered.current = true;
            startRecording();
          }
        }, 200);
      },
      onPanResponderMove: (_, gestureState) => {
        panY.current = gestureState.dy;
        // 检测是否上滑超过阈值
        if (recordState === 'recording' && gestureState.dy < CANCEL_THRESHOLD) {
          setRecordState('canceling');
        } else if (recordState === 'canceling' && gestureState.dy >= CANCEL_THRESHOLD) {
          setRecordState('recording');
        }
      },
      onPanResponderRelease: () => {
        if (isLongPressTriggered.current) {
          if (panY.current < CANCEL_THRESHOLD) {
            cancelRecording();
          } else {
            stopRecording();
          }
        }
        isLongPressTriggered.current = false;
      },
      onPanResponderTerminate: () => {
        if (isLongPressTriggered.current) {
          cancelRecording();
        }
        isLongPressTriggered.current = false;
      },
    })
  ).current;

  // 格式化时长
  const formatDuration = (seconds: number): string => {
    const mins = Math.floor(seconds / 60);
    const secs = Math.floor(seconds % 60);
    return `${mins}:${secs.toString().padStart(2, '0')}`;
  };

  // 组件卸载时清理
  useEffect(() => {
    return () => {
      clearMaxDurationTimer();
      try {
        AudioService.stopRecording();
        AudioService.removeRecordingListener();
      } catch (_) {}
    };
  }, [clearMaxDurationTimer]);

  // 录音状态UI
  if (recordState !== 'idle') {
    return (
      <View style={styles.recordingContainer}>
        {/* 取消提示区域 */}
        <View style={[
          styles.cancelHint,
          recordState === 'canceling' && styles.cancelHintActive,
        ]}>
          <Icon
            name="cancel"
            size={20}
            color={recordState === 'canceling' ? Colors.terracotta : Colors.softGrey}
          />
          <Text style={[
            styles.cancelHintText,
            recordState === 'canceling' && styles.cancelHintTextActive,
          ]}>
            {recordState === 'canceling' ? '松开取消' : '上滑取消'}
          </Text>
        </View>

        {/* 录音状态 */}
        <View style={styles.recordingStatus}>
          {/* 音量波形 */}
          <View style={styles.waveform}>
            {meteringAnims.map((anim, index) => (
              <Animated.View
                key={index}
                style={[
                  styles.waveBar,
                  {
                    transform: [{ scaleY: anim }],
                    backgroundColor: recordState === 'canceling'
                      ? Colors.terracotta
                      : Colors.brandSage,
                  },
                ]}
              />
            ))}
          </View>

          {/* 时长 */}
          <Text style={styles.durationText}>
            {formatDuration(recordDuration)}
          </Text>

          {/* 提示文字 */}
          <Text style={styles.hintText}>
            {recordState === 'canceling' ? '松开手指取消发送' : '松开发送，上滑取消'}
          </Text>
        </View>

        {/* 按住提示 */}
        <Animated.View
          style={[
            styles.pressHint,
            { transform: [{ scale: pulseAnim }] },
          ]}
          {...panResponder.panHandlers}
        >
          <Icon name="mic" size={24} color={Colors.white} />
          <Text style={styles.pressHintText}>
            {recordState === 'canceling' ? '取消' : '松开发送'}
          </Text>
        </Animated.View>
      </View>
    );
  }

  // 空闲状态
  return (
    <View
      style={[styles.container, disabled && styles.containerDisabled]}
      {...panResponder.panHandlers}
    >
      <Icon
        name="mic"
        size={24}
        color={disabled ? Colors.softGrey + '80' : Colors.softGrey + '99'}
      />
      <Text style={[styles.buttonText, disabled && styles.buttonTextDisabled]}>
        按住说话
      </Text>
    </View>
  );
};

const styles = StyleSheet.create({
  // 空闲状态按钮
  container: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    paddingVertical: Spacing.sm,
    paddingHorizontal: Spacing.md,
    backgroundColor: Colors.white,
    borderRadius: BorderRadius.full,
    borderWidth: 1,
    borderColor: Colors.borderLightAlt + '80',
    minWidth: 100,
  },
  containerDisabled: {
    opacity: 0.5,
  },
  buttonText: {
    fontSize: 14,
    color: Colors.softGrey,
    marginLeft: Spacing.xs,
  },
  buttonTextDisabled: {
    color: Colors.softGrey + '80',
  },

  // 录音状态容器
  recordingContainer: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    paddingVertical: Spacing.sm,
    paddingHorizontal: Spacing.md,
    backgroundColor: Colors.white,
    borderRadius: BorderRadius.full,
    borderWidth: 1,
    borderColor: Colors.brandSage + '40',
    minWidth: SCREEN_WIDTH - Spacing.lg * 2,
  },

  // 取消提示
  cancelHint: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingHorizontal: Spacing.sm,
    paddingVertical: Spacing.xs,
    borderRadius: BorderRadius.md,
    backgroundColor: Colors.softGrey + '1A',
  },
  cancelHintActive: {
    backgroundColor: Colors.terracotta + '1A',
  },
  cancelHintText: {
    fontSize: 12,
    color: Colors.softGrey,
    marginLeft: 4,
  },
  cancelHintTextActive: {
    color: Colors.terracotta,
    fontWeight: '500',
  },

  // 录音状态
  recordingStatus: {
    flex: 1,
    alignItems: 'center',
    paddingHorizontal: Spacing.sm,
  },

  // 音量波形
  waveform: {
    flexDirection: 'row',
    alignItems: 'center',
    height: 24,
    marginBottom: 2,
  },
  waveBar: {
    width: 3,
    height: 20,
    borderRadius: 1.5,
    marginHorizontal: 1,
  },

  // 时长
  durationText: {
    fontSize: 12,
    fontWeight: '600',
    color: Colors.darkGrey,
    fontVariant: ['tabular-nums'],
  },

  // 提示文字
  hintText: {
    fontSize: 10,
    color: Colors.softGrey,
    marginTop: 2,
  },

  // 按住提示
  pressHint: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    paddingVertical: Spacing.sm,
    paddingHorizontal: Spacing.md,
    backgroundColor: Colors.brandSage,
    borderRadius: BorderRadius.full,
    minWidth: 80,
  },
  pressHintText: {
    fontSize: 12,
    color: Colors.white,
    marginLeft: 4,
    fontWeight: '500',
  },
});

export default VoiceRecordButton;
