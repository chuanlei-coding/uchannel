# HTTPS配置说明

## 📋 概述

已配置后端服务使用HTTPS通信，Android应用也已更新为使用HTTPS。

## 🔐 后端HTTPS配置

### 1. SSL证书

- **证书位置**: `backend-java/src/main/resources/keystore.p12`
- **证书类型**: 自签名证书（开发环境）
- **有效期**: 365天
- **密码**: `changeit`
- **别名**: `uchannel`

### 2. 生成证书

```bash
./scripts/generate-ssl-cert.sh
```

### 3. 后端配置

- **端口**: 8443 (HTTPS)
- **配置文件**: `backend-java/src/main/resources/application.yml`

```yaml
server:
  port: 8443
  ssl:
    enabled: true
    key-store: classpath:keystore.p12
    key-store-password: changeit
    key-store-type: PKCS12
    key-alias: uchannel
```

## 📱 Android应用HTTPS配置

### 1. API地址

- **HTTPS地址**: `https://10.0.2.2:8443/`
- **配置位置**: `android/app/src/main/java/com/uchannel/api/ApiClient.kt`

### 2. 自签名证书信任

Android应用已配置为信任自签名证书（仅开发环境）：

- 使用自定义 `X509TrustManager` 信任所有证书
- 使用自定义 `HostnameVerifier` 信任所有主机名
- 配置网络安全策略允许用户证书

### 3. 网络安全配置

- **文件**: `android/app/src/main/res/xml/network_security_config.xml`
- 信任系统证书和用户证书
- 已移除HTTP明文通信支持

## 🚀 使用步骤

### 1. 生成SSL证书（如果还没有）

```bash
cd /Users/chuanlei/code/uchannel
./scripts/generate-ssl-cert.sh
```

### 2. 重启后端服务

```bash
cd backend-java
mvn spring-boot:run
```

后端将在 `https://localhost:8443` 启动。

### 3. 重新构建Android应用

```bash
cd android
./gradlew installDebug
```

或使用构建脚本：

```bash
./scripts/build-android.sh debug
```

### 4. 测试HTTPS连接

在Android应用中测试聊天功能，应该可以正常连接HTTPS后端。

## ⚠️ 注意事项

### 开发环境

- ✅ 使用自签名证书
- ✅ Android应用信任所有证书（仅开发环境）
- ✅ 端口：8443

### 生产环境

- ⚠️ **必须使用CA签发的证书**
- ⚠️ **移除信任所有证书的代码**
- ⚠️ **使用标准的HTTPS端口443**
- ⚠️ **配置正确的域名和证书**

## 🔧 生产环境配置

### 1. 获取CA证书

从CA（如Let's Encrypt）获取证书，或使用企业证书。

### 2. 更新后端配置

```yaml
server:
  port: 443
  ssl:
    enabled: true
    key-store: /path/to/your/certificate.p12
    key-store-password: your-password
    key-store-type: PKCS12
    key-alias: your-alias
```

### 3. 更新Android应用

移除 `ApiClient.kt` 中的信任所有证书代码，使用系统默认的证书验证：

```kotlin
private val okHttpClient: OkHttpClient = OkHttpClient.Builder()
    .addInterceptor(loggingInterceptor)
    .build()
```

## 📝 证书信息

查看证书信息：

```bash
keytool -list -v -keystore backend-java/src/main/resources/keystore.p12 -storepass changeit
```

## 🔍 故障排查

### 问题：Android应用无法连接

1. 检查后端服务是否运行在8443端口
2. 检查证书是否正确生成
3. 查看logcat日志中的SSL错误

### 问题：证书验证失败

- 确保Android应用配置了信任用户证书
- 检查网络安全配置文件是否正确

### 问题：端口不可达

- 模拟器使用 `10.0.2.2:8443`
- 真机使用电脑IP地址: `https://<your-ip>:8443`

## 📚 相关文件

- `backend-java/src/main/resources/application.yml` - 后端HTTPS配置
- `backend-java/src/main/resources/keystore.p12` - SSL证书
- `android/app/src/main/java/com/uchannel/api/ApiClient.kt` - Android HTTPS客户端
- `android/app/src/main/res/xml/network_security_config.xml` - 网络安全配置
