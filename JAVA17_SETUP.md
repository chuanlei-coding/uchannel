# Java 17 环境配置完成

## ✅ 已完成的配置

1. **安装Java 17**: `openjdk@17` 已通过Homebrew安装
2. **更新PATH**: 已添加到 `~/.zshrc`
3. **设置JAVA_HOME**: 已添加到 `~/.zshrc`

## 📝 验证配置

重新加载配置后，运行：

```bash
source ~/.zshrc
java -version
```

应该显示：
```
openjdk version "17.0.17" 2025-10-21
OpenJDK Runtime Environment Homebrew (build 17.0.17+0)
OpenJDK 64-Bit Server VM Homebrew (build 17.0.17+0, mixed mode, sharing)
```

## 🔧 当前构建状态

### ✅ 后端服务
- **状态**: 构建成功
- **JAR文件**: `build/jar/push-notification-service-latest.jar` (67MB)
- **Java版本**: 已切换到Java 17

### ⚠️ Android应用
- **状态**: 需要配置Android SDK
- **问题**: 缺少Android SDK路径配置
- **解决方案**: 见下方

## 📱 Android SDK配置

### 方法1: 安装Android Studio（推荐）

1. 下载并安装 [Android Studio](https://developer.android.com/studio)
2. 打开Android Studio，它会自动下载和配置SDK
3. SDK通常安装在: `~/Library/Android/sdk`
4. 配置local.properties:
   ```bash
   echo "sdk.dir=$HOME/Library/Android/sdk" > android/local.properties
   ```

### 方法2: 手动配置SDK路径

如果您已经安装了Android SDK，编辑 `android/local.properties`:

```properties
sdk.dir=/path/to/your/android/sdk
```

### 方法3: 使用环境变量

```bash
export ANDROID_HOME=~/Library/Android/sdk
export PATH=$PATH:$ANDROID_HOME/tools:$ANDROID_HOME/platform-tools
```

## 🚀 重新构建

配置好Android SDK后，运行：

```bash
# 确保使用Java 17
export PATH="/opt/homebrew/opt/openjdk@17/bin:$PATH"
export JAVA_HOME="/opt/homebrew/opt/openjdk@17/libexec/openjdk.jdk/Contents/Home"

# 重新构建
./scripts/build.sh
```

## 📝 注意事项

1. **重新加载配置**: 新打开的终端会自动使用Java 17
2. **当前终端**: 需要运行 `source ~/.zshrc` 或手动设置环境变量
3. **系统Java**: 如果需要系统级Java切换，需要管理员权限创建符号链接

## 🔗 相关文件

- Java配置: `~/.zshrc`
- Android SDK配置: `android/local.properties`
- Gradle配置: `android/gradle/wrapper/gradle-wrapper.properties`

