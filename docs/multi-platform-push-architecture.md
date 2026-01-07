# 多平台推送架构设计（Android + iOS）

## 📋 概述

本文档描述如何扩展现有推送方案，同时支持Android和iOS平台，实现统一的推送服务架构。

## 🎯 设计目标

1. **统一推送接口**：后端提供统一的推送API，支持多平台
2. **平台透明**：业务层无需关心具体平台实现
3. **高可用性**：支持平台降级和容错
4. **易于扩展**：未来可轻松添加新平台（如Web、小程序等）

## 🏗️ 统一推送架构

```
┌─────────────────────────────────────────────────────────────────┐
│                    统一推送服务架构                               │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│                    业务层 (Business Layer)                    │
│  ┌──────────────────────────────────────────────────────┐   │
│  │  推送业务逻辑                                         │   │
│  │  - 消息内容生成                                       │   │
│  │  - 推送策略决策                                       │   │
│  │  - 用户分组管理                                       │   │
│  └──────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────────┐
│              统一推送服务层 (Unified Push Service)             │
│                                                              │
│  ┌──────────────────────────────────────────────────────┐   │
│  │  推送服务接口 (PushService)                           │   │
│  │  - sendToUser(userId, message)                       │   │
│  │  - sendToUsers(userIds, message)                     │   │
│  │  - sendToTag(tag, message)                           │   │
│  │  - sendBroadcast(message)                             │   │
│  └──────────────────────────────────────────────────────┘   │
│                          │                                    │
│                          ▼                                    │
│  ┌──────────────────────────────────────────────────────┐   │
│  │  平台适配层 (Platform Adapter Layer)                  │   │
│  │  ┌──────────────┐  ┌──────────────┐                │   │
│  │  │ Android适配器 │  │  iOS适配器    │                │   │
│  │  │ - FCM/JPush   │  │ - APNs       │                │   │
│  │  └──────────────┘  └──────────────┘                │   │
│  └──────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
       │                              │
       ▼                              ▼
┌──────────────┐              ┌──────────────┐
│  Android推送 │              │   iOS推送     │
│  FCM/JPush   │              │   APNs       │
└──────────────┘              └──────────────┘
```

## 📱 iOS推送特殊性

### 1. Apple Push Notification Service (APNs)

**特点**：
- **系统级服务**：iOS系统提供的推送服务
- **必须使用APNs**：无法绕过，所有推送必须通过APNs
- **证书/密钥认证**：需要配置APNs证书或密钥
- **生产/开发环境**：区分开发和生产环境

**架构**：
```
应用服务器
    ↓
APNs服务器 (Apple)
    ↓
iOS设备
```

### 2. 与Android的差异

| 特性 | Android | iOS |
|------|---------|-----|
| **推送服务** | FCM/JPush/厂商推送 | 仅APNs |
| **Token获取** | 应用内获取 | 系统回调获取 |
| **Token格式** | 字符串 | 字符串（Device Token） |
| **消息格式** | JSON | JSON（APNs格式） |
| **推送限制** | 无特殊限制 | 有推送频率限制 |
| **静默推送** | 支持 | 支持（Background） |
| **通知显示** | 可自定义 | 系统统一管理 |

## 🔧 架构改进方案

### 方案一：统一推送服务层（推荐）⭐

#### 架构设计

```java
// 1. 定义统一的消息模型
public class PushMessage {
    private String title;
    private String body;
    private Map<String, String> data;
    private PushPriority priority;
    private PushPlatform platform; // ANDROID, IOS, ALL
    private String sound;
    private String badge; // iOS专用
    private String category; // iOS专用
    private Map<String, Object> customData;
}

// 2. 定义推送结果模型
public class PushResult {
    private boolean success;
    private String messageId;
    private String error;
    private PushPlatform platform;
    private Integer successCount;
    private Integer failureCount;
}

// 3. 统一推送服务接口
public interface UnifiedPushService {
    /**
     * 推送给单个用户
     */
    PushResult sendToUser(String userId, PushMessage message);
    
    /**
     * 批量推送
     */
    PushResult sendToUsers(List<String> userIds, PushMessage message);
    
    /**
     * 按标签推送
     */
    PushResult sendToTag(String tag, PushMessage message);
    
    /**
     * 广播推送
     */
    PushResult broadcast(PushMessage message);
}
```

