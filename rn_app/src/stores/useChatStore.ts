import { create } from 'zustand';
import { Message, createUserMessage, createAssistantMessage } from '../models/Message';
import chatApi from '../services/api/chatApi';
import storage, { StorageKeys } from '../services/storage/AsyncStorage';

interface ChatState {
  messages: Message[];
  isLoading: boolean;
  error: string | null;

  // Actions
  addMessage: (message: Message) => void;
  sendMessage: (content: string) => Promise<void>;
  loadHistory: () => Promise<void>;
  clearChat: () => void;
  loadPersistedMessages: () => Promise<void>;
}

const useChatStore = create<ChatState>((set, get) => ({
  messages: [],
  isLoading: false,
  error: null,

  addMessage: (message: Message) => {
    set((state) => {
      const newMessages = [...state.messages, message];
      // 持久化消息
      storage.setItem(StorageKeys.CHAT_HISTORY, newMessages);
      return { messages: newMessages };
    });
  },

  sendMessage: async (content: string) => {
    const { addMessage } = get();

    // 添加用户消息
    const userMessage = createUserMessage(content);
    addMessage(userMessage);

    set({ isLoading: true, error: null });

    try {
      const response = await chatApi.sendMessage(content);

      if (response) {
        addMessage(response);
      } else {
        set({ error: '发送失败，请重试' });
      }
    } catch (error) {
      set({ error: '网络错误，请检查连接' });
    } finally {
      set({ isLoading: false });
    }
  },

  loadHistory: async () => {
    set({ isLoading: true });

    try {
      const history = await chatApi.getHistory();
      set({ messages: history, isLoading: false });
    } catch (error) {
      set({ isLoading: false, error: '加载历史失败' });
    }
  },

  clearChat: () => {
    chatApi.clearConversation();
    storage.removeItem(StorageKeys.CHAT_HISTORY);
    set({ messages: [], error: null });
  },

  loadPersistedMessages: async () => {
    const persisted = await storage.getItem<Message[]>(StorageKeys.CHAT_HISTORY);
    if (persisted && persisted.length > 0) {
      // 将 timestamp 从 ISO 字符串转换回 Date 对象
      const messagesWithDates = persisted.map((msg) => ({
        ...msg,
        timestamp: new Date(msg.timestamp),
      }));
      set({ messages: messagesWithDates });
    }
  },
}));

export default useChatStore;
