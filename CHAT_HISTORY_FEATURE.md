# 对话历史保留功能

## 📝 功能概述

实现了聊天消息的本地持久化存储，确保用户关闭应用后重新打开时，之前的对话历史仍然保留。

## 🎯 实现方式

### 1. 消息存储管理器 (`MessageStorage.kt`)

使用 `SharedPreferences` + `Gson` 实现消息的序列化和存储：

- **存储位置**: `SharedPreferences` (键名: `chat_messages`)
- **序列化格式**: JSON (使用 Gson)
- **支持功能**:
  - 保存消息列表
  - 加载消息列表
  - 添加单条消息
  - 更新消息
  - 删除消息
  - 清空会话消息
  - 获取所有会话ID

### 2. 会话管理

- **默认会话**: 每个用户自动分配一个默认会话ID
- **多会话支持**: 支持按会话ID存储不同的对话历史
- **会话ID来源**:
  1. 从 `ChatDetailActivity` 传递的 `conversation_id`
  2. 如果没有传递，使用默认会话ID

### 3. 消息保存时机

在以下情况下自动保存消息：

1. **欢迎消息**: Fragment 首次加载且无历史消息时
2. **用户消息**: 用户发送消息后立即保存
3. **助手回复**: 收到后端回复后保存
4. **确认消息**: 添加日程后的确认消息
5. **错误消息**: 处理错误时的提示消息

### 4. 消息加载时机

- **Fragment 创建时**: `onViewCreated()` 中自动加载历史消息
- **加载逻辑**:
  - 如果有历史消息，直接加载显示
  - 如果没有历史消息，显示欢迎消息

## 📁 代码结构

```
android/app/src/main/java/com/uchannel/
├── util/
│   └── MessageStorage.kt          # 消息存储管理器
└── fragment/
    └── ChatFragment.kt            # 集成消息存储
```

## 🔧 技术细节

### MessageStorage API

```kotlin
// 获取默认会话ID
fun getDefaultConversationId(context: Context): String

// 保存消息列表
fun saveMessages(context: Context, conversationId: String, messages: List<Message>)

// 加载消息列表
fun loadMessages(context: Context, conversationId: String): List<Message>

// 添加单条消息
fun addMessage(context: Context, conversationId: String, message: Message)

// 更新消息
fun updateMessage(context: Context, conversationId: String, oldMessageId: String, newMessage: Message)

// 删除消息
fun removeMessage(context: Context, conversationId: String, messageId: String)

// 清空会话消息
fun clearMessages(context: Context, conversationId: String)

// 获取所有会话ID
fun getAllConversationIds(context: Context): List<String>
```

### ChatFragment 集成

1. **初始化会话ID**:
   ```kotlin
   conversationId = arguments?.getString("conversation_id")
       ?: MessageStorage.getDefaultConversationId(requireContext())
   ```

2. **加载历史消息**:
   ```kotlin
   private fun loadHistoryMessages() {
       conversationId?.let { id ->
           val historyMessages = MessageStorage.loadMessages(requireContext(), id)
           if (historyMessages.isNotEmpty()) {
               messages.clear()
               messages.addAll(historyMessages)
               messageAdapter.notifyDataSetChanged()
               scrollToBottom()
           } else {
               addWelcomeMessage()
           }
       }
   }
   ```

3. **保存消息**:
   ```kotlin
   conversationId?.let { id ->
       MessageStorage.addMessage(requireContext(), id, message)
   }
   ```

## 💾 存储格式

消息以 JSON 格式存储在 `SharedPreferences` 中：

```json
{
  "id": "uuid",
  "content": "消息内容",
  "sender": "USER" | "ASSISTANT",
  "timestamp": "2026-01-09T12:00:00Z"
}
```

## 🚀 使用场景

1. **单会话模式**: 默认会话，所有消息保存在一个会话中
2. **多会话模式**: 从聊天列表进入不同会话，每个会话独立保存历史

## 📊 性能考虑

- **存储方式**: `SharedPreferences` 适合中小量数据（< 1000 条消息）
- **序列化**: 使用 Gson，性能良好
- **加载时机**: 仅在 Fragment 创建时加载一次
- **保存时机**: 实时保存，确保数据不丢失

## 🔄 后续优化建议

1. **数据库迁移**: 如果消息量很大，可以迁移到 Room 数据库
2. **分页加载**: 对于大量历史消息，实现分页加载
3. **消息搜索**: 添加本地消息搜索功能
4. **消息同步**: 如果需要多设备同步，可以添加云端备份
5. **存储清理**: 添加自动清理旧消息的机制

## ✅ 测试要点

1. **基本功能**:
   - 发送消息后关闭应用，重新打开应能看到历史消息
   - 欢迎消息只在首次使用时显示

2. **多会话**:
   - 不同会话的消息应独立保存
   - 切换会话时应显示对应的历史消息

3. **边界情况**:
   - 无网络时的消息保存
   - 应用崩溃后的数据恢复
   - 存储空间不足的处理

---

*最后更新：2026-01-09*
