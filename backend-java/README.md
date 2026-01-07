# Android 推送消息服务 - Java版本

基于Spring Boot和Firebase Cloud Messaging的推送消息服务。

## 📋 技术栈

- **Spring Boot 3.2.0** - Java后端框架
- **Firebase Admin SDK 9.2.0** - FCM推送服务
- **Java 17** - 开发语言
- **Maven** - 依赖管理

## 🚀 快速开始

### 1. 环境要求

- JDK 17 或更高版本
- Maven 3.6+

### 2. 配置Firebase

1. 访问 [Firebase Console](https://console.firebase.google.com/)
2. 创建新项目或选择现有项目
3. 进入"项目设置" > "服务账号"
4. 点击"生成新的私钥"，下载 `serviceAccountKey.json`
5. 将文件放在 `src/main/resources/` 目录下

### 3. 构建和运行

```bash
# 编译项目
mvn clean compile

# 运行应用
mvn spring-boot:run

# 或者打包后运行
mvn clean package
java -jar target/push-notification-service-1.0.0.jar
```

### 4. 配置说明

在 `application.yml` 中配置：

```yaml
firebase:
  service-account-key: serviceAccountKey.json  # 服务账号密钥文件路径
  database-url:  # Firebase数据库URL（可选）
```

## 📡 API接口

### 1. 发送单个推送

**POST** `/api/push/send?userId={userId}`

请求体：
```json
{
  "title": "新消息",
  "body": "您有一条新消息",
  "data": {
    "type": "message",
    "id": "123"
  },
  "priority": "high"
}
```

响应：
```json
{
  "success": true,
  "messageId": "0:1234567890"
}
```

### 2. 广播推送

**POST** `/api/push/broadcast`

请求体：
```json
{
  "userIds": ["user1", "user2", "user3"],
  "title": "系统通知",
  "body": "系统维护通知",
  "data": {
    "type": "system"
  }
}
```

响应：
```json
{
  "success": true,
  "successCount": 2,
  "failureCount": 1
}
```

### 3. 主题推送

**POST** `/api/push/topic`

请求体：
```json
{
  "topic": "news",
  "title": "新闻推送",
  "body": "今日头条新闻",
  "data": {
    "articleId": "456"
  }
}
```

响应：
```json
{
  "success": true,
  "messageId": "0:1234567890"
}
```

### 4. 注册Token

**POST** `/api/push/register-token`

请求体：
```json
{
  "token": "fcm_token_here"
}
```

响应：
```json
{
  "success": true,
  "message": "Token注册成功"
}
```

### 5. 订阅主题

**POST** `/api/push/subscribe?topic={topic}`

请求体：
```json
["token1", "token2", "token3"]
```

### 6. 取消订阅主题

**POST** `/api/push/unsubscribe?topic={topic}`

请求体：
```json
["token1", "token2", "token3"]
```

## 🔧 使用示例

### 使用curl测试

```bash
# 发送推送
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
    "token": "your_fcm_token_here"
  }'
```

### Java代码调用示例

```java
@Autowired
private PushNotificationService pushNotificationService;

// 发送单个推送
PushResult result = pushNotificationService.sendToDevice(
    "user_fcm_token",
    "新消息",
    "您有一条新消息",
    Map.of("type", "message", "id", "123"),
    "high"
);

// 批量推送
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

## 📁 项目结构

```
backend-java/
├── src/
│   ├── main/
│   │   ├── java/com/uchannel/
│   │   │   ├── PushNotificationApplication.java  # 主应用类
│   │   │   ├── config/
│   │   │   │   └── FirebaseConfig.java           # Firebase配置
│   │   │   ├── controller/
│   │   │   │   └── PushController.java           # REST控制器
│   │   │   ├── service/
│   │   │   │   └── PushNotificationService.java  # 推送服务
│   │   │   └── dto/
│   │   │       ├── PushResult.java              # 推送结果
│   │   │       ├── PushRequest.java             # 推送请求
│   │   │       ├── BroadcastRequest.java        # 广播请求
│   │   │       ├── TopicPushRequest.java        # 主题推送请求
│   │   │       └── TokenRegisterRequest.java     # Token注册请求
│   │   └── resources/
│   │       ├── application.yml                  # 配置文件
│   │       └── serviceAccountKey.json           # Firebase密钥（需自行添加）
│   └── test/
└── pom.xml                                       # Maven配置
```

## 🛡️ 安全建议

1. **保护服务账号密钥**
   - 不要将 `serviceAccountKey.json` 提交到代码仓库
   - 使用环境变量或密钥管理服务
   - 添加到 `.gitignore`

2. **API认证**
   - 实现JWT或OAuth2认证
   - 限制推送权限
   - 添加请求频率限制

3. **Token验证**
   - 服务器端验证Token的有效性
   - 定期清理无效Token

## 🔍 错误处理

服务会自动处理以下错误：

- **无效Token**: 自动识别并从数据库删除
- **批量推送失败**: 记录失败的Token并返回统计信息
- **网络错误**: 记录日志并返回错误信息

## 📊 监控和日志

日志级别可在 `application.yml` 中配置：

```yaml
logging:
  level:
    com.uchannel: DEBUG  # 查看详细的推送日志
```

## 🚧 TODO

- [ ] 实现用户Token数据库存储
- [ ] 添加JWT认证中间件
- [ ] 实现Token自动清理机制
- [ ] 添加推送统计和监控
- [ ] 实现消息队列异步推送
- [ ] 添加单元测试和集成测试

## 📚 相关文档

- [Spring Boot文档](https://spring.io/projects/spring-boot)
- [Firebase Admin SDK文档](https://firebase.google.com/docs/admin/setup)
- [FCM Admin SDK文档](https://firebase.google.com/docs/cloud-messaging/admin/send-messages)

## 📝 许可证

MIT License