#### 平台适配器实现

```java
// Android推送适配器
@Service
public class AndroidPushAdapter implements PushAdapter {
    @Autowired
    private PushNotificationService fcmService; // FCM服务
    @Autowired
    private JPushService jpushService; // 极光推送服务
    
    @Override
    public PushResult send(String token, PushMessage message) {
        // 根据配置选择推送服务
        if (useJPush()) {
            return jpushService.send(token, convertToJPushMessage(message));
        } else {
            return fcmService.sendToDevice(token, message.getTitle(), 
                message.getBody(), message.getData(), "high");
        }
    }
    
    @Override
    public PushPlatform getPlatform() {
        return PushPlatform.ANDROID;
    }
}

// iOS推送适配器
@Service
public class IOSPushAdapter implements PushAdapter {
    @Autowired
    private APNsService apnsService;
    
    @Override
    public PushResult send(String token, PushMessage message) {
        APNsMessage apnsMessage = convertToAPNsMessage(message);
        return apnsService.send(token, apnsMessage);
    }
    
    @Override
    public PushPlatform getPlatform() {
        return PushPlatform.IOS;
    }
    
    private APNsMessage convertToAPNsMessage(PushMessage message) {
        APNsMessage apns = new APNsMessage();
        apns.setAlert(new Alert(message.getTitle(), message.getBody()));
        apns.setSound(message.getSound() != null ? message.getSound() : "default");
        apns.setBadge(message.getBadge());
        apns.setCategory(message.getCategory());
        apns.setCustomData(message.getCustomData());
        return apns;
    }
}
```

#### 统一推送服务实现

```java
@Service
public class UnifiedPushServiceImpl implements UnifiedPushService {
    
    @Autowired
    private List<PushAdapter> pushAdapters;
    
    @Autowired
    private UserDeviceService userDeviceService;
    
    private Map<PushPlatform, PushAdapter> adapterMap;
    
    @PostConstruct
    public void init() {
        adapterMap = pushAdapters.stream()
            .collect(Collectors.toMap(
                PushAdapter::getPlatform,
                adapter -> adapter
            ));
    }
    
    @Override
    public PushResult sendToUser(String userId, PushMessage message) {
        // 1. 获取用户的所有设备
        List<DeviceInfo> devices = userDeviceService.getUserDevices(userId);
        
        if (devices.isEmpty()) {
            return PushResult.failure("用户无在线设备");
        }
        
        // 2. 按平台分组
        Map<PushPlatform, List<DeviceInfo>> devicesByPlatform = 
            devices.stream().collect(Collectors.groupingBy(DeviceInfo::getPlatform));
        
        // 3. 分别推送到各平台
        List<PushResult> results = new ArrayList<>();
        for (Map.Entry<PushPlatform, List<DeviceInfo>> entry : devicesByPlatform.entrySet()) {
            PushPlatform platform = entry.getKey();
            List<DeviceInfo> platformDevices = entry.getValue();
            
            PushAdapter adapter = adapterMap.get(platform);
            if (adapter == null) {
                continue;
            }
            
            // 适配平台特定的消息格式
            PushMessage platformMessage = adaptMessageForPlatform(message, platform);
            
            // 批量推送
            for (DeviceInfo device : platformDevices) {
                PushResult result = adapter.send(device.getToken(), platformMessage);
                results.add(result);
            }
        }
        
        // 4. 合并结果
        return mergeResults(results);
    }
    
    @Override
    public PushResult sendToUsers(List<String> userIds, PushMessage message) {
        // 批量推送实现
        List<PushResult> results = userIds.stream()
            .map(userId -> sendToUser(userId, message))
            .collect(Collectors.toList());
        
        return mergeResults(results);
    }
    
    private PushMessage adaptMessageForPlatform(PushMessage message, PushPlatform platform) {
        PushMessage adapted = new PushMessage();
        adapted.setTitle(message.getTitle());
        adapted.setBody(message.getBody());
        adapted.setData(message.getData());
        adapted.setPriority(message.getPriority());
        adapted.setPlatform(platform);
        
        // iOS特定字段
        if (platform == PushPlatform.IOS) {
            adapted.setSound(message.getSound() != null ? message.getSound() : "default");
            adapted.setBadge(message.getBadge());
            adapted.setCategory(message.getCategory());
        }
        
        // Android特定字段
        if (platform == PushPlatform.ANDROID) {
            // Android特定配置
        }
        
        return adapted;
    }
}
```

