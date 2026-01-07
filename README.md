# Android 推送消息实现方案

本项目提供了完整的服务器向Android应用推送消息的实现方案。

## 📁 项目结构

```
uchannel/
├── docs/
│   └── push-notification-architecture.md  # 架构设计文档
├── backend-java/                           # Java后端实现（Spring Boot）
│   ├── src/main/java/com/uchannel/
│   │   ├── PushNotificationApplication.java
│   │   ├── config/FirebaseConfig.java
│   │   ├── controller/PushController.java
│   │   ├── service/PushNotificationService.java
│   │   └── dto/                            # 数据传输对象
│   └── pom.xml                             # Maven配置
└── android/
    ├── PushNotificationService.kt          # Android推送服务
    ├── FCMTokenManager.kt                  # Token管理器
    └── AndroidManifest.xml                 # 配置文件示例
```

## 🚀 快速开始

### 0. 一键构建（推荐）

使用提供的构建脚本同时生成APK和后端JAR包：

**Linux/Mac:**
```bash
./scripts/build.sh
```

**Windows:**
```cmd
scripts\build.bat
```

构建完成后，所有文件将输出到 `build/` 目录：
- `build/apk/` - Android APK文件
- `build/jar/` - 后端JAR包
- `build/scripts/` - 启动脚本

详细说明请参考：[scripts/README.md](scripts/README.md)

### 1. 服务器端设置

**环境要求：**
- JDK 17+
- Maven 3.6+

**安装和运行：**

```bash
cd backend-java

# 编译项目
mvn clean compile

# 运行应用
mvn spring-boot:run
```

