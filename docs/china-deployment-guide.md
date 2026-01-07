# 国内部署指南

## ⚠️ 重要说明：FCM在国内的访问限制

**在中国大陆，Google Firebase Cloud Messaging (FCM) 无法直接访问。**

### 原因
1. **网络限制**：Google服务在中国大陆被限制访问
2. **连接不稳定**：即使通过特殊方式连接，也经常出现超时和连接失败
3. **送达率低**：由于网络问题，推送消息的送达率会大幅下降

### 影响
- ❌ Android客户端无法获取FCM Token
- ❌ 服务器无法连接到FCM服务器发送推送
- ❌ 推送消息无法正常送达
- ❌ 用户体验严重受影响

## ✅ 国内推荐方案

### 方案对比

| 方案 | 优势 | 劣势 | 适用场景 |
|------|------|------|----------|
| **极光推送（JPush）** | 市场份额最大，文档完善，支持厂商通道 | 免费版有限制 | 中小型应用 |
| **个推（Getui）** | 企业级服务，稳定性高，送达率高 | 价格较高 | 大型企业应用 |
| **厂商推送** | 直达系统级，送达率最高 | 需要分别集成各厂商SDK | 大型应用，追求极致送达率 |
| **自建WebSocket** | 完全可控，无第三方依赖 | 开发维护成本高，需要处理连接管理 | 特殊需求场景 |

### 1. 极光推送（JPush）⭐ 最推荐

**官网**: https://www.jiguang.cn/

**特点**:
- 国内市场份额最大（超过70%）
- 免费版支持：100万推送/月
- 支持厂商通道（华为、小米、OPPO、VIVO等）
- 完善的SDK和文档
- 提供详细的数据统计

**集成步骤**:

#### Android端集成

1. 添加依赖（`android/app/build.gradle`）:
```gradle
dependencies {
    // 极光推送
    implementation 'cn.jiguang.sdk:jpush:4.9.0'
    implementation 'cn.jiguang.sdk:jcore:3.0.0'
    
    // 厂商通道（可选，提高送达率）
    implementation 'cn.jiguang.sdk:jpush-huawei:1.0.6'  // 华为
    implementation 'cn.jiguang.sdk:jpush-xiaomi:1.0.9'  // 小米
    implementation 'cn.jiguang.sdk:jpush-oppo:1.0.8'    // OPPO
    implementation 'cn.jiguang.sdk:jpush-vivo:1.0.7'     // VIVO
}
```

2. 初始化（Application类）:
```kotlin
class MyApplication : Application() {
    override fun onCreate() {
        super.onCreate()
        
        // 初始化极光推送
        JPushInterface.setDebugMode(BuildConfig.DEBUG)
        JPushInterface.init(this)
        
        // 设置别名（用户ID）
        JPushInterface.setAlias(this, 1, "user_123")
    }
}
```

3. 创建消息接收器:
```kotlin
class JPushMessageReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        when (intent.action) {
            JPushInterface.ACTION_MESSAGE_RECEIVED -> {
                // 自定义消息
                val message = intent.getStringExtra(JPushInterface.EXTRA_MESSAGE)
                handleCustomMessage(message)
            }
            JPushInterface.ACTION_NOTIFICATION_RECEIVED -> {
                // 通知到达
                val notification = intent.getBundleExtra(JPushInterface.EXTRA_NOTIFICATION)
                handleNotification(notification)
            }
            JPushInterface.ACTION_NOTIFICATION_OPENED -> {
                // 用户点击通知
                val notification = intent.getBundleExtra(JPushInterface.EXTRA_NOTIFICATION)
                handleNotificationClick(notification)
            }
        }
    }
}
```

4. 在AndroidManifest.xml中注册:
```xml
<receiver
    android:name=".JPushMessageReceiver"
    android:enabled="true"
    android:exported="false">
    <intent-filter>
        <action android:name="cn.jpush.android.intent.RECEIVE_MESSAGE" />
        <category android:name="${applicationId}" />
    </intent-filter>
</receiver>
```

#### 服务器端集成（Java）

1. 添加依赖（`pom.xml`）:
```xml
<dependency>
    <groupId>cn.jpush.api</groupId>
    <artifactId>jpush-client</artifactId>
    <version>3.6.8</version>
</dependency>
```

2. 创建极光推送服务:
```java
@Service
public class JPushService {
    private static final String APP_KEY = "your_app_key";
    private static final String MASTER_SECRET = "your_master_secret";
    
    private JPushClient jpushClient;
    
    @PostConstruct
    public void init() {
        jpushClient = new JPushClient(MASTER_SECRET, APP_KEY);
    }
    
    /**
     * 发送推送给单个用户
     */
    public void sendToUser(String alias, String title, String content) {
        try {
            PushPayload payload = PushPayload.newBuilder()
                    .setPlatform(Platform.all())
                    .setAudience(Audience.alias(alias))
                    .setNotification(Notification.alert(content))
                    .setOptions(Options.newBuilder()
                            .setApnsProduction(true)
                            .build())
                    .build();
            
            PushResult result = jpushClient.sendPush(payload);
            System.out.println("推送结果: " + result);
        } catch (APIConnectionException | APIRequestException e) {
            e.printStackTrace();
        }
    }
    
    /**
     * 批量推送
     */
    public void sendToUsers(List<String> aliases, String title, String content) {
        try {
            PushPayload payload = PushPayload.newBuilder()
                    .setPlatform(Platform.android())
                    .setAudience(Audience.alias(aliases))
                    .setNotification(Notification.android(content, title, null))
                    .build();
            
            PushResult result = jpushClient.sendPush(payload);
            System.out.println("推送结果: " + result);
        } catch (APIConnectionException | APIRequestException e) {
            e.printStackTrace();
        }
    }
}
```

