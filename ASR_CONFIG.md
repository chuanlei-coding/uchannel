# 阿里云ASR配置说明

## 功能说明

应用已集成阿里云 qwen3-asr-flash 语音识别服务，支持语音转文字功能。

## 配置步骤

### 1. 获取API密钥

1. 访问 [阿里云百炼平台](https://bailian.console.aliyun.com/)
2. 注册/登录账号
3. 开通 Qwen3-ASR-Flash 服务
4. 获取 API Key 和 API Secret

### 2. 配置API密钥

有两种方式配置API密钥：

#### 方式一：代码配置（开发阶段）

编辑 `android/app/src/main/java/com/uchannel/util/AsrConfig.kt`：

```kotlin
const val API_KEY = "your-actual-api-key"
const val API_SECRET = "your-actual-api-secret"
```

#### 方式二：运行时配置（推荐）

在应用运行时通过SharedPreferences设置：

```kotlin
AsrConfig.setApiKey(context, "your-api-key")
AsrConfig.setApiSecret(context, "your-api-secret")
```

### 3. API端点

当前使用的API端点为：
```
https://dashscope.aliyuncs.com/api/v1/services/audio/asr/transcription
```

如果阿里云更新了API端点，请修改 `AliyunAsrService.kt` 中的 `BASE_URL`。

### 4. 音频格式要求

- 格式：PCM
- 采样率：16kHz
- 声道：单声道（MONO）
- 位深度：16位

应用已自动配置为符合要求的格式。

## 使用方法

1. 点击聊天输入框左侧的麦克风按钮
2. 开始说话（最长30秒）
3. 再次点击按钮停止录音
4. 系统自动识别语音并填充到输入框

## 注意事项

- 首次使用需要授予录音权限
- 确保网络连接正常
- API密钥需要有效且有足够的配额
- 录音文件会自动删除，不会占用存储空间

## 故障排查

1. **提示"ASR服务未配置"**
   - 检查是否已设置API密钥
   - 确认API密钥格式正确

2. **识别失败**
   - 检查网络连接
   - 确认API密钥有效且有配额
   - 查看logcat日志获取详细错误信息

3. **录音失败**
   - 检查是否授予录音权限
   - 确认设备麦克风正常工作
