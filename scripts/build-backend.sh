#!/bin/bash

# 仅构建后端JAR包脚本

set -e

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BUILD_DIR="${PROJECT_ROOT}/build/jar"

echo "构建后端JAR包..."

cd "${PROJECT_ROOT}/backend-java"

# 检查Maven是否存在
if ! command -v mvn &> /dev/null; then
    echo "错误: Maven未安装，请先安装Maven"
    exit 1
fi

# 清理并打包
mvn clean package -DskipTests

JAR_FILE=$(find target -name "*.jar" ! -name "*-sources.jar" ! -name "*-javadoc.jar" | head -n 1)

if [ -z "$JAR_FILE" ] || [ ! -f "$JAR_FILE" ]; then
    echo "错误: JAR文件未找到"
    exit 1
fi

# 创建输出目录
mkdir -p "${BUILD_DIR}"

# 复制JAR到输出目录
JAR_NAME="push-notification-service-$(date +%Y%m%d-%H%M%S).jar"
cp "$JAR_FILE" "${BUILD_DIR}/${JAR_NAME}"

# 创建最新版本的符号链接
ln -sf "${JAR_NAME}" "${BUILD_DIR}/push-notification-service-latest.jar"

echo "✓ JAR构建成功: ${BUILD_DIR}/${JAR_NAME}"

