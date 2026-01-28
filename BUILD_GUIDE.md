# 构建指南

## 项目概述

UChannel 由 Flutter 前端应用和 Java Spring Boot 后端服务组成。

**技术栈：**
- 前端：Flutter 3.10+、Dart 3.0+
- 后端：Java 17、Spring Boot、H2 Database

## 📋 前置要求

### Flutter 开发

**安装 Flutter：**
```bash
# macOS
brew install --cask flutter

# Linux
# 下载 Flutter SDK 并添加到 PATH

# 验证安装
flutter doctor
```

**必要组件：**
- Flutter SDK 3.10+
- Dart 3.0+
- Android Studio（Android 开发）或 Xcode（iOS 开发）
- Android SDK 34+
- iOS SDK 12+

### 后端构建

**1. JDK 17 或更高版本**
```bash
# macOS
brew install openjdk@17

# Linux (Ubuntu/Debian)
sudo apt install openjdk-17-jdk

# 验证安装
java -version
```

**2. Maven 3.6+**
```bash
# macOS
brew install maven

# Linux (Ubuntu/Debian)
sudo apt install maven

# 验证安装
mvn -version
```

## 🚀 构建步骤

### Flutter App 构建

#### Debug 版本（开发用）

```bash
cd flutter_app
flutter build apk --debug
```

**输出：** `flutter_app/build/app/outputs/flutter-apk/app-debug.apk`

#### Release 版本（生产用）

```bash
cd flutter_app
flutter build apk --release
```

**输出：** `flutter_app/build/app/outputs/flutter-apk/app-release.apk`

**优化：**
- 代码混淆和优化
- 字体树摇（Font Tree-shaking）
- 移除调试符号

#### 构建选项

```bash
# 构建 Android APK（默认）
flutter build apk

# 构建 Android App Bundle（推荐用于发布到 Play Store）
flutter build appbundle

# 构建 iOS 应用（仅 macOS）
flutter build ios

# 指定构建模式
flutter build apk --debug
flutter build apk --release
```

### 后端构建

#### 使用脚本（推荐）

```bash
./scripts/build-backend.sh
```

#### 手动构建

```bash
cd backend-java

# 清理并编译
mvn clean compile

# 打包为 JAR
mvn package

# 跳过测试打包
mvn package -DskipTests
```

**输出：** `backend-java/target/*.jar`

## ▶️ 运行应用

### Flutter App

#### 在模拟器/设备上运行

```bash
cd flutter_app
flutter run

# 指定设备
flutter run -d <device-id>

# 查看可用设备
flutter devices
```

#### 热重载和热重启

开发时使用热重载加速开发：

- **热重载**：按 `r` 键 - 保留应用状态，快速应用更改
- **热重启**：按 `R` 键 - 完全重启应用
- **退出**：按 `q` 键

### 后端服务

#### 使用脚本启动

```bash
# 默认端口 8080
./scripts/start-backend.sh

# 指定端口
./scripts/start-backend.sh 9090
```

#### 手动启动

```bash
cd backend-java

# 使用 Maven 运行
mvn spring-boot:run

# 或运行打包后的 JAR
java -jar target/*.jar

# 指定端口
java -jar target/*.jar --server.port=9090
```

服务启动后访问：`http://localhost:8080`

## ⚠️ 常见问题

### Flutter 构建

**Q: Flutter SDK 未找到？**
A: 确保 Flutter 已添加到 PATH，运行 `flutter doctor` 检查。

**Q: Android SDK 配置错误？**
A: 打开 Android Studio，安装必要的 SDK，接受许可证。

**Q: 构建失败，提示 Gradle 错误？**
A:
```bash
cd flutter_app/android
./gradlew clean
cd ..
flutter clean
flutter pub get
flutter build apk
```

**Q: iOS 构建失败？**
A: 确保在 macOS 上运行，安装 Xcode 和 CocoaPods。

### 后端构建

**Q: Maven 未找到？**
A: 安装 Maven：`brew install maven`（macOS）

**Q: Java 版本不兼容？**
A: 确保使用 JDK 17 或更高版本：`java -version`

**Q: 依赖下载失败？**
A: 检查网络连接，或配置 Maven 镜像源。

**Q: 构建成功但运行失败？**
A: 检查配置文件（`application.yml`）和 Firebase 密钥文件。

## 📦 构建输出

### Flutter App

```
flutter_app/build/app/outputs/flutter-apk/
├── app-debug.apk          # Debug 版本
├── app-release.apk        # Release 版本
└── app-release-*.apk      # 带版本号
```

### 后端

```
backend-java/target/
├── *.jar                 # Spring Boot 可执行 JAR
├── classes/               # 编译后的类文件
└── generated-sources/      # 生成的源代码
```

## 🔧 配置说明

### Flutter 配置

编辑 `flutter_app/pubspec.yaml`：
- 应用名称和版本
- 依赖包
- 资源文件

编辑 `flutter_app/android/app/build.gradle.kts`：
- 应用 ID（`applicationId`）
- 版本号（`versionCode`, `versionName`）
- SDK 版本（`minSdk`, `targetSdk`）

### 后端配置

编辑 `backend-java/src/main/resources/application.yml`：
- 服务端口
- 数据库配置
- Firebase 配置

## 📊 性能优化

### Flutter Release 版本优化

Flutter 的 `--release` 模式自动包含：

- AOT 编译
- 代码混淆
- 死代码消除
- 资源压缩
- 字体树摇

### APK 大小优化

```bash
# 分析 APK 大小
flutter build apk --analyze-size

# 使用 ProGuard（Android）
flutter build apk --obfuscate --split-debug-info=./debug-info.json
```

## 📱 发布到应用商店

### Google Play Store

1. 构建 App Bundle：
```bash
flutter build appbundle --release
```

2. 上传到 Play Console：
- 文件位置：`build/app/outputs/bundle/release/app-release.aab`
- 创建应用和发布清单
- 填写商店信息

### Apple App Store

1. 构建 iOS 应用：
```bash
flutter build ios --release
```

2. 使用 Xcode 上传：
- 打开 `ios/Runner.xcworkspace`
- 选择 Product > Archive
- 上传到 App Store Connect

## 📚 更多资源

- [Flutter 官方文档](https://docs.flutter.dev/)
- [Flutter 构建指南](https://docs.flutter.dev/deployment/android)
- [Spring Boot 文档](https://spring.io/guides/gs/spring-boot/)
- [Maven 指南](https://maven.apache.org/guides/)
