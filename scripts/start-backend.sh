#!/bin/bash

# 后端服务启动脚本
# 使用方法: ./scripts/start-backend.sh [port]

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
JAR_DIR="${PROJECT_ROOT}/build/jar"
JAR_FILE="${JAR_DIR}/push-notification-service-latest.jar"
SERVER_PORT="${1:-8080}"

# 如果build目录下没有JAR，尝试从target目录找
if [ ! -f "$JAR_FILE" ]; then
    TARGET_JAR=$(find "${PROJECT_ROOT}/backend-java/target" -name "*.jar" ! -name "*-sources.jar" ! -name "*-javadoc.jar" | head -n 1)
    if [ -f "$TARGET_JAR" ]; then
        JAR_FILE="$TARGET_JAR"
        echo "使用target目录中的JAR: $JAR_FILE"
    else
        echo "错误: JAR文件未找到"
        echo "请先运行构建脚本: ./scripts/build.sh"
        exit 1
    fi
fi

# 检查Java是否安装
if ! command -v java &> /dev/null; then
    echo "错误: Java未安装，请先安装JDK 17或更高版本"
    exit 1
fi

# 检查Java版本
JAVA_VERSION=$(java -version 2>&1 | head -n 1 | cut -d'"' -f2 | cut -d'.' -f1)
if [ "$JAVA_VERSION" -lt 17 ]; then
    echo "错误: 需要JDK 17或更高版本，当前版本: $JAVA_VERSION"
    exit 1
fi

# 启动参数
JAVA_OPTS="-Xms512m -Xmx1024m -Dspring.profiles.active=prod"

# 检查Firebase配置文件
FIREBASE_CONFIG="${PROJECT_ROOT}/backend-java/src/main/resources/serviceAccountKey.json"
if [ ! -f "$FIREBASE_CONFIG" ]; then
    echo "警告: Firebase配置文件未找到: $FIREBASE_CONFIG"
    echo "请确保已配置Firebase服务账号密钥"
fi

echo "=========================================="
echo "启动推送通知服务"
echo "=========================================="
echo "JAR文件: $JAR_FILE"
echo "端口: $SERVER_PORT"
echo "Java选项: $JAVA_OPTS"
echo "=========================================="
echo ""

java $JAVA_OPTS -jar "$JAR_FILE" --server.port=$SERVER_PORT

