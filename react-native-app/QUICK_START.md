# React Native 快速开始指南

## 前置要求

- Node.js >= 18
- npm 或 yarn
- Android Studio（用于 Android 开发）
- Java Development Kit (JDK) 17

## 安装和运行

### 1. 安装依赖

```bash
cd react-native-app
npm install
```

### 2. 启动 Metro Bundler

在项目根目录运行：

```bash
npm start
```

这会启动 Metro 开发服务器，你会看到：

```
Metro Bundler ready.
Loading dependency graph, done.
```

### 3. 运行 Android 应用

在另一个终端窗口运行：

```bash
npm run android
```

或者直接构建 APK：

```bash
npm run android:build
```

## 开发工作流

### 典型开发流程

1. **启动 Metro**
   ```bash
   npm start
   ```

2. **在设备/模拟器上运行应用**
   ```bash
   npm run android
   ```

3. **修改代码**
   - 编辑 `src/` 目录下的文件
   - 保存后，应用会自动重新加载（Fast Refresh）

4. **查看日志**
   - 在 Metro 终端查看 JavaScript 日志
   - 使用 `adb logcat` 查看 Android 原生日志

### 调试技巧

#### 1. 开发者菜单
在应用运行时：
- **Android**：摇动设备或按 `Cmd+M` (Mac) / `Ctrl+M` (Windows)
- **模拟器**：按 `Cmd+M` (Mac) / `Ctrl+M` (Windows)

#### 2. Chrome DevTools
在开发者菜单中选择 "Debug"，会在 Chrome 中打开调试工具。

#### 3. React Native Debugger
安装独立的调试工具：
```bash
brew install --cask react-native-debugger
```

## 常见命令

```bash
# 启动 Metro
npm start

# 运行 Android
npm run android

# 清除 Metro 缓存
npm start -- --reset-cache

# 构建 APK
npm run android:build

# 运行测试
npm test

# 代码检查
npm run lint
```

## 项目结构说明

- `src/screens/` - 页面组件（SplashScreen, ChatScreen, ScheduleScreen）
- `src/components/` - 可复用组件（MessageItem, TaskItem）
- `src/navigation/` - 导航配置
- `src/services/` - API 服务
- `src/models/` - 数据模型
- `src/utils/` - 工具函数

## 下一步

- 阅读 `REACT_NATIVE_INTRO.md` 了解 React Native 技术细节
- 查看 `MIGRATION_GUIDE.md` 了解从原生 Android 迁移的过程
- 参考 React Native 官方文档：https://reactnative.dev
