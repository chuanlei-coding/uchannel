# 构建和启动脚本说明

## 脚本列表

### 后端构建脚本

#### `build-backend.sh` (Linux/Mac)

构建 Rust 后端二进制文件。

```bash
./scripts/build-backend.sh
```

**输出：** `build/bin/uchannel-backend`

### 启动脚本

#### `start-backend.sh` (Linux/Mac)

启动后端服务。

```bash
# 使用默认端口 8080
./scripts/start-backend.sh

# 指定端口
./scripts/start-backend.sh 9090
```

### 工具脚本

#### `generate-ssl-cert.sh`

生成自签名 SSL 证书用于 HTTPS 开发环境。

```bash
./scripts/generate-ssl-cert.sh
```

## 构建输出

### 后端

后端构建产物输出到 `build/bin/` 目录：

```
build/bin/
└── uchannel-backend      # Rust 可执行文件
```

## 快速开始

### 1. 构建后端

```bash
cd /path/to/uchannel
./scripts/build-backend.sh
```

### 2. 启动后端服务

```bash
cd /path/to/uchannel
./scripts/start-backend.sh
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

## 环境要求

### 后端构建和运行

- Rust 1.70+ (安装: https://rustup.rs)
- SQLite3

### Flutter 开发

- Flutter SDK 3.10+
- Dart 3.0+
- Android Studio（Android）或 Xcode（iOS）

## 配置说明

### 后端配置

编辑 `backend-rust/.env` 修改：
- 服务端口
- 数据库路径
- 通义千问 API Key

## 常见问题

### Q: Cargo 命令未找到？
A: 运行 `curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh` 安装 Rust。

### Q: 数据库错误？
A: 确保 `backend-rust/data/` 目录存在且有写入权限。

### Q: 端口已被占用？
A: 指定其他端口：`./scripts/start-backend.sh 9090`

## 相关文档

- [Rust 安装指南](https://www.rust-lang.org/tools/install)
- [Axum Web Framework](https://github.com/tokio-rs/axum)
