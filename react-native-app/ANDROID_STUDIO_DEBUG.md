# 使用 Android Studio 调试 React Native Android 应用

本指南将帮助您在 Android Studio 中打开、配置和调试 React Native 应用。

## 前置条件

1. **安装 Android Studio**
   - 下载并安装 [Android Studio](https://developer.android.com/studio)
   - 确保已安装 Android SDK（API Level 24 或更高）
   - 确保已安装 Android SDK Build Tools

2. **安装 Node.js 和 npm**
   ```bash
   node --version  # 应该 >= 16
   npm --version
   ```

3. **安装 React Native 依赖**
   ```bash
   cd react-native-app
   npm install
   ```

## 步骤 1: 在 Android Studio 中打开项目

### 方法 1: 打开 Android 子项目（推荐）

1. 启动 Android Studio
2. 选择 **File → Open**
3. 导航到项目目录：`/Users/chuanlei/code/uchannel/react-native-app/android`
4. 点击 **OK**

⚠️ **重要**: 只打开 `android` 子目录，不要打开整个 `react-native-app` 目录。

### 方法 2: 从现有项目导入

1. 启动 Android Studio
2. 选择 **File → Open**
3. 选择 `react-native-app/android` 目录
4. 等待 Gradle 同步完成

## 步骤 2: 配置项目

### 2.1 检查 Gradle 配置

Android Studio 会自动检测 `local.properties` 文件中的 SDK 路径。如果未自动检测：

1. 检查 `android/local.properties` 文件是否存在：
   ```properties
   sdk.dir=/Users/chuanlei/Library/Android/sdk
   ```

2. 如果文件不存在，创建它并设置正确的 SDK 路径

### 2.2 同步 Gradle

1. 打开项目后，Android Studio 会自动开始 Gradle 同步
2. 如果同步失败，点击 **File → Sync Project with Gradle Files**
3. 等待同步完成（首次可能需要几分钟）

### 2.3 检查 SDK 版本

1. 打开 **File → Project Structure**
2. 在 **SDK Location** 中确认 Android SDK 路径正确
3. 在 **Modules → app** 中确认：
   - `compileSdkVersion`: 34
   - `minSdkVersion`: 24
   - `targetSdkVersion`: 34

## 步骤 3: 启动 Metro Bundler

在运行 Android 应用之前，必须先启动 Metro Bundler（React Native 的 JavaScript 打包服务器）。

### 方法 1: 使用终端（推荐）

1. 打开终端
2. 导航到项目根目录：
   ```bash
   cd /Users/chuanlei/code/uchannel/react-native-app
   ```
3. 启动 Metro：
   ```bash
   npm start
   ```
   或者：
   ```bash
   npx react-native start
   ```

### 方法 2: 在 Android Studio 中配置运行任务

1. 在 Android Studio 中，点击右上角的 **Edit Configurations**
2. 点击 **+** 添加新配置
3. 选择 **npm**
4. 配置：
   - **Name**: Start Metro
   - **Command**: start
   - **Working directory**: `$PROJECT_DIR$/../`
5. 点击 **OK**

## 步骤 4: 运行应用

### 4.1 准备设备或模拟器

#### 使用 Android 模拟器：

1. 在 Android Studio 中，点击 **Tools → Device Manager**
2. 点击 **Create Device**（如果没有设备）
3. 选择设备型号（推荐：Pixel 5 或 Pixel 6）
4. 选择系统镜像（推荐：API 34，Android 14）
5. 点击 **Finish** 创建模拟器
6. 在设备管理器中启动模拟器

#### 使用物理设备：

1. 在手机上启用 **开发者选项**：
   - 设置 → 关于手机 → 连续点击"版本号"7次
2. 启用 **USB 调试**：
   - 设置 → 开发者选项 → USB 调试
3. 用 USB 连接手机到电脑
4. 在手机上确认允许 USB 调试

### 4.2 运行应用

1. 确保 Metro Bundler 正在运行（终端中应该显示 "Metro waiting on...")
2. 在 Android Studio 中，选择设备（顶部工具栏）
3. 点击绿色的 **Run** 按钮（▶️）或按 `Shift + F10`
4. 等待构建和安装完成

## 步骤 5: 调试应用

### 5.1 设置断点

#### 调试 Java/Kotlin 代码：

1. 在 `MainActivity.kt` 或 `MainApplication.kt` 中点击行号左侧设置断点
2. 点击 **Run → Debug 'app'** 或按 `Shift + F9`
3. 应用会在断点处暂停

#### 调试 JavaScript/TypeScript 代码：

1. 在 Chrome 中打开：`http://localhost:8081/debugger-ui/`
2. 或者使用 React Native Debugger：
   ```bash
   npm install -g react-native-debugger
   react-native-debugger
   ```
3. 在代码中设置断点（在 Chrome DevTools 或 React Native Debugger 中）

### 5.2 使用 Android Studio 调试工具

#### Logcat 查看日志：