### 方案二：设备信息管理

#### 设备信息模型

```java
@Entity
@Table(name = "user_devices")
public class UserDevice {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Column(nullable = false)
    private String userId;
    
    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private PushPlatform platform; // ANDROID, IOS
    
    @Column(nullable = false)
    private String deviceToken; // FCM Token / APNs Device Token
    
    @Column
    private String deviceId; // 设备唯一标识
    
    @Column
    private String deviceModel; // 设备型号
    
    @Column
    private String appVersion; // 应用版本
    
    @Column
    private String osVersion; // 系统版本
    
    @Column
    private Boolean isActive; // 是否活跃
    
    @Column
    private LocalDateTime lastActiveTime; // 最后活跃时间
    
    @Column
    private LocalDateTime createdAt;
    
    @Column
    private LocalDateTime updatedAt;
}

public enum PushPlatform {
    ANDROID,
    IOS,
    WEB
}
```

#### 设备服务实现

```java
@Service
public class UserDeviceService {
    
    @Autowired
    private UserDeviceRepository deviceRepository;
    
    /**
     * 注册设备Token
     */
    public void registerDevice(String userId, DeviceRegisterRequest request) {
        // 检查设备是否已存在
        UserDevice device = deviceRepository.findByUserIdAndDeviceId(
            userId, request.getDeviceId()
        ).orElse(new UserDevice());
        
        device.setUserId(userId);
        device.setPlatform(request.getPlatform());
        device.setDeviceToken(request.getToken());
        device.setDeviceId(request.getDeviceId());
        device.setDeviceModel(request.getDeviceModel());
        device.setAppVersion(request.getAppVersion());
        device.setOsVersion(request.getOsVersion());
        device.setIsActive(true);
        device.setLastActiveTime(LocalDateTime.now());
        
        if (device.getId() == null) {
            device.setCreatedAt(LocalDateTime.now());
        }
        device.setUpdatedAt(LocalDateTime.now());
        
        deviceRepository.save(device);
    }
    
    /**
     * 获取用户的所有设备
     */
    public List<DeviceInfo> getUserDevices(String userId) {
        return deviceRepository.findByUserIdAndIsActiveTrue(userId)
            .stream()
            .map(this::toDeviceInfo)
            .collect(Collectors.toList());
    }
    
    /**
     * 获取用户指定平台的设备
     */
    public List<DeviceInfo> getUserDevicesByPlatform(String userId, PushPlatform platform) {
        return deviceRepository.findByUserIdAndPlatformAndIsActiveTrue(userId, platform)
            .stream()
            .map(this::toDeviceInfo)
            .collect(Collectors.toList());
    }
    
    /**
     * 更新设备活跃状态
     */
    public void updateDeviceActive(String userId, String deviceId) {
        deviceRepository.findByUserIdAndDeviceId(userId, deviceId)
            .ifPresent(device -> {
                device.setIsActive(true);
                device.setLastActiveTime(LocalDateTime.now());
                deviceRepository.save(device);
            });
    }
    
    /**
     * 删除设备（用户退出登录或卸载应用）
     */
    public void removeDevice(String userId, String deviceId) {
        deviceRepository.findByUserIdAndDeviceId(userId, deviceId)
            .ifPresent(device -> {
                device.setIsActive(false);
                deviceRepository.save(device);
            });
    }
}
```

### 方案三：APNs服务实现

#### APNs配置

```java
@Configuration
public class APNsConfig {
    
    @Value("${apns.key-id}")
    private String keyId;
    
    @Value("${apns.team-id}")
    private String teamId;
    
    @Value("${apns.bundle-id}")
    private String bundleId;
    
    @Value("${apns.key-path}")
    private String keyPath;
    
    @Value("${apns.production:true}")
    private boolean production;
    
    @Bean
    public ApnsClient apnsClient() throws Exception {
        // 使用APNs Auth Key（推荐方式）
        File keyFile = new File(keyPath);
        String authKey = Files.readString(keyFile.toPath());
        
        ApnsClientBuilder builder = new ApnsClientBuilder()
            .setApnsServer(production ? 
                ApnsClientBuilder.PRODUCTION_APNS_HOST : 
                ApnsClientBuilder.DEVELOPMENT_APNS_HOST)
            .setSigningKey(ApnsSigningKey.loadFromP8String(authKey, teamId, keyId))
            .setConcurrentConnections(10)
            .setConnectionTimeout(Duration.ofSeconds(10));
        
        return builder.build();
    }
}
```

