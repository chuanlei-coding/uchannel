import { create } from 'zustand';
import storage, { StorageKeys } from '../services/storage/AsyncStorage';

interface SettingsState {
  // 主题设置
  isDarkMode: boolean;

  // 通知设置
  notificationsEnabled: boolean;
  reminderTime: number; // 分钟，提前提醒时间

  // 外观设置
  fontSize: 'small' | 'medium' | 'large';
  useHapticFeedback: boolean;

  // AI 设置
  aiSuggestionsEnabled: boolean;
  autoBreakdownEnabled: boolean;

  // 隐私设置
  analyticsEnabled: boolean;

  // Actions
  loadSettings: () => Promise<void>;
  toggleDarkMode: () => void;
  toggleNotifications: () => void;
  setReminderTime: (minutes: number) => void;
  setFontSize: (size: 'small' | 'medium' | 'large') => void;
  toggleHapticFeedback: () => void;
  toggleAiSuggestions: () => void;
  toggleAutoBreakdown: () => void;
  toggleAnalytics: () => void;
}

interface Settings {
  isDarkMode: boolean;
  notificationsEnabled: boolean;
  reminderTime: number;
  fontSize: 'small' | 'medium' | 'large';
  useHapticFeedback: boolean;
  aiSuggestionsEnabled: boolean;
  autoBreakdownEnabled: boolean;
  analyticsEnabled: boolean;
}

const defaultSettings: Settings = {
  isDarkMode: false,
  notificationsEnabled: true,
  reminderTime: 15,
  fontSize: 'medium',
  useHapticFeedback: true,
  aiSuggestionsEnabled: true,
  autoBreakdownEnabled: false,
  analyticsEnabled: true,
};

const useSettingsStore = create<SettingsState>((set, get) => ({
  ...defaultSettings,

  loadSettings: async () => {
    const persisted = await storage.getItem<Settings>(StorageKeys.SETTINGS);
    if (persisted) {
      set(persisted);
    }
  },

  toggleDarkMode: () => {
    set((state) => {
      const newValue = !state.isDarkMode;
      const newSettings = { ...state, isDarkMode: newValue };
      storage.setItem(StorageKeys.SETTINGS, newSettings);
      return { isDarkMode: newValue };
    });
  },

  toggleNotifications: () => {
    set((state) => {
      const newValue = !state.notificationsEnabled;
      const newSettings = { ...state, notificationsEnabled: newValue };
      storage.setItem(StorageKeys.SETTINGS, newSettings);
      return { notificationsEnabled: newValue };
    });
  },

  setReminderTime: (minutes: number) => {
    set((state) => {
      const newSettings = { ...state, reminderTime: minutes };
      storage.setItem(StorageKeys.SETTINGS, newSettings);
      return { reminderTime: minutes };
    });
  },

  setFontSize: (size: 'small' | 'medium' | 'large') => {
    set((state) => {
      const newSettings = { ...state, fontSize: size };
      storage.setItem(StorageKeys.SETTINGS, newSettings);
      return { fontSize: size };
    });
  },

  toggleHapticFeedback: () => {
    set((state) => {
      const newValue = !state.useHapticFeedback;
      const newSettings = { ...state, useHapticFeedback: newValue };
      storage.setItem(StorageKeys.SETTINGS, newSettings);
      return { useHapticFeedback: newValue };
    });
  },

  toggleAiSuggestions: () => {
    set((state) => {
      const newValue = !state.aiSuggestionsEnabled;
      const newSettings = { ...state, aiSuggestionsEnabled: newValue };
      storage.setItem(StorageKeys.SETTINGS, newSettings);
      return { aiSuggestionsEnabled: newValue };
    });
  },

  toggleAutoBreakdown: () => {
    set((state) => {
      const newValue = !state.autoBreakdownEnabled;
      const newSettings = { ...state, autoBreakdownEnabled: newValue };
      storage.setItem(StorageKeys.SETTINGS, newSettings);
      return { autoBreakdownEnabled: newValue };
    });
  },

  toggleAnalytics: () => {
    set((state) => {
      const newValue = !state.analyticsEnabled;
      const newSettings = { ...state, analyticsEnabled: newValue };
      storage.setItem(StorageKeys.SETTINGS, newSettings);
      return { analyticsEnabled: newValue };
    });
  },
}));

export default useSettingsStore;
