import React, { useState, useRef, useEffect, useCallback } from 'react';
import { View, Text, StyleSheet, Image, TouchableOpacity, Animated } from 'react-native';
import Icon from 'react-native-vector-icons/MaterialIcons';
import { Message, MessageSender, MessageType } from '../../models/Message';
import { Colors } from '../../theme';
import { Spacing, BorderRadius, Shadows } from '../../theme';
import * as AudioService from '../../services/audioService';

// ============== 旧的 react-native-audio-api 实现 (备份，等稳定后删除) ==============
/*
// 延迟加载 react-native-audio-api（避免在 JSI 未就绪时触发模块初始化）
let _audioApi: any = null;
function getAudioApi() {
  if (!_audioApi) {
    _audioApi = require('react-native-audio-api');
  }
  return _audioApi;
}

// 解析自定义 PCM base64 URI 格式
// 格式：pcm-base64:{sampleRate}:{channels}:{base64data}
function parsePcmBase64Uri(uri: string): { sampleRate: number; channels: number; base64: string } | null {
  if (!uri.startsWith('pcm-base64:')) return null;
  const parts = uri.substring('pcm-base64:'.length).split(':');
  if (parts.length < 3) return null;
  return {
    sampleRate: parseInt(parts[0], 10),
    channels: parseInt(parts[1], 10),
    base64: parts.slice(2).join(':'),
  };
}

// 旧播放逻辑...
// 问题：录音播放时出现杂音，可能是 PCM 编码/解码问题
// 相关 GitHub Issue: https://github.com/software-mansion/react-native-audio-api/issues/809
*/
// ============== 旧的 react-native-audio-api 实现结束 ==============

interface MessageItemProps {
  message: Message;
}

/**
 * 语音消息气泡 (使用 react-native-nitro-sound)
 */
const VoiceBubble: React.FC<{
  message: Message;
  isUser: boolean;
}> = ({ message, isUser }) => {
  const [isPlaying, setIsPlaying] = useState(false);
  const [playProgress, setPlayProgress] = useState(0);
  const waveAnim = useRef(new Animated.Value(0)).current;

  const duration = message.voiceDuration ?? 0;

  // 根据时长计算气泡宽度（最小120，最大240）
  const bubbleWidth = Math.min(240, Math.max(120, 120 + duration * 8));

  useEffect(() => {
    if (isPlaying) {
      const anim = Animated.loop(
        Animated.sequence([
          Animated.timing(waveAnim, { toValue: 1, duration: 800, useNativeDriver: true }),
          Animated.timing(waveAnim, { toValue: 0, duration: 800, useNativeDriver: true }),
        ])
      );
      anim.start();
      return () => anim.stop();
    } else {
      waveAnim.setValue(0);
    }
  }, [isPlaying, waveAnim]);

  // 清理
  useEffect(() => {
    return () => {
      stopPlayback();
    };
  // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  const stopPlayback = useCallback(async () => {
    try {
      await AudioService.stopPlayback();
    } catch (_) {}
    setIsPlaying(false);
    setPlayProgress(0);
  }, []);

  const handlePlay = async () => {
    if (isPlaying) {
      await stopPlayback();
      return;
    }

    if (!message.voiceUri) return;

    try {
      const result = await AudioService.startPlayback(
        message.voiceUri,
        // 进度回调
        (position: number, totalDuration: number) => {
          const progress = totalDuration > 0 ? position / totalDuration : 0;
          setPlayProgress(Math.min(progress, 1));
        },
        // 播放结束回调
        () => {
          setIsPlaying(false);
          setPlayProgress(0);
        }
      );

      if (result) {
        setIsPlaying(true);
      }
    } catch (error) {
      console.error('Play voice error:', error);
      await stopPlayback();
    }
  };

  const formatDuration = (sec: number): string => {
    if (sec < 60) return `${sec}"`;
    const min = Math.floor(sec / 60);
    const s = sec % 60;
    return `${min}'${s.toString().padStart(2, '0')}"`;
  };

  // 声波条的透明度动画
  const waveOpacity = waveAnim.interpolate({
    inputRange: [0, 1],
    outputRange: [0.3, 1],
  });

  return (
    <TouchableOpacity
      style={[
        styles.voiceBubble,
        isUser ? styles.bubbleUser : styles.bubbleAssistant,
        { width: bubbleWidth },
        Shadows.cardSm,
      ]}
      onPress={handlePlay}
      activeOpacity={0.7}
    >
      <View style={styles.voiceContent}>
        <Icon
          name={isPlaying ? 'pause' : 'play-arrow'}
          size={22}
          color={isUser ? Colors.white : Colors.brandSage}
        />

        {/* 声波动画 */}
        <View style={styles.waveContainer}>
          {[0.4, 0.7, 1, 0.6, 0.9, 0.5, 0.8, 0.3].map((h, i) => (
            <Animated.View
              key={i}
              style={[
                styles.waveBar,
                {
                  height: 4 + h * 14,
                  backgroundColor: isUser
                    ? Colors.white
                    : Colors.brandSage,
                  opacity: isPlaying
                    ? (i / 8 <= playProgress ? 1 : waveOpacity)
                    : 0.5,
                },
              ]}
            />
          ))}
        </View>

        <Text
          style={[
            styles.voiceDuration,
            { color: isUser ? Colors.white + 'CC' : Colors.softGrey },
          ]}
        >
          {formatDuration(duration)}
        </Text>
      </View>
    </TouchableOpacity>
  );
};