#### APNs服务实现

```java
@Service
public class APNsService {
    
    @Autowired
    private ApnsClient apnsClient;
    
    @Value("${apns.bundle-id}")
    private String bundleId;
    
    /**
     * 发送推送消息
     */
    public PushResult send(String deviceToken, APNsMessage message) {
        try {
            // 构建APNs推送请求
            SimpleApnsPushNotification notification = new SimpleApnsPushNotification(
                deviceToken,
                bundleId,
                buildPayload(message)
            );
            
            // 发送推送
            Future<PushNotificationResponse<SimpleApnsPushNotification>> future = 
                apnsClient.sendNotification(notification);
            
            PushNotificationResponse<SimpleApnsPushNotification> response = future.get();
            
            if (response.isAccepted()) {
                return PushResult.success(response.getApnsId().toString());
            } else {
                String reason = response.getRejectionReason().orElse("Unknown");
                return PushResult.failure("APNs rejected: " + reason);
            }
            
        } catch (Exception e) {
            logger.error("APNs推送失败", e);
            return PushResult.failure("APNs推送异常: " + e.getMessage());
        }
    }
    
    /**
     * 批量发送
     */
    public PushResult sendBatch(List<String> deviceTokens, APNsMessage message) {
        int successCount = 0;
        int failureCount = 0;
        
        for (String token : deviceTokens) {
            PushResult result = send(token, message);
            if (result.isSuccess()) {
                successCount++;
            } else {
                failureCount++;
            }
        }
        
        return PushResult.batchResult(successCount, failureCount);
    }
    
    /**
     * 构建APNs Payload
     */
    private String buildPayload(APNsMessage message) {
        JSONObject payload = new JSONObject();
        JSONObject aps = new JSONObject();
        
        // Alert
        if (message.getAlert() != null) {
            JSONObject alert = new JSONObject();
            alert.put("title", message.getAlert().getTitle());
            alert.put("body", message.getAlert().getBody());
            aps.put("alert", alert);
        }
        
        // Sound
        if (message.getSound() != null) {
            aps.put("sound", message.getSound());
        }
        
        // Badge
        if (message.getBadge() != null) {
            aps.put("badge", Integer.parseInt(message.getBadge()));
        }
        
        // Category
        if (message.getCategory() != null) {
            aps.put("category", message.getCategory());
        }
        
        // Content Available (静默推送)
        if (message.isContentAvailable()) {
            aps.put("content-available", 1);
        }
        
        payload.put("aps", aps);
        
        // 自定义数据
        if (message.getCustomData() != null) {
            message.getCustomData().forEach(payload::put);
        }
        
        return payload.toString();
    }
}
```

## 📱 客户端实现

### iOS客户端

```swift
import UserNotifications
import UIKit

class PushNotificationManager: NSObject {
    static let shared = PushNotificationManager()
    
    func registerForPushNotifications() {
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert, .sound, .badge]
        ) { granted, error in
            if granted {
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        }
    }
    
    func didRegisterForRemoteNotifications(deviceToken: Data) {
        let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
        let token = tokenParts.joined()
        
        // 发送Token到服务器
        sendTokenToServer(token)
    }
    
    func didFailToRegisterForRemoteNotifications(error: Error) {
        print("Failed to register: \(error)")
    }
    
    private func sendTokenToServer(_ token: String) {
        // 调用API注册Token
        let url = URL(string: "https://your-api.com/api/push/register-token")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "token": token,
            "platform": "IOS",
            "deviceId": UIDevice.current.identifierForVendor?.uuidString ?? "",
            "deviceModel": UIDevice.current.model,
            "osVersion": UIDevice.current.systemVersion,
            "appVersion": Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
        ]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error: \(error)")
            }
        }.resume()
    }
}

// AppDelegate扩展
extension AppDelegate: UNUserNotificationCenterDelegate {
    // 应用在前台时收到通知
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                               willPresent notification: UNNotification,
                               withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // 显示通知
        completionHandler([.alert, .sound, .badge])
    }
    
    // 用户点击通知
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                               didReceive response: UNNotificationResponse,
                               withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        
        // 处理通知点击
        handleNotificationClick(userInfo)
        
        completionHandler()
    }
}
```

