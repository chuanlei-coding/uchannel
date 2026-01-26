# 从原生 Android 迁移到 React Native 指南

## 已完成的工作

### ✅ 项目结构
- 创建了完整的 React Native 项目结构
- 配置了 TypeScript 支持
- 设置了 Metro bundler 配置

### ✅ 页面迁移
1. **启动页 (SplashScreen)**
   - 完整的 Vita Logo 动画
   - 进入按钮和品牌标识
   - 自动跳转功能

2. **聊天页面 (ChatScreen)**
   - 消息列表显示
   - 输入框和发送功能
   - 消息气泡样式（用户/助手/建议）

3. **日程页面 (ScheduleScreen)**
   - Daily Flow 进度卡片
   - 任务列表
   - 标签切换（日程/专注/反思）
   - 底部导航栏

### ✅ 组件
- MessageItem: 消息气泡组件
- TaskItem: 任务项组件

### ✅ 数据模型
- Message: 消息数据模型
- Task: 任务数据模型

### ✅ 工具和服务
- Colors: 颜色常量
- API: 网络请求服务

## 下一步操作

### 1. 安装依赖
```bash
cd react-native-app
npm install
```

### 2. 配置 Android
按照 `ANDROID_SETUP.md` 中的步骤更新 Android 配置。

### 3. 运行项目
```bash
npm run android
```

## 注意事项

1. **原生模块**: 如果需要使用原生功能（如录音、推送通知），需要创建 React Native 原生模块。

2. **API 集成**: 更新 `src/services/api.ts` 中的 API 基础 URL。

3. **样式调整**: React Native 的样式系统与原生 Android 略有不同，可能需要微调。

4. **性能优化**: 对于长列表，考虑使用 `FlatList` 的优化选项。

## 文件对应关系

| 原生 Android | React Native |
|-------------|--------------|
| SplashActivity.kt | SplashScreen.tsx |
| MainActivity.kt | ChatScreen.tsx |
| ScheduleActivity.kt | ScheduleScreen.tsx |
| MessageAdapter.kt | MessageItem.tsx |
| TaskAdapter.kt | TaskItem.tsx |
| Message.kt | Message.ts |
| Task.kt | Task.ts |
