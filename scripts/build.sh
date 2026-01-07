#!/bin/bash

# 打包脚本 - 同时生成APK和后端JAR包
# 使用方法: ./scripts/build.sh [release|debug]

set -e  # 遇到错误立即退出

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 项目根目录
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BUILD_TYPE="${1:-release}"
BUILD_DIR="${PROJECT_ROOT}/build"
APK_OUTPUT_DIR="${BUILD_DIR}/apk"
JAR_OUTPUT_DIR="${BUILD_DIR}/jar"
SCRIPTS_OUTPUT_DIR="${BUILD_DIR}/scripts"

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}开始构建项目${NC}"
echo -e "${GREEN}构建类型: ${BUILD_TYPE}${NC}"
echo -e "${GREEN}========================================${NC}"

# 创建输出目录
mkdir -p "${APK_OUTPUT_DIR}"
mkdir -p "${JAR_OUTPUT_DIR}"
mkdir -p "${SCRIPTS_OUTPUT_DIR}"

# ==================== 构建Android APK ====================
echo -e "\n${YELLOW}[1/3] 构建Android APK...${NC}"
cd "${PROJECT_ROOT}/android"

# 检查Gradle wrapper是否存在
if [ ! -f "./gradlew" ]; then
    echo -e "${YELLOW}Gradle wrapper不存在，正在初始化...${NC}"
    echo -e "${RED}错误: 请先运行 'gradle wrapper' 初始化Gradle wrapper${NC}"
    echo -e "${YELLOW}跳过Android构建，继续构建后端...${NC}"
    SKIP_ANDROID=true
else
    # 检查Android SDK是否配置
    if [ ! -f "local.properties" ] || ! grep -q "^sdk.dir=" local.properties 2>/dev/null; then
        echo -e "${YELLOW}警告: Android SDK未配置${NC}"
        echo -e "${YELLOW}请配置 android/local.properties 文件，设置 sdk.dir 路径${NC}"
        echo -e "${YELLOW}跳过Android构建，继续构建后端...${NC}"
        SKIP_ANDROID=true
    else
        SKIP_ANDROID=false
    fi
fi

if [ "$SKIP_ANDROID" != "true" ]; then
    # 赋予执行权限
    chmod +x ./gradlew

    # 清理并构建APK
    if [ "$BUILD_TYPE" = "release" ]; then
        echo "构建Release APK..."
        if ./gradlew clean assembleRelease 2>&1; then
            APK_FILE=$(find app/build/outputs/apk/release -name "*.apk" | head -n 1)
            if [ -n "$APK_FILE" ] && [ -f "$APK_FILE" ]; then
                # 复制APK到输出目录
                APK_NAME="uchannel-${BUILD_TYPE}-$(date +%Y%m%d-%H%M%S).apk"
                cp "$APK_FILE" "${APK_OUTPUT_DIR}/${APK_NAME}"
                echo -e "${GREEN}✓ APK构建成功: ${APK_OUTPUT_DIR}/${APK_NAME}${NC}"
            else
                echo -e "${YELLOW}APK文件未找到，跳过Android构建${NC}"
                SKIP_ANDROID=true
            fi
        else
            echo -e "${YELLOW}Android构建失败，继续构建后端...${NC}"
            SKIP_ANDROID=true
        fi
    else
        echo "构建Debug APK..."
        if ./gradlew clean assembleDebug 2>&1; then
            APK_FILE=$(find app/build/outputs/apk/debug -name "*.apk" | head -n 1)
            if [ -n "$APK_FILE" ] && [ -f "$APK_FILE" ]; then
                # 复制APK到输出目录
                APK_NAME="uchannel-${BUILD_TYPE}-$(date +%Y%m%d-%H%M%S).apk"
                cp "$APK_FILE" "${APK_OUTPUT_DIR}/${APK_NAME}"
                echo -e "${GREEN}✓ APK构建成功: ${APK_OUTPUT_DIR}/${APK_NAME}${NC}"
            else
                echo -e "${YELLOW}APK文件未找到，跳过Android构建${NC}"
                SKIP_ANDROID=true
            fi
        else
            echo -e "${YELLOW}Android构建失败，继续构建后端...${NC}"
            SKIP_ANDROID=true
        fi
    fi
else
    echo -e "${YELLOW}Android构建已跳过${NC}"
fi

# ==================== 构建后端JAR包 ====================
echo -e "\n${YELLOW}[2/3] 构建后端JAR包...${NC}"
cd "${PROJECT_ROOT}/backend-java"

# 检查Maven是否存在
if ! command -v mvn &> /dev/null; then
    echo -e "${RED}错误: Maven未安装，请先安装Maven${NC}"
    exit 1
fi

# 清理并打包
mvn clean package -DskipTests

JAR_FILE=$(find target -name "*.jar" ! -name "*-sources.jar" ! -name "*-javadoc.jar" | head -n 1)

if [ -z "$JAR_FILE" ] || [ ! -f "$JAR_FILE" ]; then
    echo -e "${RED}错误: JAR文件未找到${NC}"
    exit 1
fi

# 复制JAR到输出目录
JAR_NAME="push-notification-service-$(date +%Y%m%d-%H%M%S).jar"
cp "$JAR_FILE" "${JAR_OUTPUT_DIR}/${JAR_NAME}"
echo -e "${GREEN}✓ JAR构建成功: ${JAR_OUTPUT_DIR}/${JAR_NAME}${NC}"

