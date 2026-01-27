import React, {useState, useEffect, useRef} from 'react';
import {
  View,
  Text,
  StyleSheet,
  FlatList,
  TextInput,
  TouchableOpacity,
  StatusBar,
} from 'react-native';
import {Colors} from '../utils/colors';
import {Message, MessageSender} from '../models/Message';
import MessageItem from '../components/MessageItem';
import {useNavigation} from '@react-navigation/native';
import type {NativeStackNavigationProp} from '@react-navigation/native-stack';
import type {RootStackParamList} from '../navigation/AppNavigator';

type NavigationProp = NativeStackNavigationProp<RootStackParamList>;

const ChatScreen = () => {
  const navigation = useNavigation<NavigationProp>();
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
      <StatusBar barStyle="light-content" backgroundColor={Colors.charcoal} />
      
      {/* Header */}
      <View style={styles.header}>
        <View style={styles.headerLeft}>
          <View style={styles.logoIcon}>
            <View style={styles.logoLeaf} />
          </View>
          <Text style={styles.headerTitle}>Vita Assistant</Text>
        </View>
        <TouchableOpacity style={styles.moreButton}>
          <Text style={styles.moreIcon}>⋯</Text>
        </TouchableOpacity>
      </View>

      {/* Date Label */}
      <Text style={styles.dateLabel}>
        今天, {new Date().toLocaleDateString('zh-CN', {
          month: 'numeric',
          day: 'numeric',
        }).replace('/', '月')}日
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
          placeholder="与 Vita 交流..."
          placeholderTextColor={Colors.textWhite20}
          value={inputText}
          onChangeText={setInputText}
          multiline
        />
        <TouchableOpacity style={styles.sendButton} onPress={sendMessage}>
          <Text style={styles.sendIcon}>↑</Text>
        </TouchableOpacity>
      </View>

      {/* Bottom Navigation */}
      <View style={styles.bottomNav}>
        <TouchableOpacity style={styles.navItem} onPress={() => navigation.navigate('Schedule')}>
          <Text style={styles.navIcon}>📅</Text>
          <Text style={styles.navText}>日程</Text>
        </TouchableOpacity>
        <TouchableOpacity style={styles.navItem}>
          <Text style={styles.navIcon}>📊</Text>
          <Text style={styles.navText}>洞察</Text>
        </TouchableOpacity>
        <View style={styles.navItem}>
          <Text style={styles.navIconActive}>💬</Text>
          <Text style={styles.navTextActive}>AI 助手</Text>
        </View>
        <TouchableOpacity style={styles.navItem} onPress={() => navigation.navigate('Settings')}>
          <Text style={styles.navIcon}>⚙️</Text>
          <Text style={styles.navText}>设置</Text>
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
    paddingHorizontal: 24,
    paddingVertical: 16,
  },
  headerLeft: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  logoIcon: {
    width: 32,
    height: 32,
    marginRight: 12,
    justifyContent: 'center',
    alignItems: 'center',
  },
  logoLeaf: {
    width: 20,
    height: 20,
    backgroundColor: Colors.brandSage,
    opacity: 0.8,
    borderRadius: 10,
    transform: [{rotate: '-15deg'}],
  },
  headerTitle: {
    fontSize: 20,
    color: Colors.onSurface,
    fontWeight: '500',
  },
  moreButton: {
    width: 40,
    height: 40,
    borderRadius: 20,
    backgroundColor: Colors.glassGrey,
    borderWidth: 1,
    borderColor: Colors.textWhite05,
    justifyContent: 'center',
    alignItems: 'center',
  },
  moreIcon: {
    fontSize: 20,
    color: Colors.brandSage,
  },
  dateLabel: {
    textAlign: 'center',
    color: Colors.textWhite30,
    fontSize: 10,
    letterSpacing: 2,
    marginTop: 16,
    textTransform: 'uppercase',
  },
  messagesContainer: {
    padding: 24,
    paddingBottom: 180,
  },
  inputContainer: {
    position: 'absolute',
    bottom: 84,
    left: 24,
    right: 24,
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: Colors.glassGrey,
    borderWidth: 1,
    borderColor: Colors.textWhite05,
    paddingHorizontal: 16,
    paddingVertical: 8,
    borderRadius: 24,
  },
  addButton: {
    padding: 8,
  },
  addIcon: {
    fontSize: 24,
    color: Colors.textWhite40,
  },
  input: {
    flex: 1,
    color: Colors.onSurface,
    fontSize: 15,
    paddingHorizontal: 8,
    maxHeight: 100,
  },
  sendButton: {
    width: 32,
    height: 32,
    borderRadius: 16,
    backgroundColor: Colors.brandSage,
    justifyContent: 'center',
    alignItems: 'center',
  },
  sendIcon: {
    fontSize: 18,
    color: Colors.charcoal,
    fontWeight: 'bold',
  },
  bottomNav: {
    position: 'absolute',
    bottom: 0,
    left: 0,
    right: 0,
    height: 84,
    backgroundColor: 'rgba(26,31,29,0.85)',
    borderTopWidth: 1,
    borderTopColor: Colors.textWhite05,
    flexDirection: 'row',
    alignItems: 'flex-start',
    justifyContent: 'space-around',
    paddingTop: 12,
    paddingHorizontal: 24,
  },
  navItem: {
    alignItems: 'center',
  },
  navIcon: {
    fontSize: 24,
    opacity: 0.4,
  },
  navIconActive: {
    fontSize: 24,
  },
  navText: {
    fontSize: 10,
    color: Colors.textWhite40,
    marginTop: 4,
  },
  navTextActive: {
    fontSize: 10,
    color: Colors.brandSage,
    marginTop: 4,
    fontWeight: '500',
  },
});

export default ChatScreen;
