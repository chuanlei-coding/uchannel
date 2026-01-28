# 项目清理说明

## 已删除的过期文档（React Native 时代）

以下文档与旧的 React Native 项目相关，已不再使用：

- `ANDROID_CHAT_NATIVE.md` - Android 原生聊天界面实现（已替换为 Flutter）
- `ANDROID_UI_DESIGN.md` - Android UI 设计指南（已替换为 Flutter）
- `CHAT_HISTORY_FEATURE.md` - 聊天历史保留功能（React Native 版本）
- `HOME_PAGE_REDESIGN.md` - 主页重新设计（React Native 版本）
- `UI_BEAUTIFICATION.md` - UI 美化总结（React Native 版本）
- `UI_UX_PRO_MAX_OPTIMIZATION.md` - UI/UX 优化（React Native 版本）

## 已删除的过期构建脚本（Android 原生）

以下脚本用于 Android 原生项目构建，已不再需要：

- `build-android.sh` - Android APK 构建脚本（已替换为 Flutter 构建命令）
- `build.bat` - Windows 构建脚本（Android 原生）
- `build.sh` - 完整构建脚本（Android 原生 + 后端）

## 保留的文档和脚本

### 后端相关（保留）
- `backend-java/` - Java Spring Boot 后端
- `scripts/build-backend.sh` - 后端构建脚本
- `scripts/start-backend.sh` / `scripts/start-backend.bat` - 后端启动脚本
- `scripts/generate-ssl-cert.sh` - SSL 证书生成
- `docs/china-deployment-guide.md` - 国内部署指南
- `docs/push-architecture-comparison.md` - 推送架构对比
- `docs/multi-platform-push-architecture.md` - 多平台推送架构
- `docs/push-notification-architecture.md` - 推送通知架构
- `docs/websocket-push-challenges.md` - WebSocket 推送难点
- `backend-java/QWEN_CONFIG.md` - Qwen 配置
- `SERVER_MESSAGE_STORAGE.md` - 服务器消息存储（后端）

### Flutter App 相关（保留）
- `flutter_app/` - Flutter 应用
- `flutter_app/README.md` - Flutter 项目说明

### 工具配置（保留）
- `.shared/` - UI/UX 工具数据
- `README.md` - 项目主 README
- `scripts/README.md` - 脚本使用说明

### 环境配置（保留）
- `BUILD_GUIDE.md` - 构建指南（已更新为 Flutter）
- `HTTPS_SETUP.md` - HTTPS 配置（后端）
- `JAVA17_SETUP.md` - Java 17 配置（开发环境）
- `ASR_CONFIG.md` - ASR 配置

## 项目当前架构

```
uchannel/
├── flutter_app/              # Flutter 前端应用（主要）
├── backend-java/             # Java Spring Boot 后端
├── docs/                   # 后端相关文档
├── scripts/                 # 后端构建和启动脚本
├── .shared/                 # UI/UX 工具数据
└── README.md               # 项目主文档
```

## 构建和运行

### Flutter App
```bash
# Debug 构建
cd flutter_app && flutter build apk --debug

# Release 构建
cd flutter_app && flutter build apk --release

# 运行
cd flutter_app && flutter run
```

### 后端
```bash
# 构建
cd backend-java && mvn clean package

# 启动
java -jar backend-java/target/*.jar
```
