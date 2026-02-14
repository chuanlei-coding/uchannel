import React, { useEffect, useRef, useState } from 'react';
import {
  View,
  Text,
  TextInput,
  TouchableOpacity,
  FlatList,
  StyleSheet,
  KeyboardAvoidingView,
  Platform,
  Alert,
  Animated,
} from 'react-native';
import Icon from 'react-native-vector-icons/MaterialIcons';
import { launchImageLibrary, launchCamera, ImagePickerResponse } from 'react-native-image-picker';
import { useChatStore } from '../../stores';
import { MessageItem } from '../../components';
import { Colors } from '../../theme';
import { Spacing, BorderRadius, Shadows } from '../../theme';
import { MessageSender, createAssistantMessage, createImageMessage, createVoiceMessage } from '../../models/Message';
import { VoiceRecordButton } from '../../components';

// 最大文件大小：10MB
const MAX_FILE_SIZE = 10 * 1024 * 1024;

// ============== 旧的 react-native-audio-api 实现 (备份，等稳定后删除) ==============
/*
// 录音采样率和缓冲区大小
const RECORD_SAMPLE_RATE = 16000;
const RECORD_BUFFER_LENGTH = 4096;

// 延迟加载 react-native-audio-api（避免在 JSI 未就绪时触发模块初始化）
let _audioApi: any = null;
function getAudioApi() {
  if (!_audioApi) {
    _audioApi = require('react-native-audio-api');
  }
  return _audioApi;
}

// 延迟初始化录音器
let _recorder: any = null;
function getRecorder() {
  if (!_recorder) {
    const { AudioRecorder, AudioManager } = getAudioApi();
    AudioManager.setAudioSessionOptions({
      iosCategory: 'playAndRecord',
      iosMode: 'default',
      iosOptions: [],
    });
    _recorder = new AudioRecorder({
      sampleRate: RECORD_SAMPLE_RATE,
      bufferLengthInSamples: RECORD_BUFFER_LENGTH,
    });
  }
  return _recorder;
}

// 获取 AudioManager（延迟加载）
function getAudioManager() {
  return getAudioApi().AudioManager;
}

// 录音数据缓冲区
const recordChunksRef = useRef<Float32Array[]>([]);
const recordStartTimeRef = useRef<number>(0);

// 旧录音逻辑...
// 问题：录音播放时出现杂音，可能是 PCM 编码/解码问题
// 相关 GitHub Issue: https://github.com/software-mansion/react-native-audio-api/issues/809
*/
// ============== 旧的 react-native-audio-api 实现结束 ==============

/**
 * 聊天页面
 * 使用 react-native-nitro-sound 实现录音功能
 */
