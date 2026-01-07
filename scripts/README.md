# 构建和启动脚本说明

## 📋 脚本列表

### 完整构建脚本

#### `build.sh` (Linux/Mac)
同时构建Android APK和后端JAR包，并生成启动脚本。

```bash
# 构建Release版本（默认）
./scripts/build.sh

# 构建Debug版本
./scripts/build.sh debug
```

#### `build.bat` (Windows)
Windows版本的完整构建脚本。

```cmd
REM 构建Release版本（默认）
scripts\build.bat

REM 构建Debug版本
scripts\build.bat debug
```

### 单独构建脚本

#### `build-android.sh` (Linux/Mac)
仅构建Android APK。

```bash
# 构建Release APK
./scripts/build-android.sh release

# 构建Debug APK
./scripts/build-android.sh debug
```

#### `build-backend.sh` (Linux/Mac)
仅构建后端JAR包。

```bash
./scripts/build-backend.sh
```

### 启动脚本

#### `start-backend.sh` (Linux/Mac)
启动后端服务。

```bash
# 使用默认端口8080
./scripts/start-backend.sh

# 指定端口
./scripts/start-backend.sh 9090
```

#### `start-backend.bat` (Windows)
Windows版本的后端启动脚本。

```cmd
REM 使用默认端口8080
scripts\start-backend.bat

REM 指定端口
scripts\start-backend.bat 9090
```

## 📁 构建输出

所有构建产物将输出到 `build/` 目录：

```
build/
├── apk/                          # Android APK文件
│   └── uchannel-release-*.apk
├── jar/                          # 后端JAR包
│   ├── push-notification-service-*.jar
│   └── push-notification-service-latest.jar  # 最新版本符号链接
├── scripts/                      # 启动脚本
│   ├── start-backend.sh
│   └── start-backend.bat
└── DEPLOY.md                     # 部署说明文档
```

## 🚀 快速开始

### 1. 完整构建（推荐）

**Linux/Mac:**
```bash
cd /path/to/uchannel
./scripts/build.sh
```

**Windows:**
```cmd
cd C:\path\to\uchannel
scripts\build.bat
```

### 2. 启动后端服务

**Linux/Mac:**
```bash
cd build/scripts
./start-backend.sh
```

**Windows:**
```cmd
cd build\scripts
start-backend.bat
```

### 3. 安装APK

```bash
# 使用ADB安装
adb install build/apk/uchannel-release-*.apk

# 或直接传输到设备安装
```

## ⚙️ 环境要求

### Android构建
- JDK 17+
- Android SDK
- Gradle 8.2+

### 后端构建
- JDK 17+
- Maven 3.6+

### 运行后端
- JDK 17+
- 至少512MB可用内存
- Firebase服务账号密钥文件

## 🔧 配置说明

### Android构建配置

编辑 `android/app/build.gradle` 修改：
- 应用ID (`applicationId`)
- 版本号 (`versionCode`, `versionName`)
- 最低SDK版本 (`minSdk`)
- 目标SDK版本 (`targetSdk`)

### 后端构建配置

编辑 `backend-java/pom.xml` 修改：
- 项目版本
- Spring Boot版本
- 依赖版本

### 后端运行配置

编辑 `backend-java/src/main/resources/application.yml` 修改：
- 服务端口
- Firebase配置路径
- 日志级别

## 📝 注意事项

1. **首次构建前**：
   - 确保已安装所有依赖
   - Android项目需要先运行 `gradle wrapper` 初始化Gradle wrapper
   - 确保已配置Firebase服务账号密钥

2. **APK签名**：
   - Debug版本使用默认签名
   - Release版本需要配置正式签名（编辑 `android/app/build.gradle`）

3. **JAR包**：
   - 构建完成后会在 `build/jar/` 目录生成带时间戳的JAR文件
   - 同时会创建 `push-notification-service-latest.jar` 符号链接指向最新版本

4. **启动脚本**：
   - 启动脚本会自动查找JAR文件
   - 如果build目录下没有，会尝试从target目录查找
   - 可以通过环境变量 `SERVER_PORT` 指定端口

## 🐛 常见问题

### Q: Gradle wrapper不存在？
A: 在android目录下运行 `gradle wrapper` 初始化。

### Q: Maven命令未找到？
A: 确保Maven已安装并添加到PATH环境变量。

### Q: Java版本不兼容？
A: 确保使用JDK 17或更高版本。

### Q: APK构建失败？
A: 检查Android SDK是否正确配置，确保 `local.properties` 文件存在。

### Q: JAR包启动失败？
A: 检查Firebase配置文件是否存在，确保路径正确。

## 📚 相关文档

- [Android构建文档](https://developer.android.com/studio/build)
- [Spring Boot部署文档](https://spring.io/guides/gs/spring-boot/)
- [Maven使用指南](https://maven.apache.org/guides/)

