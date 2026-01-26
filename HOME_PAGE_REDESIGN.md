# 主页重新设计 - 借鉴微信设计

## 📱 设计概述

本次重新设计借鉴了微信的聊天列表界面，将应用的主页改为类似微信的聊天列表形式，包含底部导航栏。

## 🎯 主要变化

### 1. 新的主页结构

#### MainActivityNew（新的启动Activity）
- **布局文件**: `activity_main_new.xml`
- **功能**: 
  - 顶部标题栏（"微信" + 搜索和添加按钮）
  - Fragment容器（显示不同页面）
  - 底部导航栏（微信、通讯录、发现、我）

#### 聊天列表页面
- **Fragment**: `ConversationListFragment`
- **布局**: `fragment_conversation_list.xml`
- **功能**: 显示所有聊天会话列表，类似微信的聊天列表

#### 聊天详情页面
- **Activity**: `ChatDetailActivity`
- **布局**: `activity_chat_detail.xml`
- **功能**: 点击列表项后进入具体的聊天对话界面

### 2. 新增组件

#### 数据模型
- **Conversation.kt**: 聊天会话数据模型
  - `id`: 会话ID
  - `title`: 会话标题
  - `lastMessage`: 最后一条消息
  - `timestamp`: 最后消息时间
  - `avatar`: 头像
  - `unreadCount`: 未读消息数
  - `isMuted`: 是否静音
  - `type`: 会话类型（CHAT、SCHEDULE、SYSTEM）

#### 适配器
- **ConversationAdapter**: 聊天列表适配器
  - 显示会话信息
  - 处理未读消息数显示
  - 处理静音图标显示
  - 格式化时间戳（今天、昨天、星期、日期）

#### 布局文件
- **item_conversation.xml**: 聊天列表项布局
  - 头像（48dp圆形）
  - 标题和时间
  - 最后一条消息
  - 未读消息数或静音图标

#### 图标资源
- `ic_search.xml`: 搜索图标
- `ic_add_circle.xml`: 添加图标
- `ic_chat.xml`: 聊天图标
- `ic_contacts.xml`: 通讯录图标
- `ic_discover.xml`: 发现图标
- `ic_me.xml`: 我的图标
- `ic_muted.xml`: 静音图标
- `unread_badge.xml`: 未读消息数徽章

### 3. 底部导航栏

#### 导航项
1. **微信** (nav_chat): 显示聊天列表
2. **通讯录** (nav_contacts): 占位页面（待实现）
3. **发现** (nav_discover): 占位页面（待实现）
4. **我** (nav_me): 占位页面（待实现）

#### 样式
- 选中状态：绿色（`@color/button_primary`）
- 未选中状态：灰色（`@color/text_secondary`）
- 使用 `BottomNavigationView` 组件

### 4. 时间格式化

根据消息时间显示不同的格式：
- **今天**: 显示时间（如 "12:30"）
- **昨天**: 显示 "昨天"
- **一周内**: 显示星期（如 "星期一"）
- **更早**: 显示日期（如 "01/08"）

## 📁 文件结构

```
android/app/src/main/
├── java/com/uchannel/
│   ├── MainActivityNew.kt          # 新的主Activity
│   ├── ChatDetailActivity.kt       # 聊天详情Activity
│   ├── model/
│   │   └── Conversation.kt        # 会话数据模型
│   ├── adapter/
│   │   └── ConversationAdapter.kt # 会话列表适配器
│   └── fragment/
│       └── ConversationListFragment.kt # 聊天列表Fragment
│
└── res/
    ├── layout/
    │   ├── activity_main_new.xml      # 新主页布局
    │   ├── activity_chat_detail.xml   # 聊天详情布局
    │   ├── fragment_conversation_list.xml # 聊天列表布局
    │   └── item_conversation.xml      # 会话项布局
    ├── drawable/
    │   ├── ic_search.xml
    │   ├── ic_add_circle.xml
    │   ├── ic_chat.xml
    │   ├── ic_contacts.xml
    │   ├── ic_discover.xml
    │   ├── ic_me.xml
    │   ├── ic_muted.xml
    │   └── unread_badge.xml
    ├── menu/
    │   └── bottom_navigation.xml      # 底部导航菜单
    └── color/
        └── bottom_nav_color.xml        # 底部导航颜色选择器
```

## 🔄 导航流程

1. **启动应用** → `MainActivityNew`
   - 显示聊天列表（`ConversationListFragment`）
   - 底部导航栏默认选中"微信"

2. **点击会话** → `ChatDetailActivity`
   - 显示具体的聊天界面（`ChatFragment`）
   - 可以返回聊天列表

3. **底部导航切换**
   - 点击不同标签切换不同的Fragment
   - 目前只有"微信"标签有实际内容

## 🎨 UI设计特点

### 聊天列表项
- **头像**: 48dp圆形，根据会话类型显示不同头像
- **标题**: 16sp，粗体，主色
- **最后消息**: 14sp，次要色，单行省略
- **时间**: 12sp，提示色，右对齐
- **未读徽章**: 红色圆形，显示数字（超过99显示"99+"）
- **静音图标**: 灰色铃铛图标

### 顶部栏
- **标题**: "微信"，20sp，粗体，白色
- **搜索按钮**: 白色图标，44dp点击区域
- **添加按钮**: 白色图标，44dp点击区域
- **背景**: 渐变背景（`header_gradient`）

### 底部导航
- **高度**: 自动
- **背景**: 浅色背景
- **图标**: 24dp
- **文字**: 选中绿色，未选中灰色

## 🚀 后续开发建议

1. **通讯录页面**
   - 显示联系人列表
   - 支持搜索和分组

2. **发现页面**
   - 朋友圈功能
   - 扫一扫
   - 小程序入口

3. **我的页面**
   - 个人信息
   - 设置
   - 日程管理入口

4. **搜索功能**
   - 实现搜索对话框
   - 支持搜索会话、消息、联系人

5. **添加功能**
   - 新建聊天
   - 扫一扫
   - 添加朋友

6. **会话管理**
   - 长按会话显示菜单（删除、置顶、标记已读等）
   - 支持会话置顶
   - 支持会话分组

## 📝 注意事项

1. **向后兼容**: 保留了 `MainChatActivity` 和 `MainActivity`，确保现有功能不受影响
2. **Fragment复用**: `ChatFragment` 可以在 `ChatDetailActivity` 和 `MainChatActivity` 中使用
3. **数据同步**: 需要在 `ConversationListFragment` 中实现与 `ChatFragment` 的数据同步，更新最后一条消息

---

*最后更新：2026-01-09*