const ChatScreen: React.FC = () => {
  const [inputText, setInputText] = useState('');
  const [isRecording, setIsRecording] = useState(false);
  const flatListRef = useRef<FlatList>(null);

  const {
    messages,
    isLoading,
    sendMessage,
    addMessage,
    clearChat,
    loadPersistedMessages,
  } = useChatStore();

  useEffect(() => {
    loadPersistedMessages();

    // 如果没有消息，添加欢迎消息
    if (messages.length === 0) {
      const welcomeMessage = createAssistantMessage(
        '"岁序更替，步履轻盈。"'
      );
      addMessage({
        ...welcomeMessage,
        contentSecondary: '早安。今天你的行程看起来很宁静。需要我为你回顾一下下午的冥想预约吗？',
      });
    }
  }, []);

  const handleSend = async () => {
    const text = inputText.trim();
    if (!text || isLoading) return;

    setInputText('');
    await sendMessage(text);
    scrollToBottom();
  };

  const scrollToBottom = () => {
    setTimeout(() => {
      flatListRef.current?.scrollToEnd({ animated: true });
    }, 100);
  };

  const handleAttach = () => {
    Alert.alert(
      '添加附件',
      '请选择附件来源',
      [
        {
          text: '拍照',
          onPress: () => openCamera(),
        },
        {
          text: '从相册选择',
          onPress: () => openGallery(),
        },
        {
          text: '取消',
          style: 'cancel',
        },
      ]
    );
  };

  const formatFileSize = (bytes: number): string => {
    if (bytes < 1024) return `${bytes} B`;
    if (bytes < 1024 * 1024) return `${(bytes / 1024).toFixed(1)} KB`;
    return `${(bytes / (1024 * 1024)).toFixed(1)} MB`;
  };

  const openCamera = () => {
    launchCamera(
      {
        mediaType: 'photo',
        quality: 0.8,
        saveToPhotos: true,
      },
      (response: ImagePickerResponse) => {
        if (response.didCancel || response.errorCode) return;
        if (response.assets && response.assets[0]) {
          handleImageSelected(response.assets[0]);
        }
      }
    );
  };

  const openGallery = () => {
    launchImageLibrary(
      {
        mediaType: 'photo',
        quality: 0.8,
        selectionLimit: 1,
      },
      (response: ImagePickerResponse) => {
        if (response.didCancel || response.errorCode) return;
        if (response.assets && response.assets[0]) {
          handleImageSelected(response.assets[0]);
        }
      }
    );
  };

  const handleImageSelected = (asset: any) => {
    // 检查文件大小
    if (asset.fileSize && asset.fileSize > MAX_FILE_SIZE) {
      Alert.alert('文件过大', `文件大小不能超过 10MB\n当前大小: ${formatFileSize(asset.fileSize)}`);
      return;
    }
    // 创建图片消息并添加到聊天
    const imageMessage = createImageMessage(asset.uri, asset.fileName);
    addMessage(imageMessage);
  };

  /**
   * 录音完成回调
   */
  const handleRecordComplete = (uri: string, duration: number) => {
    setIsRecording(false);
    if (duration < 1) {
      Alert.alert('录音太短', '说话时间太短');
      return;
    }
    const voiceMessage = createVoiceMessage(uri, duration);
    addMessage(voiceMessage);
    scrollToBottom();
  };

  /**
   * 录音开始回调
   */
  const handleRecordStart = () => {
    setIsRecording(true);
  };

  /**
   * 录音取消回调
   */
  const handleRecordCancel = () => {
    setIsRecording(false);
  };

  const handleClearChat = () => {
    Alert.alert(
      '清空聊天记录',
      '确定要清空所有聊天记录吗？此操作不可恢复。',
      [
        { text: '取消', style: 'cancel' },
        {
          text: '清空',
          style: 'destructive',
          onPress: () => {
            clearChat();
            // 添加欢迎消息
            const welcomeMessage = createAssistantMessage(
              '"岁序更替，步履轻盈。"'
            );
            addMessage({
              ...welcomeMessage,
              contentSecondary: '聊天已清空。有什么我可以帮助你的吗？',
            });
          },
        },
      ]
    );
  };

  const formatDate = () => {
    const now = new Date();
    const weekdays = ['星期日', '星期一', '星期二', '星期三', '星期四', '星期五', '星期六'];
    return `${now.getMonth() + 1}月${now.getDate()}日 · ${weekdays[now.getDay()]}`;
  };

  const renderMessage = ({ item }: { item: typeof messages[0] }) => (
    <MessageItem message={item} />
  );

  return (
    <View style={styles.container}>
      {/* 背景装饰 */}
      <View style={styles.backgroundDecoration1} />
      <View style={styles.backgroundDecoration2} />

      {/* 头部 */}
      <View style={styles.header}>
        <View style={styles.headerLeft}>
          <View style={styles.logo}>
            <View style={styles.logoLeaf} />
            <View style={styles.logoArc} />
          </View>
          <Text style={styles.headerTitle}>Vita Assistant</Text>
        </View>

        <TouchableOpacity style={styles.clearButton} onPress={handleClearChat}>
          <Icon name="delete-outline" size={20} color={Colors.softGrey} />
        </TouchableOpacity>
      </View>

      {/* 日期标签 */}
      <Text style={styles.dateLabel}>{formatDate()}</Text>

      {/* 消息列表 */}
      <FlatList
        ref={flatListRef}
        data={messages}
        renderItem={renderMessage}
        keyExtractor={(item) => item.id}
        contentContainerStyle={styles.messageList}
        onContentSizeChange={scrollToBottom}
        ListEmptyComponent={
          <View style={styles.emptyContainer}>
            <Icon
              name="chat-bubble-outline"
              size={64}
              color={Colors.softGrey + '4D'}
            />
            <Text style={styles.emptyText}>开始与 Vita 对话</Text>
          </View>
        }
      />

      {/* 输入框 */}
      <KeyboardAvoidingView
        behavior={Platform.OS === 'ios' ? 'padding' : 'height'}
        keyboardVerticalOffset={0}
      >
        {isRecording ? (
          /* 录音状态 UI - 使用 VoiceRecordButton 内部状态 */
          <View style={styles.recordingBarWrapper}>
            <VoiceRecordButton
              onRecordComplete={handleRecordComplete}
              onRecordCancel={handleRecordCancel}
              minDuration={1}
              maxDuration={60}
            />
          </View>
        ) : (
          /* 正常输入 UI */
          <View style={styles.inputBar}>
            {/* 左侧：无文字显示语音按钮，有文字显示附件图标 */}
            {inputText.trim() ? (
              <TouchableOpacity
                style={styles.iconButton}
                onPress={handleAttach}
              >
                <Icon
                  name="add-circle"
                  size={24}
                  color={Colors.softGrey + '99'}
                />
              </TouchableOpacity>
            ) : (
              <VoiceRecordButton
                onRecordComplete={handleRecordComplete}
                onRecordStart={handleRecordStart}
                onRecordCancel={handleRecordCancel}
                minDuration={1}
                maxDuration={60}
              />
            )}

            <TextInput
              style={styles.input}
              placeholder={isLoading ? '发送中...' : '与 Vita 交流...'}
              placeholderTextColor={Colors.softGrey + '66'}
              value={inputText}
              onChangeText={setInputText}
              onSubmitEditing={handleSend}
              editable={!isLoading}
              multiline
            />

            {/* 右侧：无文字显示附件图标，有文字显示发送按钮 */}
            {inputText.trim() ? (
              <TouchableOpacity
                style={[
                  styles.sendButton,
                  isLoading && styles.sendButtonDisabled,
                ]}
                onPress={handleSend}
                disabled={isLoading}
              >
                <Icon
                  name="arrow-upward"
                  size={18}
                  color={Colors.white}
                />
              </TouchableOpacity>
            ) : (
              <TouchableOpacity style={styles.iconButton} onPress={handleAttach}>
                <Icon
                  name="add-circle"
                  size={24}
                  color={Colors.softGrey + '99'}
                />
              </TouchableOpacity>
            )}
          </View>
        )}
      </KeyboardAvoidingView>
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
    top: -50,
    right: -30,
    width: 200,
    height: 200,
    borderRadius: 100,
    backgroundColor: Colors.brandSage + '0D',
  },
  backgroundDecoration2: {
    position: 'absolute',
    bottom: 100,
    left: -50,
    width: 150,
    height: 150,
    borderRadius: 75,
    backgroundColor: Colors.brandTeal + '0D',
  },
  header: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    paddingHorizontal: Spacing.lg,
    paddingVertical: Spacing.md,
  },
  headerLeft: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  logo: {
    width: 32,
    height: 32,
    marginRight: Spacing.sm,
  },
  logoLeaf: {
    position: 'absolute',
    left: 0,
    bottom: 0,
    right: 0,
    top: 0,
    backgroundColor: Colors.brandSage + '99',
    borderTopLeftRadius: 12,
    borderBottomRightRadius: 12,
    transform: [{ rotate: '-15deg' }],
  },
  logoArc: {
    position: 'absolute',
    left: 0,
    top: 0,
    right: 0,
    bottom: 0,
    borderRadius: 16,
    borderTopWidth: 2,
    borderRightWidth: 2,
    borderColor: Colors.brandTeal + '99',
    transform: [{ rotate: '45deg' }, { scale: 1.1 }],
  },
  headerTitle: {
    fontSize: 20,
    fontWeight: '500',
    letterSpacing: -0.5,
    color: Colors.darkGrey,
  },
  clearButton: {
    width: 40,
    height: 40,
    borderRadius: BorderRadius.full,
    backgroundColor: Colors.white,
    borderWidth: 1,
    borderColor: Colors.borderLightAlt,
    alignItems: 'center',
    justifyContent: 'center',
    ...Shadows.button,
  },
  dateLabel: {
    textAlign: 'center',
    fontSize: 10,
    fontWeight: '600',
    letterSpacing: 3,
    color: Colors.softGrey + '99',
    marginVertical: Spacing.md,
  },
  messageList: {
    paddingHorizontal: Spacing.lg,
    paddingVertical: Spacing.md,
    flexGrow: 1,
  },
  emptyContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    paddingTop: 100,
  },
  emptyText: {
    fontSize: 16,
    color: Colors.softGrey + '99',
    marginTop: Spacing.md,
  },
  inputBar: {
    flexDirection: 'row',
    alignItems: 'center',
    marginHorizontal: Spacing.lg,
    marginVertical: Spacing.sm,
    paddingHorizontal: Spacing.md,
    paddingVertical: Spacing.sm,
    backgroundColor: Colors.white,
    borderRadius: BorderRadius.full,
    borderWidth: 1,
    borderColor: Colors.borderLightAlt + '80',
    ...Shadows.cardMd,
  },
  iconButton: {
    padding: Spacing.xs,
  },
  input: {
    flex: 1,
    fontSize: 15,
    color: Colors.darkGrey,
    paddingHorizontal: Spacing.sm,
    maxHeight: 100,
  },
  sendButton: {
    width: 36,
    height: 36,
    borderRadius: BorderRadius.full,
    backgroundColor: Colors.brandSage,
    alignItems: 'center',
    justifyContent: 'center',
    ...Shadows.button,
  },
  sendButtonDisabled: {
    backgroundColor: Colors.softGrey + '80',
  },
  // 录音状态容器
  recordingBarWrapper: {
    marginHorizontal: Spacing.lg,
    marginVertical: Spacing.sm,
  },
});

export default ChatScreen;
