# Android原生聊天界面实现

## 📋 概述

使用Android原生UI（Kotlin + XML）实现了类似微信的对话框界面，用于发送日程安排指令。

## 🏗️ 实现架构

- **ChatActivity**: 主聊天界面Activity
- **MessageAdapter**: RecyclerView适配器，管理消息列表
- **ChatApiService**: Retrofit API接口，与后端通信
- **Message**: 消息数据模型

## 🎨 UI特性

- ✅ 类似微信的绿色消息气泡（用户消息）
- ✅ 白色消息气泡（助手消息）
- ✅ 圆形头像
- ✅ 消息时间戳
- ✅ 自动滚动到底部
- ✅ 加载状态提示
- ✅ 错误处理

## 🚀 使用步骤

### 1. 启动后端服务

```bash
cd backend-java
mvn spring-boot:run
```

后端将在 `http://localhost:8080` 启动。

### 2. 配置API地址

如果使用真机调试，需要修改 `ApiClient.kt` 中的 `BASE_URL`：

```kotlin
// 模拟器使用
private const val BASE_URL = "http://10.0.2.2:8080/"

// 真机使用（替换为你的电脑IP）
private const val BASE_URL = "http://192.168.1.100:8080/"
```

### 3. 运行Android应用

```bash
cd android
./gradlew installDebug
```

或使用Android Studio运行应用。

### 4. 使用聊天功能

1. 打开应用
2. 点击"打开日程安排助手"按钮
3. 在聊天界面中发送日程安排指令

## 📁 项目结构

```
android/app/src/main/
├── java/com/uchannel/
│   ├── ChatActivity.kt              # 聊天Activity
│   ├── adapter/
│   │   └── MessageAdapter.kt        # 消息列表适配器
│   ├── api/
│   │   ├── ChatApiService.kt        # API接口定义
│   │   └── ApiClient.kt             # API客户端
│   └── model/
│       └── Message.kt                # 消息数据模型
├── res/
│   ├── layout/
│   │   ├── activity_chat.xml        # 聊天界面布局
│   │   ├── item_message_user.xml    # 用户消息项布局
│   │   └── item_message_assistant.xml # 助手消息项布局
│   └── drawable/
│       ├── bubble_user.xml          # 用户消息气泡
│       ├── bubble_assistant.xml     # 助手消息气泡
│       ├── avatar_user.xml          # 用户头像
│       └── avatar_assistant.xml     # 助手头像
```

## 🔌 API接口

### 发送消息

**POST** `/api/chat/send`

请求体：
```json
{
  "message": "明天下午3点开会"
}
```

响应：
```json
{
  "success": true,
  "message": "已记录您的日程安排：明天下午3点开会。时间：3点。我会在适当的时候提醒您。",
  "data": {
    "schedule": {
      "time": "3点",
      "date": "明天"
    }
  }
}
```

## 🎯 功能特性

### 已实现

- ✅ 消息发送和接收
- ✅ 消息列表显示（RecyclerView）
- ✅ 自动滚动到底部
- ✅ 加载状态提示
- ✅ 错误处理和提示
- ✅ 类似微信的UI样式
- ✅ 时间戳显示

### 后续可优化

- [ ] 添加消息发送动画
- [ ] 添加头像图片（当前为纯色圆形）
- [ ] 添加表情支持
- [ ] 添加语音输入
- [ ] 添加消息长按菜单
- [ ] 添加消息复制功能
- [ ] 优化网络错误处理
- [ ] 添加消息缓存

## 🔧 配置说明

### 网络权限

AndroidManifest.xml中已包含：
```xml
<uses-permission android:name="android.permission.INTERNET" />
```

### 依赖库

- Retrofit 2.9.0 - 网络请求
- Gson - JSON解析
- RecyclerView - 消息列表
- Kotlin Coroutines - 异步处理

## 🐛 常见问题

### 1. 无法连接到后端

**原因**：API地址配置错误或后端未启动

**解决**：
- 确保后端服务运行在 `http://localhost:8080`
- 检查 `ApiClient.kt` 中的 `BASE_URL` 配置
- 真机调试时使用电脑IP地址

### 2. 消息不显示

**原因**：RecyclerView未正确初始化

**解决**：
- 检查布局文件中的ID是否匹配
- 查看Logcat日志确认消息是否添加成功

### 3. 网络请求失败

**原因**：网络权限或配置问题

**解决**：
- 检查AndroidManifest中的网络权限
- 确保手机/模拟器可以访问后端服务
- 检查防火墙设置

## 📝 代码说明

### 消息发送流程

1. 用户输入消息并点击发送
2. 添加用户消息到列表
3. 显示"正在处理..."加载消息
4. 调用后端API
5. 收到响应后替换加载消息为实际回复
6. 自动滚动到底部

### 错误处理

- 网络错误：显示错误消息并提示用户
- 服务器错误：显示服务器返回的错误信息
- 超时：显示超时提示

## 📚 相关文档

- [后端README](backend-java/README.md)
- [聊天API文档](backend-java/src/main/java/com/uchannel/controller/ChatController.java)
