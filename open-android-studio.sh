#!/bin/bash

# 打开Android Studio并加载Android项目

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ANDROID_DIR="${PROJECT_ROOT}/android"

echo "正在打开Android Studio..."
echo "项目路径: ${ANDROID_DIR}"

# 尝试打开Android Studio
if command -v studio &> /dev/null; then
    # 如果studio命令可用
    studio "${ANDROID_DIR}"
elif [ -d "/Applications/Android Studio.app" ]; then
    # macOS上打开Android Studio
    open -a "Android Studio" "${ANDROID_DIR}"
elif [ -d "$HOME/Applications/Android Studio.app" ]; then
    # 用户目录下的Android Studio
    open -a "$HOME/Applications/Android Studio.app" "${ANDROID_DIR}"
else
    echo "未找到Android Studio，请手动打开："
    echo "1. 打开Android Studio"
    echo "2. 选择 'Open an Existing Project'"
    echo "3. 选择目录: ${ANDROID_DIR}"
    echo ""
    echo "或者直接打开布局文件："
    echo "  ${ANDROID_DIR}/app/src/main/res/layout/activity_chat.xml"
    echo "  ${ANDROID_DIR}/app/src/main/res/layout/activity_main.xml"
fi