1. 点击底部工具栏的 **Logcat** 标签
2. 过滤日志：
   - 选择应用包名：`com.uchannel`
   - 或使用搜索框过滤关键词

#### 查看变量和调用栈：

1. 在断点处暂停时，左侧面板显示：
   - **Variables**: 当前作用域的变量
   - **Watches**: 监视的表达式
   - **Frames**: 调用栈

#### 使用调试控制按钮：

- **Step Over** (F8): 单步执行，不进入函数
- **Step Into** (F7): 进入函数内部
- **Step Out** (Shift + F8): 跳出当前函数
- **Resume** (F9): 继续执行到下一个断点

### 5.3 热重载（Hot Reload）

React Native 支持热重载，修改代码后自动更新：

1. 在 Metro Bundler 终端中，按 `r` 重新加载
2. 或摇动设备/模拟器，选择 **Reload**
3. 或使用快捷键：
   - **Mac**: `Cmd + R`
   - **Windows/Linux**: `Ctrl + R`

### 5.4 调试网络请求

1. 在 Android Studio 中，打开 **View → Tool Windows → Network Profiler**
2. 运行应用并执行网络操作
3. 查看网络请求详情

## 常见问题排查

### 问题 1: Gradle 同步失败

**解决方案**：
1. 检查 `local.properties` 中的 SDK 路径是否正确
2. 检查网络连接（Gradle 需要下载依赖）
3. 清理并重新同步：
   ```bash
   cd android
   ./gradlew clean
   ```
   然后在 Android Studio 中：**File → Invalidate Caches / Restart**

### 问题 2: 找不到 Metro Bundler

**错误信息**: `Unable to load script. Make sure you're either running Metro...`

**解决方案**：
1. 确保 Metro Bundler 正在运行：
   ```bash
   cd react-native-app
   npm start
   ```
2. 检查端口 8081 是否被占用
3. 在 Android Studio 中，点击 **Run → Edit Configurations**
4. 在 **General** 标签中，添加环境变量：
   - `REACT_NATIVE_PACKAGER_HOSTNAME=localhost`

### 问题 3: 应用崩溃或白屏

**解决方案**：
1. 查看 Logcat 中的错误信息
2. 检查 Metro Bundler 终端中的错误
3. 尝试重新加载：
   - 摇动设备 → **Reload**
   - 或在 Metro 终端按 `r`
4. 清理构建：
   ```bash
   cd android
   ./gradlew clean
   ```

### 问题 4: 无法连接到设备

**解决方案**：
1. 检查设备是否已连接：
   ```bash
   adb devices
   ```
2. 如果设备未显示，尝试：
   ```bash
   adb kill-server
   adb start-server
   adb devices
   ```
3. 在手机上重新授权 USB 调试

### 问题 5: 构建错误

**解决方案**：
1. 清理项目：
   ```bash
   cd android
   ./gradlew clean
   ```
2. 删除 `.gradle` 缓存：
   ```bash
   rm -rf android/.gradle
   ```
3. 重新同步 Gradle

## 调试技巧

### 1. 使用 React Native Dev Menu

在应用运行时：
- **Android 模拟器**: 按 `Cmd + M` (Mac) 或 `Ctrl + M` (Windows/Linux)
- **物理设备**: 摇动设备

菜单选项：
- **Reload**: 重新加载 JavaScript
- **Debug**: 打开 Chrome DevTools
- **Enable Fast Refresh**: 启用快速刷新
- **Show Perf Monitor**: 显示性能监控

### 2. 查看 React Native 日志

在终端中运行：
```bash
npx react-native log-android
```

### 3. 使用 Flipper（可选）

Flipper 是 Facebook 的调试工具，提供更强大的调试功能：

1. 安装 Flipper: https://fbflipper.com/
2. 安装 React Native 插件：
   ```bash
   npm install --save-dev react-native-flipper
   ```
3. 启动 Flipper 并运行应用

### 4. 性能分析

1. 在 Android Studio 中，点击 **Run → Profile 'app'**
2. 使用 **CPU Profiler** 分析性能
3. 使用 **Memory Profiler** 检查内存泄漏

## 快速参考

### 常用命令

```bash
# 启动 Metro Bundler
cd react-native-app
npm start

# 运行 Android 应用
npm run android

# 清理构建
cd android
./gradlew clean

# 查看连接的设备
adb devices

# 查看应用日志
adb logcat | grep ReactNativeJS
```

### 快捷键

- **运行应用**: `Shift + F10`
- **调试应用**: `Shift + F9`
- **停止应用**: `Ctrl + F2`
- **同步 Gradle**: `Ctrl + Shift + O` (Mac: `Cmd + Shift + O`)

## 下一步

- 阅读 [React Native 官方文档](https://reactnative.dev/docs/debugging)
- 查看 [Android Studio 用户指南](https://developer.android.com/studio/intro)
- 学习 [React Native 性能优化](https://reactnative.dev/docs/performance)