### Android客户端（更新）

```kotlin
// 更新FCMTokenManager以支持多平台标识
class FCMTokenManager(private val context: Context) {
    
    fun getToken(callback: (String?) -> Unit) {
        FirebaseMessaging.getInstance().token.addOnCompleteListener { task ->
            if (!task.isSuccessful) {
                callback(null)
                return@addOnCompleteListener
            }
            
            val token = task.result
            saveTokenLocally(token)
            sendTokenToServer(token)
            callback(token)
        }
    }
    
    private fun sendTokenToServer(token: String) {
        val apiService = RetrofitClient.apiService
        val request = TokenRegisterRequest(
            token = token,
            platform = "ANDROID", // 明确标识平台
            deviceId = getDeviceId(),
            deviceModel = Build.MODEL,
            osVersion = Build.VERSION.RELEASE,
            appVersion = getAppVersion()
        )
        
        apiService.registerToken(request).enqueue(object : Callback<ResponseBody> {
            override fun onResponse(call: Call<ResponseBody>, response: Response<ResponseBody>) {
                if (response.isSuccessful) {
                    Log.d(TAG, "Token注册成功")
                }
            }
            
            override fun onFailure(call: Call<ResponseBody>, t: Throwable) {
                Log.e(TAG, "Token注册失败", t)
            }
        })
    }
}
```

## 🔄 API接口设计

### 统一推送API

```java
@RestController
@RequestMapping("/api/push")
public class UnifiedPushController {
    
    @Autowired
    private UnifiedPushService pushService;
    
    /**
     * 推送给单个用户
     */
    @PostMapping("/send")
    public ResponseEntity<Map<String, Object>> sendPush(
            @RequestParam String userId,
            @Valid @RequestBody PushMessageRequest request) {
        
        PushMessage message = convertToPushMessage(request);
        PushResult result = pushService.sendToUser(userId, message);
        
        return ResponseEntity.ok(createResponse(result));
    }
    
    /**
     * 批量推送
     */
    @PostMapping("/batch")
    public ResponseEntity<Map<String, Object>> batchPush(
            @Valid @RequestBody BatchPushRequest request) {
        
        PushMessage message = convertToPushMessage(request);
        PushResult result = pushService.sendToUsers(request.getUserIds(), message);
        
        return ResponseEntity.ok(createResponse(result));
    }
    
    /**
     * 按平台推送
     */
    @PostMapping("/send-by-platform")
    public ResponseEntity<Map<String, Object>> sendByPlatform(
            @RequestParam PushPlatform platform,
            @Valid @RequestBody PushMessageRequest request) {
        
        PushMessage message = convertToPushMessage(request);
        message.setPlatform(platform);
        
        // 获取该平台的所有用户
        List<String> userIds = userDeviceService.getUsersByPlatform(platform);
        PushResult result = pushService.sendToUsers(userIds, message);
        
        return ResponseEntity.ok(createResponse(result));
    }
    
    /**
     * 注册设备Token
     */
    @PostMapping("/register-device")
    public ResponseEntity<Map<String, Object>> registerDevice(
            @Valid @RequestBody DeviceRegisterRequest request) {
        
        String userId = getCurrentUserId(); // 从认证信息获取
        userDeviceService.registerDevice(userId, request);
        
        return ResponseEntity.ok(createSuccessResponse());
    }
}
```

## 📊 数据库设计

