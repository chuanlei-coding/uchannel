# Vita Flutter App

Vita 是一个优雅的个人效率管理应用，采用 Flutter 跨平台框架开发。

## 项目概览

### 功能模块

- **Splash Screen** - 品牌启动页，优雅的动画效果
- **Chat Screen** - AI 智能对话助手
- **Schedule Screen** - 任务日程管理，支持智能拆解
- **Discover Screen** - 内容探索和发现
- **Stats Screen** - 数据统计和洞察
- **Settings Screen** - 个性化设置
- **Add Todo Screen** - 创建新待办事项

### 设计特色

- **柔和配色** - 鼠尾草绿、水鸭青色、温暖米色
- **优雅字体** - Newsreader 衬线字体 + 系统字体
- **圆角设计** - 大圆角营造柔和感
- **微妙动画** - 流畅的过渡和微交互
- **毛玻璃效果** - iOS 风格的背景模糊

## 技术栈

- **Flutter** 3.10+
- **Dart** 3.0+
- **go_router** 14.0+ - 路由管理
- **dio** 5.4+ - 网络请求
- **shared_preferences** 2.2+ - 本地存储
- **flutter_svg** 2.0+ - SVG 图标
- **provider** 6.1+ - 状态管理
- **flutter_animate** 4.5+ - 动画库
- **google_fonts** 6.1+ - Google 字体

## 快速开始

### 环境要求

- Flutter SDK 3.10+
- Dart 3.0+
- Android Studio（Android）或 Xcode（iOS）
- Android SDK 34+
- iOS SDK 12+

### 安装依赖

```bash
flutter pub get
```

### 运行应用

```bash
# 在连接的设备上运行
flutter run

# 指定设备
flutter run -d <device-id>

# 查看所有可用设备
flutter devices
```

### 热重载

开发时使用热重载加速开发：

- **热重载**：按 `r` 键 - 保留应用状态
- **热重启**：按 `R` 键 - 完全重启应用
- **退出**：按 `q` 键

## 项目结构

```
flutter_app/
├── lib/
│   ├── main.dart              # 应用入口和路由配置
│   ├── models/               # 数据模型
│   │   ├── message.dart
│   │   └── task.dart
│   ├── screens/              # 页面组件
│   │   ├── splash_screen.dart
│   │   ├── chat_screen.dart
│   │   ├── schedule_screen.dart
│   │   ├── discover_screen.dart
│   │   ├── stats_screen.dart
│   │   ├── settings_screen.dart
│   │   └── add_todo_screen.dart
│   ├── services/             # 服务层
│   │   └── api_service.dart
│   ├── theme/                # 主题配置
│   │   ├── app_theme.dart
│   │   └── colors.dart
│   └── widgets/              # 可复用组件
│       ├── message_item.dart
│       └── task_card.dart
├── android/                 # Android 平台代码
├── ios/                     # iOS 平台代码（如需）
├── pubspec.yaml             # 依赖配置
├── analysis_options.yaml     # 代码分析配置
└── test/                   # 测试代码
```

## 构建

### Debug 版本

```bash
flutter build apk --debug
```

输出：`build/app/outputs/flutter-apk/app-debug.apk`

### Release 版本

```bash
flutter build apk --release
```

输出：`build/app/outputs/flutter-apk/app-release.apk`

**Release 版本优化：**
- AOT 编译
- 代码混淆
- 死代码消除
- 资源压缩
- 字体树摇（减少 99%+ 字体大小）

### 其他构建选项

```bash
# Android App Bundle（推荐用于发布到 Play Store）
flutter build appbundle

# iOS 应用（仅 macOS）
flutter build ios

# 分析 APK 大小
flutter build apk --analyze-size
```

## 路由配置

应用使用 `go_router` 进行路由管理：

| 路径 | 页面 | 说明 |
|-------|-------|-------|
| `/` | Splash Screen | 启动页 |
| `/chat` | Chat Screen | AI 助手 |
| `/schedule` | Schedule Screen | 日程管理 |
| `/schedule/add` | Add Todo | 创建待办 |
| `/discover` | Discover Screen | 发现页面 |
| `/stats` | Stats Screen | 统计页面 |
| `/settings` | Settings Screen | 设置页面 |

## 主题和样式

### 颜色方案

定义在 `lib/theme/colors.dart`：

- `brandSage` - 鼠尾草绿 (#9DC695)
- `brandTeal` - 水鸭青色 (#7DA89E)
- `creamBg` - 温暖米色背景 (#FDFBF7)
- `warmCream` - 暖奶油色 (#FDFAF5)
- `darkGrey` - 深灰色文字 (#3A3A3A)

### 字体

- **Newsreader** - 衬线字体，用于标题和品牌展示
- **系统字体** - UI 文本使用系统字体

## 开发指南

### 代码分析

```bash
# 运行静态分析
flutter analyze

# 格式化代码
flutter format .
```

### 运行测试

```bash
# 运行单元测试
flutter test

# 运行集成测试
flutter test integration_test/
```

### 添加新页面

1. 在 `lib/screens/` 创建新页面文件
2. 在 `lib/main.dart` 的路由配置中添加路由
3. 使用一致的设计风格和主题

### 状态管理

当前使用 `Provider` 进行状态管理。未来可考虑：

- **Riverpod** - 更现代的状态管理
- **Bloc** - 复杂应用场景

## 常见问题

### Q: Flutter doctor 显示问题？
A: 按照提示安装缺失的依赖，如 Android SDK、Xcode 等。

### Q: 构建失败？
A:
```bash
flutter clean
flutter pub get
flutter build apk
```

### Q: 字体显示不正确？
A: 确保在 `pubspec.yaml` 中正确配置了 `google_fonts`。

### Q: 路由跳转失败？
A: 确保在 `GoRouter` 配置中添加了路由路径。

## 发布

### Android

1. 构建 Release 版本
2. 签名 APK（如需直接分发）
3. 或构建 App Bundle 上传到 Play Store

### iOS

1. 构建 iOS 应用
2. 在 Xcode 中配置签名和证书
3. 上传到 App Store Connect

## 许可证

MIT License
