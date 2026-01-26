import React, {useState, useEffect, useRef} from 'react';
import {
  View,
  Text,
  StyleSheet,
  FlatList,
  TextInput,
  TouchableOpacity,
  Image,
} from 'react-native';
import {Colors} from '../utils/colors';
import {Message, MessageSender} from '../models/Message';
import MessageItem from '../components/MessageItem';

const ChatScreen = () => {
  const [messages, setMessages] = useState<Message[]>([]);
  const [inputText, setInputText] = useState('');
  const flatListRef = useRef<FlatList>(null);

  useEffect(() => {
    // 添加欢迎消息
    const welcomeMessage: Message = {
      id: Date.now().toString(),
      content: '"岁序更替，步履轻盈。"',
      contentSecondary: '早安。今天你的行程看起来很宁静。需要我为你回顾一下下午的冥想预约吗？',
      sender: MessageSender.ASSISTANT,
      timestamp: Date.now(),
    };
    setMessages([welcomeMessage]);
  }, []);

  const sendMessage = () => {
    if (!inputText.trim()) return;

    const userMessage: Message = {
      id: Date.now().toString(),
      content: inputText,
      sender: MessageSender.USER,
      timestamp: Date.now(),
    };

    setMessages(prev => [...prev, userMessage]);
    setInputText('');

    // 模拟助手回复
    setTimeout(() => {
      const response: Message = {
        id: (Date.now() + 1).toString(),
        content: '我已经为您重新调整了后续行程。现在，您的节奏更加从容了。',
        sender: MessageSender.SUGGESTION,
        timestamp: Date.now(),
        scheduleTitle: '下午冥想',
        scheduleTime: '15:00 - 15:30',
      };
      setMessages(prev => [...prev, response]);
      scrollToBottom();
    }, 1000);

    scrollToBottom();
  };

  const scrollToBottom = () => {
    setTimeout(() => {
      flatListRef.current?.scrollToEnd({animated: true});
    }, 100);
  };

  const formatTime = (timestamp: number) => {
    const date = new Date(timestamp);
    return date.toLocaleTimeString('en-US', {
      hour: '2-digit',
      minute: '2-digit',
      hour12: true,
    });
  };

  return (
    <View style={styles.container}>
      {/* Header */}
      <View style={styles.header}>
        <TouchableOpacity>
          <Text style={styles.menuIcon}>☰</Text>
        </TouchableOpacity>
        <Text style={styles.headerTitle}>Vita</Text>
        <View style={styles.headerRight}>
          <TouchableOpacity style={styles.headerButton}>
            <Text style={styles.searchIcon}>🔍</Text>
          </TouchableOpacity>
          <View style={styles.avatar} />
        </View>
      </View>

      {/* Date Label */}
      <Text style={styles.dateLabel}>
        {new Date().toLocaleDateString('zh-CN', {
          month: 'long',
          day: 'numeric',
        })}
      </Text>

      {/* Messages */}
      <FlatList
        ref={flatListRef}
        data={messages}
        keyExtractor={item => item.id}
        renderItem={({item}) => <MessageItem message={item} />}
        contentContainerStyle={styles.messagesContainer}
        onContentSizeChange={scrollToBottom}
      />

      {/* Input Bar */}
      <View style={styles.inputContainer}>
        <TouchableOpacity style={styles.addButton}>
          <Text style={styles.addIcon}>+</Text>
        </TouchableOpacity>
        <TextInput
          style={styles.input}
          placeholder="与 Vita 对话…"
          placeholderTextColor={Colors.textWhite40}
          value={inputText}
          onChangeText={setInputText}
          multiline
        />
        <TouchableOpacity style={styles.micButton} onPress={sendMessage}>
          <Text style={styles.micIcon}>🎤</Text>
        </TouchableOpacity>
      </View>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: Colors.charcoal,
  },
  header: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    paddingHorizontal: 16,
    paddingVertical: 12,
    backgroundColor: Colors.darkSage,
  },
  menuIcon: {
    fontSize: 24,
    color: Colors.textPrimary,
  },
  headerTitle: {
    fontSize: 18,
    color: Colors.textPrimary,
    fontFamily: 'serif',
  },
  headerRight: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  headerButton: {
    width: 40,
    height: 40,
    justifyContent: 'center',
    alignItems: 'center',
  },
  searchIcon: {
    fontSize: 20,
    color: Colors.textPrimary,
  },
  avatar: {
    width: 32,
    height: 32,
    borderRadius: 16,
    backgroundColor: Colors.brandTeal,
    marginLeft: 8,
  },
  dateLabel: {
    textAlign: 'center',
    color: Colors.textWhite30,
    fontSize: 10,
    letterSpacing: 0.02,
    marginTop: 16,
    textTransform: 'uppercase',
  },
  messagesContainer: {
    padding: 16,
    paddingBottom: 100,
  },
  inputContainer: {
    position: 'absolute',
    bottom: 100,
    left: 0,
    right: 0,
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: Colors.inputBarDarkGreen,
    marginHorizontal: 24,
    marginBottom: 16,
    paddingHorizontal: 12,
    paddingVertical: 12,
    borderRadius: 24,
  },
  addButton: {
    width: 32,
    height: 32,
    borderRadius: 16,
    backgroundColor: Colors.brandSage,
    justifyContent: 'center',
    alignItems: 'center',
  },
  addIcon: {
    fontSize: 20,
    color: Colors.charcoal,
  },
  input: {
    flex: 1,
    color: Colors.textPrimary,
    fontSize: 15,
    paddingHorizontal: 12,
    maxHeight: 100,
  },
  micButton: {
    width: 32,
    height: 32,
    borderRadius: 16,
    backgroundColor: Colors.brandSage,
    justifyContent: 'center',
    alignItems: 'center',
  },
  micIcon: {
    fontSize: 18,
    color: Colors.charcoal,
  },
});

export default ChatScreen;
