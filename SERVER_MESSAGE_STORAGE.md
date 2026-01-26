# 服务器端消息存储功能

## 📝 功能概述

实现了聊天消息在服务器端的持久化存储，确保消息数据保存在服务器数据库中，支持多设备同步和历史消息查询。

## 🎯 实现架构

### 后端实现

#### 1. 数据库配置
- **数据库**: H2 Database (文件数据库)
- **存储位置**: `./data/uchannel.mv.db`
- **JPA配置**: 自动创建表结构

#### 2. 数据模型

**Message 实体** (`Message.java`):
- `id`: 主键（自增）
- `content`: 消息内容（最大500字符）
- `sender`: 发送者（"USER" 或 "ASSISTANT"）
- `conversationId`: 会话ID（最大100字符）
- `timestamp`: 时间戳（LocalDateTime）

**MessageDTO** (`MessageDTO.java`):
- 用于API响应，将LocalDateTime转换为ISO格式字符串

#### 3. API端点

**POST /api/chat/send**
- 发送消息并保存到数据库
- 请求体: `{ "message": "消息内容", "conversationId": "会话ID（可选）" }`
- 响应: `{ "success": true, "message": "回复内容", "data": { "conversationId": "...", "schedule": {...} } }`

**GET /api/chat/history/{conversationId}**
- 获取会话历史消息
- 响应: `{ "success": true, "conversationId": "...", "messages": [...], "count": 10 }`

#### 4. 服务层

**ChatService.processMessage()**:
- 接收用户消息和会话ID
- 如果没有会话ID，创建新会话
- 保存用户消息到数据库
- 处理消息（调用LLM或备用逻辑）
- 保存助手回复到数据库
- 返回响应（包含会话ID）

**ChatService.getHistoryMessages()**:
- 根据会话ID查询历史消息
- 按时间戳升序排序
- 返回MessageDTO列表

### Android端实现

#### 1. API接口更新

**ChatApiService**:
- `sendMessage()`: 发送消息（包含conversationId）
- `getHistory()`: 获取历史消息

**数据模型**:
- `ChatRequest`: 添加 `conversationId` 字段
- `HistoryResponse`: 历史消息响应
- `MessageResponse`: 服务器消息格式

#### 2. 消息加载流程

1. **优先从服务器加载**:
   - Fragment创建时，如果有conversationId，调用 `getHistory()` API
   - 解析服务器返回的消息列表
   - 转换为本地Message格式
   - 显示在界面上

2. **本地备份**:
   - 从服务器加载成功后，同步到本地存储（作为备份）
   - 如果服务器加载失败，从本地加载

3. **消息发送**:
   - 发送消息时传递conversationId
   - 服务器返回新的conversationId（如果是新会话）
   - 更新本地conversationId

## 📊 数据流程

```
用户发送消息
    ↓
Android端: 构建ChatRequest (message + conversationId)
    ↓
POST /api/chat/send
    ↓
后端: 保存用户消息到数据库
    ↓
后端: 处理消息（LLM）
    ↓
后端: 保存助手回复到数据库
    ↓
后端: 返回响应 (包含conversationId)
    ↓
Android端: 显示消息，更新conversationId
```

```
用户打开聊天界面
    ↓
Android端: 获取conversationId
    ↓
GET /api/chat/history/{conversationId}
    ↓
后端: 从数据库查询消息
    ↓
后端: 返回消息列表（按时间排序）
    ↓
Android端: 解析并显示消息
    ↓
Android端: 同步到本地存储（备份）
```

## 🗄️ 数据库结构

### messages 表

| 字段 | 类型 | 说明 |
|------|------|------|
| id | BIGINT | 主键，自增 |
| content | VARCHAR(500) | 消息内容 |
| sender | VARCHAR(50) | 发送者（USER/ASSISTANT） |
| conversation_id | VARCHAR(100) | 会话ID |
| timestamp | TIMESTAMP | 时间戳 |

### 索引
- `conversation_id`: 用于快速查询会话消息

## 🔧 配置说明

### application.yml

```yaml
spring:
  datasource:
    url: jdbc:h2:file:./data/uchannel;AUTO_SERVER=TRUE
    driver-class-name: org.h2.Driver
    username: sa
    password: 
  jpa:
    hibernate:
      ddl-auto: update
    show-sql: false
```

### 数据库文件位置
- **开发环境**: `backend-java/data/uchannel.mv.db`
- **生产环境**: 建议使用PostgreSQL或MySQL

## 🚀 使用示例

### 发送消息

```bash
curl -X POST https://your-server/api/chat/send \
  -H "Content-Type: application/json" \
  -d '{
    "message": "明天下午3点开会",
    "conversationId": "conversation-123"
  }'
```

### 获取历史消息

```bash
curl https://your-server/api/chat/history/conversation-123
```

## ✅ 功能特点

1. **自动会话管理**: 如果没有conversationId，自动创建新会话
2. **消息持久化**: 所有消息保存在数据库，不会丢失
3. **多设备同步**: 同一会话ID可以在不同设备上查看
4. **历史查询**: 支持查询任意会话的历史消息
5. **本地备份**: Android端保留本地备份，离线时可用

## 🔄 与本地存储的关系

- **服务器存储**: 主要数据源，支持多设备同步
- **本地存储**: 备份数据源，用于离线访问和快速加载
- **同步策略**: 优先从服务器加载，失败时使用本地备份

## 📝 后续优化建议

1. **数据库迁移**: 生产环境使用PostgreSQL/MySQL
2. **分页查询**: 对于大量历史消息，实现分页加载
3. **消息搜索**: 添加全文搜索功能
4. **消息删除**: 支持删除单条或批量消息
5. **会话管理**: 添加会话列表、重命名、删除等功能
6. **数据备份**: 定期备份数据库
7. **性能优化**: 添加缓存层，优化查询性能

---

*最后更新：2026-01-09*