**配置Firebase：**
1. 访问 [Firebase Console](https://console.firebase.google.com/)
2. 创建新项目或选择现有项目
3. 进入"项目设置" > "服务账号"
4. 点击"生成新的私钥"，下载 `serviceAccountKey.json`
5. 将文件放在 `backend-java/src/main/resources/` 目录下

详细文档请参考：[backend-java/README.md](backend-java/README.md)

### 2. Android端设置

#### 添加依赖

在 `app/build.gradle` 中添加：

```gradle
dependencies {
    implementation 'com.google.firebase:firebase-messaging:23.4.0'
    implementation 'com.google.firebase:firebase-analytics:21.5.0'
}
```

#### 添加google-services.json

1. 在Firebase Console中，进入项目设置
2. 添加Android应用，输入包名
3. 下载 `google-services.json`
4. 将文件放在 `app/` 目录下

#### 在Application中初始化

```kotlin
class MyApplication : Application() {
    override fun onCreate() {
        super.onCreate()
        
        // 获取并注册FCM Token
        val tokenManager = FCMTokenManager(this)
        tokenManager.getToken { token ->
            if (token != null) {
                // Token已获取，可以发送到服务器
                Log.d("App", "FCM Token: $token")
            }
        }
    }
}
```

## 📖 使用示例

### Java后端发送推送

```java
@Autowired
private PushNotificationService pushNotificationService;

// 发送给单个设备
PushResult result = pushNotificationService.sendToDevice(
    "user_fcm_token",
    "新消息",
    "您有一条新消息",
    Map.of("type", "message", "id", "123"),
    "high"
);

// 批量发送
List<String> tokens = Arrays.asList("token1", "token2", "token3");
PushResult batchResult = pushNotificationService.sendToMultipleDevices(
    tokens,
    "系统通知",
    "系统维护通知",
    Map.of("type", "system")
);

// 主题推送
PushResult topicResult = pushNotificationService.sendToTopic(
    "news",
    "新闻推送",
    "今日头条新闻",
    Map.of("articleId", "456")
);
```

### API调用示例

```bash
# 发送推送（默认端口8080）
curl -X POST http://localhost:8080/api/push/send?userId=user123 \
  -H "Content-Type: application/json" \
  -d '{
    "title": "新消息",
    "body": "您有一条新消息",
    "data": {"type": "message", "id": "123"}
  }'

# 广播推送
curl -X POST http://localhost:8080/api/push/broadcast \
  -H "Content-Type: application/json" \
  -d '{
    "userIds": ["user1", "user2"],
    "title": "系统通知",
    "body": "系统维护通知"
  }'

# 注册Token
curl -X POST http://localhost:8080/api/push/register-token \
  -H "Content-Type: application/json" \
  -d '{
    "token": "fcm_token_here"
  }'
```

## 🔧 配置说明

### 消息优先级

- `high`: 即时消息，立即推送
- `normal`: 普通消息，可延迟

### 通知渠道（Android 8.0+）

需要在Android端创建通知渠道，服务器推送时指定 `channelId`。

### Token管理

- Token会在以下情况刷新：
  - 应用重新安装
  - 应用数据被清除
  - 应用恢复出厂设置
  - Token过期（很少发生）

- 需要在 `onNewToken` 回调中及时更新服务器端的Token

## 🛡️ 安全建议

1. **保护服务账号密钥**
   - 不要将 `serviceAccountKey.json` 提交到代码仓库
   - 使用环境变量或密钥管理服务

2. **Token验证**
   - 服务器端验证Token的有效性
   - 定期清理无效Token

3. **API认证**
   - 推送API需要身份验证
   - 限制推送权限

## 📊 监控和统计

建议实现以下监控指标：

- 推送成功率
- 推送失败原因统计
- Token有效性统计
- 用户打开率

## 🔄 国内部署说明 ⚠️

**重要提示：FCM在中国大陆无法直接访问！**

由于网络限制，Google Firebase Cloud Messaging (FCM) 在中国大陆无法正常使用。如果您的应用主要面向国内用户，**强烈建议使用国内推送服务**。

### 推荐方案

1. **极光推送（JPush）** ⭐ 最推荐
   - 国内市场份额最大（>70%）
   - 免费版：100万推送/月
   - 支持厂商通道，送达率>90%
   - [官网](https://www.jiguang.cn/)

2. **个推（Getui）**
   - 企业级推送服务
   - 高送达率（>95%）
   - 专业客服支持
   - [官网](https://www.getui.com/)

3. **厂商推送**
   - 华为推送（HMS Push）
   - 小米推送（MiPush）
   - OPPO推送、VIVO推送
   - 各厂商设备送达率接近100%

### 详细指南

请参考：[国内部署指南](docs/china-deployment-guide.md)

该文档包含：
- 完整的国内推送服务集成方案
- 从FCM迁移到国内推送的步骤
- 双通道方案（同时支持国内外用户）
- 性能对比和最佳实践

### WebSocket自建推送

如果您考虑使用WebSocket自建推送能力，请参考：[WebSocket自建推送技术难点分析](docs/websocket-push-challenges.md)

该文档详细分析了：
- 7大核心难点（连接管理、消息路由、高可用、性能优化等）
- 每个难点的技术挑战和解决方案
- 代码示例和最佳实践
- 成本分析和适用场景

### 架构对比分析

深入了解FCM和极光推送的内部架构设计，请参考：[FCM与极光推送架构对比分析](docs/push-architecture-comparison.md)

该文档包含：
- FCM和极光推送的完整系统架构图
- 各自的设计亮点深度分析
- 技术实现细节对比
- 选择建议和适用场景

## 📚 更多资源

- [Firebase Cloud Messaging 文档](https://firebase.google.com/docs/cloud-messaging)
- [FCM Admin SDK 文档](https://firebase.google.com/docs/cloud-messaging/admin/send-messages)
- [Android通知最佳实践](https://developer.android.com/develop/ui/views/notifications)

## ❓ 常见问题

### Q: Token获取失败？
A: 检查 `google-services.json` 是否正确配置，确保包名匹配。

### Q: 推送消息收不到？
A: 
1. 检查设备网络连接
2. 确认Token是否有效
3. 检查Android通知权限（Android 13+）
4. 查看FCM控制台的错误日志

### Q: 如何测试推送？
A: 可以使用Firebase Console的"发送测试消息"功能，或使用Postman调用API。

## 📝 许可证

MIT License

