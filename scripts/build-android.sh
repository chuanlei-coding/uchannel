#!/bin/bash

# 仅构建Android APK脚本

set -e

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BUILD_TYPE="${1:-release}"
BUILD_DIR="${PROJECT_ROOT}/build/apk"

echo "构建Android APK (${BUILD_TYPE})..."

cd "${PROJECT_ROOT}/android"

# 检查Gradle wrapper是否存在
if [ ! -f "./gradlew" ]; then
    echo "错误: Gradle wrapper不存在，请先运行 'gradle wrapper'"
    exit 1
fi

# 赋予执行权限
chmod +x ./gradlew

# 清理并构建APK
if [ "$BUILD_TYPE" = "release" ]; then
    ./gradlew clean assembleRelease
    APK_FILE=$(find app/build/outputs/apk/release -name "*.apk" | head -n 1)
else
    ./gradlew clean assembleDebug
    APK_FILE=$(find app/build/outputs/apk/debug -name "*.apk" | head -n 1)
fi

if [ -z "$APK_FILE" ] || [ ! -f "$APK_FILE" ]; then
    echo "错误: APK文件未找到"
    exit 1
fi

# 创建输出目录
mkdir -p "${BUILD_DIR}"

# 复制APK到输出目录
APK_NAME="uchannel-${BUILD_TYPE}-$(date +%Y%m%d-%H%M%S).apk"
cp "$APK_FILE" "${BUILD_DIR}/${APK_NAME}"

echo "✓ APK构建成功: ${BUILD_DIR}/${APK_NAME}"