```sql
-- 用户设备表
CREATE TABLE user_devices (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    user_id VARCHAR(64) NOT NULL,
    platform ENUM('ANDROID', 'IOS', 'WEB') NOT NULL,
    device_token VARCHAR(255) NOT NULL,
    device_id VARCHAR(128),
    device_model VARCHAR(128),
    app_version VARCHAR(32),
    os_version VARCHAR(32),
    is_active BOOLEAN DEFAULT TRUE,
    last_active_time DATETIME,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    INDEX idx_user_id (user_id),
    INDEX idx_platform (platform),
    INDEX idx_device_token (device_token),
    INDEX idx_user_platform (user_id, platform),
    UNIQUE KEY uk_user_device (user_id, device_id)
);

-- 推送记录表（可选，用于统计）
CREATE TABLE push_records (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    user_id VARCHAR(64),
    platform ENUM('ANDROID', 'IOS', 'WEB'),
    device_token VARCHAR(255),
    message_id VARCHAR(128),
    title VARCHAR(255),
    body TEXT,
    status ENUM('SUCCESS', 'FAILED', 'PENDING') DEFAULT 'PENDING',
    error_message TEXT,
    sent_at DATETIME,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    
    INDEX idx_user_id (user_id),
    INDEX idx_platform (platform),
    INDEX idx_status (status),
    INDEX idx_created_at (created_at)
);
```

## 🎯 最佳实践

### 1. 消息格式统一

```java
// 统一消息模型，支持多平台
public class PushMessage {
    // 通用字段
    private String title;
    private String body;
    private Map<String, String> data;
    
    // iOS特定字段
    private String sound = "default";
    private String badge;
    private String category;
    private boolean contentAvailable = false; // 静默推送
    
    // Android特定字段
    private String channelId = "default_channel";
    private String clickAction;
    private String priority = "high";
}
```

### 2. 错误处理和降级

```java
public PushResult sendToUser(String userId, PushMessage message) {
    List<DeviceInfo> devices = userDeviceService.getUserDevices(userId);
    
    Map<PushPlatform, List<PushResult>> resultsByPlatform = new HashMap<>();
    
    for (DeviceInfo device : devices) {
        PushAdapter adapter = adapterMap.get(device.getPlatform());
        if (adapter == null) {
            continue;
        }
        
        try {
            PushResult result = adapter.send(device.getToken(), message);
            resultsByPlatform.computeIfAbsent(device.getPlatform(), k -> new ArrayList<>())
                .add(result);
        } catch (Exception e) {
            // 记录错误，但不中断其他设备的推送
            logger.error("推送失败: userId={}, platform={}", userId, device.getPlatform(), e);
            
            // 可以在这里实现降级策略
            // 例如：APNs失败时，可以尝试其他方式
        }
    }
    
    return mergeResults(resultsByPlatform);
}
```

### 3. 推送统计和监控

```java
@Service
public class PushStatisticsService {
    
    public void recordPush(String userId, PushPlatform platform, 
                          String messageId, boolean success) {
        PushRecord record = new PushRecord();
        record.setUserId(userId);
        record.setPlatform(platform);
        record.setMessageId(messageId);
        record.setStatus(success ? PushStatus.SUCCESS : PushStatus.FAILED);
        record.setSentAt(LocalDateTime.now());
        
        pushRecordRepository.save(record);
    }
    
    public PushStatistics getStatistics(LocalDate startDate, LocalDate endDate) {
        // 统计各平台的推送成功率
        // 统计推送量
        // 统计错误类型
        return statistics;
    }
}
```

## 📝 配置文件示例

```yaml
# application.yml
push:
  # Android配置
  android:
    enabled: true
    provider: jpush # fcm 或 jpush
    fcm:
      service-account-key: serviceAccountKey.json
    jpush:
      app-key: your_jpush_app_key
      master-secret: your_jpush_master_secret
  
  # iOS配置
  ios:
    enabled: true
    apns:
      key-id: your_apns_key_id
      team-id: your_apns_team_id
      bundle-id: com.yourapp.ios
      key-path: /path/to/AuthKey_XXXXX.p8
      production: true # false for development
```

## ✅ 实施步骤

1. **第一阶段：iOS基础支持**
   - 实现APNs服务
   - 添加设备注册API
   - iOS客户端集成

2. **第二阶段：统一推送服务**
   - 实现统一推送接口
   - 实现平台适配器
   - 更新Android客户端

3. **第三阶段：优化和监控**
   - 添加推送统计
   - 实现错误处理和降级
   - 添加监控和告警

## 📚 总结

通过以上架构设计，可以实现：

1. ✅ **统一接口**：业务层使用统一API，无需关心平台差异
2. ✅ **易于扩展**：新增平台只需实现适配器
3. ✅ **高可用性**：支持平台降级和容错
4. ✅ **完整监控**：支持推送统计和监控

这样的架构设计既保持了灵活性，又提供了统一的接口，便于维护和扩展。

