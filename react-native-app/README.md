# Vita - React Native App

基于 React Native 的 Vita 助手应用。

## 项目结构

```
react-native-app/
├── src/
│   ├── screens/          # 页面组件
│   │   ├── SplashScreen.tsx
│   │   ├── ChatScreen.tsx
│   │   └── ScheduleScreen.tsx
│   ├── components/       # 可复用组件
│   │   ├── MessageItem.tsx
│   │   └── TaskItem.tsx
│   ├── navigation/       # 导航配置
│   │   └── AppNavigator.tsx
│   ├── models/          # 数据模型
│   │   ├── Message.ts
│   │   └── Task.ts
│   ├── services/        # API 服务
│   │   └── api.ts
│   └── utils/           # 工具函数
│       └── colors.ts
├── App.tsx              # 应用入口
├── index.js             # React Native 入口
└── package.json
```

## 安装依赖

```bash
cd react-native-app
npm install
# 或
yarn install
```

## 运行项目

### Android

```bash
npm run android
# 或
yarn android
```

### iOS

```bash
npm run ios
# 或
yarn ios
```

## 开发

启动 Metro bundler:

```bash
npm start
# 或
yarn start
```

## 功能特性

- ✅ 启动页（Splash Screen）
- ✅ 聊天助手页面
- ✅ 日程管理页面
- ✅ 消息列表和任务列表
- ✅ 导航和路由

## 技术栈

- React Native 0.73.0
- React Navigation 6.x
- TypeScript
- Axios (API 请求)
