# 构建指南

## 📋 前置要求

### 后端构建要求

1. **JDK 17或更高版本**
   ```bash
   # macOS
   brew install openjdk@17
   
   # Linux (Ubuntu/Debian)
   sudo apt install openjdk-17-jdk
   
   # 验证安装
   java -version
   ```

2. **Maven 3.6+**
   ```bash
   # macOS
   brew install maven
   
   # Linux (Ubuntu/Debian)
   sudo apt install maven
   
   # 验证安装
   mvn -version
   ```

### Android构建要求

1. **JDK 17或更高版本**（同上）

2. **Android SDK**
   - 安装Android Studio
   - 或手动安装Android SDK

3. **Gradle Wrapper**（推荐）
   ```bash
   cd android
   gradle wrapper
   ```

   或者安装Gradle：
   ```bash
   # macOS
   brew install gradle
   
   # Linux
   sudo apt install gradle
   ```

## 🚀 构建步骤

### 方式一：完整构建（推荐）

```bash
./scripts/build.sh
```

这会同时构建：
- Android APK
- 后端JAR包
- 生成启动脚本

### 方式二：分别构建

#### 仅构建后端

```bash
./scripts/build-backend.sh
```

#### 仅构建Android

```bash
./scripts/build-android.sh [release|debug]
```

## ⚠️ 常见问题

### Q: Maven未找到？
A: 请先安装Maven，参考上面的安装步骤。

### Q: Gradle wrapper不存在？
A: 在android目录下运行 `gradle wrapper` 初始化。

### Q: Java版本不兼容？
A: 确保使用JDK 17或更高版本。

### Q: 构建失败？
A: 
1. 检查所有依赖是否已安装
2. 检查网络连接（需要下载依赖）
3. 查看错误日志

## 📦 构建输出

构建成功后，所有文件将输出到 `build/` 目录：

```
build/
├── apk/                          # Android APK
│   └── uchannel-release-*.apk
├── jar/                          # 后端JAR包
│   ├── push-notification-service-*.jar
│   └── push-notification-service-latest.jar
└── scripts/                      # 启动脚本
    ├── start-backend.sh
    └── start-backend.bat
```

