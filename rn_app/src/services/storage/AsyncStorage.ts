import AsyncStorage from '@react-native-async-storage/async-storage';

/**
 * 存储键名
 */
export const StorageKeys = {
  SETTINGS: '@uchannel:settings',
  CHAT_HISTORY: '@uchannel:chat_history',
  TASKS_CACHE: '@uchannel:tasks_cache',
  CONVERSATION_ID: '@uchannel:conversation_id',
  USER_PREFERENCES: '@uchannel:user_preferences',
} as const;

/**
 * 存储服务
 */
class StorageService {
  /**
   * 保存数据
   */
  async setItem<T>(key: string, value: T): Promise<void> {
    try {
      const jsonValue = JSON.stringify(value);
      await AsyncStorage.setItem(key, jsonValue);
    } catch (error) {
      console.error(`Failed to save ${key}:`, error);
    }
  }

  /**
   * 获取数据
   */
  async getItem<T>(key: string): Promise<T | null> {
    try {
      const jsonValue = await AsyncStorage.getItem(key);
      return jsonValue ? JSON.parse(jsonValue) : null;
    } catch (error) {
      console.error(`Failed to get ${key}:`, error);
      return null;
    }
  }

  /**
   * 删除数据
   */
  async removeItem(key: string): Promise<void> {
    try {
      await AsyncStorage.removeItem(key);
    } catch (error) {
      console.error(`Failed to remove ${key}:`, error);
    }
  }

  /**
   * 清除所有数据
   */
  async clearAll(): Promise<void> {
    try {
      await AsyncStorage.clear();
    } catch (error) {
      console.error('Failed to clear storage:', error);
    }
  }

  /**
   * 获取所有键
   */
  async getAllKeys(): Promise<readonly string[]> {
    try {
      return await AsyncStorage.getAllKeys();
    } catch (error) {
      console.error('Failed to get all keys:', error);
      return [];
    }
  }
}

export default new StorageService();
