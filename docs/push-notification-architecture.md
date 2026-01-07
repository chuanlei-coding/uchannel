# Android 推送消息架构设计

## 一、技术选型

### 1. Firebase Cloud Messaging (FCM) - 推荐方案

**优势：**
- Google 官方服务，稳定可靠
- 免费使用
- 支持多平台（Android、iOS、Web）
- 自动处理设备注册和消息路由
- 支持消息优先级和送达确认

**适用场景：**
- 面向全球用户的应用
- 需要跨平台推送
- 希望使用官方标准方案

### 2. 第三方推送服务（国内推荐）

**主流服务商：**
- **极光推送（JPush）**：国内市场份额最大
- **个推（Getui）**：企业级推送服务
- **小米推送（MiPush）**：小米设备优化
- **华为推送（HMS Push）**：华为设备优化
- **OPPO推送、VIVO推送**：对应品牌设备优化

**优势：**
- 国内网络环境友好
- 支持厂商通道（提高送达率）
- 提供详细的数据统计
- 有完善的SDK和文档

**适用场景：**
- 主要面向国内用户
- 需要高送达率
- 需要详细的推送数据统计

## 二、架构设计

### FCM 架构流程

```
┌─────────────┐         ┌──────────────┐         ┌─────────────┐
│  Android    │         │  应用服务器   │         │  FCM 服务器   │
│   应用      │         │  (Backend)   │         │   (Google)  │
└─────────────┘         └──────────────┘         └─────────────┘
      │                        │                        │
      │  1. 注册获取Token      │                        │
      │──────────────────────>│                        │
      │                        │                        │
      │  2. 发送Token到服务器   │                        │
      │<──────────────────────│                        │
      │                        │                        │
      │                        │  3. 发送推送请求        │
      │                        │──────────────────────>│
      │                        │                        │
      │                        │  4. 推送到设备         │
      │<────────────────────────────────────────────────│
      │                        │                        │
```

### 核心组件

1. **Android 客户端**
   - 集成 FCM SDK
   - 获取并保存 FCM Token
   - 接收和处理推送消息
   - 实现消息通知展示

2. **应用服务器（Backend）**
   - 存储用户的 FCM Token
   - 调用 FCM API 发送推送
   - 管理推送策略和规则
   - 记录推送日志

3. **FCM 服务器**
   - 管理设备注册
   - 路由消息到目标设备
   - 处理消息队列和重试

## 三、实现步骤

### Android 端实现

#### 1. 添加依赖

```gradle
// build.gradle (app level)
dependencies {
    implementation 'com.google.firebase:firebase-messaging:23.4.0'
    implementation 'com.google.firebase:firebase-analytics:21.5.0'
}
```

#### 2. 创建 FirebaseMessagingService

```kotlin
class MyFirebaseMessagingService : FirebaseMessagingService() {
    
    override fun onNewToken(token: String) {
        // 当Token刷新时调用
        // 需要将新Token发送到服务器
        sendTokenToServer(token)
    }
    
    override fun onMessageReceived(remoteMessage: RemoteMessage) {
        // 处理接收到的消息
        if (remoteMessage.notification != null) {
            showNotification(
                remoteMessage.notification?.title ?: "",
                remoteMessage.notification?.body ?: ""
            )
        }
        
        // 处理自定义数据
        remoteMessage.data?.let { data ->
            handleCustomData(data)
        }
    }
    
    private fun sendTokenToServer(token: String) {
        // 调用API将Token发送到服务器
        // TODO: 实现API调用
    }
    
    private fun showNotification(title: String, body: String) {
        // 创建并显示通知
        // TODO: 实现通知展示
    }
    
    private fun handleCustomData(data: Map<String, String>) {
        // 处理自定义数据
        // TODO: 实现数据处理逻辑
    }
}
```

#### 3. 在 AndroidManifest.xml 中注册服务

```xml
<service
    android:name=".MyFirebaseMessagingService"
    android:exported="false">
    <intent-filter>
        <action android:name="com.google.firebase.MESSAGING_EVENT" />
    </intent-filter>
</service>
```

### 服务器端实现

#### Node.js 示例