# 创建最新版本的符号链接
ln -sf "${JAR_NAME}" "${JAR_OUTPUT_DIR}/push-notification-service-latest.jar"

# ==================== 生成启动脚本 ====================
echo -e "\n${YELLOW}[3/3] 生成启动脚本...${NC}"

# 生成Linux/Mac启动脚本
cat > "${SCRIPTS_OUTPUT_DIR}/start-backend.sh" << 'EOF'
#!/bin/bash
# 后端服务启动脚本

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
JAR_DIR="${SCRIPT_DIR}/../jar"
JAR_FILE="${JAR_DIR}/push-notification-service-latest.jar"

if [ ! -f "$JAR_FILE" ]; then
    echo "错误: JAR文件未找到: $JAR_FILE"
    echo "请先运行构建脚本生成JAR包"
    exit 1
fi

# 检查Java是否安装
if ! command -v java &> /dev/null; then
    echo "错误: Java未安装，请先安装JDK 17或更高版本"
    exit 1
fi

# 启动参数
JAVA_OPTS="-Xms512m -Xmx1024m -Dspring.profiles.active=prod"
SERVER_PORT="${SERVER_PORT:-8080}"

echo "启动推送通知服务..."
echo "JAR文件: $JAR_FILE"
echo "端口: $SERVER_PORT"
echo "Java选项: $JAVA_OPTS"
echo ""

java $JAVA_OPTS -jar "$JAR_FILE" --server.port=$SERVER_PORT
EOF

# 生成Windows启动脚本
cat > "${SCRIPTS_OUTPUT_DIR}/start-backend.bat" << 'EOF'
@echo off
REM 后端服务启动脚本 (Windows)

set SCRIPT_DIR=%~dp0
set JAR_DIR=%SCRIPT_DIR%..\jar
set JAR_FILE=%JAR_DIR%\push-notification-service-latest.jar

if not exist "%JAR_FILE%" (
    echo 错误: JAR文件未找到: %JAR_FILE%
    echo 请先运行构建脚本生成JAR包
    exit /b 1
)

REM 检查Java是否安装
where java >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo 错误: Java未安装，请先安装JDK 17或更高版本
    exit /b 1
)

REM 启动参数
set JAVA_OPTS=-Xms512m -Xmx1024m -Dspring.profiles.active=prod
set SERVER_PORT=%SERVER_PORT%
if "%SERVER_PORT%"=="" set SERVER_PORT=8080

echo 启动推送通知服务...
echo JAR文件: %JAR_FILE%
echo 端口: %SERVER_PORT%
echo Java选项: %JAVA_OPTS%
echo.

java %JAVA_OPTS% -jar "%JAR_FILE%" --server.port=%SERVER_PORT%
EOF

# 赋予执行权限
chmod +x "${SCRIPTS_OUTPUT_DIR}/start-backend.sh"

echo -e "${GREEN}✓ 启动脚本生成成功${NC}"
echo -e "  - Linux/Mac: ${SCRIPTS_OUTPUT_DIR}/start-backend.sh"
echo -e "  - Windows: ${SCRIPTS_OUTPUT_DIR}/start-backend.bat"

# ==================== 生成部署说明 ====================
cat > "${BUILD_DIR}/DEPLOY.md" << EOF
# 部署说明

## 构建信息
- 构建时间: $(date)
- 构建类型: ${BUILD_TYPE}
- APK文件: ${APK_NAME}
- JAR文件: ${JAR_NAME}

## Android APK安装

### 方法1: ADB安装
\`\`\`bash
adb install ${APK_OUTPUT_DIR}/${APK_NAME}
\`\`\`

### 方法2: 直接安装
将APK文件传输到Android设备，然后在设备上打开安装。

## 后端服务启动

### Linux/Mac
\`\`\`bash
cd ${SCRIPTS_OUTPUT_DIR}
./start-backend.sh
\`\`\`

### Windows
\`\`\`cmd
cd ${SCRIPTS_OUTPUT_DIR}
start-backend.bat
\`\`\`

### 自定义端口
\`\`\`bash
SERVER_PORT=9090 ./start-backend.sh
\`\`\`

## 配置文件

后端服务需要以下配置文件：
- \`serviceAccountKey.json\`: Firebase服务账号密钥
  - 位置: \`backend-java/src/main/resources/serviceAccountKey.json\`
  - 或通过环境变量指定路径

## 环境要求

### Android
- Android 7.0 (API 24) 或更高版本

### 后端
- JDK 17 或更高版本
- 至少 512MB 可用内存

## 验证

### 检查后端服务
\`\`\`bash
curl http://localhost:8080/actuator/health
\`\`\`

### 测试推送API
\`\`\`bash
curl -X POST http://localhost:8080/api/push/register-token \\
  -H "Content-Type: application/json" \\
  -d '{"token": "test_token"}'
\`\`\`
EOF

echo -e "\n${GREEN}========================================${NC}"
echo -e "${GREEN}构建完成！${NC}"
echo -e "${GREEN}========================================${NC}"
echo -e "\n构建输出:"
echo -e "  APK: ${GREEN}${APK_OUTPUT_DIR}/${APK_NAME}${NC}"
echo -e "  JAR: ${GREEN}${JAR_OUTPUT_DIR}/${JAR_NAME}${NC}"
echo -e "  启动脚本: ${GREEN}${SCRIPTS_OUTPUT_DIR}${NC}"
echo -e "  部署说明: ${GREEN}${BUILD_DIR}/DEPLOY.md${NC}"
echo ""

