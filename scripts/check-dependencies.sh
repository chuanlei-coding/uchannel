#!/bin/bash

# 依赖检查脚本

echo "检查构建依赖..."

# 检查Java
if ! command -v java &> /dev/null; then
    echo "❌ Java未安装"
    echo "   请安装JDK 17或更高版本"
    echo "   macOS: brew install openjdk@17"
    echo "   Linux: sudo apt install openjdk-17-jdk"
    exit 1
else
    JAVA_VERSION=$(java -version 2>&1 | head -n 1)
    echo "✅ Java已安装: $JAVA_VERSION"
fi

# 检查Maven
if ! command -v mvn &> /dev/null; then
    echo "❌ Maven未安装"
    echo "   请安装Maven 3.6+"
    echo "   macOS: brew install maven"
    echo "   Linux: sudo apt install maven"
    exit 1
else
    MVN_VERSION=$(mvn -version | head -n 1)
    echo "✅ Maven已安装: $MVN_VERSION"
fi

# 检查Gradle (用于Android构建)
if ! command -v gradle &> /dev/null; then
    echo "⚠️  Gradle未安装（可选，如果使用gradlew则不需要）"
else
    GRADLE_VERSION=$(gradle -version | head -n 1)
    echo "✅ Gradle已安装: $GRADLE_VERSION"
fi

# 检查Android项目
if [ -d "android" ]; then
    if [ ! -f "android/gradlew" ]; then
        echo "⚠️  Android项目缺少gradlew"
        echo "   请运行: cd android && gradle wrapper"
    else
        echo "✅ Android gradlew存在"
    fi
else
    echo "⚠️  Android项目目录不存在"
fi

echo ""
echo "依赖检查完成！"