```javascript
const admin = require('firebase-admin');
const serviceAccount = require('./path/to/serviceAccountKey.json');

// 初始化 Firebase Admin SDK
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

// 发送推送消息
async function sendPushNotification(token, title, body, data = {}) {
  const message = {
    notification: {
      title: title,
      body: body,
    },
    data: data,
    token: token,
    android: {
      priority: 'high',
      notification: {
        sound: 'default',
        channelId: 'default_channel',
      },
    },
  };

  try {
    const response = await admin.messaging().send(message);
    console.log('成功发送消息:', response);
    return response;
  } catch (error) {
    console.error('发送消息失败:', error);
    throw error;
  }
}

// 批量发送
async function sendToMultipleDevices(tokens, title, body, data = {}) {
  const message = {
    notification: {
      title: title,
      body: body,
    },
    data: data,
    tokens: tokens, // 最多1000个token
    android: {
      priority: 'high',
    },
  };

  try {
    const response = await admin.messaging().sendMulticast(message);
    console.log('成功发送:', response.successCount, '失败:', response.failureCount);
    return response;
  } catch (error) {
    console.error('批量发送失败:', error);
    throw error;
  }
}

// 主题推送
async function sendToTopic(topic, title, body, data = {}) {
  const message = {
    notification: {
      title: title,
      body: body,
    },
    data: data,
    topic: topic,
    android: {
      priority: 'high',
    },
  };

  try {
    const response = await admin.messaging().send(message);
    console.log('主题推送成功:', response);
    return response;
  } catch (error) {
    console.error('主题推送失败:', error);
    throw error;
  }
}
```

#### Python 示例

```python
from firebase_admin import credentials, messaging, initialize_app

# 初始化
cred = credentials.Certificate('path/to/serviceAccountKey.json')
initialize_app(cred)

def send_push_notification(token, title, body, data=None):
    """发送单个推送消息"""
    message = messaging.Message(
        notification=messaging.Notification(
            title=title,
            body=body,
        ),
        data=data or {},
        token=token,
        android=messaging.AndroidConfig(
            priority='high',
            notification=messaging.AndroidNotification(
                sound='default',
                channel_id='default_channel',
            ),
        ),
    )
    
    try:
        response = messaging.send(message)
        print(f'成功发送消息: {response}')
        return response
    except Exception as e:
        print(f'发送消息失败: {e}')
        raise

def send_to_multiple_devices(tokens, title, body, data=None):
    """批量发送推送消息"""
    message = messaging.MulticastMessage(
        notification=messaging.Notification(
            title=title,
            body=body,
        ),
        data=data or {},
        tokens=tokens,
        android=messaging.AndroidConfig(
            priority='high',
        ),
    )
    
    try:
        response = messaging.send_multicast(message)
        print(f'成功: {response.success_count}, 失败: {response.failure_count}')
        return response
    except Exception as e:
        print(f'批量发送失败: {e}')
        raise
```

## 四、最佳实践

### 1. Token 管理

- **存储位置**：服务器数据库（用户ID -> FCM Token映射）
- **更新机制**：客户端Token刷新时立即上报服务器
- **清理机制**：定期清理无效Token（FCM返回INVALID_TOKEN时）

### 2. 消息类型

- **通知消息（Notification）**：系统自动显示通知栏
- **数据消息（Data）**：应用内处理，不自动显示
- **混合消息**：同时包含通知和数据

### 3. 消息优先级

```javascript
// 高优先级 - 即时消息
android: {
  priority: 'high'
}

// 普通优先级 - 可延迟
android: {
  priority: 'normal'
}
```

### 4. 错误处理

- **INVALID_TOKEN**：从数据库删除该Token
- **UNREGISTERED**：设备已卸载应用，删除Token
- **网络错误**：实现重试机制

### 5. 安全性

- **服务账号密钥**：妥善保管，不要提交到代码仓库
- **Token验证**：服务器验证Token的有效性
- **消息加密**：敏感数据使用加密传输

## 五、国内替代方案（极光推送示例）

### Android 端集成

```kotlin
// 初始化
JPushInterface.init(context)

// 设置别名（用户ID）
JPushInterface.setAlias(context, sequence, alias)

// 设置标签
JPushInterface.setTags(context, sequence, tags)

// 接收消息
class MyJPushMessageReceiver : JPushMessageReceiver() {
    override fun onMessage(context: Context, customMessage: CustomMessage) {
        // 处理自定义消息
    }
    
    override fun onNotifyMessageArrived(context: Context, notificationMessage: NotificationMessage) {
        // 通知到达
    }
}
```

### 服务器端调用

```javascript
const JPush = require('jpush-sdk');

const client = JPush.buildClient('your_app_key', 'your_master_secret');

// 发送推送
client.push().setPlatform(JPush.ALL)
    .setAudience(JPush.alias('user_id'))
    .setNotification('推送标题', JPush.ios('推送内容'), JPush.android('推送内容'))
    .send((err, res) => {
        if (err) {
            console.log(err.message);
        } else {
            console.log('Sendno: ' + res.sendno);
            console.log('Msg_id: ' + res.msg_id);
        }
    });
```

## 六、性能优化

1. **批量发送**：合并多个推送请求，减少API调用
2. **异步处理**：使用消息队列（如RabbitMQ、Redis）异步发送
3. **限流控制**：避免短时间内大量推送导致服务降级
4. **缓存策略**：缓存常用推送模板和配置

## 七、监控和统计

- **送达率**：监控消息成功送达的比例
- **打开率**：统计用户点击通知的比例
- **错误日志**：记录发送失败的原因
- **性能指标**：API响应时间、吞吐量等