/**
 * 消息项组件
 */
const MessageItem: React.FC<MessageItemProps> = ({ message }) => {
  const isUser = message.sender === MessageSender.user;
  const isSuggestion = message.sender === MessageSender.suggestion;
  const isImage = message.type === MessageType.image;
  const isVoice = message.type === MessageType.voice;

  const formatTime = (date: Date): string => {
    return date.toLocaleTimeString('zh-CN', {
      hour: '2-digit',
      minute: '2-digit',
    });
  };

  if (isSuggestion) {
    return (
      <View style={styles.suggestionContainer}>
        <Text style={styles.suggestionText}>{message.content}</Text>
      </View>
    );
  }

  return (
    <View
      style={[
        styles.container,
        isUser ? styles.containerUser : styles.containerAssistant,
      ]}
    >
      {!isUser && (
        <View style={styles.avatar}>
          <Text style={styles.avatarText}>V</Text>
        </View>
      )}

      {/* 语音消息 */}
      {isVoice ? (
        <View>
          <VoiceBubble message={message} isUser={isUser} />
          <Text style={[styles.timeText, { textAlign: isUser ? 'right' : 'left' }]}>
            {formatTime(message.timestamp)}
          </Text>
        </View>
      ) : (
        <View
          style={[
            styles.bubble,
            isUser ? styles.bubbleUser : styles.bubbleAssistant,
            isImage && styles.bubbleImage,
            Shadows.cardSm,
          ]}
        >
          {/* 图片消息 */}
          {isImage && message.imageUri && (
            <Image
              source={{ uri: message.imageUri }}
              style={styles.messageImage}
              resizeMode="cover"
            />
          )}

          {/* 文字消息 */}
          {!isImage && (
            <Text
              style={[styles.messageText, isUser && styles.messageTextUser]}
            >
              {message.content}
            </Text>
          )}

          {message.contentSecondary && (
            <Text style={styles.secondaryText}>
              {message.contentSecondary}
            </Text>
          )}

          <Text style={[styles.timeText, isImage && styles.timeTextImage]}>
            {formatTime(message.timestamp)}
          </Text>
        </View>
      )}
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flexDirection: 'row',
    marginVertical: Spacing.xs,
    paddingHorizontal: Spacing.md,
  },
  containerUser: {
    justifyContent: 'flex-end',
  },
  containerAssistant: {
    justifyContent: 'flex-start',
  },
  avatar: {
    width: 32,
    height: 32,
    borderRadius: BorderRadius.full,
    backgroundColor: Colors.brandSage,
    alignItems: 'center',
    justifyContent: 'center',
    marginRight: Spacing.sm,
  },
  avatarText: {
    color: Colors.white,
    fontWeight: '600',
    fontSize: 14,
  },
  bubble: {
    maxWidth: '75%',
    paddingVertical: Spacing.sm,
    paddingHorizontal: Spacing.md,
    borderRadius: BorderRadius.lg,
  },
  bubbleUser: {
    backgroundColor: Colors.brandSage,
    borderBottomRightRadius: BorderRadius.xs,
  },
  bubbleAssistant: {
    backgroundColor: Colors.white,
    borderBottomLeftRadius: BorderRadius.xs,
  },
  bubbleImage: {
    padding: Spacing.xs,
    backgroundColor: 'transparent',
  },
  messageImage: {
    width: 200,
    height: 200,
    borderRadius: BorderRadius.md,
  },
  messageText: {
    fontSize: 15,
    lineHeight: 20,
    color: Colors.darkGrey,
  },
  messageTextUser: {
    color: Colors.white,
  },
  secondaryText: {
    fontSize: 13,
    color: Colors.softGrey,
    marginTop: Spacing.xs,
  },
  timeText: {
    fontSize: 10,
    color: Colors.softGrey,
    marginTop: Spacing.xs,
    textAlign: 'right',
  },
  timeTextImage: {
    color: Colors.darkGrey + '99',
  },
  suggestionContainer: {
    alignItems: 'center',
    marginVertical: Spacing.sm,
  },
  suggestionText: {
    fontSize: 13,
    color: Colors.softGrey,
    fontStyle: 'italic',
  },
  // 语音消息样式
  voiceBubble: {
    paddingVertical: Spacing.sm,
    paddingHorizontal: Spacing.md,
    borderRadius: BorderRadius.lg,
  },
  voiceContent: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  waveContainer: {
    flex: 1,
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    marginHorizontal: Spacing.sm,
    height: 22,
    gap: 2,
  },
  waveBar: {
    width: 3,
    borderRadius: 1.5,
  },
  voiceDuration: {
    fontSize: 12,
    fontWeight: '500',
    fontVariant: ['tabular-nums'],
    minWidth: 28,
    textAlign: 'right',
  },
});

export default MessageItem;