### 2. 个推（Getui）

**官网**: https://www.getui.com/

**特点**:
- 企业级推送服务
- 高送达率（>95%）
- 支持厂商通道
- 提供专业的客服支持

**适用场景**: 大型企业应用，对送达率要求极高

### 3. 厂商推送（推荐组合方案）

如果追求极致送达率，建议同时集成多个厂商推送：

#### 华为推送（HMS Push）
- 官网: https://developer.huawei.com/consumer/cn/hms/huawei-pushkit
- 华为设备送达率接近100%

#### 小米推送（MiPush）
- 官网: https://dev.mi.com/console/appservice/push.html
- 小米设备送达率接近100%

#### OPPO推送
- 官网: https://open.oppomobile.com/
- OPPO设备送达率高

#### VIVO推送
- 官网: https://dev.vivo.com.cn/
- VIVO设备送达率高

**集成策略**:
```kotlin
// 根据设备品牌选择推送通道
when (Build.MANUFACTURER.lowercase()) {
    "huawei", "honor" -> {
        // 使用华为推送
        initHuaweiPush()
    }
    "xiaomi" -> {
        // 使用小米推送
        initXiaomiPush()
    }
    "oppo" -> {
        // 使用OPPO推送
        initOppoPush()
    }
    "vivo" -> {
        // 使用VIVO推送
        initVivoPush()
    }
    else -> {
        // 使用极光推送作为默认通道
        initJPush()
    }
}
```

## 🔄 迁移方案

### 从FCM迁移到极光推送

1. **移除FCM依赖**
   - 删除Firebase相关依赖
   - 移除`google-services.json`
   - 删除FCM相关代码

2. **集成极光推送**
   - 按照上述步骤集成JPush SDK
   - 更新Token注册逻辑
   - 更新消息接收处理

3. **服务器端改造**
   - 替换FCM服务为极光推送服务
   - 更新推送API调用
   - 更新数据库中的Token字段（如果需要）

### 双通道方案（FCM + 国内推送）

如果应用需要同时支持海外和国内用户：

```java
@Service
public class HybridPushService {
    @Autowired
    private PushNotificationService fcmService;  // FCM服务
    
    @Autowired
    private JPushService jpushService;  // 极光推送服务
    
    public void sendPush(String userId, String title, String body) {
        User user = userService.getUser(userId);
        
        if (user.getRegion() == Region.CHINA) {
            // 国内用户使用极光推送
            jpushService.sendToUser(user.getJpushAlias(), title, body);
        } else {
            // 海外用户使用FCM
            fcmService.sendToDevice(user.getFcmToken(), title, body, null, "high");
        }
    }
}
```

## 📊 性能对比

| 指标 | FCM（国内） | 极光推送 | 个推 | 厂商推送 |
|------|-----------|---------|------|---------|
| 送达率 | <30% | >90% | >95% | >98% |
| 连接稳定性 | 不稳定 | 稳定 | 稳定 | 非常稳定 |
| 延迟 | 高 | 低 | 低 | 极低 |
| 免费额度 | 无限制 | 100万/月 | 有限 | 有限 |
| 集成难度 | 简单 | 简单 | 简单 | 中等 |

## 💡 最佳实践建议

1. **主要面向国内用户**
   - ✅ 使用极光推送或个推
   - ✅ 集成厂商通道提高送达率
   - ❌ 不要使用FCM

2. **同时面向国内外用户**
   - ✅ 实现双通道方案
   - ✅ 根据用户地区自动选择推送服务
   - ✅ 在用户注册时记录地区信息

3. **追求极致送达率**
   - ✅ 集成所有主流厂商推送
   - ✅ 使用极光推送作为默认通道
   - ✅ 实现推送失败自动降级

4. **成本考虑**
   - 免费版：极光推送（100万/月）
   - 付费版：根据推送量选择合适套餐
   - 厂商推送：通常免费，但需要分别集成

## 🔗 相关资源

- [极光推送官方文档](https://docs.jiguang.cn/jpush/client/android/android_guide/)
- [个推官方文档](https://docs.getui.com/getui/mobile/android/overview/)
- [华为推送文档](https://developer.huawei.com/consumer/cn/doc/development/HMS-Guides/push-introduction)
- [小米推送文档](https://dev.mi.com/console/doc/detail?pId=41)

## ❓ 常见问题

### Q: 为什么FCM在国内无法使用？
A: 由于网络限制，Google服务在中国大陆无法直接访问。即使通过特殊方式连接，稳定性和送达率也无法保证。

### Q: 极光推送和个推哪个更好？
A: 
- **极光推送**：适合中小型应用，免费版额度较高，文档完善
- **个推**：适合大型企业应用，稳定性更高，但价格较贵

### Q: 需要集成所有厂商推送吗？
A: 不一定。建议根据用户设备分布情况选择：
- 如果华为用户多，优先集成华为推送
- 如果小米用户多，优先集成小米推送
- 可以使用极光推送作为默认通道，覆盖所有设备

### Q: 如何测试推送功能？
A: 
- 极光推送：提供控制台测试功能
- 个推：提供测试工具
- 厂商推送：各厂商都提供测试工具

### Q: 推送失败如何处理？
A: 建议实现推送失败重试机制，并记录失败原因。对于重要推送，可以实现多通道降级策略。

