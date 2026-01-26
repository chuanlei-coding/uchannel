# Android Studio 找不到 Node.js 的解决方案

## 问题描述

在 Android Studio 中构建 React Native 项目时，可能会遇到以下错误：

```
A problem occurred starting process 'command 'node''
```

这是因为 Android Studio 的 Gradle 守护进程无法找到 `node` 可执行文件，尽管在终端中可以正常使用 `node` 命令。

## 根本原因

macOS 上的 GUI 应用程序（如 Android Studio）不会继承终端 shell 的环境变量（如 PATH）。因此，虽然终端可以找到 `node`，但 Android Studio 启动的 Gradle 进程找不到。

## 解决方案

### 方案 1：设置系统级环境变量（推荐）

这是最可靠的解决方案，让所有 GUI 应用都能访问 node。

1. **设置当前会话的 PATH**：
   ```bash
   launchctl setenv PATH "/opt/homebrew/opt/node@18/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"
   ```

2. **创建 LaunchAgent 让设置持久化**：
   
   创建文件 `~/Library/LaunchAgents/com.uchannel.node-path.plist`：
   ```xml
   <?xml version="1.0" encoding="UTF-8"?>
   <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
   <plist version="1.0">
   <dict>
       <key>Label</key>
       <string>com.uchannel.node-path</string>
       <key>ProgramArguments</key>
       <array>
           <string>/bin/launchctl</string>
           <string>setenv</string>
           <string>PATH</string>
           <string>/opt/homebrew/opt/node@18/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin</string>
       </array>
       <key>RunAtLoad</key>
       <true/>
   </dict>
   </plist>
   ```

3. **加载 LaunchAgent**：
   ```bash
   launchctl load ~/Library/LaunchAgents/com.uchannel.node-path.plist
   ```

4. **完全退出并重新打开 Android Studio**

### 方案 2：从终端启动 Android Studio

使用项目根目录下的脚本：

```bash
./open-android-studio.sh
```

这个脚本会：
- 确保 node 在 PATH 中
- 停止现有的 Gradle 守护进程
- 从终端启动 Android Studio（继承终端环境）

### 方案 3：创建符号链接

在标准路径下创建 node 的符号链接：

```bash
sudo ln -sf /opt/homebrew/opt/node@18/bin/node /usr/local/bin/node
sudo ln -sf /opt/homebrew/opt/node@18/bin/npm /usr/local/bin/npm
sudo ln -sf /opt/homebrew/opt/node@18/bin/npx /usr/local/bin/npx
```

## 验证修复

1. 完全退出 Android Studio（Cmd+Q）
2. 重新打开 Android Studio
3. 打开项目：`react-native-app/android`
4. 点击 File → Sync Project with Gradle Files
5. 如果同步成功且无 node 相关错误，则修复成功

## 常见问题

### Q: 为什么在终端能找到 node，但 Android Studio 找不到？

A: macOS 的 GUI 应用使用不同的环境变量系统。终端 shell（如 zsh/bash）有自己的 PATH 配置（通过 .zshrc/.bashrc），但这些不会传递给从 Dock 或 Spotlight 启动的应用。

### Q: 重启电脑后设置会丢失吗？

A: 如果使用了 LaunchAgent 方案，设置会在重启后保持。如果只使用了 `launchctl setenv`，则需要在每次重启后重新运行。

### Q: 我有多个版本的 Node.js，应该用哪个？

A: React Native 0.73.x 推荐使用 Node.js 18.x。确保 PATH 中第一个 node 是正确的版本。

## 项目配置

本项目已经在以下位置添加了 Node.js 路径配置：

1. `android/gradlew` - 在脚本末尾添加了 PATH 导出
2. `android/settings.gradle` - 设置了 NODE_BINARY 系统属性
3. `android/app/build.gradle` - 设置了 NODE_BINARY 项目属性
4. `~/.gradle/init.d/react-native-node.gradle` - Gradle 全局初始化脚本

这些配置在大多数情况下应该能够工作，但某些情况下（如 Android Studio 的 Gradle 同步）可能仍需要系统级环境变量设置。
