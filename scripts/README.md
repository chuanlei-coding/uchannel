# 构建和启动脚本说明

## 📋 脚本列表

### 后端构建脚本

#### `build-backend.sh` (Linux/Mac)

仅构建后端 JAR 包。

```bash
./scripts/build-backend.sh
```

**输出：** `backend-java/target/*.jar`

### 启动脚本

#### `start-backend.sh` (Linux/Mac)

启动后端服务。

```bash
# 使用默认端口 8080
./scripts/start-backend.sh

# 指定端口
./scripts/start-backend.sh 9090
```

#### `start-backend.bat` (Windows)

Windows 版本的后端启动脚本。

```cmd
REM 使用默认端口 8080
scripts\start-backend.bat

REM 指定端口
scripts\start-backend.bat 9090
```

### 工具脚本

#### `generate-ssl-cert.sh`

生成自签名 SSL 证书用于 HTTPS 开发环境。

```bash
./scripts/generate-ssl-cert.sh
```

**输出位置：** `backend-java/src/main/resources/keystore.p12`

## 📁 构建输出

### 后端

后端构建产物输出到 `backend-java/target/` 目录：

```
backend-java/target/
├── *.jar                 # Spring Boot 可执行 JAR
├── classes/               # 编译后的类文件
└── generated-sources/      # 生成的源代码
```

## 🚀 快速开始

### 1. 构建后端

**Linux/Mac:**
```bash
cd /path/to/uchannel
./scripts/build-backend.sh
```

### 2. 启动后端服务

**Linux/Mac:**
```bash
cd /path/to/uchannel
./scripts/start-backend.sh
```

**Windows:**
```cmd
cd C:\path\to\uchannel
scripts\start-backend.bat
```

服务启动后访问：`http://localhost:8080`

### 3. 运行 Flutter App

```bash
cd flutter_app

# 在设备上运行
flutter run

# 或构建 APK
flutter build apk --release
```

## ⚙️ 环境要求

### 后端构建和运行

- JDK 17+
- Maven 3.6+
- 至少 512MB 可用内存

### Flutter 开发

- Flutter SDK 3.10+
- Dart 3.0+
- Android Studio（Android）或 Xcode（iOS）

## 🔧 配置说明

### 后端构建配置

编辑 `backend-java/pom.xml` 修改：
- 项目版本
- Spring Boot 版本
- 依赖版本

### 后端运行配置

编辑 `backend-java/src/main/resources/application.yml` 修改：
- 服务端口
- Firebase 配置路径
- 日志级别

## 📝 注意事项

1. **首次构建前**：
   - 确保已安装所有依赖（JDK、Maven）
   - 检查网络连接（需要下载 Maven 依赖）

2. **JAR 包**：
   - 构建完成后会在 `backend-java/target/` 目录生成 JAR 文件
   - 使用 `java -jar` 命令运行

3. **启动脚本**：
   - 启动脚本会自动查找 JAR 文件
   - 可以通过环境变量 `SERVER_PORT` 指定端口

## 🐛 常见问题

### Q: Maven 命令未找到？
A: 确保Maven已安装并添加到PATH环境变量。

### Q: Java 版本不兼容？
A: 确保使用 JDK 17 或更高版本。

### Q: JAR 包启动失败？
A: 检查配置文件是否存在，确保路径正确。

### Q: 端口已被占用？
A: 指定其他端口：`./scripts/start-backend.sh 9090`

## 📚 相关文档

- [Maven 使用指南](https://maven.apache.org/guides/)
- [Spring Boot 部署文档](https://spring.io/guides/gs/spring-boot/)
- [Java 17 安装说明](../JAVA17_SETUP.md)
