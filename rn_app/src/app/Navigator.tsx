import React from 'react';
import { NavigationContainer } from '@react-navigation/native';
import { createNativeStackNavigator } from '@react-navigation/native-stack';
import { createBottomTabNavigator } from '@react-navigation/bottom-tabs';
import Icon from 'react-native-vector-icons/MaterialIcons';
import {
  SplashScreen,
  ChatScreen,
  ScheduleScreen,
  DiscoverScreen,
  StatsScreen,
  SettingsScreen,
  AddTodoScreen,
  TaskDetailScreen,
} from '../screens';
import { BottomNav } from '../components';
import { Colors } from '../theme';

const Stack = createNativeStackNavigator();
const Tab = createBottomTabNavigator();

/**
 * 主标签导航
 */
const MainTabs: React.FC = () => {
  return (
    <Tab.Navigator
      tabBar={(props) => (
        <BottomNav
          currentRoute={props.state.routes[props.state.index].name}
          navigation={props.navigation}
        />
      )}
      screenOptions={{
        headerShown: false,
      }}
    >
      <Tab.Screen name="Chat" component={ChatScreen} />
      <Tab.Screen name="Schedule" component={ScheduleScreen} />
      <Tab.Screen name="Discover" component={DiscoverScreen} />
      <Tab.Screen name="Stats" component={StatsScreen} />
      <Tab.Screen name="Settings" component={SettingsScreen} />
    </Tab.Navigator>
  );
};

/**
 * 应用导航器
 */
const AppNavigator: React.FC = () => {
  return (
    <NavigationContainer>
      <Stack.Navigator
        screenOptions={{
          headerShown: false,
          animation: 'slide_from_right',
          contentStyle: { backgroundColor: Colors.creamBg },
        }}
      >
        <Stack.Screen name="Splash" component={SplashScreen} />
        <Stack.Screen name="Main" component={MainTabs} />
        <Stack.Screen name="TaskDetail" component={TaskDetailScreen} />
        <Stack.Screen
          name="AddTodo"
          component={AddTodoScreen}
          options={{
            presentation: 'modal',
            animation: 'slide_from_bottom',
          }}
        />
      </Stack.Navigator>
    </NavigationContainer>
  );
};

export default AppNavigator;
