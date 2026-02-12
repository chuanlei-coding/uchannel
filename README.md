# UChannel - Vita 智能助手

Vita 是一个优雅的个人效率管理应用，帮助你更好地规划和实现目标。

## 项目架构

```
uchannel/
├── flutter_app/              # Flutter 前端应用
├── backend-rust/             # Rust 后端服务
├── scripts/                  # 构建和启动脚本
└── README.md                 # 项目说明
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

- **聊天服务** - 支持 AI 对话（通义千问）
- **任务管理** - 完整的 CRUD 操作
- **统计分析** - 任务统计和热力图

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
- Rust 1.70+ (安装: https://rustup.rs)
- SQLite3

**启动服务：**

```bash
# 使用脚本启动（推荐）
./scripts/start-backend.sh

# 或手动启动
cd backend-rust
cargo run
```

服务默认运行在 `http://localhost:8080`

## 技术栈

**前端：**
- Flutter 3.10+
- Dart 3.0+
- go_router（导航）
- Dio（HTTP 客户端）

**后端：**
- Rust (Axum web framework)
- SQLite (SQLx)
- Tokio (异步运行时)
- 通义千问 API

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
```

### 后端开发

```bash
cd backend-rust

# 编译项目
cargo build

# 运行测试
cargo test

# 构建发布版本
cargo build --release
```

## 脚本说明

| 脚本 | 说明 |
|------|------|
| `build-backend.sh` | 构建后端二进制文件 |
| `start-backend.sh` | 启动后端服务 |
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
backend-rust/target/
├── debug/uchannel-backend     # Debug 版本
└── release/uchannel-backend   # Release 版本
```

## 清理历史

项目已于 **2026-01-27** 从 React Native 重构为 Flutter，**2026-02-12** 从 Java Spring Boot 重构为 Rust。

详细的清理说明：[CLEANUP_NOTES.md](CLEANUP_NOTES.md)

## 许可证

MIT License

## 联系方式

如有问题或建议，欢迎提交 Issue。
