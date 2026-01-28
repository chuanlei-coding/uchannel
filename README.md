# UChannel - Vita 智能助手

Vita 是一个优雅的个人效率管理应用，帮助你更好地规划和实现目标。

## 项目架构

```
uchannel/
├── flutter_app/              # Flutter 前端应用
├── backend-java/             # Java Spring Boot 后端
├── docs/                   # 后端相关文档
├── scripts/                 # 后端构建和启动脚本
└── README.md              # 项目说明
```

## 功能特性

### Flutter 应用

- **启动页** - 优雅的品牌展示
- **助手页** - AI 智能对话助手
- **日程页** - 任务管理，支持智能拆解
- **发现页** - 内容探索
- **统计页** - 数据洞察
- **设置页** - 个性化配置

### 后端服务

- **聊天服务** - 支持 AI 对话
- **推送通知** - Firebase 消息推送
- **消息存储** - 历史消息持久化

## 快速开始

### Flutter App

**环境要求：**
- Flutter 3.10+
- Dart 3.0+
- Android Studio / Xcode

**构建应用：**

```bash
# 进入 Flutter 项目
cd flutter_app

# Debug 版本
flutter build apk --debug

# Release 版本
flutter build apk --release

# 在设备上运行
flutter run
```

**APK 输出位置：**
- Debug: `build/app/outputs/flutter-apk/app-debug.apk`
- Release: `build/app/outputs/flutter-apk/app-release.apk`

### 后端服务

**环境要求：**
- JDK 17+
- Maven 3.6+

**启动服务：**

```bash
# 使用脚本启动（推荐）
./scripts/start-backend.sh

# 或手动启动
cd backend-java
mvn spring-boot:run
```

服务默认运行在 `http://localhost:8080`

## 文档

### 后端相关

- [国内部署指南](docs/china-deployment-guide.md) - Firebase 在国内的替代方案
- [推送架构对比](docs/push-architecture-comparison.md) - FCM 与极光推送对比
- [多平台推送架构](docs/multi-platform-push-architecture.md) - Android + iOS 统一推送
- [推送通知架构](docs/push-notification-architecture.md) - 完整推送系统设计
- [WebSocket 推送难点](docs/websocket-push-challenges.md) - 自建推送的 7 大难点

### 后端配置

- `backend-java/QWEN_CONFIG.md` - Qwen AI 配置说明

## 项目特性

### UI/UX 设计

基于 **Vita** 品牌理念，采用柔和优雅的设计风格：

- **配色方案** - 鼠尾草绿、水鸭青色为主
- **字体** - Newsreader（衬线）+ 系统字体
- **圆角** - 大圆角，柔和感
- **阴影** - 轻阴影，层次感

### 技术栈

**前端：**
- Flutter 3.10+
- Dart 3.0+
- Google Fonts
- go_router（导航）

**后端：**
- Java 17
- Spring Boot
- H2 Database
- Firebase Cloud Messaging

## 开发指南

### Flutter 开发

```bash
# 安装依赖
flutter pub get

# 运行分析
flutter analyze

# 运行测试
flutter test

# 查看所有可用设备
flutter devices

# 热重载（开发时）
# 在 IDE 中按 'r' 键
# 或在命令行使用 flutter run
```

### 后端开发

```bash
# 编译项目
mvn clean compile

# 运行测试
mvn test

# 打包 JAR
mvn package
```

## 脚本说明

### 后端脚本

| 脚本 | 说明 |
|------|------|
| `build-backend.sh` | 构建后端 JAR 包 |
| `start-backend.sh` | 启动后端服务（Linux/Mac） |
| `start-backend.bat` | 启动后端服务（Windows） |
| `generate-ssl-cert.sh` | 生成 SSL 证书 |

详细说明：[scripts/README.md](scripts/README.md)

## 构建产物

### Flutter App

```
flutter_app/build/app/outputs/flutter-apk/
├── app-debug.apk          # Debug 版本
└── app-release.apk        # Release 版本
```

### 后端

```
backend-java/target/
├── *.jar                 # Spring Boot 可执行 JAR
└── *.original             # 原始打包文件
```

## 清理历史

项目已于 **2026-01-27** 从 React Native 重构为 Flutter。以下是已删除的过期内容：

**已删除的文档（React Native 时代）：**
- Android 原生聊天界面文档
- Android UI 设计指南
- 聊天历史功能文档
- 主页重新设计文档
- UI 美化文档
- UI/UX 优化文档

**已删除的脚本（Android 原生）：**
- Android APK 构建脚本
- 完整构建脚本

详细的清理说明：[CLEANUP_NOTES.md](CLEANUP_NOTES.md)

## 许可证

MIT License

## 联系方式

如有问题或建议，欢迎提交 Issue。
