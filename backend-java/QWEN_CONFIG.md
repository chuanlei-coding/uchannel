# 通义千问-flash配置说明

## 功能说明

后端服务已集成阿里云通义千问-flash大模型，用于处理用户的日程安排指令。

## 配置

### API Key配置

API Key已配置在 `application.yml` 中：

```yaml
qwen:
  api-key: sk-bbdf41fb73044d66b46976a1df35abbe
```

### 环境变量配置（可选）

可以通过环境变量覆盖配置：

```bash
export QWEN_API_KEY=your-api-key-here
```

或在启动时指定：

```bash
java -jar app.jar --qwen.api-key=your-api-key-here
```

## API端点

- **模型**: qwen-turbo（通义千问-flash）
- **API地址**: `https://dashscope.aliyuncs.com/api/v1/services/aigc/text-generation/generation`

## 使用方式

1. 用户发送消息到 `/api/chat/send`
2. 后端调用通义千问-flash处理消息
3. 返回模型生成的回复

## 系统提示词

系统已配置专门的提示词，让模型专注于日程安排助手角色：

- 理解用户的日程安排意图
- 提取关键信息（时间、地点、事件等）
- 给出友好的确认和提醒
- 如果信息不完整，礼貌地询问缺失的信息

## 降级策略

如果通义千问API调用失败，系统会自动降级到简单的规则匹配逻辑，确保服务可用性。

## 故障排查

1. **API调用失败**
   - 检查API Key是否正确
   - 检查网络连接
   - 查看日志获取详细错误信息

2. **响应为空**
   - 检查API配额是否充足
   - 检查请求格式是否正确
   - 查看日志中的API响应

3. **降级到简单逻辑**
   - 检查QwenFlashService是否正确注入
   - 查看日志确认降级原因
