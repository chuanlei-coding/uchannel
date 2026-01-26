#!/bin/bash

# 启动 Android Studio 并确保 Node.js 在 PATH 中
# 这个脚本解决了 React Native 项目在 Android Studio 中找不到 node 的问题

# 设置 Node.js 路径
export PATH="/opt/homebrew/opt/node@18/bin:/usr/local/bin:$PATH"

# 验证 node 是否可用
if ! command -v node &> /dev/null; then
    echo "❌ 错误: 找不到 node 命令"
    echo "请确保已安装 Node.js"
    exit 1
fi

echo "✅ Node.js 已找到: $(which node)"
echo "   版本: $(node --version)"
echo ""

# 停止现有的 Gradle 守护进程
echo "正在停止现有的 Gradle 守护进程..."
cd "$(dirname "$0")/react-native-app/android" && ./gradlew --stop 2>/dev/null || true
echo ""

# 启动 Android Studio
echo "正在启动 Android Studio..."
open -a "Android Studio" "$(dirname "$0")/react-native-app/android"

echo ""
echo "✅ Android Studio 已启动"
echo ""
echo "提示: 如果 Gradle 同步仍然失败，请尝试:"
echo "  1. 在 Android Studio 中: File → Invalidate Caches / Restart"
echo "  2. 然后: File → Sync Project with Gradle Files"
