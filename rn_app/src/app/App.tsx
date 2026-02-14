import React, { useEffect } from 'react';
import { StatusBar, View, StyleSheet } from 'react-native';
import { GestureHandlerRootView } from 'react-native-gesture-handler';
import { SafeAreaProvider } from 'react-native-safe-area-context';
import AppNavigator from './Navigator';
import { Colors } from '../theme';
import { useSettingsStore, useChatStore, useTaskStore } from '../stores';

/**
 * 应用入口组件
 */
const App: React.FC = () => {
  const loadSettings = useSettingsStore((state) => state.loadSettings);
  const loadPersistedMessages = useChatStore((state) => state.loadPersistedMessages);
  const loadPersistedTasks = useTaskStore((state) => state.loadPersistedTasks);

  useEffect(() => {
    // 加载持久化的设置和数据
    const initializeApp = async () => {
      await Promise.all([
        loadSettings(),
        loadPersistedMessages(),
        loadPersistedTasks(),
      ]);
    };

    initializeApp();
  }, []);

  return (
    <GestureHandlerRootView style={styles.container}>
      <SafeAreaProvider>
        <StatusBar
          barStyle="dark-content"
          backgroundColor={Colors.creamBg}
        />
        <AppNavigator />
      </SafeAreaProvider>
    </GestureHandlerRootView>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
});

export default App;
